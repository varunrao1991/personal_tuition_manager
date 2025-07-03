import 'dart:developer';
import 'package:personal_tuition_manager/models/subject.dart';
import 'package:sqflite/sqflite.dart';
import '../helpers/database_helper.dart';

class SubjectResponse {
  final List<Subject> subjects;
  final int totalPages;
  final int totalRecords;
  final int currentPage;

  SubjectResponse({
    required this.subjects,
    required this.totalPages,
    required this.totalRecords,
    required this.currentPage,
  });
}

class SubjectService {
  SubjectService();

  Future<SubjectResponse> getSubjects({
    required int page,
    required String sort,
    required String order,
    String? name,
  }) async {
    final db = await DatabaseHelper.instance.database;

    const limit = 20;
    final offset = (page - 1) * limit;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (name != null && name.isNotEmpty) {
      whereClause = 'name LIKE ?';
      whereArgs = ['%$name%'];
    }

    final orderClause = '$sort ${order.toUpperCase()}';

    final totalQuery = await db.rawQuery(
      'SELECT COUNT(*) as count FROM Subject ${whereClause.isNotEmpty ? "WHERE $whereClause" : ""}',
      whereArgs,
    );
    final totalRecords = Sqflite.firstIntValue(totalQuery) ?? 0;
    final totalPages = (totalRecords / limit).ceil();

    final rows = await db.query(
      'Subject',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: orderClause,
      limit: limit,
      offset: offset,
    );

    final List<Subject> subjects = rows.map((row) {
      return Subject(
        id: row['id'] as int,
        name: row['name'] as String,
        description: row['description'] as String?,
        createdAt: row['createdAt'] != null
            ? DateTime.parse(row['createdAt'] as String)
            : DateTime.now(),
      );
    }).toList();

    return SubjectResponse(
      subjects: subjects,
      totalPages: totalPages,
      totalRecords: totalRecords,
      currentPage: page,
    );
  }

  Future<List<Subject>> getAllSubjects() async {
    final db = await DatabaseHelper.instance.database;

    final rows = await db.query(
      'Subject',
      orderBy: 'name ASC',
    );

    return rows.map((row) {
      return Subject(
        id: row['id'] as int,
        name: row['name'] as String,
        description: row['description'] as String?,
        createdAt: row['createdAt'] != null
            ? DateTime.parse(row['createdAt'] as String)
            : DateTime.now(),
      );
    }).toList();
  }

  Future<void> createSubject({
    required SubjectUpdate subjectUpdate,
  }) async {
    final db = await DatabaseHelper.instance.database;

    await db.insert(
      'Subject',
      {
        'name': subjectUpdate.name,
        'description': subjectUpdate.description,
        'createdAt': DateTime.now().toIso8601String(),
      },
    );

    log('Subject successfully created.');
  }

  Future<bool> anySubjectExists() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery('SELECT 1 FROM Subject LIMIT 1');

    return result.isNotEmpty;
  }

  Future<void> updateSubject({
    required SubjectUpdate subjectUpdate,
  }) async {
    final db = await DatabaseHelper.instance.database;

    await db.update(
      'Subject',
      {
        if (subjectUpdate.name != null) 'name': subjectUpdate.name,
        if (subjectUpdate.description != null) 'description': subjectUpdate.description,
      },
      where: 'id = ?',
      whereArgs: [subjectUpdate.id],
    );

    log('Subject successfully updated.');
  }

  Future<void> deleteSubject({
    required int subjectId,
  }) async {
    final db = await DatabaseHelper.instance.database;

    // Check if any courses are using this subject
    final coursesUsingSubject = await db.query(
      'Course',
      where: 'subjectId = ?',
      whereArgs: [subjectId],
    );

    if (coursesUsingSubject.isNotEmpty) {
      log('Warning: ${coursesUsingSubject.length} courses are associated with this subject. Their subjectId will be set to NULL.');
    }

    await db.delete(
      'Subject',
      where: 'id = ?',
      whereArgs: [subjectId],
    );

    log('Subject successfully deleted.');
  }

  Future<Subject?> getSubjectById(int id) async {
    final db = await DatabaseHelper.instance.database;

    final rows = await db.query(
      'Subject',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (rows.isEmpty) {
      return null;
    }

    final row = rows.first;
    return Subject(
      id: row['id'] as int,
      name: row['name'] as String,
      description: row['description'] as String?,
      createdAt: row['createdAt'] != null
          ? DateTime.parse(row['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Future<bool> isSubjectNameExists(String name, {int? excludeId}) async {
    final db = await DatabaseHelper.instance.database;

    String whereClause = 'LOWER(name) = ?';
    List<dynamic> whereArgs = [name.toLowerCase()];

    if (excludeId != null) {
      whereClause += ' AND id != ?';
      whereArgs.add(excludeId);
    }

    final result = await db.query(
      'Subject',
      where: whereClause,
      whereArgs: whereArgs,
      limit: 1,
    );

    return result.isNotEmpty;
  }

  Future<List<Subject>> searchSubjects(String query) async {
    final db = await DatabaseHelper.instance.database;

    final rows = await db.query(
      'Subject',
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );

    return rows.map((row) {
      return Subject(
        id: row['id'] as int,
        name: row['name'] as String,
        description: row['description'] as String?,
        createdAt: row['createdAt'] != null
            ? DateTime.parse(row['createdAt'] as String)
            : DateTime.now(),
      );
    }).toList();
  }

  Future<int> getSubjectUsageCount(int subjectId) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM Course WHERE subjectId = ?',
      [subjectId],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getSubjectsWithUsageCount() async {
    final db = await DatabaseHelper.instance.database;

    final rows = await db.rawQuery('''
      SELECT s.*, COUNT(c.subjectId) as usageCount
      FROM Subject s
      LEFT JOIN Course c ON s.id = c.subjectId
      GROUP BY s.id
      ORDER BY s.name ASC
    ''');

    return rows.map((row) {
      return {
        'subject': Subject(
          id: row['id'] as int,
          name: row['name'] as String,
          description: row['description'] as String?,
          createdAt: row['createdAt'] != null
              ? DateTime.parse(row['createdAt'] as String)
              : DateTime.now(),
        ),
        'usageCount': row['usageCount'] as int,
      };
    }).toList();
  }
}