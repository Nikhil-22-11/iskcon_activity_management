const bcrypt = require('bcryptjs');
const db = require('../config/db');
const { generateToken, generateRefreshToken } = require('../utils/jwt');
const { sendSuccess, sendError } = require('../utils/responses');
const { validateEmail, validatePassword, sanitizeString } = require('../utils/validators');

const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return sendError(res, 'Email and password are required.', 400);
    }

    if (!validateEmail(email)) {
      return sendError(res, 'Invalid email format.', 400);
    }

    const result = await db.query(
      'SELECT * FROM users WHERE email = $1 AND is_active = true',
      [email.toLowerCase()]
    );

    if (result.rows.length === 0) {
      return sendError(res, 'Invalid email or password.', 401);
    }

    const user = result.rows[0];
    const isMatch = await bcrypt.compare(password, user.password_hash);

    if (!isMatch) {
      return sendError(res, 'Invalid email or password.', 401);
    }

    const tokenPayload = {
      id: user.id,
      email: user.email,
      role: user.role,
      name: user.name,
    };

    const token = generateToken(tokenPayload);
    const refreshToken = generateRefreshToken(tokenPayload);

    await db.query('UPDATE users SET last_login = NOW() WHERE id = $1', [user.id]);

    return sendSuccess(
      res,
      {
        token,
        refreshToken,
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
          must_change_password: user.must_change_password,
        },
      },
      'Login successful'
    );
  } catch (err) {
    next(err);
  }
};

const register = async (req, res, next) => {
  try {
    const { name, email, password, role } = req.body;

    if (!name || !email || !password || !role) {
      return sendError(res, 'Name, email, password and role are required.', 400);
    }

    if (!validateEmail(email)) {
      return sendError(res, 'Invalid email format.', 400);
    }

    if (!validatePassword(password)) {
      return sendError(res, 'Password must be at least 6 characters long.', 400);
    }

    const validRoles = ['admin', 'teacher', 'guard', 'principal'];
    if (!validRoles.includes(role)) {
      return sendError(res, `Role must be one of: ${validRoles.join(', ')}`, 400);
    }

    const existing = await db.query('SELECT id FROM users WHERE email = $1', [
      email.toLowerCase(),
    ]);
    if (existing.rows.length > 0) {
      return sendError(res, 'Email already registered.', 409);
    }

    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(password, saltRounds);

    const result = await db.query(
      `INSERT INTO users (name, email, password_hash, role, must_change_password)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING id, name, email, role, created_at`,
      [sanitizeString(name), email.toLowerCase(), passwordHash, role, true]
    );

    return sendSuccess(res, result.rows[0], 'User registered successfully', 201);
  } catch (err) {
    next(err);
  }
};

const changePassword = async (req, res, next) => {
  try {
    const { currentPassword, newPassword } = req.body;
    const userId = req.user.id;

    if (!currentPassword || !newPassword) {
      return sendError(res, 'Current password and new password are required.', 400);
    }

    if (!validatePassword(newPassword)) {
      return sendError(res, 'New password must be at least 6 characters long.', 400);
    }

    const result = await db.query('SELECT password_hash FROM users WHERE id = $1', [userId]);
    if (result.rows.length === 0) {
      return sendError(res, 'User not found.', 404);
    }

    const isMatch = await bcrypt.compare(currentPassword, result.rows[0].password_hash);
    if (!isMatch) {
      return sendError(res, 'Current password is incorrect.', 400);
    }

    const newHash = await bcrypt.hash(newPassword, 10);
    await db.query(
      'UPDATE users SET password_hash = $1, must_change_password = false, updated_at = NOW() WHERE id = $2',
      [newHash, userId]
    );

    return sendSuccess(res, null, 'Password changed successfully');
  } catch (err) {
    next(err);
  }
};

const logout = (req, res) => {
  return sendSuccess(res, null, 'Logged out successfully');
};

const getMe = async (req, res, next) => {
  try {
    const result = await db.query(
      'SELECT id, name, email, role, created_at, last_login FROM users WHERE id = $1',
      [req.user.id]
    );
    if (result.rows.length === 0) {
      return sendError(res, 'User not found.', 404);
    }
    return sendSuccess(res, result.rows[0], 'User data retrieved');
  } catch (err) {
    next(err);
  }
};

module.exports = { login, register, changePassword, logout, getMe };
