class VisitorModel {
  final int id;
  final String? docId;
  final String visitorName;
  final String? visitorPhone;
  final String? visitReason;
  final String? studentName;
  final String? checkInTime;
  final String? checkOutTime;
  final String? createdAt;

  const VisitorModel({
    required this.id,
    this.docId,
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
      docId: json['docId'] as String?,
      visitorName: json['visitor_name'] as String,
      visitorPhone: json['visitor_phone'] as String?,
      visitReason: json['visit_reason'] as String?,
      studentName: json['student_name'] as String?,
      checkInTime: json['check_in_time'] as String?,
      checkOutTime: json['check_out_time'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  factory VisitorModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return VisitorModel(
      id: (map['id'] as int?) ?? 0,
      docId: docId,
      visitorName: map['visitor_name'] as String,
      visitorPhone: map['visitor_phone'] as String?,
      visitReason: map['visit_reason'] as String?,
      studentName: map['student_name'] as String?,
      checkInTime: map['check_in_time'] as String?,
      checkOutTime: map['check_out_time'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (docId != null) 'docId': docId,
      'visitor_name': visitorName,
      if (visitorPhone != null) 'visitor_phone': visitorPhone,
      if (visitReason != null) 'visit_reason': visitReason,
      if (studentName != null) 'student_name': studentName,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'visitor_name': visitorName,
      if (visitorPhone != null) 'visitor_phone': visitorPhone,
      if (visitReason != null) 'visit_reason': visitReason,
      if (studentName != null) 'student_name': studentName,
      'check_in_time': checkInTime ?? DateTime.now().toIso8601String(),
      if (checkOutTime != null) 'check_out_time': checkOutTime,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  bool get isCheckedOut => checkOutTime != null;
}
