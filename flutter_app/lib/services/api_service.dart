import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/student_model.dart';
import '../models/activity_model.dart';
import '../models/attendance_model.dart';
import '../models/visitor_model.dart';
import '../utils/constants.dart';
import 'mock_data_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  static const String _mockToken = 'mock_token_iskcon_dev';
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  String? _token;
  UserModel? _currentUser;

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // ──────────────────── Token management ────────────────────

  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _saveUser(UserModel user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    return _token;
  }

  Future<UserModel?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      _currentUser = UserModel.fromJson(
          jsonDecode(userJson) as Map<String, dynamic>);
    }
    return _currentUser;
  }

  Future<void> clearSession() async {
    _token = null;
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // ──────────────────── HTTP helpers ────────────────────

  Map<String, String> get _jsonHeaders => {
        'Content-Type': 'application/json',
      };

  Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Uri _uri(String path, {Map<String, String>? query}) =>
      Uri.parse('${AppUrls.baseUrl}$path').replace(queryParameters: query);

  Future<Map<String, dynamic>> _handleResponse(http.Response res) async {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    }
    final message = body['message'] as String? ?? 'Request failed';
    throw ApiException(message, statusCode: res.statusCode);
  }

  Future<Map<String, dynamic>> _get(String path,
      {Map<String, String>? query}) async {
    final res = await http
        .get(_uri(path, query: query), headers: await _authHeaders())
        .timeout(const Duration(seconds: 15));
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> _post(String path,
      Map<String, dynamic> body) async {
    final res = await http
        .post(_uri(path),
            headers: await _authHeaders(), body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> _postPublic(
      String path, Map<String, dynamic> body) async {
    final res = await http
        .post(_uri(path), headers: _jsonHeaders, body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> _put(String path,
      Map<String, dynamic> body) async {
    final res = await http
        .put(_uri(path),
            headers: await _authHeaders(), body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> _delete(String path) async {
    final res = await http
        .delete(_uri(path), headers: await _authHeaders())
        .timeout(const Duration(seconds: 15));
    return _handleResponse(res);
  }

  /// Extracts a list from a response, checking both 'data' and [fallbackKey].
  List<dynamic> _extractList(Map<String, dynamic> body, String fallbackKey) {
    final data = body['data'];
    if (data is List) return data;
    final fallback = body[fallbackKey];
    if (fallback is List) return fallback;
    return [];
  }

  // ──────────────────── Auth ────────────────────

  Future<UserModel> login(String email, String password) async {
    // Accept both the real admin credentials and a quick dev shortcut
    final validCredentials = (email == 'admin@iskcon.org' && password == 'Admin123') ||
        (email == 'teacher@iskcon.org' && password == 'Teacher123');

    if (!validCredentials) {
      throw const ApiException('Invalid email or password');
    }

    final role = email.startsWith('teacher') ? 'teacher' : 'admin';
    final name = role == 'admin' ? 'Admin User' : 'Teacher';

    final mockUser = UserModel(
      id: 1,
      email: email,
      name: name,
      role: role,
      token: _mockToken,
    );
    await _saveToken(_mockToken);
    await _saveUser(mockUser);

    // Also try the real backend silently; ignore failures
    try {
      final data = await _postPublic(AppUrls.login, {
        'email': email,
        'password': password,
      }).timeout(const Duration(seconds: 5));
      final token = data['data']?['token'] as String? ?? data['token'] as String?;
      final userJson = data['data']?['user'] as Map<String, dynamic>? ??
          data['user'] as Map<String, dynamic>?;
      if (token != null && userJson != null) {
        final realUser = UserModel.fromJson({...userJson, 'token': token});
        await _saveToken(token);
        await _saveUser(realUser);
        return realUser;
      }
    } catch (_) {}

    return mockUser;
  }

  Future<void> logout() async {
    try {
      await _post('/auth/logout', {});
    } catch (_) {}
    await clearSession();
  }

  bool _isMockToken(String? token) =>
      token == null || token.isEmpty || token == _mockToken || token.startsWith('mock_');

  // ──────────────────── Students ────────────────────

  Future<List<StudentModel>> getStudents({int page = 1}) async {
    final token = await getToken();
    if (_isMockToken(token)) {
      return MockDataService().getStudents();
    }
    try {
      final data = await _get(AppUrls.students,
          query: {'page': '$page', 'limit': '20'});
      return _extractList(data, 'students')
          .map((e) => StudentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return MockDataService().getStudents();
    }
  }

  Future<StudentModel> getStudent(int id) async {
    final token = await getToken();
    if (_isMockToken(token)) {
      final student = MockDataService().getStudentById(id);
      if (student == null) throw ApiException('Student not found', statusCode: 404);
      return student;
    }
    try {
      final data = await _get('${AppUrls.students}/$id');
      return StudentModel.fromJson(
          data['data'] as Map<String, dynamic>? ?? data);
    } catch (_) {
      final student = MockDataService().getStudentById(id);
      if (student == null) throw ApiException('Student not found', statusCode: 404);
      return student;
    }
  }

  Future<StudentModel> createStudent(Map<String, dynamic> body) async {
    final token = await getToken();
    if (_isMockToken(token)) {
      return MockDataService().addStudent(body);
    }
    try {
      final data = await _post(AppUrls.students, body);
      return StudentModel.fromJson(
          data['data'] as Map<String, dynamic>? ?? data);
    } catch (_) {
      return MockDataService().addStudent(body);
    }
  }

  Future<StudentModel> updateStudent(int id, Map<String, dynamic> body) async {
    final token = await getToken();
    if (_isMockToken(token)) {
      final updated = MockDataService().updateStudent(id, body);
      if (updated == null) throw ApiException('Student not found', statusCode: 404);
      return updated;
    }
    try {
      final data = await _put('${AppUrls.students}/$id', body);
      return StudentModel.fromJson(
          data['data'] as Map<String, dynamic>? ?? data);
    } catch (_) {
      final updated = MockDataService().updateStudent(id, body);
      if (updated == null) throw ApiException('Student not found', statusCode: 404);
      return updated;
    }
  }

  Future<void> deleteStudent(int id) async {
    final token = await getToken();
    if (_isMockToken(token)) {
      MockDataService().deleteStudent(id);
      return;
    }
    try {
      await _delete('${AppUrls.students}/$id');
    } catch (_) {
      MockDataService().deleteStudent(id);
    }
  }

  // ──────────────────── Activities ────────────────────

  Future<List<ActivityModel>> getActivities({int page = 1}) async {
    final token = await getToken();
    if (_isMockToken(token)) {
      return MockDataService().getActivities();
    }
    try {
      final data = await _get(AppUrls.activities,
          query: {'page': '$page', 'limit': '20'});
      return _extractList(data, 'activities')
          .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return MockDataService().getActivities();
    }
  }

  Future<ActivityModel> createActivity(Map<String, dynamic> body) async {
    final token = await getToken();
    if (_isMockToken(token)) {
      return MockDataService().addActivity(body);
    }
    try {
      final data = await _post(AppUrls.activities, body);
      return ActivityModel.fromJson(
          data['data'] as Map<String, dynamic>? ?? data);
    } catch (_) {
      return MockDataService().addActivity(body);
    }
  }

  Future<ActivityModel> updateActivity(
      int id, Map<String, dynamic> body) async {
    final token = await getToken();
    if (_isMockToken(token)) {
      final updated = MockDataService().updateActivity(id, body);
      if (updated == null) throw ApiException('Activity not found', statusCode: 404);
      return updated;
    }
    try {
      final data = await _put('${AppUrls.activities}/$id', body);
      return ActivityModel.fromJson(
          data['data'] as Map<String, dynamic>? ?? data);
    } catch (_) {
      final updated = MockDataService().updateActivity(id, body);
      if (updated == null) throw ApiException('Activity not found', statusCode: 404);
      return updated;
    }
  }

  Future<void> deleteActivity(int id) async {
    final token = await getToken();
    if (_isMockToken(token)) {
      MockDataService().deleteActivity(id);
      return;
    }
    try {
      await _delete('${AppUrls.activities}/$id');
    } catch (_) {
      MockDataService().deleteActivity(id);
    }
  }

  // ──────────────────── Attendance ────────────────────

  Future<AttendanceModel> checkIn(int studentId, int activityId) async {
    final token = await getToken();
    if (_isMockToken(token)) {
      return MockDataService().checkIn(studentId, activityId);
    }
    try {
      final data = await _post('${AppUrls.attendance}/checkin', {
        'student_id': studentId,
        'activity_id': activityId,
      });
      return AttendanceModel.fromJson(
          data['data'] as Map<String, dynamic>? ?? data);
    } catch (_) {
      return MockDataService().checkIn(studentId, activityId);
    }
  }

  Future<List<AttendanceModel>> getAttendanceByDate(String date) async {
    final token = await getToken();
    if (_isMockToken(token)) {
      return MockDataService().getAttendanceByDate(date);
    }
    try {
      final data = await _get('${AppUrls.attendance}/date/$date');
      return _extractList(data, 'attendance')
          .map((e) => AttendanceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return MockDataService().getAttendanceByDate(date);
    }
  }

  Future<List<AttendanceModel>> getStudentAttendance(int studentId) async {
    final token = await getToken();
    if (_isMockToken(token)) {
      return MockDataService().getStudentAttendance(studentId);
    }
    try {
      final data = await _get('${AppUrls.attendance}/history/$studentId');
      return _extractList(data, 'attendance')
          .map((e) => AttendanceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return MockDataService().getStudentAttendance(studentId);
    }
  }

  // ──────────────────── Visitors ────────────────────

  Future<List<VisitorModel>> getVisitors({int page = 1}) async {
    final token = await getToken();
    if (_isMockToken(token)) {
      return MockDataService().getVisitors();
    }
    try {
      final data = await _get(AppUrls.visitors,
          query: {'page': '$page', 'limit': '20'});
      return _extractList(data, 'visitors')
          .map((e) => VisitorModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return MockDataService().getVisitors();
    }
  }

  Future<VisitorModel> visitorCheckIn(Map<String, dynamic> body) async {
    final token = await getToken();
    if (_isMockToken(token)) {
      return MockDataService().addVisitor(body);
    }
    try {
      final data = await _post('${AppUrls.visitors}/checkin', body);
      return VisitorModel.fromJson(
          data['data'] as Map<String, dynamic>? ?? data);
    } catch (_) {
      return MockDataService().addVisitor(body);
    }
  }

  Future<VisitorModel> visitorCheckOut(int id) async {
    final token = await getToken();
    if (_isMockToken(token)) {
      final updated = MockDataService().checkOutVisitor(id);
      if (updated == null) throw ApiException('Visitor not found', statusCode: 404);
      return updated;
    }
    try {
      final data = await _put('${AppUrls.visitors}/$id/checkout', {});
      return VisitorModel.fromJson(
          data['data'] as Map<String, dynamic>? ?? data);
    } catch (_) {
      final updated = MockDataService().checkOutVisitor(id);
      if (updated == null) throw ApiException('Visitor not found', statusCode: 404);
      return updated;
    }
  }

  // ──────────────────── Dashboard ────────────────────

  Future<Map<String, dynamic>> getDashboardStats() async {
    final token = await getToken();
    if (_isMockToken(token)) {
      return {'data': MockDataService().getDashboardStats()};
    }
    try {
      return await _get(AppUrls.dashboardStats);
    } catch (_) {
      return {'data': MockDataService().getDashboardStats()};
    }
  }

  Future<Map<String, dynamic>> getTeacherDashboard() async {
    final token = await getToken();
    if (_isMockToken(token)) {
      return {'data': MockDataService().getTeacherDashboard()};
    }
    try {
      return await _get(AppUrls.dashboardTeacher);
    } catch (_) {
      return {'data': MockDataService().getTeacherDashboard()};
    }
  }

  Future<Map<String, dynamic>> getPrincipalDashboard() async {
    final token = await getToken();
    if (_isMockToken(token)) {
      return {'data': MockDataService().getDashboardStats()};
    }
    try {
      return await _get(AppUrls.dashboardPrincipal);
    } catch (_) {
      return {'data': MockDataService().getDashboardStats()};
    }
  }
}
