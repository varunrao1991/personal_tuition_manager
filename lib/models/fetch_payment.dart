import 'owned_by.dart';

class Payment {
  final int id;
  final int amount;
  final DateTime paymentDate;
  final OwnedBy ownedBy;

  Payment({
    required this.id,
    required this.amount,
    required this.paymentDate,
    required this.ownedBy,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'], // Fetch payment ID
      amount: json['amount'], // Fetch payment amount
      paymentDate:
          DateTime.parse(json['paymentDate']), // Parse the payment date
      ownedBy: OwnedBy.fromJson(json[
          'student']), // Use OwnedBy factory constructor to map student object
    );
  }
}
