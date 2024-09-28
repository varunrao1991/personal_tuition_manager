import 'fetch_payment.dart';

class CreatePayment {
  final int? id; // Nullable for add operations
  final int studentId;
  final String studentName;
  final int amount;
  final DateTime paymentDate;

  CreatePayment(
      {this.id, // Optional for add, required for edit
      required this.studentId,
      required this.amount,
      required this.paymentDate,
      required this.studentName});

  // Factory constructor to create a `CreatePayment` instance from a `Payment` object
  factory CreatePayment.fromPayment(Payment payment) {
    return CreatePayment(
      id: payment.id, // Map the ID from the Payment object
      studentId: payment.paidBy.id, // Assuming `paidBy` has a `studentId`
      amount: payment.amount,
      paymentDate: payment.paymentDate,
      studentName: payment.paidBy.name,
    );
  }

  // Method to convert a `CreatePayment` instance to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      if (id != null)
        'id': id, // Include 'id' only if it exists (for edit operation)
      'studentId': studentId,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
    };
  }
}
