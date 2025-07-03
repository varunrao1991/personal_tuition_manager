class CourseCreate {
  final int paymentId;
  final int totalClasses;
  final int? subjectId;

  CourseCreate({
    required this.paymentId,
    required this.totalClasses,
    this.subjectId,
  });

  factory CourseCreate.fromJson(Map<String, dynamic> json) {
    return CourseCreate(
      paymentId: json['paymentId'],
      totalClasses: json['totalClasses'] ?? 0,
      subjectId: json['subjectId'],
    );
  }
}
