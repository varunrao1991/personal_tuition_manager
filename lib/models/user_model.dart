class User {
  final String name;
  final String mobile;
  final DateTime createdAt;
  bool isTemporaryPassword;
  String role;

  User({
    required this.name,
    required this.mobile,
    required this.createdAt,
    required this.isTemporaryPassword,
    required this.role,
  });
  User.copyFrom(User user)
      : name = user.name,
        mobile = user.mobile,
        createdAt = user.createdAt,
        isTemporaryPassword = user.isTemporaryPassword,
        role = user.role;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      mobile: json['mobile'],
      createdAt: DateTime.parse(json['createdAt']),
      isTemporaryPassword: json['isTemporaryPassword'] ?? false,
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mobile': mobile,
      'isTemporaryPassword': isTemporaryPassword,
      'role': role,
    };
  }
}
