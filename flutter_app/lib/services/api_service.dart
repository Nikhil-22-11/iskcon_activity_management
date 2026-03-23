import '../models/user_model.dart';
import '../models/student_model.dart';
import '../models/activity_model.dart';
import '../models/attendance_model.dart';
import '../models/visitor_model.dart';
import 'firestore_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ApiService — thin facade over FirestoreService.
//
// ALL data now goes through Firebase Firestore + Firebase Auth.
// The Node/PostgreSQL backend and MockDataService are no longer used.
// ─────────────────────────────────────────────────────────────────────────────

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final FirestoreService _fs = FirestoreService();

  // ── Auth ───────────────────────────────────────────────────────────────────

  Future<UserModel> login(String email, String password) async {
    try {
      return await _fs.signIn(email, password);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> logout() async {
    await _fs.signOut();
  }

  UserModel? get currentUser => _fs.currentFirebaseUser;

  // ── Students ───────────────────────────────────────────────────────────────

  Future<List<StudentModel>> getStudents({int page = 1}) async {
    try {
      return await _fs.getStudents();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Stream<List<StudentModel>> studentsStream() => _fs.studentsStream();

  Future<StudentModel> createStudent(Map<String, dynamic> body) async {
    try {
      return await _fs.createStudent(body);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  // FIX: updateStudent now takes docId (String) — Firestore uses string doc IDs,
  // not integer IDs. Always pass student.docId from the UI.
  Future<StudentModel> updateStudent(
      String docId, Map<String, dynamic> body) async {
    try {
      return await _fs.updateStudent(docId, body);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  // FIX: deleteStudent now takes docId (String)
  Future<void> deleteStudent(String docId) async {
    try {
      await _fs.deleteStudent(docId);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  // ── Activities ─────────────────────────────────────────────────────────────

  Future<List<ActivityModel>> getActivities({int page = 1}) async {
    try {
      return await _fs.getActivities();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Stream<List<ActivityModel>> activitiesStream() => _fs.activitiesStream();

  Future<ActivityModel> createActivity(Map<String, dynamic> body) async {
    try {
      return await _fs.createActivity(body);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<ActivityModel> updateActivity(
      String docId, Map<String, dynamic> body) async {
    try {
      return await _fs.updateActivity(docId, body);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> deleteActivity(String docId) async {
    try {
      await _fs.deleteActivity(docId);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  // ── Attendance ─────────────────────────────────────────────────────────────

  Future<AttendanceModel> checkIn(int studentId, int activityId,
      {String? studentName, String? activityName}) async {
    try {
      return await _fs.checkIn(studentId, activityId,
          studentName: studentName, activityName: activityName);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<AttendanceModel>> getAttendanceByDate(String date) async {
    try {
      return await _fs.getAttendanceByDate(date);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<AttendanceModel>> getStudentAttendance(int studentId) async {
    try {
      return await _fs.getStudentAttendance(studentId);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Stream<List<AttendanceModel>> attendanceTodayStream() =>
      _fs.attendanceTodayStream();

  // ── Visitors ───────────────────────────────────────────────────────────────

  Future<List<VisitorModel>> getVisitors({int page = 1}) async {
    try {
      return await _fs.getVisitors();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<VisitorModel> visitorCheckIn(Map<String, dynamic> body) async {
    try {
      return await _fs.visitorCheckIn(body);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<VisitorModel> visitorCheckOut(String docId) async {
    try {
      return await _fs.visitorCheckOut(docId);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  // ── Dashboard ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getDashboardStats() => _fs.getDashboardStats();

  Future<Map<String, dynamic>> getGuardDashboard() => _fs.getGuardDashboard();

  Future<Map<String, dynamic>> getTeacherDashboard() =>
      _fs.getTeacherDashboard();

  Future<Map<String, dynamic>> getPrincipalDashboard() =>
      _fs.getPrincipalDashboard();

  // ── Enrollments ────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getEnrolledStudents(int activityId) =>
      _fs.getEnrolledStudents(activityId);

  // ── QR Scan ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> processQrScan(Map<String, dynamic> qrData) =>
      _fs.processQrScan(qrData);

  Future<List<Map<String, dynamic>>> getQrScanHistory() =>
      _fs.getQrScanHistory();

  // ── Admissions ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> submitAdmission(
      Map<String, dynamic> data) async {
    try {
      final result = await _fs.submitAdmission(data);
      return result.toMap();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getAdmissions() async {
    try {
      final admissions = await _fs.getAdmissions();
      return admissions.map((a) => a.toMap()).toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
