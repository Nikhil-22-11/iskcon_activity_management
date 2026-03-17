const db = require('../config/db');
const { sendSuccess, sendError, sendPaginated } = require('../utils/responses');
const { validateEmail, validatePhone, sanitizeString } = require('../utils/validators');

const getAllEnquiries = async (req, res, next) => {
  try {
    const { page, limit, offset } = req.pagination;
    const { status, search } = req.query;

    let query = `
      SELECT e.id, e.name, e.email, e.phone, e.message, e.status,
             e.source, e.created_at, e.updated_at,
             u.name AS assigned_to_name
      FROM enquiries e
      LEFT JOIN users u ON e.assigned_to = u.id
      WHERE 1=1
    `;
    const params = [];
    let paramCount = 0;

    if (status) {
      paramCount++;
      query += ` AND e.status = $${paramCount}`;
      params.push(status);
    }

    if (search) {
      paramCount++;
      query += ` AND (e.name ILIKE $${paramCount} OR e.email ILIKE $${paramCount} OR e.phone ILIKE $${paramCount})`;
      params.push(`%${search}%`);
    }

    const countResult = await db.query(
      `SELECT COUNT(*) FROM (${query}) AS total`,
      params
    );
    const total = parseInt(countResult.rows[0].count);

    paramCount++;
    query += ` ORDER BY e.created_at DESC LIMIT $${paramCount}`;
    params.push(limit);

    paramCount++;
    query += ` OFFSET $${paramCount}`;
    params.push(offset);

    const result = await db.query(query, params);

    return sendPaginated(res, result.rows, total, page, limit, 'Enquiries retrieved successfully');
  } catch (err) {
    next(err);
  }
};

const createEnquiry = async (req, res, next) => {
  try {
    const { name, email, phone, message, source } = req.body;

    if (!name || !message) {
      return sendError(res, 'Name and message are required.', 400);
    }

    if (email && !validateEmail(email)) {
      return sendError(res, 'Invalid email format.', 400);
    }

    if (phone && !validatePhone(phone)) {
      return sendError(res, 'Invalid phone number.', 400);
    }

    const result = await db.query(
      `INSERT INTO enquiries (name, email, phone, message, source)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING id, name, email, phone, message, source, status, created_at`,
      [
        sanitizeString(name),
        email ? email.toLowerCase() : null,
        phone || null,
        sanitizeString(message),
        source ? sanitizeString(source) : 'website',
      ]
    );

    return sendSuccess(res, result.rows[0], 'Enquiry submitted successfully', 201);
  } catch (err) {
    next(err);
  }
};

const updateEnquiry = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { status, notes, assigned_to } = req.body;

    const existing = await db.query('SELECT id FROM enquiries WHERE id = $1', [id]);
    if (existing.rows.length === 0) {
      return sendError(res, 'Enquiry not found.', 404);
    }

    const validStatuses = ['new', 'in_progress', 'resolved', 'closed'];
    if (status && !validStatuses.includes(status)) {
      return sendError(res, `Status must be one of: ${validStatuses.join(', ')}`, 400);
    }

    const result = await db.query(
      `UPDATE enquiries
       SET status = COALESCE($1, status),
           notes = COALESCE($2, notes),
           assigned_to = COALESCE($3, assigned_to),
           updated_at = NOW()
       WHERE id = $4
       RETURNING *`,
      [status || null, notes ? sanitizeString(notes) : null, assigned_to || null, id]
    );

    return sendSuccess(res, result.rows[0], 'Enquiry updated successfully');
  } catch (err) {
    next(err);
  }
};

const getEnquiryById = async (req, res, next) => {
  try {
    const { id } = req.params;

    const result = await db.query(
      `SELECT e.*, u.name AS assigned_to_name
       FROM enquiries e
       LEFT JOIN users u ON e.assigned_to = u.id
       WHERE e.id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return sendError(res, 'Enquiry not found.', 404);
    }

    return sendSuccess(res, result.rows[0], 'Enquiry retrieved successfully');
  } catch (err) {
    next(err);
  }
};

module.exports = { getAllEnquiries, createEnquiry, updateEnquiry, getEnquiryById };
