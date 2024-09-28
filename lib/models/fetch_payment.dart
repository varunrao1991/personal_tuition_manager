import 'paid_by.dart';

class Payment {
  final int id;
  final int amount;
  final DateTime paymentDate;
  final PaidBy paidBy;

  Payment({
    required this.id,
    required this.amount,
    required this.paymentDate,
    required this.paidBy,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'], // Fetch payment ID
      amount: json['amount'], // Fetch payment amount
      paymentDate:
          DateTime.parse(json['paymentDate']), // Parse the payment date
      paidBy: PaidBy.fromJson(json[
          'student']), // Use PaidBy factory constructor to map student object
    );
  }
}
