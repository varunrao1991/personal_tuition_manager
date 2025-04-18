import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import '../../models/teacher/student_model.dart';
import '../../models/teacher/student_update.dart';
import '../../helpers/database_helper.dart';

class StudentResponse {
  final List<Student> students;
  final int totalPages;
  final int totalRecords;
  final int currentPage;

  StudentResponse({
    required this.students,
    required this.totalPages,
    required this.totalRecords,
    required this.currentPage,
  });
}

class StudentService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  StudentService();

  Future<StudentResponse> getStudents({
    required int page,
    String? sort,
    String? order,
    String? name,
  }) async {
    final db = await _dbHelper.database;

    const limit = 20;
    final offset = (page - 1) * limit;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (name != null && name.isNotEmpty) {
      whereClause = 'name LIKE ?';
      whereArgs = ['%$name%'];
    }

    final orderClause = (sort != null && order != null)
        ? '$sort ${order.toUpperCase()}'
        : 'name ASC';

    final totalQuery = await db.rawQuery(
      'SELECT COUNT(*) as count FROM User ${whereClause.isNotEmpty ? "WHERE $whereClause" : ""}',
      whereArgs,
    );
    final totalRecords = Sqflite.firstIntValue(totalQuery) ?? 0;
    final totalPages = (totalRecords / limit).ceil();

    final rows = await db.query(
      'User',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: orderClause,
      limit: limit,
      offset: offset,
    );

    final List<Student> students = rows.map((row) {
      return Student(
        id: row['id'] as int,
        name: row['name'] as String,
        mobile: row['mobile'] as String,
        createdAt: row['createdAt'] != null
            ? DateTime.parse(row['createdAt'] as String)
            : DateTime.now(),
      );
    }).toList();

    return StudentResponse(
      students: students,
      totalPages: totalPages,
      totalRecords: totalRecords,
      currentPage: page,
    );
  }

  Future<void> createStudent({
    required StudentUpdate studentUpdate,
  }) async {
    final db = await _dbHelper.database;

    await db.insert(
      'User',
      {
        'name': studentUpdate.name,
        'mobile': studentUpdate.mobile,
        'createdAt': DateTime.now().toIso8601String(),
      },
    );

    log('Student successfully created.');
  }

  Future<bool> anyUserExists() async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery('SELECT 1 FROM User LIMIT 1');

    return result.isNotEmpty;
  }

  Future<void> updateStudent({
    required StudentUpdate studentUpdate,
  }) async {
    final db = await _dbHelper.database;

    await db.update(
      'User',
      {
        if (studentUpdate.name != null) 'name': studentUpdate.name,
        if (studentUpdate.mobile != null) 'mobile': studentUpdate.mobile,
      },
      where: 'id = ?',
      whereArgs: [studentUpdate.id],
    );

    log('Student successfully updated.');
  }

  Future<void> deleteStudent({
    required int studentId,
  }) async {
    final db = await _dbHelper.database;

    await db.delete(
      'User',
      where: 'id = ?',
      whereArgs: [studentId],
    );

    log('Student successfully deleted.');
  }

  Future<Student?> getStudentById(int id) async {
    final db = await _dbHelper.database;

    final rows = await db.query(
      'User',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (rows.isEmpty) {
      return null;
    }

    final row = rows.first;
    return Student(
        id: row['id'] as int,
        name: row['name'] as String,
        mobile: row['mobile'] as String,
        createdAt: row['createdAt'] != null
            ? DateTime.parse(row['createdAt'] as String)
            : DateTime.now());
  }
}
