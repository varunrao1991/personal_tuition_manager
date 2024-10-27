import 'package:table_calendar/table_calendar.dart';

import '../models/holiday.dart';

DateTime calculateEndDate({
    required DateTime startDate,
    required int totalClasses,
    required List<Holiday> holidays,
    required List<int> weekdays,
  }) {
    DateTime endDate = startDate.subtract(const Duration(days: 1));
    int classesCount = 0;
    DateTime maxEndDate = startDate.add(Duration(days: totalClasses * 2));

    while (classesCount < totalClasses && endDate.isBefore(maxEndDate)) {
      endDate = endDate.add(const Duration(days: 1));
      if (!holidays.any((holiday) => isSameDay(holiday.holidayDate, endDate)) ||
          !weekdays.contains(endDate.weekday)) {
        classesCount++;
      }
    }
    return endDate;
  }