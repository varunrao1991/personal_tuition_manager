import 'package:personal_tuition_manager/models/subject.dart';
import 'payment_info.dart';

class Course {
  final int paymentId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int totalClasses;
  bool? canStart;
  bool? noCredit;
  final PaymentInfo payment;
  final Subject? subject;

  Course({
    required this.paymentId,
    required this.startDate,
    required this.endDate,
    required this.totalClasses,
    required this.payment,
    this.canStart,
    this.noCredit,
    this.subject,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      paymentId: json['paymentId'],
      canStart: json['canStart'] ?? false,
      noCredit: json['noCredit'] ?? false,
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      totalClasses: json['totalClasses'],
      payment: PaymentInfo.fromJson(json['payment']),
      subject: json['subject'] != null ? Subject.fromJson(json['subject']) : null,
    );
  }
}