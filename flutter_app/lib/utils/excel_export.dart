import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/student_model.dart';
import '../models/attendance_model.dart';
import '../models/payment_model.dart';
import '../models/activity_model.dart';

class ExcelExport {
  /// Returns the platform-appropriate download/documents directory path.
  static String _outputDir() {
    if (kIsWeb) return '';
    if (Platform.isAndroid) return '/storage/emulated/0/Download';
    if (Platform.isIOS) {
      // iOS sandboxed: use the app's Documents directory.
      return '${Directory.systemTemp.parent.path}/Documents';
    }
    // Windows / macOS / Linux: use the user's home Downloads folder.
    final home =
        Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'] ?? '.';
    return '$home/Downloads';
  }

  static String _timestamp() =>
      DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

  // ── Students ───────────────────────────────────────────────────────────────

  /// Exports [students] to an Excel file and returns the saved file path.
  static Future<String> exportStudents(List<StudentModel> students) async {
    final excel = Excel.createExcel();
    final sheet = excel['Students'];
    excel.delete('Sheet1');

    // Header row
    final headers = [
      'ID',
      'Name',
      'Email',
      'Phone',
      'Date of Birth',
      'Parent Name',
      'Parent Phone',
      'Address',
      'Enrolled On',
    ];
    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

    for (final s in students) {
      sheet.appendRow([
        TextCellValue(s.docId ?? s.id.toString()),
        TextCellValue(s.name),
        TextCellValue(s.email ?? ''),
        TextCellValue(s.phone ?? ''),
        TextCellValue(s.dateOfBirth ?? ''),
        TextCellValue(s.parentName ?? ''),
        TextCellValue(s.parentPhone ?? ''),
        TextCellValue(s.address ?? ''),
        TextCellValue(s.createdAt?.split('T').first ?? ''),
      ]);
    }

    return _save(excel, 'Students_${_timestamp()}.xlsx');
  }

  // ── Attendance ─────────────────────────────────────────────────────────────

  static Future<String> exportAttendance(
      List<AttendanceModel> records, {String? dateLabel}) async {
    final excel = Excel.createExcel();
    final sheetName = dateLabel != null ? 'Attendance_$dateLabel' : 'Attendance';
    final sheet = excel[sheetName];
    excel.delete('Sheet1');

    final headers = [
      'Doc ID',
      'Student ID',
      'Student Name',
      'Activity ID',
      'Activity Name',
      'Check-In Time',
      'Check-Out Time',
    ];
    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

    for (final r in records) {
      sheet.appendRow([
        TextCellValue(r.docId ?? r.id.toString()),
        TextCellValue(r.studentId.toString()),
        TextCellValue(r.studentName ?? ''),
        TextCellValue(r.activityId.toString()),
        TextCellValue(r.activityName ?? ''),
        TextCellValue(r.checkInTime ?? ''),
        TextCellValue(r.checkOutTime ?? ''),
      ]);
    }

    return _save(excel, 'Attendance_${_timestamp()}.xlsx');
  }

  // ── Finance / Payments ─────────────────────────────────────────────────────

  static Future<String> exportFinancialReport(
      List<PaymentModel> payments) async {
    final excel = Excel.createExcel();
    final sheet = excel['Payments'];
    excel.delete('Sheet1');

    final headers = [
      'Doc ID',
      'Student ID',
      'Student Name',
      'Amount (₹)',
      'Payment Mode',
      'Transaction ID',
      'Period',
      'Date',
    ];
    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

    double total = 0;
    for (final p in payments) {
      total += p.amount;
      sheet.appendRow([
        TextCellValue(p.docId ?? ''),
        TextCellValue(p.studentId?.toString() ?? ''),
        TextCellValue(p.studentName ?? ''),
        DoubleCellValue(p.amount),
        TextCellValue(p.paymentMode),
        TextCellValue(p.transactionId ?? ''),
        TextCellValue(p.period ?? ''),
        TextCellValue(p.createdAt?.split('T').first ?? ''),
      ]);
    }

    // Total row
    sheet.appendRow([
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue('TOTAL'),
      DoubleCellValue(total),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
    ]);

    return _save(excel, 'Financial_Report_${_timestamp()}.xlsx');
  }

  // ── Activity enrollments ───────────────────────────────────────────────────

  static Future<String> exportActivityEnrollments(
    ActivityModel activity,
    List<Map<String, dynamic>> enrolledStudents,
  ) async {
    final excel = Excel.createExcel();
    final safeName = activity.name.replaceAll(RegExp(r'[/\\?*:\[\]]'), '_');
    final sheet = excel[safeName];
    excel.delete('Sheet1');

    // Activity details
    sheet.appendRow([TextCellValue('Activity'), TextCellValue(activity.name)]);
    sheet.appendRow([
      TextCellValue('Teacher'),
      TextCellValue(activity.teacher ?? '')
    ]);
    sheet.appendRow([
      TextCellValue('Schedule'),
      TextCellValue(activity.schedule ?? '')
    ]);
    sheet.appendRow([TextCellValue('')]);

    // Enrolled students header
    final headers = ['Student ID', 'Student Name'];
    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

    for (final s in enrolledStudents) {
      sheet.appendRow([
        TextCellValue(s['student_id']?.toString() ?? ''),
        TextCellValue(s['student_name']?.toString() ?? ''),
      ]);
    }

    final fileName =
        '${safeName}_Enrollments_${_timestamp()}.xlsx';
    return _save(excel, fileName);
  }

  // ── Save helper ────────────────────────────────────────────────────────────

  static Future<String> _save(Excel excel, String fileName) async {
    if (kIsWeb) {
      // On web, we cannot save to filesystem; caller should handle bytes.
      throw UnsupportedError(
          'File save is not supported on web. Use the bytes directly.');
    }
    final dir = Directory(_outputDir());
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    final path = '${dir.path}/$fileName';
    final bytes = excel.save();
    if (bytes == null) throw Exception('Failed to generate Excel bytes');
    await File(path).writeAsBytes(bytes);
    return path;
  }

  /// Returns raw Excel bytes (useful for web or sharing via OS).
  static List<int>? exportStudentsBytes(List<StudentModel> students) {
    final excel = Excel.createExcel();
    final sheet = excel['Students'];
    excel.delete('Sheet1');
    final headers = [
      'ID', 'Name', 'Email', 'Phone', 'Date of Birth',
      'Parent Name', 'Parent Phone', 'Address', 'Enrolled On',
    ];
    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());
    for (final s in students) {
      sheet.appendRow([
        TextCellValue(s.docId ?? s.id.toString()),
        TextCellValue(s.name),
        TextCellValue(s.email ?? ''),
        TextCellValue(s.phone ?? ''),
        TextCellValue(s.dateOfBirth ?? ''),
        TextCellValue(s.parentName ?? ''),
        TextCellValue(s.parentPhone ?? ''),
        TextCellValue(s.address ?? ''),
        TextCellValue(s.createdAt?.split('T').first ?? ''),
      ]);
    }
    return excel.save();
  }
}
