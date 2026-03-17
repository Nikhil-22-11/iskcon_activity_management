import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/student_model.dart';
import '../models/activity_model.dart';
import '../models/attendance_model.dart';
import '../models/visitor_model.dart';
import '../utils/constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
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
    final data = await _postPublic(AppUrls.login, {
      'email': email,
      'password': password,
    });
    final token = data['token'] as String;
    final userJson = data['user'] as Map<String, dynamic>;
    final user = UserModel.fromJson({...userJson, 'token': token});
    await _saveToken(token);
    await _saveUser(user);
    return user;
  }

  Future<void> logout() async {
    try {
      await _post('/auth/logout', {});
    } catch (_) {}
    await clearSession();
  }

  // ──────────────────── Students ────────────────────

  Future<List<StudentModel>> getStudents({int page = 1}) async {
    final data = await _get(AppUrls.students,
        query: {'page': '$page', 'limit': '20'});
    return _extractList(data, 'students')
        .map((e) => StudentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<StudentModel> getStudent(int id) async {
    final data = await _get('${AppUrls.students}/$id');
    return StudentModel.fromJson(data['data'] as Map<String, dynamic>? ?? data);
  }

  Future<StudentModel> createStudent(Map<String, dynamic> body) async {
    final data = await _post(AppUrls.students, body);
    return StudentModel.fromJson(data['data'] as Map<String, dynamic>? ?? data);
  }

  Future<StudentModel> updateStudent(int id, Map<String, dynamic> body) async {
    final data = await _put('${AppUrls.students}/$id', body);
    return StudentModel.fromJson(data['data'] as Map<String, dynamic>? ?? data);
  }

  Future<void> deleteStudent(int id) async {
    await _delete('${AppUrls.students}/$id');
  }

  // ──────────────────── Activities ────────────────────

  Future<List<ActivityModel>> getActivities({int page = 1}) async {
    final data = await _get(AppUrls.activities,
        query: {'page': '$page', 'limit': '20'});
    return _extractList(data, 'activities')
        .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ActivityModel> createActivity(Map<String, dynamic> body) async {
    final data = await _post(AppUrls.activities, body);
    return ActivityModel.fromJson(
        data['data'] as Map<String, dynamic>? ?? data);
  }

  Future<ActivityModel> updateActivity(
      int id, Map<String, dynamic> body) async {
    final data = await _put('${AppUrls.activities}/$id', body);
    return ActivityModel.fromJson(
        data['data'] as Map<String, dynamic>? ?? data);
  }

  Future<void> deleteActivity(int id) async {
    await _delete('${AppUrls.activities}/$id');
  }

  // ──────────────────── Attendance ────────────────────

  Future<AttendanceModel> checkIn(
      int studentId, int activityId) async {
    final data = await _post('${AppUrls.attendance}/checkin', {
      'student_id': studentId,
      'activity_id': activityId,
    });
    return AttendanceModel.fromJson(
        data['data'] as Map<String, dynamic>? ?? data);
  }

  Future<List<AttendanceModel>> getAttendanceByDate(String date) async {
    final data = await _get('${AppUrls.attendance}/date/$date');
    return _extractList(data, 'attendance')
        .map((e) => AttendanceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<AttendanceModel>> getStudentAttendance(int studentId) async {
    final data =
        await _get('${AppUrls.attendance}/history/$studentId');
    return _extractList(data, 'attendance')
        .map((e) => AttendanceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ──────────────────── Visitors ────────────────────

  Future<List<VisitorModel>> getVisitors({int page = 1}) async {
    final data = await _get(AppUrls.visitors,
        query: {'page': '$page', 'limit': '20'});
    return _extractList(data, 'visitors')
        .map((e) => VisitorModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<VisitorModel> visitorCheckIn(Map<String, dynamic> body) async {
    final data = await _post('${AppUrls.visitors}/checkin', body);
    return VisitorModel.fromJson(data['data'] as Map<String, dynamic>? ?? data);
  }

  Future<VisitorModel> visitorCheckOut(int id) async {
    final data = await _put('${AppUrls.visitors}/$id/checkout', {});
    return VisitorModel.fromJson(data['data'] as Map<String, dynamic>? ?? data);
  }

  // ──────────────────── Dashboard ────────────────────

  Future<Map<String, dynamic>> getDashboardStats() async {
    return _get(AppUrls.dashboardStats);
  }

  Future<Map<String, dynamic>> getTeacherDashboard() async {
    return _get(AppUrls.dashboardTeacher);
  }

  Future<Map<String, dynamic>> getPrincipalDashboard() async {
    return _get(AppUrls.dashboardPrincipal);
  }
}
