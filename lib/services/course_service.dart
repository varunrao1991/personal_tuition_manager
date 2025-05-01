import 'package:sqflite/sqflite.dart';

import '../helpers/database_helper.dart';
import '../models/owned_by.dart';
import '../models/payment_info.dart';
import '../models/course.dart';

class CourseResponse {
  final List<Course> courses;
  final int totalPages;
  final int totalRecords;
  final int currentPage;

  CourseResponse({
    required this.courses,
    required this.totalPages,
    required this.totalRecords,
    required this.currentPage,
  });
}

class EligibleStudentResponse {
  final List<OwnedBy> students;
  final int totalPages;
  final int totalRecords;
  final int currentPage;

  EligibleStudentResponse({
    required this.students,
    required this.totalPages,
    required this.totalRecords,
    required this.currentPage,
  });
}

enum CourseStatus {
  noCourse, // No course (no row in the database for given paymentId)
  notStarted, // Course exists but startDate is null
  started, // Course exists and startDate is present but endDate is null
  closed, // Course exists, both startDate and endDate are present
}

class CourseService {
  

  Future<Course> createCourse(int totalClasses, int studentId) async {
    final db = await DatabaseHelper.instance.database;

    final studentResult = await db.query(
      'User',
      where: 'id = ?',
      whereArgs: [studentId],
    );

    if (studentResult.isEmpty) {
      throw Exception('Could not find the student selected. Id is $studentId');
    }

    final existingNotStarted = await db.rawQuery('''
      SELECT C.* FROM Course C
      JOIN Payment P ON C.paymentId = P.id
      WHERE C.startDate IS NULL AND P.studentId = ?
    ''', [studentId]);

    if (existingNotStarted.isNotEmpty) {
      throw Exception(
          'A course is already in a waitlist state for this student.');
    }

    final paymentResult = await db.rawQuery('''
      SELECT P.id FROM Payment P
      LEFT JOIN Course C ON P.id = C.paymentId
      WHERE P.studentId = ? AND C.paymentId IS NULL
      ORDER BY P.paymentDate ASC
      LIMIT 1
    ''', [studentId]);

    if (paymentResult.isEmpty) {
      throw Exception('Cannot create a course without an associated payment.');
    }

    final paymentId = paymentResult.first['id'] as int;

    await db.insert('Course', {
      'paymentId': paymentId,
      'totalClasses': totalClasses,
    });

    final paymentInfo = await _getPaymentInfo(db, paymentId);
    return Course(
        paymentId: paymentId,
        totalClasses: totalClasses,
        payment: paymentInfo,
        startDate: null,
        endDate: null);
  }

  Future<CourseStatus> getCourseStatus(int paymentId) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'Course',
      where: 'paymentId = ?',
      whereArgs: [paymentId],
      limit: 1,
    );

    if (result.isEmpty) {
      return CourseStatus.noCourse; // No course exists
    }

    final row = result.first;
    final String? startDate = row['startDate'] as String?;
    final String? endDate = row['endDate'] as String?;

    if (startDate == null) {
      return CourseStatus.notStarted; // Course not started (startDate is null)
    } else if (endDate == null) {
      return CourseStatus
          .started; // Course started (startDate is present, but no endDate)
    } else {
      return CourseStatus
          .closed; // Course is closed (both startDate and endDate are present)
    }
  }

Future<bool> hasEligibleStudents() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery('''
      SELECT 
        P.studentId
      FROM 
        Payment P
      LEFT OUTER JOIN 
        Course C ON P.id = C.paymentId
      GROUP BY 
        P.studentId
      HAVING 
        COUNT(CASE WHEN C.paymentId IS NULL THEN 1 END) > 0
        AND NOT COUNT(CASE WHEN C.paymentId IS NOT NULL AND C.startDate IS NULL THEN 1 END) > 0
    ''');

    return result.isNotEmpty;
  }

  Future<EligibleStudentResponse> getEligibleStudents(
      {required int page}) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery('''
      SELECT U.id, U.name
      FROM Payment P
      LEFT JOIN Course C ON P.id = C.paymentId
      JOIN User U ON P.studentId = U.id
      GROUP BY P.studentId
      HAVING 
        COUNT(CASE WHEN C.paymentId IS NULL THEN 1 END) > 0
        AND NOT COUNT(CASE WHEN C.paymentId IS NOT NULL AND C.startDate IS NULL THEN 1 END) > 0
    ''');

    final students = result
        .map((e) => OwnedBy(id: e['id'] as int, name: e['name'] as String))
        .toList();

    return EligibleStudentResponse(
      students: students,
      totalPages: 1,
      totalRecords: students.length,
      currentPage: page,
    );
  }

  Future<Course> startCourseById(
      int courseId, DateTime startDate) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery('''
      SELECT C.*, P.studentId FROM Course C
      JOIN Payment P ON C.paymentId = P.id
      JOIN User U ON P.studentId = U.id
      WHERE C.paymentId = ?
    ''', [courseId]);

    if (result.isEmpty) throw Exception('Course not found.');

    final row = result.first;
    final studentId = row['studentId'] as int;
    final existingStart = row['startDate'];
    final existingEnd = row['endDate'];

    if (existingStart != null && existingEnd != null) {
      throw Exception('Course is already closed.');
    }

    final ongoingResult = await db.rawQuery('''
      SELECT C.* FROM Course C
      JOIN Payment P ON C.paymentId = P.id
      WHERE C.startDate IS NOT NULL AND C.endDate IS NULL AND P.studentId = ? AND C.paymentId != ?
    ''', [studentId, courseId]);

    if (ongoingResult.isNotEmpty) {
      throw Exception('Student has an ongoing course.');
    }

    await db.update(
      'Course',
      {'startDate': startDate.toIso8601String()},
      where: 'paymentId = ?',
      whereArgs: [courseId],
    );

    final courseRow =
        await db.query('Course', where: 'paymentId = ?', whereArgs: [courseId]);
    final courseData = courseRow.first;

    final paymentInfo = await _getPaymentInfo(db, courseId);

    return Course(
        paymentId: courseId,
        startDate: startDate,
        totalClasses: courseData['totalClasses'] as int,
        payment: paymentInfo,
        endDate: null);
  }

  Future<Course> endCourseById(
      int courseId, DateTime endDate) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery('''
      SELECT C.* FROM Course C
      JOIN Payment P ON C.paymentId = P.id
      JOIN User U ON P.studentId = U.id
      WHERE C.startDate IS NOT NULL AND C.endDate IS NULL AND C.paymentId = ?
    ''', [courseId]);

    if (result.isEmpty) {
      throw Exception('This is not an ongoing course to close.');
    }

    await db.update(
      'Course',
      {'endDate': endDate.toIso8601String()},
      where: 'paymentId = ?',
      whereArgs: [courseId],
    );

    final courseRow =
        await db.query('Course', where: 'paymentId = ?', whereArgs: [courseId]);
    final courseData = courseRow.first;

    final paymentInfo = await _getPaymentInfo(db, courseId);

    return Course(
      paymentId: courseId,
      totalClasses: courseData['totalClasses'] as int,
      payment: paymentInfo,
      startDate: courseData['startDate'] != null
          ? DateTime.parse(courseData['startDate'] as String)
          : null,
      endDate: endDate,
    );
  }

  Future<Course> updateCourseById(
      int courseId, int totalClasses) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery('''
      SELECT C.* FROM Course C
      JOIN Payment P ON C.paymentId = P.id
      JOIN User U ON P.studentId = U.id
      WHERE C.paymentId = ? AND C.endDate IS NULL
    ''', [courseId]);

    if (result.isEmpty) throw Exception('Cannot update this course.');

    await db.update(
      'Course',
      {'totalClasses': totalClasses},
      where: 'paymentId = ?',
      whereArgs: [courseId],
    );

    final courseRow =
        await db.query('Course', where: 'paymentId = ?', whereArgs: [courseId]);
    final courseData = courseRow.first;

    final paymentInfo = await _getPaymentInfo(db, courseId);

    return Course(
      paymentId: courseId,
      totalClasses: totalClasses,
      payment: paymentInfo,
      startDate: courseData['startDate'] != null
          ? DateTime.parse(courseData['startDate'] as String)
          : null,
      endDate: courseData['endDate'] != null
          ? DateTime.parse(courseData['endDate'] as String)
          : null,
    );
  }

  Future<void> deleteCourse(int courseId) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery('''
      SELECT C.* FROM Course C
      JOIN Payment P ON C.paymentId = P.id
      JOIN User U ON P.studentId = U.id
      WHERE C.paymentId = ?
    ''', [courseId]);

    if (result.isEmpty) throw Exception('Course not found or access denied.');

    await db.delete('Course', where: 'paymentId = ?', whereArgs: [courseId]);
  }

  Future<PaymentInfo> _getPaymentInfo(Database db, int paymentId) async {
    final paymentRows = await db.rawQuery('''
      SELECT P.*, U.id as studentId, U.name as studentName
      FROM Payment P
      JOIN User U ON P.studentId = U.id
      WHERE P.id = ?
    ''', [paymentId]);

    if (paymentRows.isEmpty) {
      throw Exception('Payment info not found.');
    }

    final row = paymentRows.first;

    return PaymentInfo(
      amount: row['amount'] as int,
      paymentDate: DateTime.parse(row['paymentDate'] as String),
      student: OwnedBy(
        id: row['studentId'] as int,
        name: row['studentName'] as String,
      ),
    );
  }

  Future<CourseResponse> getCourses({
    int page = 1,
    int limit = 10,
    String? sortBy = 'totalClasses',
    String? sortOrder = 'DESC',
    String? filterBy,
  }) async {
    final db = await DatabaseHelper.instance.database;
    sortBy = sortBy ?? 'totalClasses';
    sortOrder = sortOrder ?? 'DESC';
    // Base query with joins
    var query = '''
      SELECT 
        C.paymentId,
        C.totalClasses,
        C.startDate,
        C.endDate,
        P.id as paymentId,
        P.amount,
        P.paymentDate,
        U.id as studentId,
        U.name as studentName
      FROM Course C
      JOIN Payment P ON C.paymentId = P.id
      JOIN User U ON P.studentId = U.id
    ''';

    final List<Object?> whereArgs = [];
    final List<String> whereClauses = [];

    // Apply filters
    if (filterBy != null) {
      switch (filterBy) {
        case 'ongoing':
          whereClauses.add('C.startDate IS NOT NULL');
          whereClauses.add('C.endDate IS NULL');
          break;
        case 'waitlist':
          whereClauses.add('C.startDate IS NULL');
          whereClauses.add('C.endDate IS NULL');
          break;
        case 'closed':
          whereClauses.add('C.startDate IS NOT NULL');
          whereClauses.add('C.endDate IS NOT NULL');
          break;
      }
    }

    if (whereClauses.isNotEmpty) {
      query += ' AND ${whereClauses.join(' AND ')}';
    }

    // Apply sorting
    query += ' ORDER BY C.$sortBy $sortOrder';

    // Apply pagination
    query += ' LIMIT ? OFFSET ?';
    whereArgs.addAll([limit, (page - 1) * limit]);

    // Execute main query
    final List<Map<String, dynamic>> results =
        await db.rawQuery(query, whereArgs);

    // Get total count for pagination
    final countQuery = '''
      SELECT COUNT(*) as total
      FROM Course C
      JOIN Payment P ON C.paymentId = P.id
      JOIN User U ON P.studentId = U.id
      ${whereClauses.isNotEmpty ? 'AND ${whereClauses.join(' AND ')}' : ''}
    ''';
    final countResult = await db.rawQuery(countQuery, []);
    final totalRecords = countResult.first['total'] as int;
    final totalPages = (totalRecords / limit).ceil();

    // Process results
    final courses = results.map((e) {
      final student = OwnedBy(
        id: e['studentId'] as int,
        name: e['studentName'] as String,
      );

      final payment = PaymentInfo(
        amount: (e['amount'] as num).toInt(),
        paymentDate: DateTime.parse(e['paymentDate'] as String),
        student: student,
      );

      return Course(
        paymentId: e['paymentId'] as int,
        startDate: e['startDate'] != null
            ? DateTime.parse(e['startDate'] as String)
            : null,
        endDate: e['endDate'] != null
            ? DateTime.parse(e['endDate'] as String)
            : null,
        totalClasses: e['totalClasses'] as int,
        payment: payment,
      );
    }).toList();

    // Additional logic for waitlist and ongoing filters
    if (filterBy == 'waitlist') {
      final studentIds =
          courses.map((c) => c.payment.student.id).toSet().toList();
      final ongoingStudentIds = await _getOngoingCourseStudents(db, studentIds);

      for (final course in courses) {
        course.canStart =
            !ongoingStudentIds.contains(course.payment.student.id);
      }
    } else if (filterBy == 'ongoing') {
      final studentIds =
          courses.map((c) => c.payment.student.id).toSet().toList();
      final nonStartedStudentIds = await _getNonStartedStudents(db, studentIds);

      for (final course in courses) {
        course.noCredit =
            !nonStartedStudentIds.contains(course.payment.student.id);
      }
    }

    return CourseResponse(
      courses: courses,
      totalPages: totalPages,
      totalRecords: totalRecords,
      currentPage: page,
    );
  }

  Future<Set<int>> _getOngoingCourseStudents(
      Database db, List<int> studentIds) async {
    final results = await db.rawQuery('''
      SELECT 
        C.paymentId,
        U.id as studentId
      FROM Course C
      JOIN Payment P ON C.paymentId = P.id
      JOIN User U ON P.studentId = U.id
      WHERE C.startDate IS NOT NULL 
      AND C.endDate IS NULL
      AND U.id IN (${studentIds.map((_) => '?').join(',')})
    ''', studentIds);

    return results.map((e) {
      return e['studentId'] as int;
    }).toSet();
  }

  Future<Set<int>> _getNonStartedStudents(
      Database db, List<int> studentIds) async {
    final results = await db.rawQuery('''
      SELECT 
        P.id,
        P.studentId
      FROM Payment P
      LEFT JOIN Course C ON P.id = C.paymentId
      WHERE P.studentId IN (${studentIds.map((_) => '?').join(',')})
      AND (C.paymentId IS NULL OR (C.startDate IS NULL AND C.endDate IS NULL))
    ''', studentIds);

    return results.map((e) {
      return e['studentId'] as int;
    }).toSet();
  }
}
