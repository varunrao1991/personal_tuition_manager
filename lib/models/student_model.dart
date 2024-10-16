class Student {
  final int id;
  final String name;
  final String mobile;
  final DateTime dob;
  final DateTime joiningDate;

  Student({
    required this.id,
    required this.name,
    required this.mobile,
    required this.dob,
    required this.joiningDate,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      mobile: json['mobile'],
      dob: DateTime.parse(json['dob']),
      joiningDate: DateTime.parse(json['joiningDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'dob': dob,
      'joiningDate': joiningDate,
    };
  }

  Student copy({
    int? id,
    String? name,
    String? mobile,
    DateTime? dob,
    DateTime? joiningDate,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      dob: dob ?? this.dob,
      joiningDate: joiningDate ?? this.joiningDate,
    );
  }
}
