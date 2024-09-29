class OwnedBy {
  final int id;
  final String name;

  OwnedBy({
    required this.id,
    required this.name,
  });

  factory OwnedBy.fromJson(Map<String, dynamic> json) {
    return OwnedBy(
      id: json['id'], // Extract the student ID from the student object
      name: json['name'], // Extract the student name from the student object
    );
  }
}
