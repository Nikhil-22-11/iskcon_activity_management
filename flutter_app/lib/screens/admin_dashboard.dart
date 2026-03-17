import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../navigation/routes.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, dynamic>? _stats;
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
      final stats = await ApiService().getDashboardStats();
      if (mounted) {
        setState(() {
          _userName = user?.name ?? user?.email ?? 'Admin';
          _stats = stats['data'] as Map<String, dynamic>? ?? stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
        title: const Text(AppStrings.adminDashboard),
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
              _buildStatsGrid(),
              const SizedBox(height: 24),
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
          colors: [AppColors.deepBlue, AppColors.krishnaBlue],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('🕉', style: TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${_userName ?? 'Admin'}!',
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

  Widget _buildStatsGrid() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.krishnaBlue));
    }
    final items = [
      _StatItem(
        icon: Icons.people_outline,
        label: 'Total Students',
        value: '${_stats?['total_students'] ?? _stats?['totalStudents'] ?? 0}',
        color: AppColors.krishnaBlue,
      ),
      _StatItem(
        icon: Icons.event_outlined,
        label: 'Activities',
        value:
            '${_stats?['total_activities'] ?? _stats?['totalActivities'] ?? 0}',
        color: AppColors.krishnaOrange,
      ),
      _StatItem(
        icon: Icons.check_circle_outline,
        label: "Today's Attendance",
        value:
            '${_stats?['today_attendance'] ?? _stats?['todayAttendance'] ?? 0}',
        color: AppColors.success,
      ),
      _StatItem(
        icon: Icons.person_add_outlined,
        label: "Today's Visitors",
        value:
            '${_stats?['today_visitors'] ?? _stats?['todayVisitors'] ?? 0}',
        color: const Color(0xFF7B1FA2),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: items.map(_buildStatCard).toList(),
    );
  }

  Widget _buildStatCard(_StatItem item) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: item.color, size: 32),
            const SizedBox(height: 8),
            Text(
              item.value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: item.color,
              ),
            ),
            Text(
              item.label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
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
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildActionCard(
              context,
              icon: Icons.people,
              label: AppStrings.students,
              route: AppRoutes.studentList,
              color: AppColors.krishnaBlue,
            ),
            _buildActionCard(
              context,
              icon: Icons.event,
              label: AppStrings.activities,
              route: AppRoutes.activityList,
              color: AppColors.krishnaOrange,
            ),
            _buildActionCard(
              context,
              icon: Icons.assignment_turned_in,
              label: AppStrings.attendance,
              route: AppRoutes.attendance,
              color: AppColors.success,
            ),
            _buildActionCard(
              context,
              icon: Icons.person_add,
              label: AppStrings.visitors,
              route: AppRoutes.visitorCheckIn,
              color: const Color(0xFF7B1FA2),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context,
      {required IconData icon,
      required String label,
      required String route,
      required Color color}) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).pushNamed(route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatItem(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});
}
