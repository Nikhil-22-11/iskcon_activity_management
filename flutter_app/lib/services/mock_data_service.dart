import '../models/student_model.dart';
import '../models/activity_model.dart';
import '../models/attendance_model.dart';
import '../models/visitor_model.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  // ──────────────────── Students (20+) ────────────────────

  final List<StudentModel> _students = [
    StudentModel(id: 1, name: 'Arjun Sharma', email: 'arjun@iskcon.org', phone: '9876543210', parentName: 'Ramesh Sharma', parentPhone: '9876543200', dateOfBirth: '2010-05-15', address: '12 Vrindavan Nagar, Delhi', createdAt: '2024-01-01T10:00:00Z'),
    StudentModel(id: 2, name: 'Radha Patel', email: 'radha@iskcon.org', phone: '9876543211', parentName: 'Suresh Patel', parentPhone: '9876543201', dateOfBirth: '2011-08-22', address: '45 Krishna Colony, Mumbai', createdAt: '2024-01-02T10:00:00Z'),
    StudentModel(id: 3, name: 'Krishna Kumar', email: 'krishna@iskcon.org', phone: '9876543212', parentName: 'Mahesh Kumar', parentPhone: '9876543202', dateOfBirth: '2009-12-10', address: '78 Govinda Street, Bangalore', createdAt: '2024-01-03T10:00:00Z'),
    StudentModel(id: 4, name: 'Priya Nair', email: 'priya@iskcon.org', phone: '9876543213', parentName: 'Vijay Nair', parentPhone: '9876543203', dateOfBirth: '2012-03-18', address: '23 Tulsi Park, Chennai', createdAt: '2024-01-04T10:00:00Z'),
    StudentModel(id: 5, name: 'Govind Mishra', email: 'govind@iskcon.org', phone: '9876543214', parentName: 'Ravi Mishra', parentPhone: '9876543204', dateOfBirth: '2010-11-25', address: '56 Mathura Road, Vrindavan', createdAt: '2024-01-05T10:00:00Z'),
    StudentModel(id: 6, name: 'Meera Iyer', email: 'meera@iskcon.org', phone: '9876543215', parentName: 'Suresh Iyer', parentPhone: '9876543205', dateOfBirth: '2011-07-04', address: '90 Gopinath Lane, Hyderabad', createdAt: '2024-01-06T10:00:00Z'),
    StudentModel(id: 7, name: 'Balaram Singh', email: 'balaram@iskcon.org', phone: '9876543216', parentName: 'Hari Singh', parentPhone: '9876543206', dateOfBirth: '2009-09-01', address: '34 Madhav Street, Kolkata', createdAt: '2024-01-07T10:00:00Z'),
    StudentModel(id: 8, name: 'Yamuna Devi', email: 'yamuna@iskcon.org', phone: '9876543217', parentName: 'Narayan Devi', parentPhone: '9876543207', dateOfBirth: '2012-01-14', address: '67 Ganga Nagar, Haridwar', createdAt: '2024-01-08T10:00:00Z'),
    StudentModel(id: 9, name: 'Tulsi Das', email: 'tulsi@iskcon.org', phone: '9876543218', parentName: 'Ram Das', parentPhone: '9876543208', dateOfBirth: '2010-06-20', address: '11 Nandgaon, Mathura', createdAt: '2024-01-09T10:00:00Z'),
    StudentModel(id: 10, name: 'Gopi Krishnan', email: 'gopi@iskcon.org', phone: '9876543219', parentName: 'Hari Krishnan', parentPhone: '9876543209', dateOfBirth: '2013-02-28', address: '22 Puri Road, Odisha', createdAt: '2024-01-10T10:00:00Z'),
    StudentModel(id: 11, name: 'Sita Ram', email: 'sita@iskcon.org', phone: '9876543220', parentName: 'Laxman Ram', parentPhone: '9876543220', dateOfBirth: '2011-09-15', address: '33 Ayodhya Lane, UP', createdAt: '2024-01-11T10:00:00Z'),
    StudentModel(id: 12, name: 'Draupadi Mehta', email: 'draupadi@iskcon.org', phone: '9876543221', parentName: 'Drupada Mehta', parentPhone: '9876543221', dateOfBirth: '2012-11-05', address: '44 Dwarka Nagar, Gujarat', createdAt: '2024-01-12T10:00:00Z'),
    StudentModel(id: 13, name: 'Hanuman Prasad', email: 'hanuman@iskcon.org', phone: '9876543222', parentName: 'Bharat Prasad', parentPhone: '9876543222', dateOfBirth: '2009-07-12', address: '55 Kishkindha Colony, Karnataka', createdAt: '2024-01-13T10:00:00Z'),
    StudentModel(id: 14, name: 'Rukmini Desai', email: 'rukmini@iskcon.org', phone: '9876543223', parentName: 'Vidarbha Desai', parentPhone: '9876543223', dateOfBirth: '2010-04-07', address: '66 Dwaraka Street, Gujarat', createdAt: '2024-01-14T10:00:00Z'),
    StudentModel(id: 15, name: 'Subhadra Rao', email: 'subhadra@iskcon.org', phone: '9876543224', parentName: 'Vasudeva Rao', parentPhone: '9876543224', dateOfBirth: '2011-03-22', address: '77 Panchavati, Nashik', createdAt: '2024-01-15T10:00:00Z'),
    StudentModel(id: 16, name: 'Narada Muni', email: 'narada@iskcon.org', phone: '9876543225', parentName: 'Brahma Muni', parentPhone: '9876543225', dateOfBirth: '2012-08-11', address: '88 Vaikuntha Nagar, Tirupati', createdAt: '2024-01-16T10:00:00Z'),
    StudentModel(id: 17, name: 'Lakshmi Nair', email: 'lakshmi@iskcon.org', phone: '9876543226', parentName: 'Vishnu Nair', parentPhone: '9876543226', dateOfBirth: '2013-01-30', address: '99 Guruvayur Road, Kerala', createdAt: '2024-01-17T10:00:00Z'),
    StudentModel(id: 18, name: 'Dharma Raj', email: 'dharma@iskcon.org', phone: '9876543227', parentName: 'Yudhishthira Raj', parentPhone: '9876543227', dateOfBirth: '2010-10-09', address: '101 Indraprastha, Delhi', createdAt: '2024-01-18T10:00:00Z'),
    StudentModel(id: 19, name: 'Sudarshana Das', email: 'sudarshana@iskcon.org', phone: '9876543228', parentName: 'Chakra Das', parentPhone: '9876543228', dateOfBirth: '2011-05-17', address: '112 Naimisharanya, UP', createdAt: '2024-01-19T10:00:00Z'),
    StudentModel(id: 20, name: 'Vrinda Kumari', email: 'vrinda@iskcon.org', phone: '9876543229', parentName: 'Tulasi Kumari', parentPhone: '9876543229', dateOfBirth: '2012-07-25', address: '123 Vrindavan Dham, UP', createdAt: '2024-01-20T10:00:00Z'),
    StudentModel(id: 21, name: 'Madhava Rao', email: 'madhava@iskcon.org', phone: '9876543230', parentName: 'Keshava Rao', parentPhone: '9876543230', dateOfBirth: '2009-11-03', address: '134 Udupi Math, Karnataka', createdAt: '2024-01-21T10:00:00Z'),
    StudentModel(id: 22, name: 'Satyabhama Singh', email: 'satyabhama@iskcon.org', phone: '9876543231', parentName: 'Satrajit Singh', parentPhone: '9876543231', dateOfBirth: '2010-12-19', address: '145 Dwaraka, Gujarat', createdAt: '2024-01-22T10:00:00Z'),
  ];

  int _nextStudentId = 23;

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
      name: 'Swimming',
      description: 'Swimming training and water safety',
      schedule: 'Mon, Wed, Fri - 7:00 AM',
      teacher: 'Coach Mahesh',
      capacity: 20,
      ageGroup: '8+',
      createdAt: '2024-01-01T10:00:00Z',
    ),
    ActivityModel(
      id: 2,
      name: 'Yoga',
      description: 'Morning yoga and meditation session',
      schedule: 'Daily - 6:00 AM',
      teacher: 'Prabhu Gopal Das',
      capacity: 30,
      ageGroup: 'All',
      createdAt: '2024-01-01T10:00:00Z',
    ),
    ActivityModel(
      id: 3,
      name: 'Self-Defence',
      description: 'Self-defence techniques and martial arts basics',
      schedule: 'Tue, Thu - 4:00 PM',
      teacher: 'Instructor Ravi',
      capacity: 25,
      ageGroup: '10+',
      createdAt: '2024-01-01T10:00:00Z',
    ),
    ActivityModel(
      id: 4,
      name: 'Phonix',
      description: 'Phonics and early reading programme',
      schedule: 'Mon, Wed - 10:00 AM',
      teacher: 'Mataji Tulsi Devi',
      capacity: 20,
      ageGroup: '5-10',
      createdAt: '2024-01-01T10:00:00Z',
    ),
    ActivityModel(
      id: 5,
      name: 'Art & Craft',
      description: 'Creative arts, painting and handicrafts',
      schedule: 'Saturday - 10:00 AM',
      teacher: 'Mataji Saraswati Devi',
      capacity: 25,
      ageGroup: 'All',
      createdAt: '2024-01-01T10:00:00Z',
    ),
    ActivityModel(
      id: 6,
      name: 'Sanskrit',
      description: 'Introduction to Sanskrit language and Vedic texts',
      schedule: 'Mon, Thu - 4:00 PM',
      teacher: 'Prabhu Nityananda Das',
      capacity: 25,
      ageGroup: '12-18',
      createdAt: '2024-01-01T10:00:00Z',
    ),
    ActivityModel(
      id: 7,
      name: 'Speech & Drama',
      description: 'Public speaking, drama and stage performance',
      schedule: 'Sunday - 3:00 PM',
      teacher: 'Mataji Bhakti Devi',
      capacity: 30,
      ageGroup: '8-18',
      createdAt: '2024-01-01T10:00:00Z',
    ),
    ActivityModel(
      id: 8,
      name: 'Indian Culture and Value for Kids',
      description: 'Learning Indian traditions, values and cultural heritage',
      schedule: 'Fri - 3:00 PM',
      teacher: 'HH Radhanath Swami',
      capacity: 40,
      ageGroup: '5-15',
      createdAt: '2024-01-01T10:00:00Z',
    ),
    ActivityModel(
      id: 9,
      name: 'Bharat Natiyam',
      description: 'Classical Indian dance – Bharatanatyam',
      schedule: 'Tue, Sat - 5:00 PM',
      teacher: 'Mataji Radha Devi',
      capacity: 20,
      ageGroup: '6-16',
      createdAt: '2024-01-01T10:00:00Z',
    ),
    ActivityModel(
      id: 10,
      name: 'Music & Movement',
      description: 'Music, rhythm and movement for kids',
      schedule: 'Wed, Fri - 4:30 PM',
      teacher: 'Prabhu Hari Das',
      capacity: 30,
      ageGroup: '4-12',
      createdAt: '2024-01-01T10:00:00Z',
    ),
  ];

  int _nextActivityId = 11;

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
      activityName: 'Swimming',
      checkInTime: '${_todayDate()}T07:05:00Z',
      checkOutTime: '${_todayDate()}T08:00:00Z',
      createdAt: '${_todayDate()}T07:05:00Z',
    ),
    AttendanceModel(
      id: 2,
      studentId: 2,
      activityId: 1,
      studentName: 'Radha Patel',
      activityName: 'Swimming',
      checkInTime: '${_todayDate()}T07:10:00Z',
      checkOutTime: null,
      createdAt: '${_todayDate()}T07:10:00Z',
    ),
    AttendanceModel(
      id: 3,
      studentId: 3,
      activityId: 2,
      studentName: 'Krishna Kumar',
      activityName: 'Yoga',
      checkInTime: '${_todayDate()}T06:05:00Z',
      checkOutTime: '${_todayDate()}T07:00:00Z',
      createdAt: '${_todayDate()}T06:05:00Z',
    ),
    AttendanceModel(
      id: 4,
      studentId: 4,
      activityId: 2,
      studentName: 'Priya Nair',
      activityName: 'Yoga',
      checkInTime: '${_todayDate()}T06:10:00Z',
      checkOutTime: null,
      createdAt: '${_todayDate()}T06:10:00Z',
    ),
    AttendanceModel(
      id: 5,
      studentId: 5,
      activityId: 9,
      studentName: 'Govind Mishra',
      activityName: 'Bharat Natiyam',
      checkInTime: '${_todayDate()}T17:05:00Z',
      checkOutTime: null,
      createdAt: '${_todayDate()}T17:05:00Z',
    ),
    AttendanceModel(
      id: 6,
      studentId: 6,
      activityId: 6,
      studentName: 'Meera Iyer',
      activityName: 'Sanskrit',
      checkInTime: '${_todayDate()}T16:05:00Z',
      checkOutTime: '${_todayDate()}T17:00:00Z',
      createdAt: '${_todayDate()}T16:05:00Z',
    ),
    AttendanceModel(
      id: 7,
      studentId: 7,
      activityId: 5,
      studentName: 'Balaram Singh',
      activityName: 'Art & Craft',
      checkInTime: '${_todayDate()}T10:05:00Z',
      checkOutTime: '${_todayDate()}T11:30:00Z',
      createdAt: '${_todayDate()}T10:05:00Z',
    ),
  ];

  int _nextAttendanceId = 8;

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

  // ──────────────────── Enrollments (students per activity) ────────────────────

  // Map: activityId -> list of studentIds
  final Map<int, List<int>> _enrollments = {
    1: [1, 2, 9, 10, 14, 18],            // Swimming
    2: [3, 4, 11, 15, 19, 20, 21],       // Yoga
    3: [5, 7, 13, 16, 22],               // Self-Defence
    4: [8, 10, 12, 17],                  // Phonix
    5: [6, 7, 11, 14, 15, 16, 18, 20],  // Art & Craft
    6: [3, 6, 13, 19, 22],              // Sanskrit
    7: [2, 4, 8, 12, 17, 21],           // Speech & Drama
    8: [1, 5, 9, 11, 14, 18, 20, 22],   // Indian Culture
    9: [4, 6, 10, 15, 17],              // Bharat Natiyam
    10: [1, 2, 3, 7, 8, 12, 16, 19],    // Music & Movement
  };

  List<Map<String, dynamic>> getEnrolledStudents(int activityId) {
    final ids = _enrollments[activityId] ?? [];
    return ids.map((id) {
      final s = getStudentById(id);
      if (s == null) return <String, dynamic>{};
      return {
        'id': s.id,
        'name': s.name,
        'roll_number': 'ISKCON-${s.id.toString().padLeft(3, '0')}',
        'enrollment_status': 'Active',
        'dob': s.dateOfBirth,
        'phone': s.phone,
      };
    }).where((m) => m.isNotEmpty).toList();
  }

  // ──────────────────── QR Scan History (guard) ────────────────────

  final List<Map<String, dynamic>> _qrScanHistory = [];
  int _nextScanId = 1;

  List<Map<String, dynamic>> getQrScanHistory() {
    // Seed with 5+ mock scans if empty
    if (_qrScanHistory.isEmpty) {
      final now = DateTime.now();
      _qrScanHistory.addAll([
        {
          'id': 1,
          'studentId': 1,
          'studentName': 'Arjun Sharma',
          'activityId': 1,
          'activityName': 'Swimming',
          'checkInTime': now.subtract(const Duration(hours: 3)).toUtc().toIso8601String(),
        },
        {
          'id': 2,
          'studentId': 3,
          'studentName': 'Krishna Kumar',
          'activityId': 2,
          'activityName': 'Yoga',
          'checkInTime': now.subtract(const Duration(hours: 2, minutes: 45)).toUtc().toIso8601String(),
        },
        {
          'id': 3,
          'studentId': 5,
          'studentName': 'Govind Mishra',
          'activityId': 9,
          'activityName': 'Bharat Natiyam',
          'checkInTime': now.subtract(const Duration(hours: 2)).toUtc().toIso8601String(),
        },
        {
          'id': 4,
          'studentId': 7,
          'studentName': 'Balaram Singh',
          'activityId': 5,
          'activityName': 'Art & Craft',
          'checkInTime': now.subtract(const Duration(hours: 1, minutes: 30)).toUtc().toIso8601String(),
        },
        {
          'id': 5,
          'studentId': 10,
          'studentName': 'Gopi Krishnan',
          'activityId': 10,
          'activityName': 'Music & Movement',
          'checkInTime': now.subtract(const Duration(hours: 1)).toUtc().toIso8601String(),
        },
        {
          'id': 6,
          'studentId': 14,
          'studentName': 'Rukmini Desai',
          'activityId': 8,
          'activityName': 'Indian Culture and Value for Kids',
          'checkInTime': now.subtract(const Duration(minutes: 30)).toUtc().toIso8601String(),
        },
      ]);
      _nextScanId = 7;
    }
    return List.unmodifiable(_qrScanHistory);
  }

  Map<String, dynamic> addQrScan(Map<String, dynamic> qrData) {
    final scan = {
      'id': _nextScanId++,
      'studentId': qrData['studentId'],
      'studentName': qrData['studentName'],
      'activityId': qrData['activityId'],
      'activityName': qrData['activityName'],
      'checkInTime': DateTime.now().toUtc().toIso8601String(),
    };
    _qrScanHistory.insert(0, scan);
    return scan;
  }

  // ──────────────────── Admissions ────────────────────

  final List<Map<String, dynamic>> _admissions = [];
  int _nextAdmissionId = 1;

  Map<String, dynamic> addAdmission(Map<String, dynamic> data) {
    final admission = {
      'id': _nextAdmissionId++,
      ...data,
      'admissionDate': DateTime.now().toUtc().toIso8601String(),
    };
    _admissions.add(admission);
    return admission;
  }

  List<Map<String, dynamic>> getAdmissions() => List.unmodifiable(_admissions);

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

  Map<String, dynamic> getGuardDashboard() {
    final scans = getQrScanHistory();
    return {
      'total_scans_today': scans.length,
      'scan_history': scans,
    };
  }

  Map<String, dynamic> getTeacherDashboard() {
    final today = _todayDate();
    final todayAttendance =
        _attendance.where((a) => a.checkInTime?.startsWith(today) ?? false).toList();
    final presentToday = todayAttendance.length;
    final totalStudents = _students.length;
    final absentToday = totalStudents - presentToday;
    return {
      'class_name': 'All Activities',
      'total_students': totalStudents,
      'present_today': presentToday,
      'absent_today': absentToday < 0 ? 0 : absentToday,
      'upcoming_activities': _activities
          .map((a) => {
                'id': a.id,
                'name': a.name,
                'schedule': a.schedule,
                'teacher': a.teacher,
                'total_enrolled': (_enrollments[a.id] ?? []).length,
              })
          .toList(),
      'attendance_history': todayAttendance
          .map((a) => {
                'student': a.studentName,
                'activity': a.activityName,
                'check_in': a.checkInTime,
                'check_out': a.checkOutTime,
              })
          .toList(),
    };
  }

  Map<String, dynamic> getPrincipalDashboard() {
    final today = _todayDate();
    final todayAttendance =
        _attendance.where((a) => a.checkInTime?.startsWith(today) ?? false).length;
    final totalStudents = _students.length;
    final attendancePct = totalStudents > 0
        ? ((todayAttendance / totalStudents) * 100).round()
        : 0;

    // Activity enrollment stats
    final activityStats = _activities.map((a) => {
      'id': a.id,
      'name': a.name,
      'schedule': a.schedule,
      'teacher': a.teacher,
      'capacity': a.capacity,
      'enrolled': (_enrollments[a.id] ?? []).length,
    }).toList();

    return {
      'total_students': totalStudents,
      'total_activities': _activities.length,
      'total_teachers': 10,
      'average_attendance_pct': attendancePct,
      'today_attendance': todayAttendance,
      'monthly_stats': [
        {'month': 'Oct', 'attendance': 88},
        {'month': 'Nov', 'attendance': 91},
        {'month': 'Dec', 'attendance': 85},
        {'month': 'Jan', 'attendance': 93},
        {'month': 'Feb', 'attendance': 90},
        {'month': 'Mar', 'attendance': attendancePct},
      ],
      'activity_stats': activityStats,
      'students': _students.map((s) => {
        'id': s.id,
        'name': s.name,
        'phone': s.phone,
        'dob': s.dateOfBirth,
        'roll': 'ISKCON-${s.id.toString().padLeft(3, '0')}',
        'enrolled_activities': _enrollments.entries
            .where((e) => e.value.contains(s.id))
            .map((e) => e.key)
            .length,
      }).toList(),
      'financial': {
        'admissions_this_month': 12,
        'revenue_total': 185000,
        'payment_cash_count': 7,
        'payment_online_count': 5,
        'payment_cash_amount': 111000,
        'payment_online_amount': 74000,
        'pending_payments': [
          {'name': 'Arjun Sharma',  'amount': 4500,  'period': 'Monthly',    'overdue_days': 5},
          {'name': 'Priya Patel',   'amount': 6000,  'period': 'Quarterly',  'overdue_days': 12},
          {'name': 'Rahul Verma',   'amount': 8000,  'period': 'Yearly',     'overdue_days': 3},
          {'name': 'Sneha Joshi',   'amount': 4500,  'period': 'Monthly',    'overdue_days': 8},
          {'name': 'Karan Mehta',   'amount': 6000,  'period': 'Quarterly',  'overdue_days': 15},
        ],
        'revenue_by_period': [
          {'period': 'Monthly',     'count': 5, 'revenue': 45000},
          {'period': 'Quarterly',   'count': 4, 'revenue': 60000},
          {'period': 'Yearly',      'count': 3, 'revenue': 80000},
        ],
      },
    };
  }
}
