const express = require('express');
const router = express.Router();
const {
  createAdmission,
  getAdmissions,
  getAdmissionById,
  updateAdmissionStatus,
} = require('../controllers/admissionController');
const { authenticate, authorize } = require('../middleware/auth.middleware');
const { validatePagination } = require('../middleware/validation.middleware');

router.use(authenticate);

// Submit a new admission (teacher, principal, admin)
router.post('/', authorize('teacher', 'principal', 'admin'), createAdmission);

// List all admissions with pagination (principal, admin)
router.get('/', authorize('principal', 'admin'), validatePagination, getAdmissions);

// Get single admission by ID (principal, admin)
router.get('/:id', authorize('principal', 'admin'), getAdmissionById);

// Approve / reject an admission (principal, admin)
router.patch('/:id/status', authorize('principal', 'admin'), updateAdmissionStatus);

module.exports = router;
