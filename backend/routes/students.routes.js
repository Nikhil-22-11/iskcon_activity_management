const express = require('express');
const router = express.Router();
const {
  getAllStudents,
  getStudentById,
  createStudent,
  updateStudent,
  deleteStudent,
  getStudentQR,
  enrollStudent,
} = require('../controllers/studentController');
const { authenticate, authorize } = require('../middleware/auth.middleware');
const { validatePagination } = require('../middleware/validation.middleware');

router.use(authenticate);

router.get('/', validatePagination, getAllStudents);
router.get('/qr/:studentId', getStudentQR);
router.get('/:id', getStudentById);
router.post('/', authorize('admin', 'principal', 'teacher'), createStudent);
router.put('/:id', authorize('admin', 'principal', 'teacher'), updateStudent);
router.delete('/:id', authorize('admin', 'principal'), deleteStudent);
router.post('/enrollment', authorize('admin', 'principal', 'teacher'), enrollStudent);

module.exports = router;
