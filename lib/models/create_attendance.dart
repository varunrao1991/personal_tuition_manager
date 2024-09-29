class CreateAttendance {
  final int studentId;
  final DateTime attendanceDate;

  CreateAttendance({
    required this.studentId,
    required this.attendanceDate,
  });

  // Convert the instance to a JSON map for API requests
  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'attendanceDate': attendanceDate.toIso8601String(),
    };
  }

  // Create an instance from a JSON map (useful if needed for responses)
  factory CreateAttendance.fromJson(Map<String, dynamic> json) {
    return CreateAttendance(
      studentId: json['studentId'],
      attendanceDate: DateTime.parse(json['attendanceDate']),
    );
  }
}
