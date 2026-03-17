const express = require('express');
const router = express.Router();
const { login, register, changePassword, logout, getMe } = require('../controllers/authController');
const { authenticate, authorize } = require('../middleware/auth.middleware');
const { validateBody } = require('../middleware/validation.middleware');

router.post('/login', validateBody(['email', 'password']), login);
router.post('/register', authenticate, authorize('admin', 'principal'), validateBody(['name', 'email', 'password', 'role']), register);
router.post('/change-password', authenticate, validateBody(['currentPassword', 'newPassword']), changePassword);
router.post('/logout', authenticate, logout);
router.get('/me', authenticate, getMe);

module.exports = router;
