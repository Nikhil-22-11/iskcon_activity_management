class AttendanceModel {
  final int id;
  final int studentId;
  final int activityId;
  final String? studentName;
  final String? activityName;
  final String? checkInTime;
  final String? checkOutTime;
  final String? createdAt;

  const AttendanceModel({
    required this.id,
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
      studentId: json['student_id'] as int,
      activityId: json['activity_id'] as int,
      studentName: json['student_name'] as String?,
      activityName: json['activity_name'] as String?,
      checkInTime: json['check_in_time'] as String?,
      checkOutTime: json['check_out_time'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'activity_id': activityId,
      if (checkInTime != null) 'check_in_time': checkInTime,
      if (checkOutTime != null) 'check_out_time': checkOutTime,
    };
  }

  bool get isCheckedOut => checkOutTime != null;
}
