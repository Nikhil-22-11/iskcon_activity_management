const express = require('express');
const router = express.Router();
const {
  visitorCheckIn,
  visitorCheckOut,
  getAllVisitors,
  getVisitorsByDate,
} = require('../controllers/visitorController');
const { authenticate, authorize } = require('../middleware/auth.middleware');
const { validatePagination } = require('../middleware/validation.middleware');

router.use(authenticate);

router.post('/checkin', visitorCheckIn);
router.put('/:id/checkout', visitorCheckOut);
router.get('/', validatePagination, getAllVisitors);
router.get('/date/:date', getVisitorsByDate);

module.exports = router;
