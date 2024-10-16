import '../models/owned_by.dart';

class PaymentInfo {
  final int amount;
  final DateTime paymentDate;
  final OwnedBy student;

  PaymentInfo({
    required this.amount,
    required this.paymentDate,
    required this.student,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      amount: json['amount'],
      paymentDate: DateTime.parse(json['paymentDate']),
      student: OwnedBy.fromJson(json['student']),
    );
  }
}
