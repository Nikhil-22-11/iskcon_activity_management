import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../navigation/routes.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await ApiService().getCurrentUser();
      final data = await ApiService().getTeacherDashboard();
      if (mounted) {
        setState(() {
          _userName = user?.name ?? user?.email ?? 'Teacher';
          _dashboardData =
              data['data'] as Map<String, dynamic>? ?? data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await ApiService().logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      appBar: AppBar(
        title: const Text(AppStrings.teacherDashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: AppStrings.logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeBanner(),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.krishnaBlue))
              else ...[
                _buildTodaySummary(),
                const SizedBox(height: 20),
              ],
              _buildQuickActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.krishnaBlue, Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('🙏', style: TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${_userName ?? 'Teacher'}!',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  AppStrings.hareKrishna,
                  style: TextStyle(
                    color: AppColors.krishnaOrange.withAlpha(230),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySummary() {
    final todayCount =
        _dashboardData?['today_attendance'] ?? _dashboardData?['todayCount'] ?? 0;
    final myStudents =
        _dashboardData?['my_students'] ?? _dashboardData?['myStudents'] ?? 0;
    final myActivities =
        _dashboardData?['my_activities'] ?? _dashboardData?['myActivities'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryTile(
              'Today\'s\nAttendance',
              '$todayCount',
              Icons.check_circle_outline,
              AppColors.krishnaOrange),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryTile('My Students', '$myStudents',
              Icons.people_outline, AppColors.krishnaBlue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryTile('My Activities', '$myActivities',
              Icons.event_outlined, AppColors.success),
        ),
      ],
    );
  }

  Widget _buildSummaryTile(
      String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 18,
                color: AppColors.deepBlue,
              ),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          context,
          icon: Icons.assignment_turned_in,
          label: 'Mark Attendance',
          subtitle: 'Record student attendance',
          route: AppRoutes.attendance,
          color: AppColors.krishnaOrange,
        ),
        _buildActionTile(
          context,
          icon: Icons.people,
          label: AppStrings.students,
          subtitle: 'View and manage students',
          route: AppRoutes.studentList,
          color: AppColors.krishnaBlue,
        ),
        _buildActionTile(
          context,
          icon: Icons.event,
          label: AppStrings.activities,
          subtitle: 'View class activities',
          route: AppRoutes.activityList,
          color: AppColors.success,
        ),
        _buildActionTile(
          context,
          icon: Icons.person_add,
          label: AppStrings.visitors,
          subtitle: 'Visitor check-in & check-out',
          route: AppRoutes.visitorCheckIn,
          color: const Color(0xFF7B1FA2),
        ),
      ],
    );
  }

  Widget _buildActionTile(BuildContext context,
      {required IconData icon,
      required String label,
      required String subtitle,
      required String route,
      required Color color}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right, color: AppColors.krishnaBlue),
        onTap: () => Navigator.of(context).pushNamed(route),
      ),
    );
  }
}
