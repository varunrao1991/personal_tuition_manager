class CourseOfPayment {
  final int courseStatus;

  CourseOfPayment({
    required this.courseStatus,
  });

  factory CourseOfPayment.fromJson(Map<String, dynamic> json) {
    return CourseOfPayment(
      courseStatus: json['courseStatus'],
    );
  }
}
