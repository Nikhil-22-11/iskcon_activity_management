class AdmissionModel {
  final String? docId;
  final String studentName;
  final String? motherContact;
  final String? fatherContact;
  final String? dob;
  final String? school;
  final String gender;
  final String? hearAboutUs;
  final String paymentPeriod;
  final String paymentMode;
  final String? transactionId;
  final double? amount;
  final String? createdAt;

  const AdmissionModel({
    this.docId,
    required this.studentName,
    this.motherContact,
    this.fatherContact,
    this.dob,
    this.school,
    this.gender = 'Male',
    this.hearAboutUs,
    this.paymentPeriod = 'Monthly',
    this.paymentMode = 'Cash',
    this.transactionId,
    this.amount,
    this.createdAt,
  });

  factory AdmissionModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return AdmissionModel(
      docId: docId,
      studentName: map['student_name'] as String,
      motherContact: map['mother_contact'] as String?,
      fatherContact: map['father_contact'] as String?,
      dob: map['dob'] as String?,
      school: map['school'] as String?,
      gender: map['gender'] as String? ?? 'Male',
      hearAboutUs: map['hear_about_us'] as String?,
      paymentPeriod: map['payment_period'] as String? ?? 'Monthly',
      paymentMode: map['payment_mode'] as String? ?? 'Cash',
      transactionId: map['transaction_id'] as String?,
      amount: (map['amount'] as num?)?.toDouble(),
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'student_name': studentName,
      if (motherContact != null) 'mother_contact': motherContact,
      if (fatherContact != null) 'father_contact': fatherContact,
      if (dob != null) 'dob': dob,
      if (school != null) 'school': school,
      'gender': gender,
      if (hearAboutUs != null) 'hear_about_us': hearAboutUs,
      'payment_period': paymentPeriod,
      'payment_mode': paymentMode,
      if (transactionId != null) 'transaction_id': transactionId,
      if (amount != null) 'amount': amount,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }
}
