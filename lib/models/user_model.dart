class User {
  final String name;
  final String mobile;
  final DateTime joiningDate; // DateTime for better date handling
  final DateTime dob; // DateTime for better date handling
  final String? accessToken;
  bool isTemporaryPassword;
  String role;

  // Constructor for the User class
  User({
    required this.name,
    required this.mobile,
    required this.joiningDate,
    required this.dob,
    this.accessToken,
    required this.isTemporaryPassword,
    required this.role,
  });

  User.copyFrom(User user)
      : name = user.name,
        mobile = user.mobile,
        joiningDate = user.joiningDate,
        dob = user.dob,
        accessToken = user.accessToken, // Retain the original accessToken
        isTemporaryPassword = user.isTemporaryPassword,
        role = user.role;

  // Factory constructor to create a User object from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      mobile: json['mobile'],
      joiningDate:
          DateTime.parse(json['joiningDate']), // Parsing string to DateTime
      dob: DateTime.parse(json['dob']), // Parsing string to DateTime
      accessToken: json['accessToken'],
      isTemporaryPassword: json['isTemporaryPassword'] ??
          false, // Providing default value if null
      role: json['role'],
    );
  }

  // Method to convert a User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mobile': mobile,
      'joiningDate': joiningDate
          .toIso8601String(), // Converting DateTime to ISO8601 string
      'dob': dob.toIso8601String(), // Converting DateTime to ISO8601 string
      'accessToken': accessToken,
      'isTemporaryPassword': isTemporaryPassword,
      'role': role,
    };
  }
}
