const db = require('../config/db');
const { sendSuccess, sendError, sendPaginated } = require('../utils/responses');
const { validatePhone, sanitizeString, validateDate } = require('../utils/validators');

const visitorCheckIn = async (req, res, next) => {
  try {
    const { name, phone, purpose, host_name, id_type, id_number, photo_url } = req.body;

    if (!name || !purpose) {
      return sendError(res, 'Name and purpose are required.', 400);
    }

    if (phone && !validatePhone(phone)) {
      return sendError(res, 'Invalid phone number.', 400);
    }

    const result = await db.query(
      `INSERT INTO visitors (name, phone, purpose, host_name, id_type, id_number,
                             photo_url, check_in_time, checked_in_by)
       VALUES ($1, $2, $3, $4, $5, $6, $7, NOW(), $8)
       RETURNING id, name, phone, purpose, host_name, check_in_time, status`,
      [
        sanitizeString(name),
        phone || null,
        sanitizeString(purpose),
        host_name ? sanitizeString(host_name) : null,
        id_type ? sanitizeString(id_type) : null,
        id_number ? sanitizeString(id_number) : null,
        photo_url || null,
        req.user.id,
      ]
    );

    return sendSuccess(res, result.rows[0], 'Visitor checked in successfully', 201);
  } catch (err) {
    next(err);
  }
};

const visitorCheckOut = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { notes } = req.body;

    const existing = await db.query(
      "SELECT id, check_out_time FROM visitors WHERE id = $1 AND status = 'checked_in'",
      [id]
    );

    if (existing.rows.length === 0) {
      return sendError(res, 'Visitor not found or already checked out.', 404);
    }

    const result = await db.query(
      `UPDATE visitors
       SET check_out_time = NOW(),
           status = 'checked_out',
           notes = COALESCE($1, notes),
           updated_at = NOW()
       WHERE id = $2
       RETURNING id, name, check_in_time, check_out_time, status`,
      [notes ? sanitizeString(notes) : null, id]
    );

    return sendSuccess(res, result.rows[0], 'Visitor checked out successfully');
  } catch (err) {
    next(err);
  }
};

const getAllVisitors = async (req, res, next) => {
  try {
    const { page, limit, offset } = req.pagination;
    const { status, search } = req.query;

    let query = `
      SELECT v.id, v.name, v.phone, v.purpose, v.host_name, v.status,
             v.check_in_time, v.check_out_time, v.id_type, v.notes,
             u.name AS checked_in_by_name
      FROM visitors v
      LEFT JOIN users u ON v.checked_in_by = u.id
      WHERE 1=1
    `;
    const params = [];
    let paramCount = 0;

    if (status) {
      paramCount++;
      query += ` AND v.status = $${paramCount}`;
      params.push(status);
    }

    if (search) {
      paramCount++;
      query += ` AND (v.name ILIKE $${paramCount} OR v.phone ILIKE $${paramCount} OR v.purpose ILIKE $${paramCount})`;
      params.push(`%${search}%`);
    }

    const countResult = await db.query(
      `SELECT COUNT(*) FROM (${query}) AS total`,
      params
    );
    const total = parseInt(countResult.rows[0].count);

    paramCount++;
    query += ` ORDER BY v.check_in_time DESC LIMIT $${paramCount}`;
    params.push(limit);

    paramCount++;
    query += ` OFFSET $${paramCount}`;
    params.push(offset);

    const result = await db.query(query, params);

    return sendPaginated(res, result.rows, total, page, limit, 'Visitors retrieved successfully');
  } catch (err) {
    next(err);
  }
};

const getVisitorsByDate = async (req, res, next) => {
  try {
    const { date } = req.params;

    if (!validateDate(date)) {
      return sendError(res, 'Invalid date format. Use YYYY-MM-DD.', 400);
    }

    const result = await db.query(
      `SELECT v.id, v.name, v.phone, v.purpose, v.host_name, v.status,
              v.check_in_time, v.check_out_time, u.name AS checked_in_by_name
       FROM visitors v
       LEFT JOIN users u ON v.checked_in_by = u.id
       WHERE DATE(v.check_in_time) = $1
       ORDER BY v.check_in_time ASC`,
      [date]
    );

    return sendSuccess(
      res,
      { date, visitors: result.rows, total: result.rows.length },
      'Visitors retrieved successfully'
    );
  } catch (err) {
    next(err);
  }
};

module.exports = { visitorCheckIn, visitorCheckOut, getAllVisitors, getVisitorsByDate };
