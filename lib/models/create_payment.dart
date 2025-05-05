import 'fetch_payment.dart';

class CreatePayment {
  final int? id;
  final int studentId;
  final String studentName;
  final int amount;
  final DateTime paymentDate;

  CreatePayment(
      {this.id,
      required this.studentId,
      required this.amount,
      required this.paymentDate,
      required this.studentName});

  factory CreatePayment.fromPayment(Payment payment) {
    return CreatePayment(
      id: payment.id,
      studentId: payment.studentFrom.id,
      amount: payment.amount,
      paymentDate: payment.paymentDate,
      studentName: payment.studentFrom.name,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'studentId': studentId,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
    };
  }
}
