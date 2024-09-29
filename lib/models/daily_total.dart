class DailyTotal {
  final DateTime dateTime;
  final double totalAmount;

  DailyTotal({
    required this.dateTime,
    required this.totalAmount,
  });

  // Factory method to create a DailyTotal from a JSON map
  factory DailyTotal.fromJson(Map<String, dynamic> json) {
    return DailyTotal(
      dateTime:
          DateTime.parse(json['date']), // Assuming 'date' is in ISO 8601 format
      totalAmount: json['totalAmount'].toDouble(),
    );
  }

  // Method to convert DailyTotal to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'date':
          dateTime.toIso8601String(), // Converts DateTime to ISO 8601 format
      'totalAmount': totalAmount,
    };
  }
}
