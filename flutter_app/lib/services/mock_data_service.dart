import '../models/student_model.dart';
import '../models/activity_model.dart';
import '../models/attendance_model.dart';
import '../models/visitor_model.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  // ──────────────────── Students ────────────────────

  final List<StudentModel> _students = [
    StudentModel(
      id: 1,
      name: 'Arjun Sharma',
      email: 'arjun@iskcon.org',
      phone: '9876543210',
      parentName: 'Ramesh Sharma',
      parentPhone: '9876543200',
      dateOfBirth: '2010-05-15',
      address: '12 Vrindavan Nagar, Delhi',
      createdAt: '2024-01-01T10:00:00Z',
    ),
    StudentModel(
      id: 2,
      name: 'Radha Patel',
      email: 'radha@iskcon.org',
      phone: '9876543211',
      parentName: 'Suresh Patel',
      parentPhone: '9876543201',
      dateOfBirth: '2011-08-22',
      address: '45 Krishna Colony, Mumbai',
      createdAt: '2024-01-02T10:00:00Z',
    ),
    StudentModel(
      id: 3,
      name: 'Krishna Kumar',
      email: 'krishna@iskcon.org',
      phone: '9876543212',
      parentName: 'Mahesh Kumar',
      parentPhone: '9876543202',
      dateOfBirth: '2009-12-10',
      address: '78 Govinda Street, Bangalore',
      createdAt: '2024-01-03T10:00:00Z',
    ),
    StudentModel(
      id: 4,
      name: 'Priya Nair',
      email: 'priya@iskcon.org',
      phone: '9876543213',
      parentName: 'Vijay Nair',
      parentPhone: '9876543203',
      dateOfBirth: '2012-03-18',
      address: '23 Tulsi Park, Chennai',
      createdAt: '2024-01-04T10:00:00Z',
    ),
    StudentModel(
      id: 5,
      name: 'Govind Mishra',
      email: 'govind@iskcon.org',
      phone: '9876543214',
      parentName: 'Ravi Mishra',
      parentPhone: '9876543204',
      dateOfBirth: '2010-11-25',
      address: '56 Mathura Road, Vrindavan',
      createdAt: '2024-01-05T10:00:00Z',
    ),
    StudentModel(
      id: 6,
      name: 'Meera Iyer',
      email: 'meera@iskcon.org',
      phone: '9876543215',
      parentName: 'Suresh Iyer',
      parentPhone: '9876543205',
      dateOfBirth: '2011-07-04',
      address: '90 Gopinath Lane, Hyderabad',
      createdAt: '2024-01-06T10:00:00Z',
    ),
    StudentModel(
      id: 7,
      name: 'Balaram Singh',
      email: 'balaram@iskcon.org',
      phone: '9876543216',
      parentName: 'Hari Singh',
      parentPhone: '9876543206',
      dateOfBirth: '2009-09-01',
      address: '34 Madhav Street, Kolkata',
      createdAt: '2024-01-07T10:00:00Z',
    ),
    StudentModel(
      id: 8,
      name: 'Yamuna Devi',
      email: 'yamuna@iskcon.org',
      phone: '9876543217',
      parentName: 'Narayan Devi',
      parentPhone: '9876543207',
      dateOfBirth: '2012-01-14',
      address: '67 Ganga Nagar, Haridwar',
      createdAt: '2024-01-08T10:00:00Z',
    ),
  ];

  int _nextStudentId = 9;

  List<StudentModel> getStudents() => List.unmodifiable(_students);

  StudentModel? getStudentById(int id) {
    try {
      return _students.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  StudentModel addStudent(Map<String, dynamic> data) {
    final student = StudentModel(
      id: _nextStudentId++,
      name: data['name'] as String,
      email: data['email'] as String?,
      phone: data['phone'] as String?,
      parentName: data['parent_name'] as String?,
      parentPhone: data['parent_phone'] as String?,
      dateOfBirth: data['date_of_birth'] as String?,
      address: data['address'] as String?,
      createdAt: DateTime.now().toIso8601String(),
    );
    _students.add(student);
    return student;
  }

  StudentModel? updateStudent(int id, Map<String, dynamic> data) {
    final index = _students.indexWhere((s) => s.id == id);
    if (index == -1) return null;
    final existing = _students[index];
    final updated = StudentModel(
      id: existing.id,
      name: data['name'] as String? ?? existing.name,
      email: data['email'] as String? ?? existing.email,
      phone: data['phone'] as String? ?? existing.phone,
      parentName: data['parent_name'] as String? ?? existing.parentName,
      parentPhone: data['parent_phone'] as String? ?? existing.parentPhone,
      dateOfBirth: data['date_of_birth'] as String? ?? existing.dateOfBirth,
      address: data['address'] as String? ?? existing.address,
      createdAt: existing.createdAt,
    );
    _students[index] = updated;
    return updated;
  }

  bool deleteStudent(int id) {
    final index = _students.indexWhere((s) => s.id == id);
    if (index == -1) return false;
    _students.removeAt(index);
    return true;
  }

  // ──────────────────── Activities ────────────────────

  final List<ActivityModel> _activities = [
    ActivityModel(
      id: 1,
      name: 'Bhagavad Gita Class',
      description: 'Study of Bhagavad Gita with commentary',
      schedule: 'Mon, Wed, Fri - 6:00 AM',
      teacher: 'HH Radhanath Swami',
      capacity: 30,
      ageGroup: '10-18',
      createdAt: '2024-01-01T10:00:00Z',
    ),
    ActivityModel(
      id: 2,
      name: 'Kirtan & Bhajan',
      description: 'Devotional singing and chanting',
      schedule: 'Daily - 5:30 AM',
      teacher: 'Prabhu Nityananda Das',
      capacity: 50,
      ageGroup: 'All',
      createdAt: '2024-01-01T10:00:00Z',
    ),
    ActivityModel(
      id: 3,
      name: 'Deity Worship (Puja)',
      description: 'Learning deity worship rituals and procedures',
      schedule: 'Tue, Thu - 7:00 AM',
      teacher: 'Mataji Bhakti Devi',
      capacity: 15,
      ageGroup: '12+',
      createdAt: '2024-01-01T10:00:00Z',
    ),
    ActivityModel(
      id: 4,
      name: 'Vedic Cooking',
      description: 'Cooking prasadam following Vedic traditions',
      schedule: 'Saturday - 9:00 AM',
      teacher: 'Mataji Tulsi Devi',
      capacity: 20,
      ageGroup: '14+',
      createdAt: '2024-01-01T10:00:00Z',
    ),
    ActivityModel(
      id: 5,
      name: 'Sanskrit Study',
      description: 'Introduction to Sanskrit language and Vedic texts',
      schedule: 'Mon, Thu - 4:00 PM',
      teacher: 'Prabhu Gopal Das',
      capacity: 25,
      ageGroup: '12-18',
      createdAt: '2024-01-01T10:00:00Z',
    ),
    ActivityModel(
      id: 6,
      name: 'Drama & Cultural Arts',
      description: 'Performances based on Vedic epics and stories',
      schedule: 'Sunday - 3:00 PM',
      teacher: 'Mataji Saraswati Devi',
      capacity: 40,
      ageGroup: '8-18',
      createdAt: '2024-01-01T10:00:00Z',
    ),
  ];

  int _nextActivityId = 7;

  List<ActivityModel> getActivities() => List.unmodifiable(_activities);

  ActivityModel? getActivityById(int id) {
    try {
      return _activities.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  ActivityModel addActivity(Map<String, dynamic> data) {
    final activity = ActivityModel(
      id: _nextActivityId++,
      name: data['name'] as String,
      description: data['description'] as String?,
      schedule: data['schedule'] as String?,
      teacher: data['teacher'] as String?,
      capacity: data['capacity'] as int?,
      ageGroup: data['age_group'] as String?,
      createdAt: DateTime.now().toIso8601String(),
    );
    _activities.add(activity);
    return activity;
  }

  ActivityModel? updateActivity(int id, Map<String, dynamic> data) {
    final index = _activities.indexWhere((a) => a.id == id);
    if (index == -1) return null;
    final existing = _activities[index];
    final updated = ActivityModel(
      id: existing.id,
      name: data['name'] as String? ?? existing.name,
      description: data['description'] as String? ?? existing.description,
      schedule: data['schedule'] as String? ?? existing.schedule,
      teacher: data['teacher'] as String? ?? existing.teacher,
      capacity: data['capacity'] as int? ?? existing.capacity,
      ageGroup: data['age_group'] as String? ?? existing.ageGroup,
      createdAt: existing.createdAt,
    );
    _activities[index] = updated;
    return updated;
  }

  bool deleteActivity(int id) {
    final index = _activities.indexWhere((a) => a.id == id);
    if (index == -1) return false;
    _activities.removeAt(index);
    return true;
  }

  // ──────────────────── Attendance ────────────────────

  final List<AttendanceModel> _attendance = [
    AttendanceModel(
      id: 1,
      studentId: 1,
      activityId: 1,
      studentName: 'Arjun Sharma',
      activityName: 'Bhagavad Gita Class',
      checkInTime: '${_todayDate()}T06:05:00Z',
      checkOutTime: '${_todayDate()}T07:30:00Z',
      createdAt: '${_todayDate()}T06:05:00Z',
    ),
    AttendanceModel(
      id: 2,
      studentId: 2,
      activityId: 1,
      studentName: 'Radha Patel',
      activityName: 'Bhagavad Gita Class',
      checkInTime: '${_todayDate()}T06:10:00Z',
      checkOutTime: null,
      createdAt: '${_todayDate()}T06:10:00Z',
    ),
    AttendanceModel(
      id: 3,
      studentId: 3,
      activityId: 2,
      studentName: 'Krishna Kumar',
      activityName: 'Kirtan & Bhajan',
      checkInTime: '${_todayDate()}T05:35:00Z',
      checkOutTime: '${_todayDate()}T07:00:00Z',
      createdAt: '${_todayDate()}T05:35:00Z',
    ),
    AttendanceModel(
      id: 4,
      studentId: 4,
      activityId: 2,
      studentName: 'Priya Nair',
      activityName: 'Kirtan & Bhajan',
      checkInTime: '${_todayDate()}T05:40:00Z',
      checkOutTime: null,
      createdAt: '${_todayDate()}T05:40:00Z',
    ),
    AttendanceModel(
      id: 5,
      studentId: 5,
      activityId: 3,
      studentName: 'Govind Mishra',
      activityName: 'Deity Worship (Puja)',
      checkInTime: '${_todayDate()}T07:05:00Z',
      checkOutTime: null,
      createdAt: '${_todayDate()}T07:05:00Z',
    ),
  ];

  int _nextAttendanceId = 6;

  static String _todayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  List<AttendanceModel> getAttendanceByDate(String date) {
    return _attendance
        .where((a) => a.checkInTime != null && a.checkInTime!.startsWith(date))
        .toList();
  }

  List<AttendanceModel> getStudentAttendance(int studentId) {
    return _attendance.where((a) => a.studentId == studentId).toList();
  }

  AttendanceModel checkIn(int studentId, int activityId) {
    final student = getStudentById(studentId);
    final activity = getActivityById(activityId);
    final record = AttendanceModel(
      id: _nextAttendanceId++,
      studentId: studentId,
      activityId: activityId,
      studentName: student?.name,
      activityName: activity?.name,
      checkInTime: DateTime.now().toUtc().toIso8601String(),
      checkOutTime: null,
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );
    _attendance.add(record);
    return record;
  }

  AttendanceModel? checkOut(int attendanceId) {
    final index = _attendance.indexWhere((a) => a.id == attendanceId);
    if (index == -1) return null;
    final existing = _attendance[index];
    final updated = AttendanceModel(
      id: existing.id,
      studentId: existing.studentId,
      activityId: existing.activityId,
      studentName: existing.studentName,
      activityName: existing.activityName,
      checkInTime: existing.checkInTime,
      checkOutTime: DateTime.now().toUtc().toIso8601String(),
      createdAt: existing.createdAt,
    );
    _attendance[index] = updated;
    return updated;
  }

  // ──────────────────── Visitors ────────────────────

  final List<VisitorModel> _visitors = [
    VisitorModel(
      id: 1,
      visitorName: 'Ramesh Gupta',
      visitorPhone: '9123456789',
      visitReason: 'Parent meeting - Arjun Sharma',
      studentName: 'Arjun Sharma',
      checkInTime: '${_todayDate()}T10:00:00Z',
      checkOutTime: '${_todayDate()}T11:00:00Z',
      createdAt: '${_todayDate()}T10:00:00Z',
    ),
    VisitorModel(
      id: 2,
      visitorName: 'Sita Devi',
      visitorPhone: '9123456790',
      visitReason: 'Devotee visit for seva',
      studentName: null,
      checkInTime: '${_todayDate()}T11:30:00Z',
      checkOutTime: null,
      createdAt: '${_todayDate()}T11:30:00Z',
    ),
    VisitorModel(
      id: 3,
      visitorName: 'Bhakta Prahlad',
      visitorPhone: '9123456791',
      visitReason: 'New student inquiry',
      studentName: null,
      checkInTime: '${_todayDate()}T14:00:00Z',
      checkOutTime: null,
      createdAt: '${_todayDate()}T14:00:00Z',
    ),
  ];

  int _nextVisitorId = 4;

  List<VisitorModel> getVisitors() => List.unmodifiable(_visitors);

  VisitorModel addVisitor(Map<String, dynamic> data) {
    final visitor = VisitorModel(
      id: _nextVisitorId++,
      visitorName: data['visitor_name'] as String,
      visitorPhone: data['visitor_phone'] as String?,
      visitReason: data['visit_reason'] as String?,
      studentName: data['student_name'] as String?,
      checkInTime: DateTime.now().toUtc().toIso8601String(),
      checkOutTime: null,
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );
    _visitors.add(visitor);
    return visitor;
  }

  VisitorModel? checkOutVisitor(int id) {
    final index = _visitors.indexWhere((v) => v.id == id);
    if (index == -1) return null;
    final existing = _visitors[index];
    final updated = VisitorModel(
      id: existing.id,
      visitorName: existing.visitorName,
      visitorPhone: existing.visitorPhone,
      visitReason: existing.visitReason,
      studentName: existing.studentName,
      checkInTime: existing.checkInTime,
      checkOutTime: DateTime.now().toUtc().toIso8601String(),
      createdAt: existing.createdAt,
    );
    _visitors[index] = updated;
    return updated;
  }

  // ──────────────────── Dashboard Stats ────────────────────

  Map<String, dynamic> getDashboardStats() {
    final today = _todayDate();
    final todayAttendance =
        _attendance.where((a) => a.checkInTime?.startsWith(today) ?? false).length;
    final activeVisitors = _visitors
        .where((v) => v.checkInTime?.startsWith(today) ?? false)
        .length;
    return {
      'total_students': _students.length,
      'total_activities': _activities.length,
      'today_attendance': todayAttendance,
      'today_visitors': activeVisitors,
    };
  }

  Map<String, dynamic> getTeacherDashboard() {
    final today = _todayDate();
    final todayCount =
        _attendance.where((a) => a.checkInTime?.startsWith(today) ?? false).length;
    return {
      'today_attendance': todayCount,
      'my_students': _students.length,
      'my_activities': _activities.length,
    };
  }
}
