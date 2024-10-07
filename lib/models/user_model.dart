class User {
  final String name;
  final String mobile;
  final DateTime joiningDate;
  final DateTime dob;
  bool isTemporaryPassword;
  String role;

  User({
    required this.name,
    required this.mobile,
    required this.joiningDate,
    required this.dob,
    required this.isTemporaryPassword,
    required this.role,
  });
  User.copyFrom(User user)
      : name = user.name,
        mobile = user.mobile,
        joiningDate = user.joiningDate,
        dob = user.dob,
        isTemporaryPassword = user.isTemporaryPassword,
        role = user.role;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      mobile: json['mobile'],
      joiningDate: DateTime.parse(json['joiningDate']),
      dob: DateTime.parse(json['dob']),
      isTemporaryPassword: json['isTemporaryPassword'] ?? false,
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mobile': mobile,
      'joiningDate': joiningDate.toIso8601String(),
      'dob': dob.toIso8601String(),
      'isTemporaryPassword': isTemporaryPassword,
      'role': role,
    };
  }
}
