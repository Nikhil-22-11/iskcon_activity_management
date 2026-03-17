import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/visitor_model.dart';
import '../utils/constants.dart';
import '../services/qr_service.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class VisitorCheckInScreen extends StatefulWidget {
  const VisitorCheckInScreen({super.key});

  @override
  State<VisitorCheckInScreen> createState() => _VisitorCheckInScreenState();
}

class _VisitorCheckInScreenState extends State<VisitorCheckInScreen> {
  List<VisitorModel> _visitors = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVisitors();
  }

  Future<void> _loadVisitors() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final visitors = await ApiService().getVisitors();
      if (mounted) {
        setState(() {
          _visitors = visitors;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _error = 'Failed to load visitors';
        _isLoading = false;
      });
    }
  }

  void _showCheckInDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    final studentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.person_add, color: AppColors.krishnaBlue),
            const SizedBox(width: 8),
            const Text('Visitor Check-In'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration:
                    const InputDecoration(labelText: 'Visitor Name *'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneCtrl,
                decoration:
                    const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: studentCtrl,
                decoration:
                    const InputDecoration(labelText: 'Student Name (if any)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reasonCtrl,
                decoration:
                    const InputDecoration(labelText: 'Reason for Visit'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              try {
                await ApiService().visitorCheckIn({
                  'visitor_name': nameCtrl.text.trim(),
                  if (phoneCtrl.text.isNotEmpty)
                    'visitor_phone': phoneCtrl.text.trim(),
                  if (studentCtrl.text.isNotEmpty)
                    'student_name': studentCtrl.text.trim(),
                  if (reasonCtrl.text.isNotEmpty)
                    'visit_reason': reasonCtrl.text.trim(),
                });
                _loadVisitors();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Visitor checked in successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Check In'),
          ),
        ],
      ),
    );
  }

  void _showVisitorQr(VisitorModel visitor) {
    final qrData = QrService.visitorQrData(visitor);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(visitor.visitorName,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            if (visitor.visitReason != null) ...[
              const SizedBox(height: 4),
              Text(visitor.visitReason!,
                  style:
                      const TextStyle(color: AppColors.textSecondary)),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF7B1FA2).withAlpha(80)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(15), blurRadius: 8),
                ],
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 180,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Color(0xFF4A148C),
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Color(0xFF7B1FA2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Visitor ID: ${visitor.id}',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCheckOut(VisitorModel visitor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Visitor Check-Out'),
        content: Text('Check out ${visitor.visitorName}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Check Out')),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await ApiService().visitorCheckOut(visitor.id);
        _loadVisitors();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Visitor checked out'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeVisitors = _visitors.where((v) => !v.isCheckedOut).toList();
    final pastVisitors = _visitors.where((v) => v.isCheckedOut).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.visitors),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh), onPressed: _loadVisitors),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCheckInDialog,
        backgroundColor: AppColors.krishnaOrange,
        icon: const Icon(Icons.person_add, color: AppColors.white),
        label: const Text('Visitor Check-In',
            style: TextStyle(color: AppColors.white)),
      ),
      body: _buildBody(activeVisitors, pastVisitors),
    );
  }

  Widget _buildBody(
      List<VisitorModel> active, List<VisitorModel> past) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.krishnaBlue));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: _loadVisitors, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_visitors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline,
                size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text('No visitor records',
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            const Text('Tap the button to check in a visitor',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        if (active.isNotEmpty) ...[
          _buildSectionHeader(
              'Currently Inside (${active.length})', AppColors.krishnaOrange),
          const SizedBox(height: 8),
          ...active.map((v) => _buildVisitorCard(v, isActive: true)),
          const SizedBox(height: 16),
        ],
        if (past.isNotEmpty) ...[
          _buildSectionHeader(
              'Past Visitors (${past.length})', AppColors.textSecondary),
          const SizedBox(height: 8),
          ...past.map((v) => _buildVisitorCard(v, isActive: false)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
        color: color,
      ),
    );
  }

  Widget _buildVisitorCard(VisitorModel visitor, {required bool isActive}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showVisitorQr(visitor),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: isActive
                    ? AppColors.krishnaOrange.withAlpha(30)
                    : AppColors.textSecondary.withAlpha(30),
                child: Text(
                  visitor.visitorName[0].toUpperCase(),
                  style: TextStyle(
                    color: isActive
                        ? AppColors.krishnaOrange
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visitor.visitorName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    if (visitor.visitorPhone != null)
                      Text(
                        visitor.visitorPhone!,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                    if (visitor.visitReason != null)
                      Text(
                        visitor.visitReason!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    if (visitor.checkInTime != null)
                      Text(
                        'In: ${_formatTime(visitor.checkInTime!)}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                    if (visitor.checkOutTime != null)
                      Text(
                        'Out: ${_formatTime(visitor.checkOutTime!)}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.qr_code,
                        color: Color(0xFF7B1FA2), size: 20),
                    tooltip: 'Show QR',
                    onPressed: () => _showVisitorQr(visitor),
                  ),
                  if (isActive)
                    TextButton(
                      onPressed: () => _handleCheckOut(visitor),
                      child: const Text('Check Out',
                          style: TextStyle(
                              color: AppColors.krishnaOrange,
                              fontSize: 12)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('hh:mm a, MMM d').format(dt);
    } catch (_) {
      return isoString;
    }
  }
}
