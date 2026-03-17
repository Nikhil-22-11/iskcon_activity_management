import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../navigation/routes.dart';

class PrincipalDashboard extends StatefulWidget {
  const PrincipalDashboard({super.key});

  @override
  State<PrincipalDashboard> createState() => _PrincipalDashboardState();
}

class _PrincipalDashboardState extends State<PrincipalDashboard> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = await ApiService().getCurrentUser();
      final result = await ApiService().getPrincipalDashboard();
      if (mounted) {
        setState(() {
          _userName = user?.name ?? 'Principal';
          _data = result['data'] as Map<String, dynamic>? ?? result;
          _isLoading = false;
        });
      }
    } catch (_) {
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
        title: const Text(AppStrings.principalDashboard),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
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
                _buildStatsGrid(),
                const SizedBox(height: 24),
                _buildMonthlyStats(),
                const SizedBox(height: 24),
                _buildQuickActions(context),
              ],
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
          colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('🏫', style: TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${_userName ?? 'Principal'}!',
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
    final items = [
      _StatItem(
        icon: Icons.class_outlined,
        label: 'Total Classes',
        value: '${_data?['total_classes'] ?? 0}',
        color: const Color(0xFF4A148C),
      ),
      _StatItem(
        icon: Icons.people_outline,
        label: 'Total Students',
        value: '${_data?['total_students'] ?? 0}',
        color: AppColors.krishnaBlue,
      ),
      _StatItem(
        icon: Icons.school_outlined,
        label: 'Total Teachers',
        value: '${_data?['total_teachers'] ?? 0}',
        color: AppColors.success,
      ),
      _StatItem(
        icon: Icons.trending_up,
        label: 'Avg Attendance %',
        value: '${_data?['average_attendance_pct'] ?? 0}%',
        color: AppColors.krishnaOrange,
      ),
      _StatItem(
        icon: Icons.event_note_outlined,
        label: 'Activities This Month',
        value: '${_data?['total_activities_this_month'] ?? 0}',
        color: const Color(0xFF00838F),
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
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: item.color,
              ),
            ),
            Text(
              item.label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyStats() {
    final stats =
        (_data?['monthly_stats'] as List<dynamic>?) ?? [];
    if (stats.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Attendance Statistics',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 16,
                    color: AppColors.deepBlue,
                  ),
            ),
            const SizedBox(height: 16),
            ...stats.map((item) {
              final m = item as Map<String, dynamic>;
              final month = m['month'] as String? ?? '';
              final pct = (m['attendance'] as num?)?.toDouble() ?? 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 36,
                      child: Text(
                        month,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct / 100,
                          minHeight: 14,
                          backgroundColor: AppColors.lightBlue,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF4A148C)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${pct.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF4A148C),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }),
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
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}
