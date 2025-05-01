import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import '../../helpers/database_helper.dart';
import '../../models/holiday.dart';

class HolidayService {
  

  HolidayService();

  Future<List<Holiday>> getHolidays(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'Holiday',
      where: 'holidayDate BETWEEN ? AND ?',
      whereArgs: [
        startDate.toIso8601String().split('T').first,
        endDate.toIso8601String().split('T').first
      ],
      orderBy: 'holidayDate ASC',
    );

    return result.map((e) => Holiday(
      holidayDate: DateTime.parse(e['holidayDate'] as String),
      reason: e['reason'] as String,
    )).toList();
  }

  Future<void> addHoliday(DateTime holidayDate, String reason) async {
    final db = await DatabaseHelper.instance.database;

    final formattedDate = holidayDate.toIso8601String().split('T').first;

    await db.insert(
      'Holiday',
      {
        'holidayDate': formattedDate,
        'reason': reason,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    log('Holiday successfully upserted.');
  }

  Future<void> deleteHoliday({
    required DateTime holidayDate,
  }) async {
    final db = await DatabaseHelper.instance.database;

    final formattedDate = holidayDate.toIso8601String().split('T').first;

    final deleted = await db.delete(
      'Holiday',
      where: 'holidayDate = ?',
      whereArgs: [formattedDate],
    );

    if (deleted > 0) {
      log('Holiday successfully deleted.');
    } else {
      log('No holiday found to delete.');
    }
  }
}
