const db = require('../config/db');
const { sendSuccess, sendError } = require('../utils/responses');

const getTeacherDashboard = async (req, res, next) => {
  try {
    const teacherId = req.user.id;
    const today = new Date().toISOString().split('T')[0];

    const [activitiesResult, todayAttendanceResult, studentsResult] = await Promise.all([
      db.query(
        `SELECT COUNT(*) FROM activities WHERE created_by = $1 AND is_active = true`,
        [teacherId]
      ),
      db.query(
        `SELECT COUNT(*) FROM attendance att
         JOIN activities a ON att.activity_id = a.id
         WHERE a.created_by = $1 AND DATE(att.check_in_time) = $2`,
        [teacherId, today]
      ),
      db.query(
        `SELECT COUNT(DISTINCT e.student_id) FROM enrollments e
         JOIN activities a ON e.activity_id = a.id
         WHERE a.created_by = $1 AND e.is_active = true`,
        [teacherId]
      ),
    ]);

    const recentAttendance = await db.query(
      `SELECT s.name AS student_name, s.student_id AS student_code,
              a.name AS activity_name, att.check_in_time, att.status
       FROM attendance att
       JOIN students s ON att.student_id = s.id
       JOIN activities a ON att.activity_id = a.id
       WHERE a.created_by = $1
       ORDER BY att.check_in_time DESC
       LIMIT 10`,
      [teacherId]
    );

    return sendSuccess(
      res,
      {
        stats: {
          my_activities: parseInt(activitiesResult.rows[0].count),
          today_attendance: parseInt(todayAttendanceResult.rows[0].count),
          my_students: parseInt(studentsResult.rows[0].count),
        },
        recent_attendance: recentAttendance.rows,
      },
      'Teacher dashboard data retrieved'
    );
  } catch (err) {
    next(err);
  }
};

const getPrincipalDashboard = async (req, res, next) => {
  try {
    const today = new Date().toISOString().split('T')[0];
    const thisMonth = new Date().toISOString().slice(0, 7);

    const [
      studentsResult,
      activitiesResult,
      todayAttendanceResult,
      monthlyAttendanceResult,
      enquiriesResult,
      visitorsResult,
    ] = await Promise.all([
      db.query('SELECT COUNT(*) FROM students WHERE is_active = true'),
      db.query('SELECT COUNT(*) FROM activities WHERE is_active = true'),
      db.query(
        `SELECT COUNT(*) FROM attendance WHERE DATE(check_in_time) = $1 AND status = 'present'`,
        [today]
      ),
      db.query(
        `SELECT COUNT(*) FROM attendance
         WHERE TO_CHAR(check_in_time, 'YYYY-MM') = $1 AND status = 'present'`,
        [thisMonth]
      ),
      db.query("SELECT COUNT(*) FROM enquiries WHERE status = 'new'"),
      db.query("SELECT COUNT(*) FROM visitors WHERE DATE(check_in_time) = $1 AND status = 'checked_in'", [today]),
    ]);

    const activityBreakdown = await db.query(
      `SELECT a.name, a.type,
              COUNT(DISTINCT e.student_id) AS enrolled_students,
              COUNT(att.id) FILTER (WHERE DATE(att.check_in_time) = $1) AS today_attendance
       FROM activities a
       LEFT JOIN enrollments e ON a.id = e.activity_id AND e.is_active = true
       LEFT JOIN attendance att ON a.id = att.activity_id
       WHERE a.is_active = true
       GROUP BY a.id, a.name, a.type
       ORDER BY enrolled_students DESC
       LIMIT 10`,
      [today]
    );

    const teacherStats = await db.query(
      `SELECT u.name AS teacher_name,
              COUNT(DISTINCT a.id) AS activities_count,
              COUNT(DISTINCT e.student_id) AS students_count
       FROM users u
       LEFT JOIN activities a ON u.id = a.created_by AND a.is_active = true
       LEFT JOIN enrollments e ON a.id = e.activity_id AND e.is_active = true
       WHERE u.role = 'teacher'
       GROUP BY u.id, u.name
       ORDER BY activities_count DESC`
    );

    return sendSuccess(
      res,
      {
        stats: {
          total_students: parseInt(studentsResult.rows[0].count),
          total_activities: parseInt(activitiesResult.rows[0].count),
          today_attendance: parseInt(todayAttendanceResult.rows[0].count),
          monthly_attendance: parseInt(monthlyAttendanceResult.rows[0].count),
          pending_enquiries: parseInt(enquiriesResult.rows[0].count),
          current_visitors: parseInt(visitorsResult.rows[0].count),
        },
        activity_breakdown: activityBreakdown.rows,
        teacher_stats: teacherStats.rows,
      },
      'Principal dashboard data retrieved'
    );
  } catch (err) {
    next(err);
  }
};

const getOverallStats = async (req, res, next) => {
  try {
    const today = new Date().toISOString().split('T')[0];

    const [students, activities, todayAtt, enquiries, visitors] = await Promise.all([
      db.query('SELECT COUNT(*) FROM students WHERE is_active = true'),
      db.query('SELECT COUNT(*) FROM activities WHERE is_active = true'),
      db.query(
        "SELECT COUNT(*) FROM attendance WHERE DATE(check_in_time) = $1 AND status = 'present'",
        [today]
      ),
      db.query('SELECT COUNT(*) FROM enquiries'),
      db.query('SELECT COUNT(*) FROM visitors WHERE DATE(check_in_time) = $1', [today]),
    ]);

    return sendSuccess(
      res,
      {
        total_students: parseInt(students.rows[0].count),
        total_activities: parseInt(activities.rows[0].count),
        today_attendance: parseInt(todayAtt.rows[0].count),
        total_enquiries: parseInt(enquiries.rows[0].count),
        today_visitors: parseInt(visitors.rows[0].count),
        date: today,
      },
      'Overall statistics retrieved'
    );
  } catch (err) {
    next(err);
  }
};

module.exports = { getTeacherDashboard, getPrincipalDashboard, getOverallStats };
