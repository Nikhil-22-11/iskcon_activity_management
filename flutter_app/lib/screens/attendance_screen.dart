import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/api_service.dart';
import '../services/firestore_service.dart';
import '../services/qr_service.dart';
import '../models/attendance_model.dart';
import '../models/student_model.dart';
import '../models/activity_model.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<AttendanceModel> _attendance = [];
  List<StudentModel> _students = [];
  List<ActivityModel> _activities = [];
  bool _isLoading = true;
  String? _error;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final results = await Future.wait([
        FirestoreService().getAttendanceByDate(dateStr),
        FirestoreService().getStudents(),
        FirestoreService().getActivities(),
      ]);
      if (mounted) {
        setState(() {
          _attendance = results[0] as List<AttendanceModel>;
          _students = results[1] as List<StudentModel>;
          _activities = results[2] as List<ActivityModel>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load attendance data';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadData();
    }
  }

  void _showCheckInDialog() {
    StudentModel? selectedStudent;
    ActivityModel? selectedActivity;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Mark Attendance'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<StudentModel>(
                decoration: const InputDecoration(labelText: 'Select Student'),
                items: _students
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                    .toList(),
                onChanged: (v) => setDialogState(() => selectedStudent = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ActivityModel>(
                decoration:
                    const InputDecoration(labelText: 'Select Activity'),
                items: _activities
                    .map((a) => DropdownMenuItem(value: a, child: Text(a.name)))
                    .toList(),
                onChanged: (v) => setDialogState(() => selectedActivity = v),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: (selectedStudent == null || selectedActivity == null)
                  ? null
                  : () async {
                      Navigator.pop(ctx);
                      try {
                        await FirestoreService().checkIn(
                            selectedStudent!.id, selectedActivity!.id,
                            studentName: selectedStudent!.name,
                            activityName: selectedActivity!.name);
                        _loadData();
                        if (mounted) {
                          _showAttendanceQr(selectedStudent!, selectedActivity!);
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
      ),
    );
  }

  void _showAttendanceQr(StudentModel student, ActivityModel activity) {
    final qrData = QrService.attendanceQrData(
      studentId: student.id,
      studentName: student.name,
      activityId: activity.id,
      activityName: activity.name,
    );
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
            const SizedBox(height: 12),
            const Icon(Icons.check_circle,
                color: AppColors.success, size: 32),
            const SizedBox(height: 8),
            Text(
              '${student.name} – Check-in Confirmed',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              activity.name,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.krishnaBlue.withAlpha(80)),
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
                  color: AppColors.deepBlue,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.krishnaBlue,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan to verify attendance',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.attendance),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCheckInDialog,
        backgroundColor: AppColors.krishnaOrange,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: const Text('Mark Attendance',
            style: TextStyle(color: AppColors.white)),
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: AppColors.krishnaBlue),
          const SizedBox(width: 12),
          Text(
            DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: AppColors.deepBlue),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.edit_calendar, size: 16),
            label: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
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
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_attendance.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_outlined,
                size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'No attendance records for ${DateFormat('MMM d').format(_selectedDate)}',
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the button below to mark attendance',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: _attendance.length,
      itemBuilder: (ctx, index) => _buildAttendanceCard(_attendance[index]),
    );
  }

  Widget _buildAttendanceCard(AttendanceModel record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: record.isCheckedOut
              ? AppColors.success.withAlpha(30)
              : AppColors.krishnaOrange.withAlpha(30),
          child: Icon(
            record.isCheckedOut ? Icons.check_circle : Icons.login,
            color: record.isCheckedOut ? AppColors.success : AppColors.krishnaOrange,
          ),
        ),
        title: Text(
          record.studentName ?? 'Student #${record.studentId}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(record.activityName ?? 'Activity #${record.activityId}'),
            if (record.checkInTime != null)
              Text(
                'In: ${_formatTime(record.checkInTime!)}',
                style: const TextStyle(fontSize: 12),
              ),
            if (record.checkOutTime != null)
              Text(
                'Out: ${_formatTime(record.checkOutTime!)}',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: record.isCheckedOut
                ? AppColors.success.withAlpha(20)
                : AppColors.krishnaOrange.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            record.isCheckedOut ? 'Checked Out' : 'Present',
            style: TextStyle(
              fontSize: 11,
              color: record.isCheckedOut ? AppColors.success : AppColors.krishnaOrange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        isThreeLine: true,
      ),
    );
  }

  String _formatTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return isoString;
    }
  }
}
