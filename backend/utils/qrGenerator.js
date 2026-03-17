const QRCode = require('qrcode');

const generateQRCode = async (data) => {
  try {
    const qrDataURL = await QRCode.toDataURL(JSON.stringify(data), {
      errorCorrectionLevel: 'H',
      type: 'image/png',
      quality: 0.92,
      margin: 1,
      color: {
        dark: '#000000',
        light: '#FFFFFF',
      },
    });
    return qrDataURL;
  } catch (err) {
    throw new Error('Failed to generate QR code: ' + err.message);
  }
};

const generateStudentQRData = (studentId, studentName) => {
  return {
    studentId,
    studentName,
    type: 'student_attendance',
    timestamp: new Date().toISOString(),
  };
};

module.exports = { generateQRCode, generateStudentQRData };
