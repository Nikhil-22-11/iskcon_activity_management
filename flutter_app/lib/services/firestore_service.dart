import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/student_model.dart';
import '../models/activity_model.dart';
import '../models/attendance_model.dart';
import '../models/visitor_model.dart';
import '../models/admission_model.dart';
import '../models/payment_model.dart';
import '../models/user_model.dart';
import 'mock_data_service.dart';

/// Returns true when Firebase has been successfully initialized.
bool get _firebaseReady {
  try {
    Firebase.app();
    return true;
  } catch (_) {
    return false;
  }
}

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  FirebaseFirestore get _db => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  // ── Collection references ──────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _students =>
      _db.collection('students');
  CollectionReference<Map<String, dynamic>> get _activities =>
      _db.collection('activities');
  CollectionReference<Map<String, dynamic>> get _attendance =>
      _db.collection('attendance');
  CollectionReference<Map<String, dynamic>> get _visitors =>
      _db.collection('visitors');
  CollectionReference<Map<String, dynamic>> get _admissions =>
      _db.collection('admissions');
  CollectionReference<Map<String, dynamic>> get _payments =>
      _db.collection('payments');
  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  // ── Offline persistence ───────────────────────────────────────────────────

  static void enableOfflinePersistence() {
    try {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (_) {}
  }

  // ── Authentication ─────────────────────────────────────────────────────────

  Future<UserModel> signIn(String email, String password) async {
    if (!_firebaseReady) {
      return _mockLogin(email, password);
    }
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;
      final doc = await _users.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, docId: uid);
      }
      // User exists in Auth but not yet in Firestore → create basic record
      final role = _guessRole(email);
      final newUser = UserModel(
        id: 0,
        docId: uid,
        email: email,
        name: role[0].toUpperCase() + role.substring(1),
        role: role,
      );
      await _users.doc(uid).set(newUser.toMap());
      return newUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Authentication failed');
    }
  }

  Future<void> signOut() async {
    if (!_firebaseReady) return;
    try {
      await _auth.signOut();
    } catch (_) {}
  }

  UserModel? get currentFirebaseUser {
    if (!_firebaseReady) return null;
    final user = _auth.currentUser;
    if (user == null) return null;
    return UserModel(
      id: 0,
      docId: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? user.email ?? '',
      role: _guessRole(user.email ?? ''),
    );
  }

  String _guessRole(String email) {
    if (email.contains('guard')) return 'guard';
    if (email.contains('teacher')) return 'teacher';
    if (email.contains('principal')) return 'principal';
    return 'guard';
  }

  // ── Mock login fallback ────────────────────────────────────────────────────

  UserModel _mockLogin(String email, String password) {
    const credentials = {
      'guard@iskcon.org': {'password': 'Guard123', 'role': 'guard', 'name': 'Guard'},
      'teacher@iskcon.org': {
        'password': 'Teacher123',
        'role': 'teacher',
        'name': 'Teacher'
      },
      'principal@iskcon.org': {
        'password': 'Principal123',
        'role': 'principal',
        'name': 'Principal',
      },
    };
    final entry = credentials[email.toLowerCase().trim()];
    if (entry == null || entry['password'] != password) {
      throw Exception('Invalid email or password');
    }
    return UserModel(
      id: credentials.keys.toList().indexOf(email.toLowerCase().trim()) + 1,
      email: email,
      name: entry['name']!,
      role: entry['role']!,
    );
  }

  // ── Students ───────────────────────────────────────────────────────────────

  Future<List<StudentModel>> getStudents() async {
    if (!_firebaseReady) return MockDataService().getStudents();
    try {
      final snap = await _students.orderBy('name').get();
      if (snap.docs.isEmpty) {
        // Seed mock data once on first run (tracked by a metadata document).
        await _seedStudents();
        return MockDataService().getStudents();
      }
      return snap.docs
          .map((d) => StudentModel.fromMap(d.data(), docId: d.id))
          .toList();
    } catch (_) {
      return MockDataService().getStudents();
    }
  }

  Stream<List<StudentModel>> studentsStream() {
    if (!_firebaseReady) {
      return Stream.value(MockDataService().getStudents());
    }
    return _students.orderBy('name').snapshots().map(
          (snap) => snap.docs
              .map((d) => StudentModel.fromMap(d.data(), docId: d.id))
              .toList(),
        );
  }

  Future<StudentModel> createStudent(Map<String, dynamic> data) async {
    if (!_firebaseReady) return MockDataService().addStudent(data);
    try {
      _validateStudentData(data);
      final docRef = await _students.add({
        ...data,
        'created_at': FieldValue.serverTimestamp(),
      });
      final snap = await docRef.get();
      return StudentModel.fromMap(_timestampToString(snap.data()!),
          docId: snap.id);
    } catch (e) {
      if (e is Exception) rethrow;
      return MockDataService().addStudent(data);
    }
  }

  Future<StudentModel> updateStudent(String docId, Map<String, dynamic> data) async {
    if (!_firebaseReady) {
      final idVal = data['id'] as int?;
      return MockDataService().updateStudent(idVal ?? 0, data) ??
          MockDataService().addStudent(data);
    }
    try {
      _validateStudentData(data);
      await _students.doc(docId).update(data);
      final snap = await _students.doc(docId).get();
      return StudentModel.fromMap(_timestampToString(snap.data()!),
          docId: snap.id);
    } catch (_) {
      return MockDataService().addStudent(data);
    }
  }

  Future<void> deleteStudent(String docId) async {
    if (!_firebaseReady) return;
    await _students.doc(docId).delete();
  }

  void _validateStudentData(Map<String, dynamic> data) {
    if ((data['name'] as String?)?.trim().isEmpty ?? true) {
      throw Exception('Student name is required');
    }
  }

  // ── Activities ─────────────────────────────────────────────────────────────

  Future<List<ActivityModel>> getActivities() async {
    if (!_firebaseReady) return MockDataService().getActivities();
    try {
      final snap = await _activities.orderBy('name').get();
      if (snap.docs.isEmpty) {
        await _seedActivities();
        return MockDataService().getActivities();
      }
      return snap.docs
          .map((d) => ActivityModel.fromMap(d.data(), docId: d.id))
          .toList();
    } catch (_) {
      return MockDataService().getActivities();
    }
  }

  Stream<List<ActivityModel>> activitiesStream() {
    if (!_firebaseReady) {
      return Stream.value(MockDataService().getActivities());
    }
    return _activities.orderBy('name').snapshots().map(
          (snap) => snap.docs
              .map((d) => ActivityModel.fromMap(d.data(), docId: d.id))
              .toList(),
        );
  }

  Future<ActivityModel> createActivity(Map<String, dynamic> data) async {
    if (!_firebaseReady) return MockDataService().addActivity(data);
    try {
      _validateActivityData(data);
      final docRef = await _activities.add({
        ...data,
        'created_at': FieldValue.serverTimestamp(),
      });
      final snap = await docRef.get();
      return ActivityModel.fromMap(_timestampToString(snap.data()!),
          docId: snap.id);
    } catch (e) {
      if (e is Exception) rethrow;
      return MockDataService().addActivity(data);
    }
  }

  Future<ActivityModel> updateActivity(
      String docId, Map<String, dynamic> data) async {
    if (!_firebaseReady) {
      final idVal = data['id'] as int?;
      return MockDataService().updateActivity(idVal ?? 0, data) ??
          MockDataService().addActivity(data);
    }
    try {
      _validateActivityData(data);
      await _activities.doc(docId).update(data);
      final snap = await _activities.doc(docId).get();
      return ActivityModel.fromMap(_timestampToString(snap.data()!),
          docId: snap.id);
    } catch (_) {
      return MockDataService().addActivity(data);
    }
  }

  Future<void> deleteActivity(String docId) async {
    if (!_firebaseReady) return;
    await _activities.doc(docId).delete();
  }

  void _validateActivityData(Map<String, dynamic> data) {
    if ((data['name'] as String?)?.trim().isEmpty ?? true) {
      throw Exception('Activity name is required');
    }
  }

  // ── Attendance ─────────────────────────────────────────────────────────────

  Future<AttendanceModel> checkIn(int studentId, int activityId,
      {String? studentName, String? activityName}) async {
    if (!_firebaseReady) {
      return MockDataService().checkIn(studentId, activityId);
    }
    try {
      final now = DateTime.now().toIso8601String();
      final docRef = await _attendance.add({
        'student_id': studentId,
        'activity_id': activityId,
        if (studentName != null) 'student_name': studentName,
        if (activityName != null) 'activity_name': activityName,
        'check_in_time': now,
        'created_at': FieldValue.serverTimestamp(),
      });
      return AttendanceModel(
        id: 0,
        docId: docRef.id,
        studentId: studentId,
        activityId: activityId,
        studentName: studentName,
        activityName: activityName,
        checkInTime: now,
        createdAt: now,
      );
    } catch (_) {
      return MockDataService().checkIn(studentId, activityId);
    }
  }

  Future<AttendanceModel> checkOut(String docId) async {
    if (!_firebaseReady) throw Exception('Firebase not ready');
    final now = DateTime.now().toIso8601String();
    await _attendance.doc(docId).update({'check_out_time': now});
    final snap = await _attendance.doc(docId).get();
    return AttendanceModel.fromMap(_timestampToString(snap.data()!),
        docId: snap.id);
  }

  Future<List<AttendanceModel>> getAttendanceByDate(String date) async {
    if (!_firebaseReady) {
      return MockDataService().getAttendanceByDate(date);
    }
    try {
      // Two range conditions on the same field are supported natively.
      // Firestore index on 'check_in_time' (ascending) is auto-created.
      final snap = await _attendance
          .orderBy('check_in_time')
          .startAt(['${date}T00:00:00'])
          .endAt(['${date}T23:59:59'])
          .get();
      return snap.docs
          .map((d) => AttendanceModel.fromMap(_timestampToString(d.data()),
              docId: d.id))
          .toList();
    } catch (_) {
      return MockDataService().getAttendanceByDate(date);
    }
  }

  Future<List<AttendanceModel>> getStudentAttendance(int studentId) async {
    if (!_firebaseReady) {
      return MockDataService().getStudentAttendance(studentId);
    }
    try {
      final snap = await _attendance
          .where('student_id', isEqualTo: studentId)
          .orderBy('check_in_time', descending: true)
          .get();
      return snap.docs
          .map((d) => AttendanceModel.fromMap(_timestampToString(d.data()),
              docId: d.id))
          .toList();
    } catch (_) {
      return MockDataService().getStudentAttendance(studentId);
    }
  }

  Stream<List<AttendanceModel>> attendanceTodayStream() {
    if (!_firebaseReady) {
      return Stream.value(MockDataService()
          .getAttendanceByDate(DateTime.now().toIso8601String().split('T').first));
    }
    final today = DateTime.now().toIso8601String().split('T').first;
    return _attendance
        .orderBy('check_in_time', descending: true)
        .startAt(['${today}T23:59:59'])
        .endAt(['${today}T00:00:00'])
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AttendanceModel.fromMap(_timestampToString(d.data()),
                docId: d.id))
            .toList());
  }

  // ── QR Scan ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> processQrScan(
      Map<String, dynamic> qrData) async {
    if (!_firebaseReady) return MockDataService().addQrScan(qrData);
    try {
      final studentId = qrData['studentId'] as int? ?? 0;
      final activityId = qrData['activityId'] as int? ?? 0;
      final record = await checkIn(
        studentId,
        activityId,
        studentName: qrData['studentName'] as String?,
        activityName: qrData['activityName'] as String?,
      );
      return {
        'success': true,
        'docId': record.docId,
        'studentName': record.studentName,
        'activityName': record.activityName,
        'checkInTime': record.checkInTime,
      };
    } catch (_) {
      return MockDataService().addQrScan(qrData);
    }
  }

  Future<List<Map<String, dynamic>>> getQrScanHistory() async {
    if (!_firebaseReady) return MockDataService().getQrScanHistory();
    try {
      final snap = await _attendance
          .orderBy('check_in_time', descending: true)
          .limit(50)
          .get();
      return snap.docs.map((d) {
        final data = _timestampToString(d.data());
        return {
          'docId': d.id,
          'studentId': data['student_id'],
          'studentName': data['student_name'] ?? 'Unknown',
          'activityId': data['activity_id'],
          'activityName': data['activity_name'] ?? 'Unknown',
          'timestamp': data['check_in_time'],
        };
      }).toList();
    } catch (_) {
      return MockDataService().getQrScanHistory();
    }
  }

  // ── Visitors ───────────────────────────────────────────────────────────────

  Future<List<VisitorModel>> getVisitors() async {
    if (!_firebaseReady) return MockDataService().getVisitors();
    try {
      final snap = await _visitors
          .orderBy('check_in_time', descending: true)
          .limit(50)
          .get();
      return snap.docs
          .map((d) => VisitorModel.fromMap(_timestampToString(d.data()),
              docId: d.id))
          .toList();
    } catch (_) {
      return MockDataService().getVisitors();
    }
  }

  Future<VisitorModel> visitorCheckIn(Map<String, dynamic> data) async {
    if (!_firebaseReady) return MockDataService().addVisitor(data);
    try {
      final now = DateTime.now().toIso8601String();
      final docRef = await _visitors.add({
        ...data,
        'check_in_time': now,
        'created_at': FieldValue.serverTimestamp(),
      });
      return VisitorModel(
        id: 0,
        docId: docRef.id,
        visitorName: data['visitor_name'] as String,
        visitorPhone: data['visitor_phone'] as String?,
        visitReason: data['visit_reason'] as String?,
        checkInTime: now,
      );
    } catch (_) {
      return MockDataService().addVisitor(data);
    }
  }

  Future<VisitorModel> visitorCheckOut(String docId) async {
    if (!_firebaseReady) throw Exception('Firebase not ready');
    final now = DateTime.now().toIso8601String();
    await _visitors.doc(docId).update({'check_out_time': now});
    final snap = await _visitors.doc(docId).get();
    return VisitorModel.fromMap(_timestampToString(snap.data()!),
        docId: snap.id);
  }

  // ── Admissions ─────────────────────────────────────────────────────────────

  Future<AdmissionModel> submitAdmission(Map<String, dynamic> data) async {
    if (!_firebaseReady) {
      MockDataService().addAdmission(data);
      return AdmissionModel.fromMap({
        ...data,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
    try {
      _validateAdmissionData(data);
      final docRef = await _admissions.add({
        ...data,
        'created_at': FieldValue.serverTimestamp(),
      });
      final snap = await docRef.get();
      return AdmissionModel.fromMap(_timestampToString(snap.data()!),
          docId: snap.id);
    } catch (e) {
      if (e is Exception) rethrow;
      return AdmissionModel.fromMap(data);
    }
  }

  Future<List<AdmissionModel>> getAdmissions() async {
    if (!_firebaseReady) return [];
    try {
      final snap =
          await _admissions.orderBy('created_at', descending: true).get();
      return snap.docs
          .map((d) =>
              AdmissionModel.fromMap(_timestampToString(d.data()), docId: d.id))
          .toList();
    } catch (_) {
      return [];
    }
  }

  void _validateAdmissionData(Map<String, dynamic> data) {
    if ((data['student_name'] as String?)?.trim().isEmpty ?? true) {
      throw Exception('Student name is required');
    }
    final motherContact = data['mother_contact'] as String?;
    final fatherContact = data['father_contact'] as String?;
    if ((motherContact == null || motherContact.isEmpty) &&
        (fatherContact == null || fatherContact.isEmpty)) {
      throw Exception('At least one parent contact is required');
    }
  }

  // ── Payments ───────────────────────────────────────────────────────────────

  Future<PaymentModel> recordPayment(Map<String, dynamic> data) async {
    if (!_firebaseReady) {
      return PaymentModel.fromMap({
        ...data,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
    try {
      final docRef = await _payments.add({
        ...data,
        'created_at': FieldValue.serverTimestamp(),
      });
      final snap = await docRef.get();
      return PaymentModel.fromMap(_timestampToString(snap.data()!),
          docId: snap.id);
    } catch (_) {
      return PaymentModel.fromMap(data);
    }
  }

  Future<List<PaymentModel>> getPayments() async {
    if (!_firebaseReady) return [];
    try {
      final snap =
          await _payments.orderBy('created_at', descending: true).get();
      return snap.docs
          .map((d) =>
              PaymentModel.fromMap(_timestampToString(d.data()), docId: d.id))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Dashboard analytics ────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getDashboardStats() async {
    if (!_firebaseReady) {
      return {'data': MockDataService().getDashboardStats()};
    }
    try {
      final students = await _students.count().get();
      final activities = await _activities.count().get();
      final today = DateTime.now().toIso8601String().split('T').first;
      final attendance = await _attendance
          .where('check_in_time', isGreaterThanOrEqualTo: '${today}T00:00:00')
          .count()
          .get();
      return {
        'data': {
          'total_students': students.count,
          'total_activities': activities.count,
          'today_attendance': attendance.count,
        }
      };
    } catch (_) {
      return {'data': MockDataService().getDashboardStats()};
    }
  }

  Future<Map<String, dynamic>> getGuardDashboard() async {
    if (!_firebaseReady) {
      return {'data': MockDataService().getGuardDashboard()};
    }
    try {
      final scanHistory = await getQrScanHistory();
      final today = DateTime.now().toIso8601String().split('T').first;
      final todayScans = scanHistory.where((s) {
        final ts = s['timestamp'] as String? ?? '';
        return ts.startsWith(today);
      }).toList();
      return {
        'data': {
          'scan_history': scanHistory,
          'today_count': todayScans.length,
        }
      };
    } catch (_) {
      return {'data': MockDataService().getGuardDashboard()};
    }
  }

  Future<Map<String, dynamic>> getTeacherDashboard() async {
    if (!_firebaseReady) {
      return {'data': MockDataService().getTeacherDashboard()};
    }
    try {
      final activities = await getActivities();
      return {
        'data': {
          'activities': activities.map((a) => a.toMap()).toList(),
          'total_activities': activities.length,
        }
      };
    } catch (_) {
      return {'data': MockDataService().getTeacherDashboard()};
    }
  }

  Future<Map<String, dynamic>> getPrincipalDashboard() async {
    if (!_firebaseReady) {
      return {'data': MockDataService().getPrincipalDashboard()};
    }
    try {
      final stats = await getDashboardStats();
      final students = await getStudents();
      final activities = await getActivities();
      final payments = await getPayments();
      final totalRevenue =
          payments.fold<double>(0, (sum, p) => sum + p.amount);
      return {
        'data': {
          ...stats['data'] as Map<String, dynamic>,
          'students': students.map((s) => s.toMap()).toList(),
          'activities': activities.map((a) => a.toMap()).toList(),
          'total_revenue': totalRevenue,
          'payments': payments.map((p) => p.toMap()).toList(),
        }
      };
    } catch (_) {
      return {'data': MockDataService().getPrincipalDashboard()};
    }
  }

  // ── Enrollments ────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getEnrolledStudents(
      int activityId) async {
    if (!_firebaseReady) {
      return MockDataService().getEnrolledStudents(activityId);
    }
    try {
      final snap = await _attendance
          .where('activity_id', isEqualTo: activityId)
          .get();
      final seen = <int>{};
      final result = <Map<String, dynamic>>[];
      for (final d in snap.docs) {
        final sid = d.data()['student_id'] as int? ?? 0;
        if (seen.add(sid)) {
          result.add({
            'student_id': sid,
            'student_name': d.data()['student_name'] ?? 'Unknown',
          });
        }
      }
      return result;
    } catch (_) {
      return MockDataService().getEnrolledStudents(activityId);
    }
  }

  // ── Seeding ────────────────────────────────────────────────────────────────

  /// Tracks whether initial seeding has been done by writing a metadata doc.
  /// This prevents re-seeding if all students are intentionally deleted.
  static const _seedMetaCollection = '_meta';
  static const _seedStudentsDocId = 'students_seeded';
  static const _seedActivitiesDocId = 'activities_seeded';

  Future<void> _seedStudents() async {
    final metaRef = _db.collection(_seedMetaCollection).doc(_seedStudentsDocId);
    final meta = await metaRef.get();
    if (meta.exists) return; // already seeded
    final mock = MockDataService().getStudents();
    final batch = _db.batch();
    for (final s in mock) {
      batch.set(_students.doc(), s.toMap());
    }
    batch.set(metaRef, {'seeded_at': FieldValue.serverTimestamp()});
    await batch.commit();
  }

  Future<void> _seedActivities() async {
    final metaRef =
        _db.collection(_seedMetaCollection).doc(_seedActivitiesDocId);
    final meta = await metaRef.get();
    if (meta.exists) return; // already seeded
    final mock = MockDataService().getActivities();
    final batch = _db.batch();
    for (final a in mock) {
      batch.set(_activities.doc(), a.toMap());
    }
    batch.set(metaRef, {'seeded_at': FieldValue.serverTimestamp()});
    await batch.commit();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Converts Firestore [Timestamp] values in a map to ISO-8601 strings so
  /// that [fromMap] constructors (which expect String?) work correctly.
  Map<String, dynamic> _timestampToString(Map<String, dynamic> data) {
    return data.map((k, v) {
      if (v is Timestamp) return MapEntry(k, v.toDate().toIso8601String());
      return MapEntry(k, v);
    });
  }
}
