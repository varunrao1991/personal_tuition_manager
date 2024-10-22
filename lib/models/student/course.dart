import '../payment_info.dart';

class Course {
  final int paymentId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int totalClasses;
  final PaymentInfo payment;

  Course(
      {required this.paymentId,
      required this.startDate,
      required this.endDate,
      required this.totalClasses,
      required this.payment});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      paymentId: json['paymentId'],
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      totalClasses: json['totalClasses'],
      payment: PaymentInfo.fromJson(json['payment']),
    );
  }
}
