class CreateAttendance {
  final int studentId;
  final DateTime attendanceDate;

  CreateAttendance({
    required this.studentId,
    required this.attendanceDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'attendanceDate': attendanceDate.toIso8601String(),
    };
  }

  factory CreateAttendance.fromJson(Map<String, dynamic> json) {
    return CreateAttendance(
      studentId: json['studentId'],
      attendanceDate: DateTime.parse(json['attendanceDate']),
    );
  }
}
