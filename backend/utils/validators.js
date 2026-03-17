const validateEmail = (email) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

// Validates 10-digit Indian mobile numbers starting with 6-9
const validatePhone = (phone) => {
  const phoneRegex = /^[6-9]\d{9}$/;
  return phoneRegex.test(phone);
};

const validateDate = (date) => {
  const d = new Date(date);
  return d instanceof Date && !isNaN(d);
};

const validatePassword = (password) => {
  return typeof password === 'string' && password.length >= 6;
};

const validateRequired = (fields, body) => {
  const missing = [];
  fields.forEach((field) => {
    if (body[field] === undefined || body[field] === null || body[field] === '') {
      missing.push(field);
    }
  });
  return missing;
};

const sanitizeString = (str) => {
  if (typeof str !== 'string') return str;
  // Encode HTML special characters to prevent HTML injection
  return str.trim()
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#x27;');
};

module.exports = {
  validateEmail,
  validatePhone,
  validateDate,
  validatePassword,
  validateRequired,
  sanitizeString,
};
