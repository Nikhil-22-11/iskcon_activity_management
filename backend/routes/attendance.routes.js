const express = require('express');
const router = express.Router();
const {
  checkIn,
  getStudentAttendanceHistory,
  getAttendanceByDate,
  getAttendanceReport,
  getAttendanceByActivity,
} = require('../controllers/attendanceController');
const { authenticate, authorize } = require('../middleware/auth.middleware');
const { validatePagination } = require('../middleware/validation.middleware');

router.use(authenticate);

router.post('/checkin', checkIn);
router.get('/history/:studentId', validatePagination, getStudentAttendanceHistory);
router.get('/date/:date', getAttendanceByDate);
router.get('/report', authorize('admin', 'principal'), getAttendanceReport);
router.get('/activity/:activityId', validatePagination, getAttendanceByActivity);

module.exports = router;
