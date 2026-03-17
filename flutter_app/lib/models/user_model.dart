class UserModel {
  final int id;
  final String email;
  final String name;
  final String role;
  final String? token;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String? ?? json['email'] as String,
      role: json['role'] as String,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      if (token != null) 'token': token,
    };
  }

  bool get isAdmin => role == 'admin' || role == 'principal';
  bool get isTeacher => role == 'teacher';
}
