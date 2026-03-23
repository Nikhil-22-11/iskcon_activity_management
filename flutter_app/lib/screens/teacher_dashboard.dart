import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import '../navigation/routes.dart';
import 'admission_form.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
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
      final user = ApiService().currentUser;
      final result = await FirestoreService().getTeacherDashboard();
      if (mounted) {
        setState(() {
          _userName = user?.name ?? user?.email ?? 'Teacher';
          _data = result['data'] as Map<String, dynamic>? ?? result;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await FirestoreService().signOut();
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
                    child:
                        CircularProgressIndicator(color: AppColors.krishnaBlue))
              else ...[
                _buildClassSummary(),
                const SizedBox(height: 20),
                _buildAttendanceSummary(),
                const SizedBox(height: 20),
                _buildUpcomingActivities(),
                const SizedBox(height: 20),
                _buildAttendanceHistory(),
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
    final className = _data?['class_name'] as String? ?? 'My Class';
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
                  className,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                  ),
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

  Widget _buildClassSummary() {
    final total = _data?['total_students'] ?? 0;
    final present = _data?['present_today'] ?? 0;
    final absent = _data?['absent_today'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryTile(
            'Total Students',
            '$total',
            Icons.people_outline,
            AppColors.krishnaBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryTile(
            'Present Today',
            '$present',
            Icons.check_circle_outline,
            AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryTile(
            'Absent Today',
            '$absent',
            Icons.cancel_outlined,
            AppColors.error,
          ),
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
                  fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceSummary() {
    final total = (_data?['total_students'] as num?)?.toDouble() ?? 1;
    final present = (_data?['present_today'] as num?)?.toDouble() ?? 0;
    final pct = total > 0 ? (present / total * 100).round() : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Attendance Rate",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 15,
                    color: AppColors.deepBlue,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: total > 0 ? present / total : 0,
                      minHeight: 18,
                      backgroundColor: AppColors.lightBlue,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.success),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$pct%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingActivities() {
    final activities = (_data?['upcoming_activities'] as List<dynamic>?) ?? [];
    if (activities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activities',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 18,
                color: AppColors.deepBlue,
              ),
        ),
        const SizedBox(height: 12),
        ...activities.map((item) {
          final a = item as Map<String, dynamic>;
          final activityId = a['id'] as int? ?? 0;
          final enrolled = a['total_enrolled'] as int? ?? 0;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showActivityStudents(a),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.krishnaOrange.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.event,
                          color: AppColors.krishnaOrange, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a['name'] as String? ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            a['schedule'] as String? ?? '',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                          if (a['teacher'] != null)
                            Text(
                              'Teacher: ${a['teacher']}',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.krishnaBlue.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$enrolled enrolled',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.krishnaBlue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tap to view',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showActivityStudents(Map<String, dynamic> activity) {
    final activityId = activity['id'] as int? ?? 0;
    final activityName = activity['name'] as String? ?? 'Activity';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ActivityStudentsSheet(
        activityId: activityId,
        activityName: activityName,
        activitySchedule: activity['schedule'] as String? ?? '',
        activityTeacher: activity['teacher'] as String? ?? '',
      ),
    );
  }

  Widget _buildAttendanceHistory() {
    final history = (_data?['attendance_history'] as List<dynamic>?) ?? [];
    if (history.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Attendance History",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 18,
                color: AppColors.deepBlue,
              ),
        ),
        const SizedBox(height: 12),
        ...history.map((item) {
          final h = item as Map<String, dynamic>;
          final isOut = h['check_out'] != null;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isOut
                    ? AppColors.success.withAlpha(30)
                    : AppColors.krishnaOrange.withAlpha(30),
                child: Icon(
                  isOut ? Icons.check_circle : Icons.login,
                  color: isOut ? AppColors.success : AppColors.krishnaOrange,
                  size: 20,
                ),
              ),
              title: Text(
                h['student'] as String? ?? 'Student',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(h['activity'] as String? ?? '',
                      style: const TextStyle(fontSize: 12)),
                  if (h['check_in'] != null)
                    Text(
                      'In: ${_fmt(h['check_in'] as String)}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  if (h['check_out'] != null)
                    Text(
                      'Out: ${_fmt(h['check_out'] as String)}',
                      style: const TextStyle(fontSize: 11),
                    ),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOut
                      ? AppColors.success.withAlpha(20)
                      : AppColors.krishnaOrange.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isOut ? 'Done' : 'Present',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isOut ? AppColors.success : AppColors.krishnaOrange,
                  ),
                ),
              ),
              isThreeLine: true,
            ),
          );
        }),
      ],
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
        Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF7B1FA2).withAlpha(30),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.person_add_alt_1, color: Color(0xFF7B1FA2)),
            ),
            title: const Text('Admission',
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Add new student admission'),
            trailing:
                const Icon(Icons.chevron_right, color: AppColors.krishnaBlue),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AdmissionForm()),
            ),
          ),
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
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right, color: AppColors.krishnaBlue),
        onTap: () => Navigator.of(context).pushNamed(route),
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

// ─────────────────────────────────────────────────────────────────
// Bottom sheet: enrolled students for an activity
// ─────────────────────────────────────────────────────────────────

class _ActivityStudentsSheet extends StatefulWidget {
  final int activityId;
  final String activityName;
  final String activitySchedule;
  final String activityTeacher;

  const _ActivityStudentsSheet({
    required this.activityId,
    required this.activityName,
    required this.activitySchedule,
    required this.activityTeacher,
  });

  @override
  State<_ActivityStudentsSheet> createState() => _ActivityStudentsSheetState();
}

class _ActivityStudentsSheetState extends State<_ActivityStudentsSheet> {
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final result =
          await FirestoreService().getEnrolledStudents(widget.activityId);
      if (mounted) {
        setState(() {
          _students = result;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_search.isEmpty) return _students;
    final q = _search.toLowerCase();
    return _students
        .where((s) =>
            (s['name'] as String? ?? '').toLowerCase().contains(q) ||
            (s['roll_number'] as String? ?? '').toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollCtrl) => Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.krishnaOrange.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.event,
                          color: AppColors.krishnaOrange),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.activityName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.deepBlue,
                            ),
                          ),
                          Text(widget.activitySchedule,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                          if (widget.activityTeacher.isNotEmpty)
                            Text('Teacher: ${widget.activityTeacher}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.krishnaBlue.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_students.length} enrolled',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: AppColors.krishnaBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Search bar
                TextField(
                  onChanged: (v) => setState(() => _search = v),
                  decoration: InputDecoration(
                    hintText: 'Search students...',
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.textSecondary),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Student list
          Expanded(
            child: _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.krishnaBlue))
                : _filtered.isEmpty
                    ? const Center(
                        child: Text('No students found',
                            style: TextStyle(color: AppColors.textSecondary)))
                    : ListView.builder(
                        controller: scrollCtrl,
                        padding: const EdgeInsets.all(12),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) {
                          final s = _filtered[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    AppColors.krishnaBlue.withAlpha(25),
                                child: Text(
                                  '${i + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.krishnaBlue,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              title: Text(
                                s['name'] as String? ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                'Roll: ${s['roll_number'] ?? ''}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withAlpha(20),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  s['enrollment_status'] as String? ?? 'Active',
                                  style: const TextStyle(
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
      ),
    );
  }
}
