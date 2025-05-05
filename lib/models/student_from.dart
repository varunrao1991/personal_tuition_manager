class StudentFrom {
  final int id;
  final String name;
  final String mobile;

  StudentFrom({
    required this.id,
    required this.name,
    required this.mobile
  });

  factory StudentFrom.fromJson(Map<String, dynamic> json) {
    return StudentFrom(
      id: json['id'],
      name: json['name'],
      mobile: json['mobile'],
    );
  }

  StudentFrom copy({
    int? id,
    String? name,
    String? mobile,
  }) {
    return StudentFrom(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
    );
  }
}
