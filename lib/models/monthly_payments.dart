class MonthlyPayment {
  final int month; // Month number (1 for January, 2 for February, etc.)
  final int year; // Year of the payments
  final double totalAmount; // Total amount of payments for that month

  MonthlyPayment({
    required this.month,
    required this.year,
    required this.totalAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'year': year,
      'totalAmount': totalAmount,
    };
  }

  factory MonthlyPayment.fromJson(Map<String, dynamic> json) {
    return MonthlyPayment(
      month: json['month'],
      year: json['year'],
      totalAmount: json['totalAmount'].toDouble(),
    );
  }
}
