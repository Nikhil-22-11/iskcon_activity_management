import 'package:flutter/material.dart';

class AppColors {
  static const Color krishnaBlue = Color(0xFF1565C0);
  static const Color deepBlue = Color(0xFF0D47A1);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color krishnaOrange = Color(0xFFFF6F00);
  static const Color white = Colors.white;
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFB71C1C);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
}

class AppStrings {
  static const String appName = 'ISKCON Activity Management';
  static const String hareKrishna = 'Hare Krishna 🙏';
  static const String login = 'Sign In';
  static const String loginButton = 'Sign In';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String adminDashboard = 'Admin Dashboard';
  static const String teacherDashboard = 'Teacher Dashboard';
  static const String students = 'Students';
  static const String activities = 'Activities';
  static const String attendance = 'Attendance';
  static const String visitors = 'Visitors';
}

class AppUrls {
  static const String baseUrl = 'http://127.0.0.1:5000/api';
  static const String login = '/auth/login';
  static const String students = '/students';
  static const String activities = '/activities';
  static const String attendance = '/attendance';
  static const String visitors = '/visitors';
  static const String dashboardStats = '/dashboard/stats';
  static const String dashboardTeacher = '/dashboard/teacher';
  static const String dashboardPrincipal = '/dashboard/principal';
}