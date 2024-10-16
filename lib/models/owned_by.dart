class OwnedBy {
  final int id;
  final String name;

  OwnedBy({
    required this.id,
    required this.name,
  });

  factory OwnedBy.fromJson(Map<String, dynamic> json) {
    return OwnedBy(
      id: json['id'],
      name: json['name'],
    );
  }

  OwnedBy copy({
    int? id,
    String? name,
  }) {
    return OwnedBy(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
