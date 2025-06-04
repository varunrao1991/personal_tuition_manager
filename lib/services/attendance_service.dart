import 'package:sqflite/sqflite.dart';
import '../models/attendance.dart';
import '../models/owned_by.dart';
import '../helpers/database_helper.dart';

class AttendanceService {
  // Helper method to format date consistently
  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Helper method to update last attended date for a student
  Future<void> _updateLastAttendedDate(int studentId) async {
    final db = await DatabaseHelper.instance.database;
    
    // Get the most recent attendance date for this student
    final result = await db.query(
      DatabaseHelper.attendanceTable,
      columns: ['attendanceDate'],
      where: 'studentId = ?',
      whereArgs: [studentId],
      orderBy: 'attendanceDate DESC',
      limit: 1,
    );

    String? lastAttendedDate;
    if (result.isNotEmpty) {
      lastAttendedDate = result.first['attendanceDate'] as String;
    }

    // Update the user's lastAttendedDate
    await DatabaseHelper.instance.updateLastAttendedDate(
      studentId, 
      lastAttendedDate
    );
  }

  Future<void> deleteAttendance({
    required DateTime attendanceDate,
    required int studentId,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final formattedDate = _formatDate(attendanceDate);

    // Delete the attendance record
    final deletedRows = await db.delete(
      DatabaseHelper.attendanceTable,
      where: 'attendanceDate = ? AND studentId = ?',
      whereArgs: [formattedDate, studentId],
    );

    // If a record was actually deleted, update the last attended date
    if (deletedRows > 0) {
      await _updateLastAttendedDate(studentId);
    }
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
        _formatDate(startDate),
        _formatDate(endDate),
      ];
    }

    final result = await db.rawQuery('''
      SELECT A.attendanceDate, U.id, U.name
      FROM ${DatabaseHelper.attendanceTable} A
      JOIN ${DatabaseHelper.userTable} U ON A.studentId = U.id
      ${where != null ? 'WHERE $where' : ''}
      ORDER BY A.attendanceDate DESC, U.name ASC
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
    final formattedDate = _formatDate(attendanceDate);

    // Add the attendance record
    final insertedId = await db.insert(
      DatabaseHelper.attendanceTable,
      {
        'attendanceDate': formattedDate,
        'studentId': studentId,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    // If the record was successfully inserted (not ignored due to conflict),
    // check if this is the most recent attendance and update last attended date
    if (insertedId != 0) {
      // Get current last attended date for the student
      final userResult = await db.query(
        DatabaseHelper.userTable,
        columns: ['lastAttendedDate'],
        where: 'id = ?',
        whereArgs: [studentId],
      );

      if (userResult.isNotEmpty) {
        final currentLastAttended = userResult.first['lastAttendedDate'] as String?;
        
        // If this is the first attendance or this date is more recent, update it
        if (currentLastAttended == null || formattedDate.compareTo(currentLastAttended) > 0) {
          await DatabaseHelper.instance.updateLastAttendedDate(studentId, formattedDate);
        }
      }
    }
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
        _formatDate(startDate),
        _formatDate(endDate),
      ],
      orderBy: 'attendanceDate ASC',
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
    final formattedDate = _formatDate(attendanceDate);

    final result = await db.query(
      DatabaseHelper.attendanceTable,
      where: 'attendanceDate = ? AND studentId = ?',
      whereArgs: [formattedDate, studentId],
    );

    return result.isNotEmpty;
  }

  // Additional helper methods for last attended date functionality

  /// Get students with their last attended date information
  Future<List<Map<String, dynamic>>> getStudentsWithLastAttendance() async {
    final db = await DatabaseHelper.instance.database;
    
    final result = await db.rawQuery('''
      SELECT 
        U.id,
        U.name,
        U.mobile,
        U.email,
        U.lastAttendedDate,
        CASE 
          WHEN U.lastAttendedDate IS NULL THEN NULL
          ELSE julianday('now') - julianday(U.lastAttendedDate)
        END as daysSinceLastAttendance
      FROM ${DatabaseHelper.userTable} U
      ORDER BY U.lastAttendedDate DESC NULLS LAST, U.name ASC
    ''');

    return result.map((row) {
      final map = Map<String, dynamic>.from(row);
      // Convert daysSinceLastAttendance to int if it's not null
      if (map['daysSinceLastAttendance'] != null) {
        map['daysSinceLastAttendance'] = (map['daysSinceLastAttendance'] as double).round();
      }
      return map;
    }).toList();
  }

  /// Get students who haven't attended for more than specified days
  Future<List<Map<String, dynamic>>> getAbsentStudents(int days) async {
    final db = await DatabaseHelper.instance.database;
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final cutoffDateString = _formatDate(cutoffDate);
    
    final result = await db.rawQuery('''
      SELECT 
        U.id,
        U.name,
        U.mobile,
        U.email,
        U.lastAttendedDate,
        CASE 
          WHEN U.lastAttendedDate IS NULL THEN NULL
          ELSE julianday('now') - julianday(U.lastAttendedDate)
        END as daysSinceLastAttendance
      FROM ${DatabaseHelper.userTable} U
      WHERE U.lastAttendedDate IS NULL OR U.lastAttendedDate < ?
      ORDER BY U.lastAttendedDate ASC NULLS FIRST, U.name ASC
    ''', [cutoffDateString]);

    return result.map((row) {
      final map = Map<String, dynamic>.from(row);
      if (map['daysSinceLastAttendance'] != null) {
        map['daysSinceLastAttendance'] = (map['daysSinceLastAttendance'] as double).round();
      }
      return map;
    }).toList();
  }

  /// Bulk update last attended dates for all students (useful for data consistency)
  Future<void> refreshAllLastAttendedDates() async {
    final db = await DatabaseHelper.instance.database;
    
    // Get all students with their latest attendance
    final result = await db.rawQuery('''
      SELECT u.id, MAX(a.attendanceDate) as lastAttended
      FROM ${DatabaseHelper.userTable} u
      LEFT JOIN ${DatabaseHelper.attendanceTable} a ON u.id = a.studentId
      GROUP BY u.id
    ''');

    // Update each student's lastAttendedDate
    final batch = db.batch();
    for (final row in result) {
      final userId = row['id'] as int;
      final lastAttended = row['lastAttended'] as String?;
      
      batch.update(
        DatabaseHelper.userTable,
        {'lastAttendedDate': lastAttended},
        where: 'id = ?',
        whereArgs: [userId],
      );
    }
    
    await batch.commit(noResult: true);
  }
}