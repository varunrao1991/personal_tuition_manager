import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import '../../helpers/database_helper.dart';
import '../../models/owned_by.dart';
import '../../models/create_payment.dart';
import '../../models/fetch_payment.dart';
import './student_service.dart';
import './course_service.dart';

class PaymentResponse {
  final List<Payment> payments;
  final int totalPages;
  final int totalRecords;
  final int currentPage;

  PaymentResponse({
    required this.payments,
    required this.totalPages,
    required this.totalRecords,
    required this.currentPage,
  });
}

class PaymentService {
  PaymentService();

  final StudentService _userService = StudentService();
  final CourseService _courseService = CourseService();

  Future<PaymentResponse> getPayments({
  required int page,
  String? sort,
  String? order,
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final db = await DatabaseHelper.instance.database;

  const limit = 20;
  final offset = (page - 1) * limit;

  String whereClause = '';
  List<dynamic> whereArgs = [];

  if (startDate != null && endDate != null) {
    whereClause = 'paymentDate BETWEEN ? AND ?';
    whereArgs = [
      startDate.toIso8601String(),
      endDate.toIso8601String(),
    ];
  }

  final orderClause = (sort != null && order != null)
      ? '$sort ${order.toUpperCase()}'
      : 'paymentDate DESC';

  final totalQuery = await db.rawQuery(
    'SELECT COUNT(*) as count FROM Payment ${whereClause.isNotEmpty ? "WHERE $whereClause" : ""}',
    whereArgs,
  );
  final totalRecords = Sqflite.firstIntValue(totalQuery) ?? 0;
  final totalPages = (totalRecords / limit).ceil();

  final rows = await db.query(
    'Payment',
    where: whereClause.isNotEmpty ? whereClause : null,
    whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    orderBy: orderClause,
    limit: limit,
    offset: offset,
  );

  final List<Payment> payments = [];

  for (var row in rows) {
    final student = await _userService.getStudentById(row['studentId'] as int);
    if (student == null) {
      log('Student not found for payment ID: ${row['id']} - Payment will be excluded');
      continue; // Skip this payment if the student is not found
    }

    final courseStatus = await _courseService.getCourseStatus(row['id'] as int);

    payments.add(Payment(
      id: row['id'] as int,
      amount: row['amount'] as int,
      paymentDate: DateTime.parse(row['paymentDate'] as String),
      ownedBy: OwnedBy(id: student.id, name: student.name),
      courseStatus: courseStatus,
    ));
  }

  return PaymentResponse(
    payments: payments,
    totalPages: totalPages,
    totalRecords: totalRecords,
    currentPage: page,
  );
}

  Future<void> addPayment({
    required CreatePayment createPayment,
  }) async {
    final db = await DatabaseHelper.instance.database;

    await db.insert(
      'Payment',
      {
        'amount': createPayment.amount,
        'paymentDate': createPayment.paymentDate.toIso8601String(),
        'studentId': createPayment.studentId,
      },
    );

    log('Payment successfully created.');
  }

  Future<int> getTotalAmountPayments({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery(
      '''
      SELECT SUM(amount) as total
      FROM Payment
      WHERE paymentDate BETWEEN ? AND ?
      ''',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    return result.first['total'] != null ? result.first['total'] as int : 0;
  }

  Future<Map<int, double>> getDailyTotalPayments({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery(
      '''
      SELECT paymentDate, SUM(amount) as total
      FROM Payment
      WHERE paymentDate BETWEEN ? AND ?
      GROUP BY paymentDate
      ''',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    final Map<int, double> dailyTotals = {};

    for (var row in result) {
      final date = DateTime.parse(row['paymentDate'] as String);
      dailyTotals[date.day] = (row['total'] as num).toDouble();
    }

    return dailyTotals;
  }

  Future<void> updatePayment({
    required CreatePayment updatePayment,
  }) async {
    final db = await DatabaseHelper.instance.database;

    await db.update(
      'Payment',
      {
        'amount': updatePayment.amount,
        'paymentDate': updatePayment.paymentDate.toIso8601String(),
        'studentId': updatePayment.studentId,
      },
      where: 'id = ?',
      whereArgs: [updatePayment.id],
    );

    log('Payment successfully updated.');
  }

  Future<void> deletePayment({
    required int paymentId,
  }) async {
    final db = await DatabaseHelper.instance.database;

    await db.delete(
      'Payment',
      where: 'id = ?',
      whereArgs: [paymentId],
    );

    log('Payment successfully deleted.');
  }
}
