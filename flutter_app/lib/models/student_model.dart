class StudentModel {
  final int id;
  final String? docId;
  final String name;
  final String? email;
  final String? phone;
  final String? dateOfBirth;
  final String? parentName;
  final String? parentPhone;
  final String? address;
  final String? createdAt;

  const StudentModel({
    required this.id,
    this.docId,
    required this.name,
    this.email,
    this.phone,
    this.dateOfBirth,
    this.parentName,
    this.parentPhone,
    this.address,
    this.createdAt,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as int,
      docId: json['docId'] as String?,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      parentName: json['parent_name'] as String?,
      parentPhone: json['parent_phone'] as String?,
      address: json['address'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  factory StudentModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return StudentModel(
      id: (map['id'] as int?) ?? 0,
      docId: docId,
      name: map['name'] as String,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      dateOfBirth: map['date_of_birth'] as String?,
      parentName: map['parent_name'] as String?,
      parentPhone: map['parent_phone'] as String?,
      address: map['address'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (docId != null) 'docId': docId,
      'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (parentName != null) 'parent_name': parentName,
      if (parentPhone != null) 'parent_phone': parentPhone,
      if (address != null) 'address': address,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (parentName != null) 'parent_name': parentName,
      if (parentPhone != null) 'parent_phone': parentPhone,
      if (address != null) 'address': address,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }
}
