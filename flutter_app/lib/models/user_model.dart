class UserModel {
  final int id;
  final String? docId;
  final String email;
  final String name;
  final String role;
  final String? token;

  const UserModel({
    required this.id,
    this.docId,
    required this.email,
    required this.name,
    required this.role,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      docId: json['docId'] as String?,
      email: json['email'] as String,
      name: json['name'] as String? ?? json['email'] as String,
      role: json['role'] as String,
      token: json['token'] as String?,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return UserModel(
      id: (map['id'] as int?) ?? 0,
      docId: docId,
      email: map['email'] as String,
      name: map['name'] as String? ?? map['email'] as String,
      role: map['role'] as String,
      token: map['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (docId != null) 'docId': docId,
      'email': email,
      'name': name,
      'role': role,
      if (token != null) 'token': token,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isGuard => role == 'guard';
  bool get isTeacher => role == 'teacher';
  bool get isPrincipal => role == 'principal';
}
