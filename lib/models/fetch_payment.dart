import 'course_of_payment.dart';
import 'owned_by.dart';

class Payment {
  final int id;
  final int amount;
  final DateTime paymentDate;
  final OwnedBy ownedBy;
  final int courseStatus;

  Payment({
    required this.id,
    required this.amount,
    required this.paymentDate,
    required this.ownedBy,
    required this.courseStatus,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      amount: json['amount'],
      paymentDate: DateTime.parse(json['paymentDate']),
      ownedBy: OwnedBy.fromJson(json['student']),
      courseStatus: json['course'] == null
          ? 3
          : CourseOfPayment.fromJson(json['course']).courseStatus,
    );
  }
}
