import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/holiday.dart';

class StudentCalendar extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final List<Holiday> holidays;
  final List<int> weekdays;
  final List<DateTime> attendanceRecords;

  const StudentCalendar({
    super.key,
    required this.startDate,
    required this.holidays,
    required this.weekdays,
    required this.attendanceRecords,
    required this.endDate,
  });

  @override
  _StudentCalendarState createState() => _StudentCalendarState();
}

class _StudentCalendarState extends State<StudentCalendar> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = _getValidFocusedDate(DateTime.now());
  }

  DateTime _getValidFocusedDate(DateTime date) {
    if (date.isBefore(widget.startDate)) return widget.startDate;
    if (date.isAfter(widget.endDate)) return widget.endDate;
    return date;
  }

  @override
  Widget build(BuildContext context) {
    return _buildCalendar();
  }

  Widget _buildCalendar() {
    return TableCalendar(
      focusedDay: _selectedDate!,
      firstDay: widget.startDate,
      lastDay: widget.endDate,
      availableCalendarFormats: const {CalendarFormat.month: 'Month'},
      headerStyle: const HeaderStyle(titleCentered: true),
      calendarFormat: CalendarFormat.month,
      calendarStyle: _buildCalendarStyle(),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, date, focusedDay) {
          return _buildDayContainer(date);
        },
        todayBuilder: (context, date, focusedDay) {
          return _buildDayContainer(date);
        },
        selectedBuilder: (context, date, focusedDay) {
          return _buildDayContainer(date);
        },
      ),
      headerVisible: true,
    );
  }

  CalendarStyle _buildCalendarStyle() {
    return const CalendarStyle(
      todayDecoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
      ),
      todayTextStyle: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      selectedDecoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
      ),
      selectedTextStyle: TextStyle(color: Colors.black),
      defaultDecoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
      ),
      defaultTextStyle: TextStyle(color: Colors.black),
      weekendDecoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
      ),
      weekendTextStyle: TextStyle(color: Colors.black54),
    );
  }

  Widget _buildDayContainer(DateTime date) {
    DateTime today = DateTime.now();
    bool isHoliday =
        widget.holidays.any((holiday) => isSameDay(holiday.holidayDate, date));
    bool isWeekday = !widget.weekdays.contains(date.weekday);
    bool isAttended = widget.attendanceRecords
        .any((attendance) => isSameDay(attendance, date));
    bool isToday = isSameDay(date, today);

    bool isStartDate = isSameDay(date, widget.startDate);
    bool isEndDate = isSameDay(date, widget.endDate);
    bool isInRange =
        date.isAfter(widget.startDate) && date.isBefore(widget.endDate);

    BoxDecoration? stripDecoration;
    if (!isHoliday && !isWeekday) {
      if (isStartDate) {
        stripDecoration = BoxDecoration(
          color: date.isAfter(today)
              ? Colors.redAccent.withOpacity(0.3)
              : Colors.blueAccent.withOpacity(0.3),
          borderRadius:
              const BorderRadius.horizontal(left: Radius.circular(50.0)),
        );
      } else if (isEndDate) {
        stripDecoration = BoxDecoration(
          color: date.isAfter(today)
              ? Colors.redAccent.withOpacity(0.3)
              : Colors.blueAccent.withOpacity(0.3),
          borderRadius:
              const BorderRadius.horizontal(right: Radius.circular(50.0)),
        );
      } else if (isInRange) {
        stripDecoration = BoxDecoration(
          color: date.isAfter(today)
              ? Colors.redAccent.withOpacity(0.3)
              : Colors.blueAccent.withOpacity(0.3),
          shape: BoxShape.rectangle,
        );
      }
    } else {
      if (isStartDate) {
        stripDecoration = BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          borderRadius:
              const BorderRadius.horizontal(left: Radius.circular(50.0)),
        );
      } else if (isEndDate) {
        stripDecoration = BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          borderRadius:
              const BorderRadius.horizontal(right: Radius.circular(50.0)),
        );
      } else if (isInRange) {
        stripDecoration = BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          shape: BoxShape.rectangle,
        );
      }
    }

    // Determine the background color based on the day's status
    Color backgroundColor = Colors.transparent;

    Color textColor;
    if (isToday) {
      textColor = Theme.of(context).colorScheme.primary;
    } else if (isHoliday || !isWeekday) {
      textColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.7);
    } else {
      textColor = Theme.of(context).colorScheme.onSurface;
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: isToday
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : null,
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: stripDecoration ??
                BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                ),
            child: Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: textColor,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
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
    );
  }
}
