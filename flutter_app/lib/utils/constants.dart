import 'package:flutter/material.dart';

class AppColors {
  static const Color krishnaBlue = Color(0xFF4A7BA7);
  static const Color krishnaOrange = Color(0xFFFF9500);
  static const Color deepBlue = Color(0xFF1A3A5C);
  static const Color lightBlue = Color(0xFFE8F1F8);
  static const Color white = Colors.white;
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF616161);
  static const Color cardBackground = Color(0xFFF5F5F5);
}

class AppStrings {
  static const String appName = 'ISKCON Activity Management';
  static const String login = 'Login';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String loginButton = 'Sign In';
  static const String dashboard = 'Dashboard';
  static const String students = 'Students';
  static const String activities = 'Activities';
  static const String attendance = 'Attendance';
  static const String visitors = 'Visitors';
  static const String logout = 'Logout';
  static const String adminDashboard = 'Admin Dashboard';
  static const String teacherDashboard = 'Teacher Dashboard';
  static const String hareKrishna = 'Hare Krishna 🙏';
}

class AppUrls {
  static const String baseUrl = 'http://localhost:5000/api';
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String students = '/students';
  static const String activities = '/activities';
  static const String attendance = '/attendance';
  static const String visitors = '/visitors';
  static const String dashboardStats = '/dashboard/stats';
  static const String dashboardTeacher = '/dashboard/teacher';
  static const String dashboardPrincipal = '/dashboard/principal';
}
