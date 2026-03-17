require('dotenv').config();
const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');

const authRoutes = require('./routes/auth.routes');
const studentRoutes = require('./routes/students.routes');
const activityRoutes = require('./routes/activities.routes');
const attendanceRoutes = require('./routes/attendance.routes');
const enquiryRoutes = require('./routes/enquiries.routes');
const visitorRoutes = require('./routes/visitors.routes');
const dashboardRoutes = require('./routes/dashboard.routes');
const { errorHandler, notFound } = require('./middleware/errorHandler.middleware');

const app = express();
const PORT = process.env.PORT || 5000;

// Rate limiters
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 200,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many requests. Please try again later.', statusCode: 429 },
});

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many authentication attempts. Please try again later.', statusCode: 429 },
});

// Middleware
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(globalLimiter);

// Health check
app.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'ISKCON Activity Management API is running',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
  });
});

// API Routes
app.use('/api/auth', authLimiter, authRoutes);
app.use('/api/students', studentRoutes);
app.use('/api/activities', activityRoutes);
app.use('/api/attendance', attendanceRoutes);
app.use('/api/enquiries', enquiryRoutes);
app.use('/api/visitors', visitorRoutes);
app.use('/api/dashboard', dashboardRoutes);

// 404 handler
app.use(notFound);

// Global error handler
app.use(errorHandler);

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT} in ${process.env.NODE_ENV || 'development'} mode`);
  console.log(`Health check: http://localhost:${PORT}/health`);
});

module.exports = app;
