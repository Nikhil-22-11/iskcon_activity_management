const db = require('../config/db');
const { sendSuccess, sendError, sendPaginated } = require('../utils/responses');
const { sanitizeString, validateDate } = require('../utils/validators');

const getAllActivities = async (req, res, next) => {
  try {
    const { page, limit, offset } = req.pagination;
    const { search, type } = req.query;

    let query = `
      SELECT a.id, a.name, a.description, a.type, a.location, a.schedule,
             a.start_date, a.end_date, a.max_students, a.is_active, a.created_at,
             u.name AS created_by_name,
             COUNT(e.id) AS enrolled_count
      FROM activities a
      LEFT JOIN users u ON a.created_by = u.id
      LEFT JOIN enrollments e ON a.id = e.activity_id AND e.is_active = true
      WHERE a.is_active = true
    `;
    const params = [];
    let paramCount = 0;

    if (search) {
      paramCount++;
      query += ` AND (a.name ILIKE $${paramCount} OR a.description ILIKE $${paramCount})`;
      params.push(`%${search}%`);
    }

    if (type) {
      paramCount++;
      query += ` AND a.type = $${paramCount}`;
      params.push(type);
    }

    query += ' GROUP BY a.id, u.name';

    const countResult = await db.query(
      `SELECT COUNT(*) FROM (${query}) AS total`,
      params
    );
    const total = parseInt(countResult.rows[0].count);

    paramCount++;
    query += ` ORDER BY a.name ASC LIMIT $${paramCount}`;
    params.push(limit);

    paramCount++;
    query += ` OFFSET $${paramCount}`;
    params.push(offset);

    const result = await db.query(query, params);

    return sendPaginated(res, result.rows, total, page, limit, 'Activities retrieved successfully');
  } catch (err) {
    next(err);
  }
};

const getActivityById = async (req, res, next) => {
  try {
    const { id } = req.params;

    const result = await db.query(
      `SELECT a.*, u.name AS created_by_name,
              COUNT(e.id) AS enrolled_count
       FROM activities a
       LEFT JOIN users u ON a.created_by = u.id
       LEFT JOIN enrollments e ON a.id = e.activity_id AND e.is_active = true
       WHERE a.id = $1 AND a.is_active = true
       GROUP BY a.id, u.name`,
      [id]
    );

    if (result.rows.length === 0) {
      return sendError(res, 'Activity not found.', 404);
    }

    return sendSuccess(res, result.rows[0], 'Activity retrieved successfully');
  } catch (err) {
    next(err);
  }
};

const createActivity = async (req, res, next) => {
  try {
    const {
      name, description, type, location, schedule,
      start_date, end_date, max_students,
    } = req.body;

    if (!name) {
      return sendError(res, 'Activity name is required.', 400);
    }

    if (start_date && !validateDate(start_date)) {
      return sendError(res, 'Invalid start_date format.', 400);
    }

    if (end_date && !validateDate(end_date)) {
      return sendError(res, 'Invalid end_date format.', 400);
    }

    const result = await db.query(
      `INSERT INTO activities (name, description, type, location, schedule,
                               start_date, end_date, max_students, created_by)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
       RETURNING *`,
      [
        sanitizeString(name),
        description ? sanitizeString(description) : null,
        type ? sanitizeString(type) : null,
        location ? sanitizeString(location) : null,
        schedule ? sanitizeString(schedule) : null,
        start_date || null,
        end_date || null,
        max_students || null,
        req.user.id,
      ]
    );

    return sendSuccess(res, result.rows[0], 'Activity created successfully', 201);
  } catch (err) {
    next(err);
  }
};

const updateActivity = async (req, res, next) => {
  try {
    const { id } = req.params;
    const {
      name, description, type, location, schedule,
      start_date, end_date, max_students,
    } = req.body;

    const existing = await db.query(
      'SELECT id FROM activities WHERE id = $1 AND is_active = true',
      [id]
    );
    if (existing.rows.length === 0) {
      return sendError(res, 'Activity not found.', 404);
    }

    const result = await db.query(
      `UPDATE activities
       SET name = COALESCE($1, name),
           description = COALESCE($2, description),
           type = COALESCE($3, type),
           location = COALESCE($4, location),
           schedule = COALESCE($5, schedule),
           start_date = COALESCE($6, start_date),
           end_date = COALESCE($7, end_date),
           max_students = COALESCE($8, max_students),
           updated_at = NOW()
       WHERE id = $9
       RETURNING *`,
      [
        name ? sanitizeString(name) : null,
        description ? sanitizeString(description) : null,
        type ? sanitizeString(type) : null,
        location ? sanitizeString(location) : null,
        schedule ? sanitizeString(schedule) : null,
        start_date || null,
        end_date || null,
        max_students || null,
        id,
      ]
    );

    return sendSuccess(res, result.rows[0], 'Activity updated successfully');
  } catch (err) {
    next(err);
  }
};

const deleteActivity = async (req, res, next) => {
  try {
    const { id } = req.params;

    const existing = await db.query(
      'SELECT id FROM activities WHERE id = $1 AND is_active = true',
      [id]
    );
    if (existing.rows.length === 0) {
      return sendError(res, 'Activity not found.', 404);
    }

    await db.query(
      'UPDATE activities SET is_active = false, updated_at = NOW() WHERE id = $1',
      [id]
    );

    return sendSuccess(res, null, 'Activity deleted successfully');
  } catch (err) {
    next(err);
  }
};

const getActivityStudents = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { page, limit, offset } = req.pagination;

    const activityCheck = await db.query(
      'SELECT id, name FROM activities WHERE id = $1 AND is_active = true',
      [id]
    );
    if (activityCheck.rows.length === 0) {
      return sendError(res, 'Activity not found.', 404);
    }

    const countResult = await db.query(
      'SELECT COUNT(*) FROM enrollments WHERE activity_id = $1 AND is_active = true',
      [id]
    );
    const total = parseInt(countResult.rows[0].count);

    const result = await db.query(
      `SELECT s.id, s.student_id, s.name, s.email, s.phone, s.class_name,
              s.section, e.enrolled_at
       FROM enrollments e
       JOIN students s ON e.student_id = s.id
       WHERE e.activity_id = $1 AND e.is_active = true AND s.is_active = true
       ORDER BY s.name ASC
       LIMIT $2 OFFSET $3`,
      [id, limit, offset]
    );

    return sendPaginated(
      res,
      result.rows,
      total,
      page,
      limit,
      `Students in activity "${activityCheck.rows[0].name}" retrieved successfully`
    );
  } catch (err) {
    next(err);
  }
};

module.exports = {
  getAllActivities,
  getActivityById,
  createActivity,
  updateActivity,
  deleteActivity,
  getActivityStudents,
};
