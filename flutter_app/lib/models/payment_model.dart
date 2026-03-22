class PaymentModel {
  final String? docId;
  final int? studentId;
  final String? studentName;
  final double amount;
  final String paymentMode;
  final String? transactionId;
  final String? period;
  final String? notes;
  final String? createdAt;

  const PaymentModel({
    this.docId,
    this.studentId,
    this.studentName,
    required this.amount,
    this.paymentMode = 'Cash',
    this.transactionId,
    this.period,
    this.notes,
    this.createdAt,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return PaymentModel(
      docId: docId,
      studentId: map['student_id'] as int?,
      studentName: map['student_name'] as String?,
      amount: (map['amount'] as num).toDouble(),
      paymentMode: map['payment_mode'] as String? ?? 'Cash',
      transactionId: map['transaction_id'] as String?,
      period: map['period'] as String?,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (studentId != null) 'student_id': studentId,
      if (studentName != null) 'student_name': studentName,
      'amount': amount,
      'payment_mode': paymentMode,
      if (transactionId != null) 'transaction_id': transactionId,
      if (period != null) 'period': period,
      if (notes != null) 'notes': notes,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }
}
