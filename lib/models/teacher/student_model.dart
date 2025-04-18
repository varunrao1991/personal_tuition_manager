class Student {
  final int id;
  final String name;
  final String mobile;
  final DateTime createdAt;

  Student(
      {required this.id,
      required this.name,
      required this.mobile,
      required this.createdAt});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
        id: json['id'],
        name: json['name'],
        mobile: json['mobile'],
        createdAt: DateTime.parse(json['createdAt']));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'createdAt': createdAt,
    };
  }

  Student copy(
      {int? id,
      String? name,
      String? mobile,
      DateTime? createdAt}) {
    return Student(
        id: id ?? this.id,
        name: name ?? this.name,
        mobile: mobile ?? this.mobile,
        createdAt: createdAt ?? this.createdAt);
  }
}
