const { sendError } = require('../utils/responses');

const errorHandler = (err, req, res, next) => {
  console.error('Error:', err);

  if (err.name === 'ValidationError') {
    return sendError(res, err.message, 400, err);
  }

  if (err.name === 'UnauthorizedError') {
    return sendError(res, 'Invalid token.', 401, err);
  }

  if (err.code === '23505') {
    return sendError(res, 'Duplicate entry. Record already exists.', 409, err);
  }

  if (err.code === '23503') {
    return sendError(res, 'Referenced record does not exist.', 400, err);
  }

  if (err.code === '23502') {
    return sendError(res, 'Required field is missing.', 400, err);
  }

  const statusCode = err.statusCode || 500;
  const message = err.message || 'Internal Server Error';

  return sendError(res, message, statusCode, err);
};

const notFound = (req, res) => {
  return sendError(res, `Route ${req.method} ${req.originalUrl} not found.`, 404);
};

module.exports = { errorHandler, notFound };
