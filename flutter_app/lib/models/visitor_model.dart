class VisitorModel {
  final int id;
  final String visitorName;
  final String? visitorPhone;
  final String? visitReason;
  final String? studentName;
  final String? checkInTime;
  final String? checkOutTime;
  final String? createdAt;

  const VisitorModel({
    required this.id,
    required this.visitorName,
    this.visitorPhone,
    this.visitReason,
    this.studentName,
    this.checkInTime,
    this.checkOutTime,
    this.createdAt,
  });

  factory VisitorModel.fromJson(Map<String, dynamic> json) {
    return VisitorModel(
      id: json['id'] as int,
      visitorName: json['visitor_name'] as String,
      visitorPhone: json['visitor_phone'] as String?,
      visitReason: json['visit_reason'] as String?,
      studentName: json['student_name'] as String?,
      checkInTime: json['check_in_time'] as String?,
      checkOutTime: json['check_out_time'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visitor_name': visitorName,
      if (visitorPhone != null) 'visitor_phone': visitorPhone,
      if (visitReason != null) 'visit_reason': visitReason,
      if (studentName != null) 'student_name': studentName,
    };
  }

  bool get isCheckedOut => checkOutTime != null;
}
