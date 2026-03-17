import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/admin_dashboard.dart';
import '../screens/teacher_dashboard.dart';
import '../screens/student_list_screen.dart';
import '../screens/activity_list_screen.dart';
import '../screens/attendance_screen.dart';
import '../screens/visitor_checkin_screen.dart';

class AppRoutes {
  static const String login = '/';
  static const String adminDashboard = '/admin-dashboard';
  static const String teacherDashboard = '/teacher-dashboard';
  static const String studentList = '/students';
  static const String activityList = '/activities';
  static const String attendance = '/attendance';
  static const String visitorCheckIn = '/visitor-checkin';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboard());
      case teacherDashboard:
        return MaterialPageRoute(builder: (_) => const TeacherDashboard());
      case studentList:
        return MaterialPageRoute(builder: (_) => const StudentListScreen());
      case activityList:
        return MaterialPageRoute(builder: (_) => const ActivityListScreen());
      case attendance:
        return MaterialPageRoute(builder: (_) => const AttendanceScreen());
      case visitorCheckIn:
        return MaterialPageRoute(
            builder: (_) => const VisitorCheckInScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
