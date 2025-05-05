import '../services/course_service.dart';
import 'student_from.dart';

class Payment {
  final int id;
  final int amount;
  final DateTime paymentDate;
  final StudentFrom studentFrom;
  final CourseStatus courseStatus;

  Payment({
    required this.id,
    required this.amount,
    required this.paymentDate,
    required this.studentFrom,
    required this.courseStatus,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      amount: json['amount'],
      paymentDate: DateTime.parse(json['paymentDate']),
      studentFrom: StudentFrom.fromJson(json['student']),
      courseStatus: CourseStatus.noCourse,
    );
  }
}
