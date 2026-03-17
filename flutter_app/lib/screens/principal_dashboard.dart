import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../navigation/routes.dart';
import 'admission_form.dart';

class PrincipalDashboard extends StatefulWidget {
  const PrincipalDashboard({super.key});

  @override
  State<PrincipalDashboard> createState() => _PrincipalDashboardState();
}

class _PrincipalDashboardState extends State<PrincipalDashboard>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _userName;
  late TabController _tabController;
  String _studentSearch = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard, size: 18), text: 'Overview'),
            Tab(icon: Icon(Icons.people, size: 18), text: 'Students'),
            Tab(icon: Icon(Icons.bar_chart, size: 18), text: 'Attendance'),
            Tab(icon: Icon(Icons.sports, size: 18), text: 'Activities'),
            Tab(icon: Icon(Icons.payments, size: 18), text: 'Finance'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.krishnaBlue))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildStudentsTab(),
                _buildAttendanceTab(),
                _buildActivitiesTab(),
                _buildFinanceTab(),
              ],
            ),
    );
  }

  // ─────────────────────────── TAB 1: Overview ───────────────────────────

  Widget _buildOverviewTab() {
    final totalStudents = _data?['total_students'] ?? 0;
    final totalActivities = _data?['total_activities'] ?? 0;
    final totalTeachers = _data?['total_teachers'] ?? 0;
    final todayAttendance = _data?['today_attendance'] ?? 0;
    final avgPct = (_data?['average_attendance_pct'] as num?) ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeBanner(),
          const SizedBox(height: 20),
          _sectionTitle('Key Statistics'),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _statCard(Icons.people_outline, 'Total Students', '$totalStudents', AppColors.krishnaBlue),
              _statCard(Icons.sports_outlined, 'Activities', '$totalActivities', AppColors.krishnaOrange),
              _statCard(Icons.person_outline, 'Teachers', '$totalTeachers', const Color(0xFF7B1FA2)),
              _statCard(Icons.today, "Today's Attendance", '$todayAttendance', AppColors.success),
            ],
          ),
          const SizedBox(height: 20),
          _sectionTitle('Attendance Rate'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Average attendance this month',
                          style: TextStyle(fontSize: 13)),
                      Text(
                        '$avgPct%',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (avgPct as num) / 100,
                      minHeight: 14,
                      backgroundColor: AppColors.lightBlue,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _sectionTitle('Quick Actions'),
          const SizedBox(height: 12),
          _quickActionTile(
            icon: Icons.person_add_alt_1,
            label: 'New Admission',
            subtitle: 'Register a new student',
            color: const Color(0xFF7B1FA2),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AdmissionForm()),
            ),
          ),
          _quickActionTile(
            icon: Icons.people,
            label: 'Students',
            subtitle: 'View all students',
            color: AppColors.krishnaBlue,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.studentList),
          ),
          _quickActionTile(
            icon: Icons.assignment_turned_in,
            label: 'Attendance',
            subtitle: 'View attendance records',
            color: AppColors.krishnaOrange,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.attendance),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── TAB 2: Students ───────────────────────────

  Widget _buildStudentsTab() {
    final students = (_data?['students'] as List<dynamic>?) ?? [];
    final filtered = _studentSearch.isEmpty
        ? students
        : students.where((s) {
            final m = s as Map<String, dynamic>;
            final name = m['name'] as String? ?? '';
            final roll = m['roll'] as String? ?? '';
            final q = _studentSearch.toLowerCase();
            return name.toLowerCase().contains(q) || roll.toLowerCase().contains(q);
          }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _studentSearch = v),
                  decoration: InputDecoration(
                    hintText: 'Search students...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.krishnaBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${filtered.length} students',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final s = filtered[i] as Map<String, dynamic>;
              final name = s['name'] as String? ?? '?';
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.krishnaBlue.withAlpha(25),
                    child: Text(
                      name[0].toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.krishnaBlue,
                      ),
                    ),
                  ),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    'Roll: ${s['roll'] ?? ''}  •  Activities: ${s['enrolled_activities'] ?? 0}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─────────────────────────── TAB 3: Attendance ───────────────────────────

  Widget _buildAttendanceTab() {
    final monthlyStats = (_data?['monthly_stats'] as List<dynamic>?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Monthly Attendance Trends'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: monthlyStats.map((item) {
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
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: pct / 100,
                              minHeight: 20,
                              backgroundColor: AppColors.lightBlue,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                pct >= 90
                                    ? AppColors.success
                                    : pct >= 75
                                        ? AppColors.krishnaOrange
                                        : AppColors.error,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 44,
                          child: Text(
                            '${pct.toStringAsFixed(0)}%',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: pct >= 90
                                  ? AppColors.success
                                  : pct >= 75
                                      ? AppColors.krishnaOrange
                                      : AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _sectionTitle('Enrollment by Activity'),
          const SizedBox(height: 12),
          ..._buildActivityEnrollmentCards(),
          const SizedBox(height: 20),
          _sectionTitle('Generate Reports'),
          const SizedBox(height: 12),
          _reportButton(Icons.picture_as_pdf, 'Monthly Attendance Report', AppColors.error),
          _reportButton(Icons.table_chart, 'Export Attendance CSV', AppColors.success),
        ],
      ),
    );
  }

  List<Widget> _buildActivityEnrollmentCards() {
    final activityStats = (_data?['activity_stats'] as List<dynamic>?) ?? [];
    return activityStats.map((item) {
      final a = item as Map<String, dynamic>;
      final enrolled = (a['enrolled'] as num?)?.toInt() ?? 0;
      final capacity = (a['capacity'] as num?)?.toInt() ?? 1;
      final pct = capacity > 0 ? enrolled / capacity : 0.0;
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      a['name'] as String? ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                  Text(
                    '$enrolled / $capacity',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 8,
                  backgroundColor: AppColors.lightBlue,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.krishnaOrange),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  // ─────────────────────────── TAB 4: Activities ───────────────────────────

  Widget _buildActivitiesTab() {
    final activityStats = (_data?['activity_stats'] as List<dynamic>?) ?? [];
    const colors = [
      AppColors.krishnaBlue,
      AppColors.krishnaOrange,
      AppColors.success,
      Color(0xFF7B1FA2),
      Color(0xFFE65100),
      Color(0xFF00695C),
      Color(0xFF37474F),
      Color(0xFF1565C0),
      Color(0xFFC62828),
      Color(0xFF558B2F),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: activityStats.length,
      itemBuilder: (_, i) {
        final a = activityStats[i] as Map<String, dynamic>;
        final enrolled = (a['enrolled'] as num?)?.toInt() ?? 0;
        final capacity = (a['capacity'] as num?)?.toInt() ?? 0;
        final color = colors[i % colors.length];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.sports, color: color, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        a['name'] as String? ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: color.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$enrolled enrolled',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        a['schedule'] as String? ?? '',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        a['teacher'] as String? ?? '',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                    Text(
                      'Capacity: $capacity',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: capacity > 0 ? enrolled / capacity : 0,
                    minHeight: 6,
                    backgroundColor: AppColors.lightBlue,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────── TAB 5: Finance ───────────────────────────

  Widget _buildFinanceTab() {
    final financial = (_data?['financial'] as Map<String, dynamic>?) ?? {};
    final admissionsThisMonth = (financial['admissions_this_month'] as num?)?.toInt() ?? 0;
    final revenueTotal = (financial['revenue_total'] as num?)?.toInt() ?? 0;
    final paymentCashCount = (financial['payment_cash_count'] as num?)?.toInt() ?? 0;
    final paymentOnlineCount = (financial['payment_online_count'] as num?)?.toInt() ?? 0;
    final paymentCashAmount = (financial['payment_cash_amount'] as num?)?.toInt() ?? 0;
    final paymentOnlineAmount = (financial['payment_online_amount'] as num?)?.toInt() ?? 0;
    final pendingList = (financial['pending_payments'] as List<dynamic>?) ?? [];
    final revenueByPeriod = (financial['revenue_by_period'] as List<dynamic>?) ?? [];
    final totalCount = paymentCashCount + paymentOnlineCount;
    final maxRevenue = revenueByPeriod.isEmpty
        ? 1
        : revenueByPeriod
            .map((e) => (e as Map<String, dynamic>)['revenue'] as int? ?? 0)
            .reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Summary Cards ──────────────────────────────────────────────
          _sectionTitle('Financial Overview'),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _statCard(Icons.people_alt_outlined, 'Admissions\nThis Month',
                  '$admissionsThisMonth', AppColors.krishnaBlue),
              _statCard(Icons.currency_rupee, 'Total Revenue',
                  '\u20b9${_formatAmount(revenueTotal)}', AppColors.success),
              _statCard(Icons.money, 'Cash Payments',
                  '$paymentCashCount students', AppColors.krishnaOrange),
              _statCard(Icons.phone_android, 'Online Payments',
                  '$paymentOnlineCount students', const Color(0xFF7B1FA2)),
            ],
          ),
          // ── Revenue by Period ───────────────────────────────────────────
          const SizedBox(height: 20),
          _sectionTitle('Revenue by Payment Period'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: revenueByPeriod.map((item) {
                  final r = item as Map<String, dynamic>;
                  final period = r['period'] as String? ?? '';
                  final count = (r['count'] as num?)?.toInt() ?? 0;
                  final revenue = (r['revenue'] as num?)?.toInt() ?? 0;
                  final periodColors = {
                    'Monthly': AppColors.krishnaBlue,
                    'Quarterly': AppColors.krishnaOrange,
                    'Yearly': AppColors.success,
                  };
                  final color = periodColors[period] ?? AppColors.krishnaBlue;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                      color: color, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 6),
                                Text(period,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            Text(
                              '$count students  •  \u20b9${_formatAmount(revenue)}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: maxRevenue > 0 ? revenue / maxRevenue : 0,
                            minHeight: 10,
                            backgroundColor: AppColors.lightBlue,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // ── Payment Mode Distribution ───────────────────────────────────
          const SizedBox(height: 20),
          _sectionTitle('Payment Mode Distribution'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _paymentModeBar(
                      'Cash (\u20b9${_formatAmount(paymentCashAmount)})',
                      paymentCashCount,
                      totalCount,
                      AppColors.krishnaOrange),
                  const SizedBox(height: 10),
                  _paymentModeBar(
                      'Online (\u20b9${_formatAmount(paymentOnlineAmount)})',
                      paymentOnlineCount,
                      totalCount,
                      const Color(0xFF7B1FA2)),
                ],
              ),
            ),
          ),
          // ── Pending Payments ────────────────────────────────────────────
          if (pendingList.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle('Pending Payments'),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${pendingList.length} pending',
                    style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...pendingList.map((p) {
              final item = p as Map<String, dynamic>;
              final name = item['name'] as String? ?? '';
              final amount = (item['amount'] as num?)?.toInt() ?? 0;
              final period = item['period'] as String? ?? '';
              final days = (item['overdue_days'] as num?)?.toInt() ?? 0;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: AppColors.error.withAlpha(8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: AppColors.error.withAlpha(20),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.warning_amber,
                        color: AppColors.error, size: 18),
                  ),
                  title: Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: Text('$period  •  Overdue $days days',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                  trailing: Text(
                    '\u20b9${_formatAmount(amount)}',
                    style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ),
              );
            }),
          ],
          // ── Export Finance Report ───────────────────────────────────────
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Export Finance Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _showExportDialog('Finance Report'),
            ),
          ),
          // ── Reports ─────────────────────────────────────────────────────
          const SizedBox(height: 20),
          _sectionTitle('Reports'),
          const SizedBox(height: 12),
          _reportButton(Icons.people, 'Generate Student Report',
              AppColors.krishnaBlue,
              onTap: () => _showStudentReportDialog()),
          _reportButton(Icons.assignment_turned_in, 'Generate Attendance Report',
              AppColors.krishnaOrange,
              onTap: () => _showAttendanceReportDialog()),
          _reportButton(Icons.currency_rupee, 'Generate Financial Report',
              AppColors.success,
              onTap: () => _showFinancialReportDialog()),
          _reportButton(Icons.table_chart, 'Export to CSV',
              const Color(0xFF37474F),
              onTap: () => _showExportDialog('CSV')),
          _reportButton(Icons.picture_as_pdf, 'Export to PDF',
              AppColors.error,
              onTap: () => _showExportDialog('PDF')),
        ],
      ),
    );
  }

  String _formatAmount(int amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toString();
  }

  void _showExportDialog(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$type exported successfully!'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showStudentReportDialog() {
    final students = (_data?['students'] as List<dynamic>?) ?? [];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Student Report'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.separated(
            itemCount: students.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final s = students[i] as Map<String, dynamic>;
              final roll = s['roll'] as String? ?? '';
              final name = s['name'] as String? ?? '';
              final enrolled = (s['enrolled_activities'] as num?)?.toInt() ?? 0;
              return ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.krishnaBlue.withAlpha(20),
                  child: Text(
                    name.isNotEmpty ? name[0] : '?',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.krishnaBlue),
                  ),
                ),
                title: Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                subtitle: Text(roll,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
                trailing: Text('$enrolled activities',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showExportDialog('Student Report CSV');
            },
            child: const Text('Export CSV'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAttendanceReportDialog() {
    final monthlyStats = (_data?['monthly_stats'] as List<dynamic>?) ?? [];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Monthly Attendance Report'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: monthlyStats.map((item) {
              final m = item as Map<String, dynamic>;
              final month = m['month'] as String? ?? '';
              final pct = (m['attendance'] as num?)?.toDouble() ?? 0.0;
              final color = pct >= 90
                  ? AppColors.success
                  : pct >= 75
                      ? AppColors.krishnaOrange
                      : AppColors.error;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 36,
                      child: Text(month,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: pct / 100,
                          minHeight: 16,
                          backgroundColor: AppColors.lightBlue,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${pct.toStringAsFixed(0)}%',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: color)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showExportDialog('Attendance Report PDF');
            },
            child: const Text('Export PDF'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFinancialReportDialog() {
    final financial = (_data?['financial'] as Map<String, dynamic>?) ?? {};
    final revenueByPeriod =
        (financial['revenue_by_period'] as List<dynamic>?) ?? [];
    final total = (financial['revenue_total'] as num?)?.toInt() ?? 0;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Financial Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...revenueByPeriod.map((item) {
              final r = item as Map<String, dynamic>;
              final period = r['period'] as String? ?? '';
              final count = (r['count'] as num?)?.toInt() ?? 0;
              final revenue = (r['revenue'] as num?)?.toInt() ?? 0;
              return ListTile(
                dense: true,
                leading: const Icon(Icons.currency_rupee,
                    color: AppColors.success, size: 18),
                title: Text(period,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                subtitle: Text('$count students'),
                trailing: Text('\u20b9${_formatAmount(revenue)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                        fontSize: 14)),
              );
            }),
            const Divider(),
            ListTile(
              dense: true,
              leading: const Icon(Icons.summarize,
                  color: AppColors.krishnaBlue, size: 18),
              title: const Text('Total Revenue',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.krishnaBlue)),
              trailing: Text('\u20b9${_formatAmount(total)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.krishnaBlue,
                      fontSize: 15)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showExportDialog('Financial Report PDF');
            },
            child: const Text('Export PDF'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _paymentModeBar(String label, int value, int total, Color color) {
    final pct = total > 0 ? value / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text(
              '$value (${(pct * 100).round()}%)',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 14,
            backgroundColor: AppColors.lightBlue,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────── Shared Widgets ───────────────────────────

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
                const Text(
                  'ISKCON Activity Management',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  AppStrings.hareKrishna,
                  style: TextStyle(
                    color: AppColors.krishnaOrange.withAlpha(230),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: AppColors.deepBlue,
      ),
    );
  }

  Widget _statCard(IconData icon, String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _quickActionTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withAlpha(30), shape: BoxShape.circle),
          child: Icon(icon, color: color),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right, color: AppColors.krishnaBlue),
        onTap: onTap,
      ),
    );
  }

  Widget _reportButton(IconData icon, String label, Color color,
      {VoidCallback? onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withAlpha(25), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        trailing: const Icon(Icons.download, color: AppColors.textSecondary, size: 18),
        onTap: onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label \u2013 feature coming soon!'),
                  backgroundColor: AppColors.krishnaBlue,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
      ),
    );
  }
}

