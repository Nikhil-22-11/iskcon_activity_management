const db = require('../config/db');
const { sendSuccess, sendError, sendPaginated } = require('../utils/responses');
const { validateDate } = require('../utils/validators');

const checkIn = async (req, res, next) => {
  try {
    const { qr_data, activity_id, notes } = req.body;

    if (!qr_data) {
      return sendError(res, 'QR data is required.', 400);
    }

    let parsedQR;
    try {
      parsedQR = typeof qr_data === 'string' ? JSON.parse(qr_data) : qr_data;
    } catch {
      return sendError(res, 'Invalid QR code data.', 400);
    }

    if (!parsedQR.studentId) {
      return sendError(res, 'Invalid QR code format.', 400);
    }

    const studentResult = await db.query(
      'SELECT id, name, student_id FROM students WHERE student_id = $1 AND is_active = true',
      [parsedQR.studentId]
    );

    if (studentResult.rows.length === 0) {
      return sendError(res, 'Student not found or inactive.', 404);
    }

    const student = studentResult.rows[0];
    const today = new Date().toISOString().split('T')[0];

    const existing = await db.query(
      `SELECT id FROM attendance
       WHERE student_id = $1 AND DATE(check_in_time) = $2 AND activity_id IS NOT DISTINCT FROM $3`,
      [student.id, today, activity_id || null]
    );

    if (existing.rows.length > 0) {
      return sendError(res, 'Attendance already marked for today.', 409);
    }

    if (activity_id) {
      const enrollCheck = await db.query(
        'SELECT id FROM enrollments WHERE student_id = $1 AND activity_id = $2 AND is_active = true',
        [student.id, activity_id]
      );
      if (enrollCheck.rows.length === 0) {
        return sendError(res, 'Student is not enrolled in this activity.', 400);
      }
    }

    const result = await db.query(
      `INSERT INTO attendance (student_id, activity_id, check_in_time, marked_by, notes, status)
       VALUES ($1, $2, NOW(), $3, $4, 'present')
       RETURNING id, student_id, activity_id, check_in_time, status, notes`,
      [student.id, activity_id || null, req.user.id, notes || null]
    );

    return sendSuccess(
      res,
      {
        ...result.rows[0],
        student_name: student.name,
        student_code: student.student_id,
      },
      'Attendance marked successfully',
      201
    );
  } catch (err) {
    next(err);
  }
};

const getStudentAttendanceHistory = async (req, res, next) => {
  try {
    const { studentId } = req.params;
    const { page, limit, offset } = req.pagination;

    const studentResult = await db.query(
      'SELECT id, name FROM students WHERE id = $1 AND is_active = true',
      [studentId]
    );
    if (studentResult.rows.length === 0) {
      return sendError(res, 'Student not found.', 404);
    }

    const countResult = await db.query(
      'SELECT COUNT(*) FROM attendance WHERE student_id = $1',
      [studentId]
    );
    const total = parseInt(countResult.rows[0].count);

    const result = await db.query(
      `SELECT att.id, att.check_in_time, att.check_out_time, att.status, att.notes,
              a.name AS activity_name, u.name AS marked_by_name
       FROM attendance att
       LEFT JOIN activities a ON att.activity_id = a.id
       LEFT JOIN users u ON att.marked_by = u.id
       WHERE att.student_id = $1
       ORDER BY att.check_in_time DESC
       LIMIT $2 OFFSET $3`,
      [studentId, limit, offset]
    );

    return sendPaginated(
      res,
      result.rows,
      total,
      page,
      limit,
      `Attendance history for ${studentResult.rows[0].name}`
    );
  } catch (err) {
    next(err);
  }
};

const getAttendanceByDate = async (req, res, next) => {
  try {
    const { date } = req.params;

    if (!validateDate(date)) {
      return sendError(res, 'Invalid date format. Use YYYY-MM-DD.', 400);
    }

    const result = await db.query(
      `SELECT att.id, att.check_in_time, att.check_out_time, att.status, att.notes,
              s.name AS student_name, s.student_id AS student_code, s.class_name,
              a.name AS activity_name
       FROM attendance att
       JOIN students s ON att.student_id = s.id
       LEFT JOIN activities a ON att.activity_id = a.id
       WHERE DATE(att.check_in_time) = $1
       ORDER BY att.check_in_time ASC`,
      [date]
    );

    return sendSuccess(
      res,
      { date, records: result.rows, total: result.rows.length },
      'Attendance retrieved successfully'
    );
  } catch (err) {
    next(err);
  }
};

const getAttendanceReport = async (req, res, next) => {
  try {
    const { start_date, end_date, activity_id } = req.query;

    if (!start_date || !end_date) {
      return sendError(res, 'start_date and end_date are required.', 400);
    }

    if (!validateDate(start_date) || !validateDate(end_date)) {
      return sendError(res, 'Invalid date format. Use YYYY-MM-DD.', 400);
    }

    let query = `
      SELECT s.student_id AS student_code, s.name AS student_name,
             s.class_name, s.section,
             COUNT(att.id) AS total_present,
             COUNT(DISTINCT DATE(att.check_in_time)) AS days_present
      FROM students s
      LEFT JOIN attendance att ON s.id = att.student_id
        AND DATE(att.check_in_time) BETWEEN $1 AND $2
        AND att.status = 'present'
    `;
    const params = [start_date, end_date];

    if (activity_id) {
      params.push(activity_id);
      query += ` AND att.activity_id = $${params.length}`;
    }

    query += ` WHERE s.is_active = true GROUP BY s.id, s.student_id, s.name, s.class_name, s.section
               ORDER BY s.name ASC`;

    const result = await db.query(query, params);

    const summaryResult = await db.query(
      `SELECT COUNT(DISTINCT DATE(check_in_time)) AS total_days,
              COUNT(*) AS total_records
       FROM attendance
       WHERE DATE(check_in_time) BETWEEN $1 AND $2`,
      [start_date, end_date]
    );

    return sendSuccess(
      res,
      {
        period: { start_date, end_date },
        summary: summaryResult.rows[0],
        students: result.rows,
      },
      'Attendance report generated successfully'
    );
  } catch (err) {
    next(err);
  }
};

const getAttendanceByActivity = async (req, res, next) => {
  try {
    const { activityId } = req.params;
    const { page, limit, offset } = req.pagination;
    const { date } = req.query;

    const activityCheck = await db.query(
      'SELECT id, name FROM activities WHERE id = $1 AND is_active = true',
      [activityId]
    );
    if (activityCheck.rows.length === 0) {
      return sendError(res, 'Activity not found.', 404);
    }

    let countQuery = 'SELECT COUNT(*) FROM attendance WHERE activity_id = $1';
    let dataQuery = `
      SELECT att.id, att.check_in_time, att.check_out_time, att.status, att.notes,
             s.name AS student_name, s.student_id AS student_code, s.class_name
      FROM attendance att
      JOIN students s ON att.student_id = s.id
      WHERE att.activity_id = $1
    `;
    const params = [activityId];

    if (date) {
      if (!validateDate(date)) {
        return sendError(res, 'Invalid date format.', 400);
      }
      params.push(date);
      countQuery += ` AND DATE(check_in_time) = $${params.length}`;
      dataQuery += ` AND DATE(att.check_in_time) = $${params.length}`;
    }

    const countResult = await db.query(countQuery, params);
    const total = parseInt(countResult.rows[0].count);

    params.push(limit, offset);
    dataQuery += ` ORDER BY att.check_in_time DESC LIMIT $${params.length - 1} OFFSET $${params.length}`;

    const result = await db.query(dataQuery, params);

    return sendPaginated(
      res,
      result.rows,
      total,
      page,
      limit,
      `Attendance for activity "${activityCheck.rows[0].name}"`
    );
  } catch (err) {
    next(err);
  }
};

module.exports = {
  checkIn,
  getStudentAttendanceHistory,
  getAttendanceByDate,
  getAttendanceReport,
  getAttendanceByActivity,
};
