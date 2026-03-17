const express = require('express');
const router = express.Router();
const {
  getTeacherDashboard,
  getPrincipalDashboard,
  getOverallStats,
} = require('../controllers/dashboardController');
const { authenticate, authorize } = require('../middleware/auth.middleware');

router.use(authenticate);

router.get('/teacher', authorize('admin', 'principal', 'teacher'), getTeacherDashboard);
router.get('/principal', authorize('admin', 'principal'), getPrincipalDashboard);
router.get('/stats', getOverallStats);

module.exports = router;
