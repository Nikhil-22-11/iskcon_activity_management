const db = require('../config/db');
const { sendSuccess, sendError, sendPaginated } = require('../utils/responses');
const { sanitizeString } = require('../utils/validators');

/**
 * POST /api/admissions
 * Submit a new student admission request.
 * Roles: teacher, principal, admin
 */
const createAdmission = async (req, res, next) => {
  try {
    const {
      student_name,
      dob,
      school,
      gender,
      mother_contact,
      father_contact,
      hear_about_us,
      payment_period,
      payment_mode,
      transaction_id,
    } = req.body;

    if (!student_name || !student_name.trim()) {
      return sendError(res, 'student_name is required', 400);
    }

    if (payment_mode === 'Online' && !transaction_id?.trim()) {
      return sendError(res, 'transaction_id is required for Online payment', 400);
    }

    const result = await db.query(
      `INSERT INTO admissions
         (student_name, dob, school, gender, mother_contact, father_contact,
          hear_about_us, payment_period, payment_mode, transaction_id, submitted_by)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
       RETURNING *`,
      [
        sanitizeString(student_name),
        dob || null,
        school ? sanitizeString(school) : null,
        gender || null,
        mother_contact || null,
        father_contact || null,
        hear_about_us || 'Friends',
        payment_period || 'Monthly',
        payment_mode || 'Cash',
        transaction_id ? transaction_id.trim() : null,
        req.user?.id || null,
      ]
    );

    return sendSuccess(res, result.rows[0], 'Admission submitted successfully', 201);
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/admissions
 * List all admissions with optional status filter and pagination.
 * Roles: principal, admin
 */
const getAdmissions = async (req, res, next) => {
  try {
    const { page, limit, offset } = req.pagination;
    const { status, search } = req.query;

    let query = `
      SELECT a.*,
             u.name AS submitted_by_name,
             r.name AS reviewed_by_name
      FROM admissions a
      LEFT JOIN users u ON u.id = a.submitted_by
      LEFT JOIN users r ON r.id = a.reviewed_by
      WHERE 1=1
    `;
    const params = [];
    let paramCount = 0;

    if (status) {
      paramCount++;
      query += ` AND a.status = $${paramCount}`;
      params.push(status);
    }

    if (search) {
      // Limit search length to prevent excessively long wildcard queries
      const searchTerm = String(search).slice(0, 100);
      paramCount++;
      query += ` AND (a.student_name ILIKE $${paramCount} OR a.school ILIKE $${paramCount})`;
      params.push(`%${searchTerm}%`);
    }

    const countResult = await db.query(
      `SELECT COUNT(*) FROM (${query}) AS total`,
      params
    );
    const total = parseInt(countResult.rows[0].count);

    paramCount++;
    query += ` ORDER BY a.created_at DESC LIMIT $${paramCount}`;
    params.push(limit);

    paramCount++;
    query += ` OFFSET $${paramCount}`;
    params.push(offset);

    const result = await db.query(query, params);

    return sendPaginated(res, result.rows, total, page, limit, 'Admissions retrieved successfully');
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/admissions/:id
 * Get a single admission by ID.
 * Roles: principal, admin, teacher (own submissions)
 */
const getAdmissionById = async (req, res, next) => {
  try {
    const { id } = req.params;
    const result = await db.query(
      `SELECT a.*,
              u.name AS submitted_by_name,
              r.name AS reviewed_by_name
       FROM admissions a
       LEFT JOIN users u ON u.id = a.submitted_by
       LEFT JOIN users r ON r.id = a.reviewed_by
       WHERE a.id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return sendError(res, 'Admission not found', 404);
    }

    return sendSuccess(res, result.rows[0], 'Admission retrieved successfully');
  } catch (err) {
    next(err);
  }
};

/**
 * PATCH /api/admissions/:id/status
 * Approve or reject an admission.
 * Roles: principal, admin
 */
const updateAdmissionStatus = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { status, notes } = req.body;

    if (!status || !['approved', 'rejected'].includes(status)) {
      return sendError(res, 'status must be "approved" or "rejected"', 400);
    }

    const result = await db.query(
      `UPDATE admissions
       SET status = $1, notes = COALESCE($2, notes),
           reviewed_by = $3, reviewed_at = NOW(), updated_at = NOW()
       WHERE id = $4
       RETURNING *`,
      [status, notes || null, req.user?.id || null, id]
    );

    if (result.rows.length === 0) {
      return sendError(res, 'Admission not found', 404);
    }

    return sendSuccess(res, result.rows[0], `Admission ${status} successfully`);
  } catch (err) {
    next(err);
  }
};

module.exports = {
  createAdmission,
  getAdmissions,
  getAdmissionById,
  updateAdmissionStatus,
};
