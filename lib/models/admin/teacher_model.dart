
class Teacher {
  final int id;
  final String name;
  final String mobile;
  final DateTime createdAt;
  final bool enabled;

  Teacher({
    required this.id,
    required this.name,
    required this.mobile,
    required this.createdAt,
    required this.enabled,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
        id: json['id'],
        name: json['name'],
        mobile: json['mobile'],
        createdAt: DateTime.parse(json['createdAt']),
        enabled: json['enabled'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'createdAt': createdAt,
    };
  }

  Teacher copy(
      {int? id,
      String? name,
      String? mobile,
      DateTime? createdAt,
      bool? enabled}) {
    return Teacher(
        id: id ?? this.id,
        name: name ?? this.name,
        mobile: mobile ?? this.mobile,
        createdAt: createdAt ?? this.createdAt,
        enabled: enabled ?? this.enabled);
  }
}
