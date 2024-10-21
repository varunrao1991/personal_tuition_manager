import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../constants/app_constants.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/holiday_provider.dart';
import '../../providers/weekday_provider.dart';
import '../../utils/handle_errors.dart';

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  _StudentAttendanceScreen createState() => _StudentAttendanceScreen();
}

class _StudentAttendanceScreen extends State<StudentAttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DateTime startDate = DateTime(_focusedDate.year, _focusedDate.month, 1);
      DateTime endDate = DateTime(_focusedDate.year, _focusedDate.month + 1, 0);
      _fetchForMonth(startDate, endDate);
      final weekDayProvider =
          Provider.of<WeekdayProvider>(context, listen: false);
      weekDayProvider.fetchWeekdays();
    });
  }

  void _fetchForMonth(DateTime startDate, DateTime endDate) async {
    setState(() {});

    final attendanceProvider =
        Provider.of<AttendanceProvider>(context, listen: false);
    final holidayProvider =
        Provider.of<HolidayProvider>(context, listen: false);
    try {
      await holidayProvider.fetchHolidays(
          startDate: startDate, endDate: endDate);
      await attendanceProvider.fetchAttendances(
          startDate: startDate,
          endDate: endDate,
          forceRefresh: true,
          myAttendance: true);
    } catch (e) {
      handleErrors(context, e);
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _onPageChanged(DateTime focusedDay) {
    if (focusedDay != _focusedDate) {
      DateTime startDate = DateTime(focusedDay.year, focusedDay.month, 1);
      DateTime endDate = DateTime(focusedDay.year, focusedDay.month + 1, 0);
      _fetchForMonth(startDate, endDate);

      setState(() {
        _focusedDate = focusedDay;
        _selectedDate = DateTime(_focusedDate.year, _focusedDate.month, 1);
      });
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (selectedDay != _selectedDate || focusedDay != _focusedDate) {
      setState(() {
        _selectedDate = selectedDay;
        _focusedDate = focusedDay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppPaddings.smallPadding),
        child: Column(
          children: [
            Consumer2<HolidayProvider, WeekdayProvider>(
              builder: (context, holidayProvider, weekdayProvider, child) {
                return TableCalendar(
                  focusedDay: _focusedDate,
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.now(),
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Month',
                  },
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    titleTextStyle: Theme.of(context).textTheme.headlineSmall!,
                  ),
                  calendarFormat: CalendarFormat.month,
                  calendarStyle: CalendarStyle(
                    todayDecoration: const BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    defaultDecoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    defaultTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface),
                    weekendDecoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    weekendTextStyle: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7)),
                  ),
                  selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                  onDaySelected: _onDaySelected,
                  onPageChanged: _onPageChanged,
                  calendarBuilders: CalendarBuilders(
                    selectedBuilder: (context, date, _) =>
                        _buildDayContainer(date, isSelected: true),
                    todayBuilder: (context, date, _) =>
                        _buildDayContainer(date, isToday: true),
                    defaultBuilder: (context, date, _) => _buildDayContainer(
                      date,
                      isWeekday:
                          weekdayProvider.weekdays.contains(date.weekday),
                      isHoliday: holidayProvider.holidays.any(
                          (holiday) => isSameDay(holiday.holidayDate, date)),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayContainer(DateTime date,
      {bool isToday = false,
      bool isSelected = false,
      bool isWeekday = false,
      bool isHoliday = false}) {
    DateTime dateTrimmed = DateTime(date.year, date.month, date.day);
    final attendanceProvider =
        Provider.of<AttendanceProvider>(context, listen: false);
    bool isAttended = attendanceProvider.attendances
        .any((attendance) => isSameDay(attendance.attendanceDate, dateTrimmed));

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.secondary
            : (isHoliday || !isWeekday
                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.3)
                : Colors.transparent),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Center(
            child: Text(
              '${date.day}',
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (isAttended)
            Positioned(
              right: 0.0,
              top: 0.0,
              child: Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 16.0,
              ),
            ),
        ],
      ),
    );
  }
}
