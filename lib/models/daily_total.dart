class DailyTotal {
  final DateTime dateTime;
  final double totalAmount;

  DailyTotal({
    required this.dateTime,
    required this.totalAmount,
  });

  factory DailyTotal.fromJson(Map<String, dynamic> json) {
    return DailyTotal(
      dateTime: DateTime.parse(json['date']),
      totalAmount: json['totalAmount'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': dateTime.toIso8601String(),
      'totalAmount': totalAmount,
    };
  }
}
