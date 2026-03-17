import 'dart:convert';
import '../models/student_model.dart';
import '../models/activity_model.dart';
import '../models/visitor_model.dart';

class QrService {
  /// Generates a JSON QR payload for an attendance check-in event.
  /// Format: {"studentId":1,"studentName":"John","activityId":1,"activityName":"Swimming","timestamp":"2026-03-17T15:06:14Z"}
  static String attendanceQrData({
    required int studentId,
    required String studentName,
    required int activityId,
    required String activityName,
  }) {
    return jsonEncode({
      'studentId': studentId,
      'studentName': studentName,
      'activityId': activityId,
      'activityName': activityName,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    });
  }

  static String studentQrData(StudentModel student) {
    return jsonEncode({
      'type': 'student',
      'id': student.id,
      'name': student.name,
      if (student.phone != null) 'phone': student.phone,
    });
  }

  static String activityQrData(ActivityModel activity) {
    return jsonEncode({
      'type': 'activity',
      'id': activity.id,
      'name': activity.name,
      if (activity.schedule != null) 'schedule': activity.schedule,
    });
  }

  static String visitorQrData(VisitorModel visitor) {
    return jsonEncode({
      'type': 'visitor',
      'id': visitor.id,
      'name': visitor.visitorName,
      if (visitor.visitorPhone != null) 'phone': visitor.visitorPhone,
      'checkInTime': visitor.checkInTime,
    });
  }
}
