import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../navigation/routes.dart';

class GuardDashboard extends StatefulWidget {
  const GuardDashboard({super.key});

  @override
  State<GuardDashboard> createState() => _GuardDashboardState();
}

class _GuardDashboardState extends State<GuardDashboard> {
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
      final result = await ApiService().getGuardDashboard();
      if (mounted) {
        setState(() {
          _userName = user?.name ?? 'Guard';
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
        title: const Text(AppStrings.guardDashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
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
                _buildStatsRow(),
                const SizedBox(height: 24),
                _buildQuickActions(context),
                const SizedBox(height: 24),
                _buildRecentLogs(),
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
          colors: [Color(0xFF37474F), Color(0xFF546E7A)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('🛡️', style: TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${_userName ?? 'Guard'}!',
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

  Widget _buildStatsRow() {
    final totalVisitors = _data?['total_visitors_today'] ?? 0;
    final checkIns = _data?['check_ins'] ?? 0;
    final checkOuts = _data?['check_outs'] ?? 0;
    final pending = _data?['pending_checkouts'] ?? 0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard(
          icon: Icons.people_outline,
          label: 'Total Visitors Today',
          value: '$totalVisitors',
          color: AppColors.krishnaBlue,
        ),
        _buildStatCard(
          icon: Icons.login,
          label: 'Check-ins',
          value: '$checkIns',
          color: AppColors.success,
        ),
        _buildStatCard(
          icon: Icons.logout,
          label: 'Check-outs',
          value: '$checkOuts',
          color: const Color(0xFF7B1FA2),
        ),
        _buildStatCard(
          icon: Icons.pending_actions,
          label: 'Pending Check-outs',
          value: '$pending',
          color: AppColors.krishnaOrange,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
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
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.person_add,
                label: 'Visitor Check-in',
                route: AppRoutes.visitorCheckIn,
                color: AppColors.krishnaBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.assignment_turned_in,
                label: 'Attendance',
                route: AppRoutes.attendance,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required IconData icon,
      required String label,
      required String route,
      required Color color}) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).pushNamed(route),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
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

  Widget _buildRecentLogs() {
    final logs = (_data?['recent_logs'] as List<dynamic>?) ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Visitor Logs',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 18,
                color: AppColors.deepBlue,
              ),
        ),
        const SizedBox(height: 12),
        if (logs.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No visitor logs for today',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          )
        else
          ...logs.map((log) => _buildLogCard(log as Map<String, dynamic>)),
      ],
    );
  }

  Widget _buildLogCard(Map<String, dynamic> log) {
    final isCheckedOut = log['check_out'] != null;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCheckedOut
              ? AppColors.success.withAlpha(30)
              : AppColors.krishnaOrange.withAlpha(30),
          child: Icon(
            isCheckedOut ? Icons.check_circle : Icons.person,
            color: isCheckedOut ? AppColors.success : AppColors.krishnaOrange,
          ),
        ),
        title: Text(
          log['name'] as String? ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (log['reason'] != null)
              Text(log['reason'] as String,
                  style: const TextStyle(fontSize: 12)),
            if (log['check_in'] != null)
              Text(
                'In: ${_fmt(log['check_in'] as String)}',
                style: const TextStyle(fontSize: 11),
              ),
            if (log['check_out'] != null)
              Text(
                'Out: ${_fmt(log['check_out'] as String)}',
                style: const TextStyle(fontSize: 11),
              ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isCheckedOut
                ? AppColors.success.withAlpha(20)
                : AppColors.krishnaOrange.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isCheckedOut ? 'Checked Out' : 'Inside',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color:
                  isCheckedOut ? AppColors.success : AppColors.krishnaOrange,
            ),
          ),
        ),
        isThreeLine: true,
      ),
    );
  }

  String _fmt(String iso) {
    try {
      return DateFormat('hh:mm a').format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return iso;
    }
  }
}
