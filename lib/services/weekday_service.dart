import 'dart:developer';
import '../exceptions/weekday_exception.dart';
import '../helpers/database_helper.dart';

class WeekdayService {
  WeekdayService();

  Future<void> setWeekdays(List<int> enabledDayIds) async {
    final db = await DatabaseHelper.instance.database;

    // Validate input
    if (enabledDayIds.any((dayId) => dayId < 1 || dayId > 7)) {
      throw WeekdayException(
          'Day IDs must be integers between 1 (Monday) and 7 (Sunday).');
    }

    try {
      // Begin transaction
      await db.transaction((txn) async {
        // First disable all weekdays
        await txn.update(
          DatabaseHelper.weekdayTable,
          {'isEnabled': 0},
        );

        // Then enable only the specified days
        for (final dayId in enabledDayIds) {
          await txn.update(
            DatabaseHelper.weekdayTable,
            {'isEnabled': 1},
            where: 'id = ?',
            whereArgs: [dayId],
          );
        }
      });

      log('Weekdays successfully updated: $enabledDayIds');
    } catch (e) {
      log('Error updating weekdays: $e');
      throw WeekdayException('Failed to update weekdays in database');
    }
  }

  Future<List<int>> getWeekdays() async {
    final db = await DatabaseHelper.instance.database;

    try {
      final List<Map<String, dynamic>> results = await db.query(
        DatabaseHelper.weekdayTable,
        where: 'isEnabled = ?',
        whereArgs: [1],
      );

      // Extract the IDs of enabled days
      List<int> enabledDayIds = results.map((day) => day['id'] as int).toList();
      return enabledDayIds;
    } catch (e) {
      log('Error retrieving weekdays: $e');
      throw WeekdayException('Failed to retrieve weekdays from database');
    }
  }

  Future<List<Map<String, dynamic>>> getAllWeekdays() async {
    final db = await DatabaseHelper.instance.database;

    try {
      return await db.query(
        DatabaseHelper.weekdayTable,
        orderBy: 'id',
      );
    } catch (e) {
      log('Error retrieving all weekdays: $e');
      throw WeekdayException('Failed to retrieve weekdays from database');
    }
  }

  Future<void> clearWeekdays() async {
    final db = await DatabaseHelper.instance.database;

    try {
      await db.update(
        DatabaseHelper.weekdayTable,
        {'isEnabled': 0},
      );
      log("Reset all weekdays to disabled");
    } catch (e) {
      log('Error clearing weekdays: $e');
      throw WeekdayException('Failed to clear weekdays in database');
    }
  }
}