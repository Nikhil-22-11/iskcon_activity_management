class StudentModel {
  final int id;
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (parentName != null) 'parent_name': parentName,
      if (parentPhone != null) 'parent_phone': parentPhone,
      if (address != null) 'address': address,
    };
  }
}
