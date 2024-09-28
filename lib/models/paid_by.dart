class PaidBy {
  final int id;
  final String name;

  PaidBy({
    required this.id,
    required this.name,
  });

  factory PaidBy.fromJson(Map<String, dynamic> json) {
    return PaidBy(
      id: json['id'], // Extract the student ID from the student object
      name: json['name'], // Extract the student name from the student object
    );
  }
}
