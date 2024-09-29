class Holiday {
  final DateTime holidayDate;
  final String reason;

  Holiday({
    required this.holidayDate,
    required this.reason,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      holidayDate: DateTime.parse(json['holidayDate']),
      reason: json['reason'],
    );
  }
}
