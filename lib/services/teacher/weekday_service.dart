import 'dart:developer';
import 'dart:convert';
import '../../exceptions/weekday_exception.dart';
import '../../utils/shared_pref.dart';

class WeekdayService {
  static const String _weekdaysKey = 'weekdays';

  WeekdayService();

  Future<void> setWeekdays(List<int> days) async {
    if (days.any((day) => day < 0 || day > 6)) {
      throw WeekdayException(
          'Days must be integers between 0 (Sunday) and 6 (Saturday).');
    }

    // Convert the list to a JSON string for storage
    String daysJson = jsonEncode(days);
    await sharedPrefs.saveString(_weekdaysKey, daysJson);
    
    log('Weekdays successfully saved: $days');
  }

  Future<List<int>> getWeekdays() async {
    final daysJson = await sharedPrefs.getString(_weekdaysKey);
    
    if (daysJson == null || daysJson.isEmpty) {
      // Return default value (all days) if no preference is saved
      return [0, 1, 2, 3, 4, 5, 6]; // All days of the week
    }
    
    try {
      final List<dynamic> decoded = jsonDecode(daysJson);
      List<int> weekdays = decoded.map((day) => day as int).toList();
      return weekdays;
    } catch (e) {
      log('Error parsing weekdays from shared preferences: $e');
      // Return default value on error
      return [0, 1, 2, 3, 4, 5, 6];
    }
  }

  Future<void> clearWeekdays() async {
    await sharedPrefs.clear(_weekdaysKey);
    log("Cleared weekdays preference");
  }
}