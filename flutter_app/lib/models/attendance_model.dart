class AttendanceModel {
  final int id;
  final String? docId;
  final int studentId;
  final int activityId;
  final String? studentName;
  final String? activityName;
  final String? checkInTime;
  final String? checkOutTime;
  final String? createdAt;

  const AttendanceModel({
    required this.id,
    this.docId,
    required this.studentId,
    required this.activityId,
    this.studentName,
    this.activityName,
    this.checkInTime,
    this.checkOutTime,
    this.createdAt,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as int,
      docId: json['docId'] as String?,
      studentId: json['student_id'] as int,
      activityId: json['activity_id'] as int,
      studentName: json['student_name'] as String?,
      activityName: json['activity_name'] as String?,
      checkInTime: json['check_in_time'] as String?,
      checkOutTime: json['check_out_time'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return AttendanceModel(
      id: (map['id'] as int?) ?? 0,
      docId: docId,
      studentId: (map['student_id'] as int?) ?? 0,
      activityId: (map['activity_id'] as int?) ?? 0,
      studentName: map['student_name'] as String?,
      activityName: map['activity_name'] as String?,
      checkInTime: map['check_in_time'] as String?,
      checkOutTime: map['check_out_time'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (docId != null) 'docId': docId,
      'student_id': studentId,
      'activity_id': activityId,
      if (checkInTime != null) 'check_in_time': checkInTime,
      if (checkOutTime != null) 'check_out_time': checkOutTime,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'activity_id': activityId,
      if (studentName != null) 'student_name': studentName,
      if (activityName != null) 'activity_name': activityName,
      'check_in_time': checkInTime ?? DateTime.now().toIso8601String(),
      if (checkOutTime != null) 'check_out_time': checkOutTime,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  bool get isCheckedOut => checkOutTime != null;
}
