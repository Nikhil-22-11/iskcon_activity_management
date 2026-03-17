const { verifyToken } = require('../utils/jwt');
const { sendError } = require('../utils/responses');

const authenticate = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return sendError(res, 'Access denied. No token provided.', 401);
    }

    const token = authHeader.substring(7);
    const decoded = verifyToken(token);
    req.user = decoded;
    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return sendError(res, 'Token has expired. Please login again.', 401);
    }
    return sendError(res, 'Invalid token.', 401);
  }
};

const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return sendError(res, 'Not authenticated.', 401);
    }
    if (!roles.includes(req.user.role)) {
      return sendError(res, 'Access denied. Insufficient permissions.', 403);
    }
    next();
  };
};

module.exports = { authenticate, authorize };
