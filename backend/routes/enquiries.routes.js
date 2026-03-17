const express = require('express');
const router = express.Router();
const {
  getAllEnquiries,
  createEnquiry,
  updateEnquiry,
  getEnquiryById,
} = require('../controllers/enquiryController');
const { authenticate, authorize } = require('../middleware/auth.middleware');
const { validatePagination } = require('../middleware/validation.middleware');

router.get('/', authenticate, authorize('admin', 'principal', 'teacher'), validatePagination, getAllEnquiries);
router.post('/', createEnquiry);
router.get('/:id', authenticate, authorize('admin', 'principal', 'teacher'), getEnquiryById);
router.put('/:id', authenticate, authorize('admin', 'principal', 'teacher'), updateEnquiry);

module.exports = router;
