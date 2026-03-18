import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/mock_data_service.dart';
import '../utils/constants.dart';

/// Runtime data inspector.
///
/// Shows:
///  • Current session (user, role, token type)
///  • All admissions recorded this session (MockDataService) +
///    admissions persisted to SharedPreferences
///  • QR scan history recorded this session
///
/// Access: Principal Dashboard → app bar storage icon.
class DataInspectorScreen extends StatefulWidget {
  const DataInspectorScreen({super.key});

  @override
  State<DataInspectorScreen> createState() => _DataInspectorScreenState();
}

class _DataInspectorScreenState extends State<DataInspectorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  // Session info
  String _userName = '—';
  String _userRole = '—';
  String _userEmail = '—';
  String _tokenType = '—';

  // Admissions
  List<Map<String, dynamic>> _sessionAdmissions = [];
  List<Map<String, dynamic>> _persistedAdmissions = [];

  // QR scans
  List<Map<String, dynamic>> _qrScans = [];

  // SharedPreferences raw keys (for advanced view)
  Map<String, String> _rawPrefs = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      // Session
      final user = await ApiService().getCurrentUser();
      final token = await ApiService().getToken();
      final isMock = token == null ||
          token == 'mock_token_iskcon_dev' ||
          token.startsWith('mock_');

      // In-memory admissions (this session)
      final sessionAdm = MockDataService().getAdmissions();

      // Persisted admissions (SharedPreferences)
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('admissions_data') ?? '[]';
      List<Map<String, dynamic>> persistedList;
      try {
        persistedList = (jsonDecode(raw) as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      } catch (_) {
        // Corrupted storage – treat as empty
        persistedList = [];
      }

      // QR scans (this session)
      final scans = await ApiService().getQrScanHistory();

      // Raw prefs keys (for debugging)
      final keys = prefs.getKeys();
      final rawMap = <String, String>{};
      for (final k in keys) {
        rawMap[k] = prefs.get(k).toString();
      }

      if (mounted) {
        setState(() {
          _userName = user?.name ?? '—';
          _userRole = user?.role ?? '—';
          _userEmail = user?.email ?? '—';
          _tokenType = isMock ? 'Mock (offline)' : 'Real JWT (backend)';
          _sessionAdmissions =
              sessionAdm.map((e) => Map<String, dynamic>.from(e)).toList();
          _persistedAdmissions = persistedList;
          _qrScans = List<Map<String, dynamic>>.from(scans);
          _rawPrefs = rawMap;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      appBar: AppBar(
        title: const Text('Data Inspector'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.account_circle, size: 18), text: 'Session'),
            Tab(icon: Icon(Icons.assignment, size: 18), text: 'Admissions'),
            Tab(icon: Icon(Icons.qr_code_scanner, size: 18), text: 'QR Scans'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.krishnaBlue))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSessionTab(),
                _buildAdmissionsTab(),
                _buildQrScansTab(),
              ],
            ),
    );
  }

  // ─────────────────────────── TAB 1: Session ───────────────────────────

  Widget _buildSessionTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionHeader('Current Session', Icons.account_circle_outlined),
        const SizedBox(height: 12),
        _infoCard([
          _infoRow(Icons.person_outline, 'Name', _userName),
          _infoRow(Icons.badge_outlined, 'Role', _userRole.toUpperCase()),
          _infoRow(Icons.email_outlined, 'Email', _userEmail),
          _infoRow(
            _tokenType.startsWith('Mock')
                ? Icons.wifi_off
                : Icons.verified_user_outlined,
            'Token Type',
            _tokenType,
            valueColor: _tokenType.startsWith('Mock')
                ? Colors.orange.shade700
                : AppColors.success,
          ),
        ]),
        const SizedBox(height: 20),
        _sectionHeader('SharedPreferences Keys', Icons.storage_outlined),
        const SizedBox(height: 12),
        if (_rawPrefs.isEmpty)
          const _EmptyState(message: 'No SharedPreferences keys found.')
        else
          ..._rawPrefs.entries.map((e) => _keyValueTile(e.key, e.value)),
        const SizedBox(height: 20),
        _sectionHeader('Persistence Guide', Icons.help_outline),
        const SizedBox(height: 8),
        _guideCard(
          title: 'What is persisted',
          items: const [
            'auth_token – JWT / mock token (survives restart)',
            'user_data – JSON-encoded role + name + email',
            'admissions_data – all submitted admissions (JSON array)',
          ],
          color: AppColors.success,
        ),
        const SizedBox(height: 8),
        _guideCard(
          title: 'What is NOT persisted (lost on restart)',
          items: const [
            'Students, activities, attendance, visitors',
            'QR scan history',
            '(All reset to mock seed data on each cold start)',
          ],
          color: AppColors.error,
        ),
      ],
    );
  }

  // ─────────────────────────── TAB 2: Admissions ─────────────────────────

  Widget _buildAdmissionsTab() {
    // Merge session + persisted; deduplicate by id
    final seen = <dynamic>{};
    final combined = [
      ..._sessionAdmissions,
      ..._persistedAdmissions,
    ].where((a) {
      final id = a['id'];
      if (seen.contains(id)) return false;
      seen.add(id);
      return true;
    }).toList()
      ..sort((a, b) {
        final idA = (a['id'] as int?) ?? 0;
        final idB = (b['id'] as int?) ?? 0;
        return idB.compareTo(idA);
      });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionHeader(
          'Admissions (${combined.length} total)',
          Icons.assignment_outlined,
        ),
        const SizedBox(height: 8),
        if (_sessionAdmissions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.success.withAlpha(80)),
            ),
            child: Text(
              '${_sessionAdmissions.length} new admission(s) recorded this session '
              '(also saved to SharedPreferences)',
              style: const TextStyle(
                  color: AppColors.success, fontWeight: FontWeight.w500),
            ),
          ),
        if (combined.isEmpty)
          const _EmptyState(
            message:
                'No admissions yet.\nFill the Admission Form as Teacher to see records here.',
          )
        else
          ...combined.map(_buildAdmissionCard),
      ],
    );
  }

  Widget _buildAdmissionCard(Map<String, dynamic> a) {
    final name = a['student_name'] as String? ?? '—';
    final date = a['admissionDate'] as String? ?? '—';
    final gender = a['gender'] as String? ?? '—';
    final school = a['school'] as String? ?? '—';
    final payPeriod = a['payment_period'] as String? ?? '—';
    final payMode = a['payment_mode'] as String? ?? '—';
    final txnId = a['transaction_id'] as String?;
    final id = a['id'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.krishnaBlue.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.krishnaBlue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'ID: $id  •  ${_formatDate(date)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            _detailRow('Gender', gender),
            _detailRow('School', school),
            _detailRow('Payment', '$payPeriod · $payMode'),
            if (txnId != null && txnId.isNotEmpty)
              _detailRow('Transaction ID', txnId),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────── TAB 3: QR Scans ─────────────────────────

  Widget _buildQrScansTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionHeader(
          'QR Scan History (${_qrScans.length})',
          Icons.qr_code_scanner,
        ),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withAlpha(80)),
          ),
          child: const Text(
            'QR scan history is in-memory only and resets on app restart.',
            style: TextStyle(
                color: Colors.orange, fontWeight: FontWeight.w500),
          ),
        ),
        if (_qrScans.isEmpty)
          const _EmptyState(
            message:
                'No QR scans yet.\nLog in as Guard and tap "Scan QR" to record entries.',
          )
        else
          ..._qrScans.map(_buildScanCard),
      ],
    );
  }

  Widget _buildScanCard(Map<String, dynamic> scan) {
    final student = scan['studentName'] as String? ?? '—';
    final activity = scan['activityName'] as String? ?? '—';
    final rawTime = scan['checkInTime'] as String? ?? '';
    final time = _formatDate(rawTime);
    final id = scan['id'];

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.krishnaOrange.withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.qr_code,
              color: AppColors.krishnaOrange, size: 20),
        ),
        title: Text(student,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('$activity\n$time',
            style: const TextStyle(fontSize: 12)),
        trailing: Text('#$id',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
        isThreeLine: true,
      ),
    );
  }

  // ─────────────────────────── Helpers ─────────────────────────────────

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.krishnaBlue, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.deepBlue,
          ),
        ),
      ],
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  /// Formats an ISO-8601 timestamp string to a human-readable date-time.
  /// Returns [raw] unchanged if it cannot be parsed.
  String _formatDate(String raw) {
    if (raw.isEmpty || raw == '—') return '—';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (_) {
      return raw;
    }
  }

  Widget _infoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _keyValueTile(String key, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              key,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.krishnaBlue,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value.length > 120 ? '${value.substring(0, 120)}…' : value,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _guideCard({
    required String title,
    required List<String> items,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 13)),
          const SizedBox(height: 4),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ',
                        style: TextStyle(color: color)),
                    Expanded(
                      child: Text(item,
                          style: TextStyle(
                              color: color.withAlpha(200),
                              fontSize: 12)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined,
                size: 48, color: AppColors.textSecondary.withAlpha(100)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textSecondary.withAlpha(180)),
            ),
          ],
        ),
      ),
    );
  }
}
