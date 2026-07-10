class UserModel {
  final int id;
  final String username;
  final String password;
  final String role;
  final String displayName;
  final String email;
  final String phone;

  UserModel({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
    required this.displayName,
    required this.email,
    required this.phone,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int,
      username: map['username'] as String,
      password: map['password'] as String,
      role: map['role'] as String,
      displayName: (map['displayName'] as String?)?.trim().isNotEmpty == true
          ? map['displayName'] as String
          : map['username'] as String,
      email: (map['email'] as String?) ?? '',
      phone: (map['phone'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'role': role,
      'displayName': displayName,
      'email': email,
      'phone': phone,
    };
  }
}
