class Student {
  final int id;
  final String name;
  final String mobile;
  final DateTime dob; // Consider using DateTime for actual date handling
  final DateTime joiningDate; // Consider using DateTime for actual date handling

  Student({
    required this.id,
    required this.name,
    required this.mobile,
    required this.dob,
    required this.joiningDate,
  });

  // Factory method to create a Student instance from JSON
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      mobile: json['mobile'],
      dob: DateTime.parse(json['dob']),
      joiningDate: DateTime.parse(json['joiningDate']),
    );
  }

  // Method to convert a Student instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'dob': dob,
      'joiningDate': joiningDate,
    };
  }
}
