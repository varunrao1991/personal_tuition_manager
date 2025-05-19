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

    final formattedDate = "${attendanceDate.year.toString().padLeft(4, '0')}-${attendanceDate.month.toString().padLeft(2, '0')}-${attendanceDate.day.toString().padLeft(2, '0')}";

    await db.delete(
      DatabaseHelper.attendanceTable,
      where: 'attendanceDate = ? AND studentId = ?',
      whereArgs: [formattedDate, studentId],
    );
  }

  Future<List<Attendance>> getAllAttendances({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await DatabaseHelper.instance.database;

    String? where;
    List<String>? whereArgs;

    String formatDate(DateTime? date) {
      if (date == null) return '';
      return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    }

    if (startDate != null && endDate != null) {
      where = 'A.attendanceDate BETWEEN ? AND ?';
      whereArgs = [
        formatDate(startDate),
        formatDate(endDate),
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
    final formattedDate = "${attendanceDate.year.toString().padLeft(4, '0')}-${attendanceDate.month.toString().padLeft(2, '0')}-${attendanceDate.day.toString().padLeft(2, '0')}";

    await db.insert(
      DatabaseHelper.attendanceTable,
      {
        'attendanceDate': formattedDate,
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

    String formatDate(DateTime? date) {
      if (date == null) return '';
      return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    }

    final result = await db.query(
      DatabaseHelper.attendanceTable,
      columns: ['attendanceDate'],
      where: 'studentId = ? AND attendanceDate BETWEEN ? AND ?',
      whereArgs: [
        studentId,
        formatDate(startDate),
        formatDate(endDate),
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
    final formattedDate = "${attendanceDate.year.toString().padLeft(4, '0')}-${attendanceDate.month.toString().padLeft(2, '0')}-${attendanceDate.day.toString().padLeft(2, '0')}";

    final result = await db.query(
      DatabaseHelper.attendanceTable,
      where: 'attendanceDate = ? AND studentId = ?',
      whereArgs: [formattedDate, studentId],
    );

    return result.isNotEmpty;
  }
}