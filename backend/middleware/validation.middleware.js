const { sendError } = require('../utils/responses');
const { validateRequired } = require('../utils/validators');

const validateBody = (requiredFields) => {
  return (req, res, next) => {
    const missing = validateRequired(requiredFields, req.body);
    if (missing.length > 0) {
      return sendError(
        res,
        `Missing required fields: ${missing.join(', ')}`,
        400
      );
    }
    next();
  };
};

const validatePagination = (req, res, next) => {
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 10;

  if (page < 1) {
    return sendError(res, 'Page must be a positive integer.', 400);
  }
  if (limit < 1 || limit > 100) {
    return sendError(res, 'Limit must be between 1 and 100.', 400);
  }

  req.pagination = { page, limit, offset: (page - 1) * limit };
  next();
};

module.exports = { validateBody, validatePagination };
