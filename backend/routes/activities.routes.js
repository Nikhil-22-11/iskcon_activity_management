const express = require('express');
const router = express.Router();
const {
  getAllActivities,
  getActivityById,
  createActivity,
  updateActivity,
  deleteActivity,
  getActivityStudents,
} = require('../controllers/activityController');
const { authenticate, authorize } = require('../middleware/auth.middleware');
const { validatePagination } = require('../middleware/validation.middleware');

router.use(authenticate);

router.get('/', validatePagination, getAllActivities);
router.get('/:id', getActivityById);
router.post('/', authorize('admin', 'principal', 'teacher'), createActivity);
router.put('/:id', authorize('admin', 'principal', 'teacher'), updateActivity);
router.delete('/:id', authorize('admin', 'principal'), deleteActivity);
router.get('/:id/students', validatePagination, getActivityStudents);

module.exports = router;
