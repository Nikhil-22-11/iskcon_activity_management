const db = require('../config/db');
const { sendSuccess, sendError, sendPaginated } = require('../utils/responses');
const { validateEmail, validatePhone, sanitizeString } = require('../utils/validators');
const { generateQRCode, generateStudentQRData } = require('../utils/qrGenerator');

const getAllStudents = async (req, res, next) => {
  try {
    const { page, limit, offset } = req.pagination;
    const { search, activity_id } = req.query;

    let query = `
      SELECT s.id, s.student_id, s.name, s.email, s.phone, s.parent_name,
             s.parent_phone, s.class_name, s.section, s.address, s.is_active,
             s.created_at, s.photo_url
      FROM students s
      WHERE s.is_active = true
    `;
    const params = [];
    let paramCount = 0;

    if (search) {
      paramCount++;
      query += ` AND (s.name ILIKE $${paramCount} OR s.student_id ILIKE $${paramCount} OR s.email ILIKE $${paramCount})`;
      params.push(`%${search}%`);
    }

    if (activity_id) {
      paramCount++;
      query += ` AND s.id IN (SELECT student_id FROM enrollments WHERE activity_id = $${paramCount})`;
      params.push(activity_id);
    }

    const countResult = await db.query(
      `SELECT COUNT(*) FROM (${query}) AS total`,
      params
    );
    const total = parseInt(countResult.rows[0].count);

    paramCount++;
    query += ` ORDER BY s.name ASC LIMIT $${paramCount}`;
    params.push(limit);

    paramCount++;
    query += ` OFFSET $${paramCount}`;
    params.push(offset);

    const result = await db.query(query, params);

    return sendPaginated(res, result.rows, total, page, limit, 'Students retrieved successfully');
  } catch (err) {
    next(err);
  }
};

const getStudentById = async (req, res, next) => {
  try {
    const { id } = req.params;

    const result = await db.query(
      `SELECT s.*, 
              json_agg(DISTINCT jsonb_build_object('id', a.id, 'name', a.name, 'type', a.type)) 
                FILTER (WHERE a.id IS NOT NULL) AS activities
       FROM students s
       LEFT JOIN enrollments e ON s.id = e.student_id AND e.is_active = true
       LEFT JOIN activities a ON e.activity_id = a.id
       WHERE s.id = $1 AND s.is_active = true
       GROUP BY s.id`,
      [id]
    );

    if (result.rows.length === 0) {
      return sendError(res, 'Student not found.', 404);
    }

    return sendSuccess(res, result.rows[0], 'Student retrieved successfully');
  } catch (err) {
    next(err);
  }
};

const createStudent = async (req, res, next) => {
  try {
    const {
      name, email, phone, parent_name, parent_phone,
      class_name, section, address, date_of_birth, photo_url,
    } = req.body;

    if (!name) {
      return sendError(res, 'Student name is required.', 400);
    }

    if (email && !validateEmail(email)) {
      return sendError(res, 'Invalid email format.', 400);
    }

    if (phone && !validatePhone(phone)) {
      return sendError(res, 'Invalid phone number. Must be a 10-digit Indian mobile number.', 400);
    }

    if (parent_phone && !validatePhone(parent_phone)) {
      return sendError(res, 'Invalid parent phone number.', 400);
    }

    const prefix = 'STU';
    const year = new Date().getFullYear().toString().slice(-2);
    const countResult = await db.query('SELECT COUNT(*) FROM students');
    const count = parseInt(countResult.rows[0].count) + 1;
    const studentId = `${prefix}${year}${String(count).padStart(4, '0')}`;

    const qrData = generateStudentQRData(studentId, sanitizeString(name));
    const qrCode = await generateQRCode(qrData);

    const result = await db.query(
      `INSERT INTO students (student_id, name, email, phone, parent_name, parent_phone,
                             class_name, section, address, date_of_birth, photo_url, qr_code)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
       RETURNING id, student_id, name, email, phone, parent_name, parent_phone,
                 class_name, section, address, date_of_birth, photo_url, qr_code, created_at`,
      [
        studentId,
        sanitizeString(name),
        email ? email.toLowerCase() : null,
        phone || null,
        parent_name ? sanitizeString(parent_name) : null,
        parent_phone || null,
        class_name ? sanitizeString(class_name) : null,
        section ? sanitizeString(section) : null,
        address ? sanitizeString(address) : null,
        date_of_birth || null,
        photo_url || null,
        qrCode,
      ]
    );

    return sendSuccess(res, result.rows[0], 'Student created successfully', 201);
  } catch (err) {
    next(err);
  }
};

const updateStudent = async (req, res, next) => {
  try {
    const { id } = req.params;
    const {
      name, email, phone, parent_name, parent_phone,
      class_name, section, address, date_of_birth, photo_url,
    } = req.body;

    const existing = await db.query(
      'SELECT id FROM students WHERE id = $1 AND is_active = true',
      [id]
    );
    if (existing.rows.length === 0) {
      return sendError(res, 'Student not found.', 404);
    }

    if (email && !validateEmail(email)) {
      return sendError(res, 'Invalid email format.', 400);
    }

    if (phone && !validatePhone(phone)) {
      return sendError(res, 'Invalid phone number.', 400);
    }

    const result = await db.query(
      `UPDATE students
       SET name = COALESCE($1, name),
           email = COALESCE($2, email),
           phone = COALESCE($3, phone),
           parent_name = COALESCE($4, parent_name),
           parent_phone = COALESCE($5, parent_phone),
           class_name = COALESCE($6, class_name),
           section = COALESCE($7, section),
           address = COALESCE($8, address),
           date_of_birth = COALESCE($9, date_of_birth),
           photo_url = COALESCE($10, photo_url),
           updated_at = NOW()
       WHERE id = $11
       RETURNING id, student_id, name, email, phone, parent_name, parent_phone,
                 class_name, section, address, date_of_birth, photo_url, updated_at`,
      [
        name ? sanitizeString(name) : null,
        email ? email.toLowerCase() : null,
        phone || null,
        parent_name ? sanitizeString(parent_name) : null,
        parent_phone || null,
        class_name ? sanitizeString(class_name) : null,
        section ? sanitizeString(section) : null,
        address ? sanitizeString(address) : null,
        date_of_birth || null,
        photo_url || null,
        id,
      ]
    );

    return sendSuccess(res, result.rows[0], 'Student updated successfully');
  } catch (err) {
    next(err);
  }
};

const deleteStudent = async (req, res, next) => {
  try {
    const { id } = req.params;

    const existing = await db.query(
      'SELECT id FROM students WHERE id = $1 AND is_active = true',
      [id]
    );
    if (existing.rows.length === 0) {
      return sendError(res, 'Student not found.', 404);
    }

    await db.query(
      'UPDATE students SET is_active = false, updated_at = NOW() WHERE id = $1',
      [id]
    );

    return sendSuccess(res, null, 'Student deleted successfully');
  } catch (err) {
    next(err);
  }
};

const getStudentQR = async (req, res, next) => {
  try {
    const { studentId } = req.params;

    const result = await db.query(
      'SELECT id, student_id, name, qr_code FROM students WHERE student_id = $1 AND is_active = true',
      [studentId]
    );

    if (result.rows.length === 0) {
      return sendError(res, 'Student not found.', 404);
    }

    const student = result.rows[0];

    if (!student.qr_code) {
      const qrData = generateStudentQRData(student.student_id, student.name);
      const qrCode = await generateQRCode(qrData);

      await db.query('UPDATE students SET qr_code = $1 WHERE id = $2', [qrCode, student.id]);
      student.qr_code = qrCode;
    }

    return sendSuccess(
      res,
      { student_id: student.student_id, name: student.name, qr_code: student.qr_code },
      'QR code retrieved successfully'
    );
  } catch (err) {
    next(err);
  }
};

const enrollStudent = async (req, res, next) => {
  try {
    const { student_id, activity_id } = req.body;

    if (!student_id || !activity_id) {
      return sendError(res, 'student_id and activity_id are required.', 400);
    }

    const studentCheck = await db.query(
      'SELECT id FROM students WHERE id = $1 AND is_active = true',
      [student_id]
    );
    if (studentCheck.rows.length === 0) {
      return sendError(res, 'Student not found.', 404);
    }

    const activityCheck = await db.query(
      'SELECT id, max_students FROM activities WHERE id = $1 AND is_active = true',
      [activity_id]
    );
    if (activityCheck.rows.length === 0) {
      return sendError(res, 'Activity not found.', 404);
    }

    const existing = await db.query(
      'SELECT id FROM enrollments WHERE student_id = $1 AND activity_id = $2 AND is_active = true',
      [student_id, activity_id]
    );
    if (existing.rows.length > 0) {
      return sendError(res, 'Student is already enrolled in this activity.', 409);
    }

    if (activityCheck.rows[0].max_students) {
      const countResult = await db.query(
        'SELECT COUNT(*) FROM enrollments WHERE activity_id = $1 AND is_active = true',
        [activity_id]
      );
      if (parseInt(countResult.rows[0].count) >= activityCheck.rows[0].max_students) {
        return sendError(res, 'Activity has reached maximum student capacity.', 400);
      }
    }

    const result = await db.query(
      `INSERT INTO enrollments (student_id, activity_id, enrolled_by)
       VALUES ($1, $2, $3)
       RETURNING id, student_id, activity_id, enrolled_at`,
      [student_id, activity_id, req.user.id]
    );

    return sendSuccess(res, result.rows[0], 'Student enrolled successfully', 201);
  } catch (err) {
    next(err);
  }
};

module.exports = {
  getAllStudents,
  getStudentById,
  createStudent,
  updateStudent,
  deleteStudent,
  getStudentQR,
  enrollStudent,
};
