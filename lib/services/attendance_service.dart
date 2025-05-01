import 'package:sqflite/sqflite.dart';
import '../models/attendance.dart';
import '../models/owned_by.dart';
import '../helpers/database_helper.dart';

class AttendanceService {
  Future<void> deleteAttendance({
    required DateTime attendanceDate,
    required int studentId,
  }) async {
    final db = await DatabaseHelper.instance.database;

    await db.delete(
      DatabaseHelper.attendanceTable,
      where: 'attendanceDate = ? AND studentId = ?',
      whereArgs: [attendanceDate.toIso8601String(), studentId],
    );
  }

  Future<List<Attendance>> getAllAttendances({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await DatabaseHelper.instance.database;

    String? where;
    List<String>? whereArgs;

    if (startDate != null && endDate != null) {
      where = 'A.attendanceDate BETWEEN ? AND ?';
      whereArgs = [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ];
    }

    final result = await db.rawQuery('''
    SELECT A.attendanceDate, U.id, U.name
    FROM ${DatabaseHelper.attendanceTable} A
    JOIN ${DatabaseHelper.userTable} U ON A.studentId = U.id
    ${where != null ? 'WHERE $where' : ''}
  ''', whereArgs);

    return result.map((row) {
      return Attendance(
        attendanceDate: DateTime.parse(row['attendanceDate'] as String),
        ownedBy: OwnedBy(id: row['id'] as int, name: row['name'] as String),
      );
    }).toList();
  }

  Future<void> addAttendance({
    required DateTime attendanceDate,
    required int studentId,
  }) async {
    final db = await DatabaseHelper.instance.database;

    await db.insert(
      DatabaseHelper.attendanceTable,
      {
        'attendanceDate': attendanceDate.toIso8601String(),
        'studentId': studentId,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<DateTime>> getAttendancesForStudent({
    required int studentId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      DatabaseHelper.attendanceTable,
      columns: ['attendanceDate'],
      where: 'studentId = ? AND attendanceDate BETWEEN ? AND ?',
      whereArgs: [
        studentId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
    );

    return result
        .map((row) => DateTime.parse(row['attendanceDate'] as String))
        .toList();
  }

  Future<bool> attendanceExists({
    required DateTime attendanceDate,
    required int studentId,
  }) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      DatabaseHelper.attendanceTable,
      where: 'attendanceDate = ? AND studentId = ?',
      whereArgs: [attendanceDate.toIso8601String(), studentId],
    );

    return result.isNotEmpty;
  }
}
