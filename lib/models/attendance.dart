import 'owned_by.dart';

class Attendance {
  final DateTime attendanceDate;
  final OwnedBy ownedBy;

  Attendance({
    required this.attendanceDate,
    required this.ownedBy,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      attendanceDate: DateTime.parse(json['attendanceDate']),
      ownedBy: OwnedBy.fromJson(json['student']),
    );
  }
}
