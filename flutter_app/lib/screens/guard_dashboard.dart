import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import '../navigation/routes.dart';

class GuardDashboard extends StatefulWidget {
  const GuardDashboard({super.key});

  @override
  State<GuardDashboard> createState() => _GuardDashboardState();
}

class _GuardDashboardState extends State<GuardDashboard> {
  List<Map<String, dynamic>> _scanHistory = [];
  bool _isLoading = true;
  bool _isScanning = false;
  String? _userName;

  // Rotating mock QR payloads for simulated scanning
  static const List<Map<String, dynamic>> _mockQrPayloads = [
    {'studentId': 2, 'studentName': 'Radha Patel', 'activityId': 1, 'activityName': 'Swimming', 'timestamp': '2026-03-17T07:10:00Z'},
    {'studentId': 4, 'studentName': 'Priya Nair', 'activityId': 2, 'activityName': 'Yoga', 'timestamp': '2026-03-17T06:05:00Z'},
    {'studentId': 6, 'studentName': 'Meera Iyer', 'activityId': 6, 'activityName': 'Sanskrit', 'timestamp': '2026-03-17T16:05:00Z'},
    {'studentId': 9, 'studentName': 'Tulsi Das', 'activityId': 8, 'activityName': 'Indian Culture and Value for Kids', 'timestamp': '2026-03-17T15:00:00Z'},
    {'studentId': 11, 'studentName': 'Sita Ram', 'activityId': 5, 'activityName': 'Art & Craft', 'timestamp': '2026-03-17T10:00:00Z'},
    {'studentId': 13, 'studentName': 'Hanuman Prasad', 'activityId': 3, 'activityName': 'Self-Defence', 'timestamp': '2026-03-17T16:00:00Z'},
  ];
  int _mockPayloadIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = await ApiService().getCurrentUser();
      final history = await FirestoreService().getQrScanHistory();
      if (mounted) {
        setState(() {
          _userName = user?.name ?? 'Guard';
          _scanHistory = List<Map<String, dynamic>>.from(history);
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

  Future<void> _simulateScan() async {
    setState(() => _isScanning = true);

    // Show scanning dialog
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _ScanningDialog(),
    );

    // Simulate 2-second scan delay
    await Future<void>.delayed(const Duration(seconds: 2));

    // Pick next mock QR payload
    final payload = _mockQrPayloads[_mockPayloadIndex % _mockQrPayloads.length];
    _mockPayloadIndex++;

    try {
      final result = await FirestoreService().processQrScan(Map<String, dynamic>.from(payload));
      if (mounted) {
        Navigator.of(context).pop(); // close scanning dialog
        setState(() {
          _scanHistory = [result, ..._scanHistory];
          _isScanning = false;
        });
        _showScanSuccess(result);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        setState(() => _isScanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scan failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showScanSuccess(Map<String, dynamic> scan) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: AppColors.success, size: 28),
            ),
            const SizedBox(width: 12),
            const Text('Attendance Marked!', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow(Icons.person, 'Student', scan['studentName'] as String? ?? ''),
            const SizedBox(height: 8),
            _detailRow(Icons.sports, 'Activity', scan['activityName'] as String? ?? ''),
            const SizedBox(height: 8),
            _detailRow(Icons.access_time, 'Check-in', _fmtTime(scan['checkInTime'] as String? ?? '')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.krishnaBlue),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
      ],
    );
  }

  void _showQrPreview() {
    final payload = _mockQrPayloads[_mockPayloadIndex % _mockQrPayloads.length];
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('QR Code Data Format'),
        content: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            const JsonEncoder.withIndent('  ').convert(payload),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Color(0xFF4EC9B0),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      appBar: AppBar(
        title: const Text(AppStrings.guardDashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: _showQrPreview,
            tooltip: 'View QR Format',
          ),
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
              _buildScanButton(),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: AppColors.krishnaBlue))
              else ...[
                _buildScanStats(),
                const SizedBox(height: 24),
                _buildScanHistory(),
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
                const Text(
                  'Scan student QR codes to mark attendance',
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

  Widget _buildScanButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isScanning ? null : _simulateScan,
        icon: const Icon(Icons.qr_code_scanner, size: 28),
        label: const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Text(
            'Scan QR Code',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.krishnaBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildScanStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem(Icons.qr_code_scanner, '${_scanHistory.length}', 'Total Scans\nToday', AppColors.krishnaBlue),
            Container(width: 1, height: 50, color: Colors.grey.shade200),
            _statItem(Icons.check_circle_outline, '${_scanHistory.length}', 'Attendance\nMarked', AppColors.success),
          ],
        ),
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildScanHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scan History (${_scanHistory.length})',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 18,
                color: AppColors.deepBlue,
              ),
        ),
        const SizedBox(height: 12),
        if (_scanHistory.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.qr_code_scanner, size: 48, color: AppColors.textSecondary),
                    SizedBox(height: 12),
                    Text('No scans yet. Tap "Scan QR Code" to begin.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
          )
        else
          ...(_scanHistory.map((scan) => _buildScanCard(scan))),
      ],
    );
  }

  Widget _buildScanCard(Map<String, dynamic> scan) {
    final checkInTime = scan['checkInTime'] as String? ?? '';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.success.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, color: AppColors.success, size: 24),
        ),
        title: Text(
          scan['studentName'] as String? ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sports, size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    scan['activityName'] as String? ?? '',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.access_time, size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Check-in: ${_fmtTime(checkInTime)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.success.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Present',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.success,
            ),
          ),
        ),
        isThreeLine: true,
      ),
    );
  }

  String _fmtTime(String iso) {
    try {
      return DateFormat('hh:mm a').format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return iso;
    }
  }
}

class _ScanningDialog extends StatefulWidget {
  const _ScanningDialog();

  @override
  State<_ScanningDialog> createState() => _ScanningDialogState();
}

class _ScanningDialogState extends State<_ScanningDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Scanning QR Code...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.krishnaBlue, width: 3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.qr_code, size: 64, color: AppColors.krishnaBlue),
                  ),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Positioned(
                        top: _controller.value * 100,
                        left: 10,
                        right: 10,
                        child: Container(
                          height: 2,
                          color: AppColors.krishnaOrange,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Hold QR code in front of camera...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

