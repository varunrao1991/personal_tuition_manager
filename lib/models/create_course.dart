class CourseCreate {
  final int paymentId;
  final int totalClasses;

  CourseCreate({
    required this.paymentId,
    required this.totalClasses,
  });

  factory CourseCreate.fromJson(Map<String, dynamic> json) {
    return CourseCreate(
      paymentId: json['paymentId'],
      totalClasses: json['totalClasses'] ?? 0,
    );
  }
}
