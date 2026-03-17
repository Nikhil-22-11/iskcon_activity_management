const sendSuccess = (res, data = null, message = 'Operation successful', statusCode = 200) => {
  const response = {
    success: true,
    message,
    statusCode,
  };
  if (data !== null) {
    response.data = data;
  }
  return res.status(statusCode).json(response);
};

const sendError = (res, message = 'An error occurred', statusCode = 500, error = null) => {
  const response = {
    success: false,
    message,
    statusCode,
  };
  if (error && process.env.NODE_ENV === 'development') {
    response.error = error.toString();
  }
  return res.status(statusCode).json(response);
};

const sendPaginated = (res, data, total, page, limit, message = 'Data retrieved successfully') => {
  return res.status(200).json({
    success: true,
    message,
    statusCode: 200,
    data,
    pagination: {
      total,
      page: parseInt(page),
      limit: parseInt(limit),
      totalPages: Math.ceil(total / limit),
    },
  });
};

module.exports = { sendSuccess, sendError, sendPaginated };
