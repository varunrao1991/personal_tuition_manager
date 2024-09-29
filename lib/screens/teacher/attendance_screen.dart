import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:padmayoga/models/attendance.dart';
import 'package:padmayoga/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/holiday_provider.dart';
import '../../providers/weekday_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_fab.dart';
import '../../widgets/custom_swipe_card.dart';
import '../../widgets/show_custom_bottom_modal.dart';
import 'widgets/mark_attendance.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  List<Attendance> _attendanceList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchForMonth();
    });
  }

  // Fetch attendance data for the selected month
  void _fetchForMonth() async {
    final attendanceProvider =
        Provider.of<AttendanceProvider>(context, listen: false);
    DateTime startDate = DateTime(_focusedDate.year, _focusedDate.month, 1);
    DateTime endDate = DateTime(_focusedDate.year, _focusedDate.month + 1, 0);

    try {
      await attendanceProvider.fetchAttendances(
          startDate: startDate, endDate: endDate);
      _updateAttendanceList(attendanceProvider.attendances);
    } catch (error) {
      log('Error fetching attendances: $error');
      showCustomSnackBar(
          context, 'Failed to fetch attendance data: ${error.toString()}');
    }
  }

  void _updateAttendanceList(List<Attendance> attendances) {
    setState(() {
      _attendanceList = attendances;
    });
  }

  // Update calendar when the page (month) is changed
  void _onPageChanged(DateTime focusedDay) {
    if (focusedDay != _focusedDate) {
      setState(() {
        _focusedDate = focusedDay;
        _selectedDate = DateTime(_focusedDate.year, _focusedDate.month, 1);
      });
      _fetchForMonth();
    }
  }

  // Update selected day on the calendar
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
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Using Consumer to listen for changes in HolidayProvider and WeekdayProvider
            Consumer2<HolidayProvider, WeekdayProvider>(
              builder: (context, holidayProvider, weekdayProvider, child) {
                return TableCalendar(
                  focusedDay: _focusedDate,
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.now(),
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Month'
                  },
                  headerStyle: const HeaderStyle(titleCentered: true),
                  calendarFormat: CalendarFormat.month,
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: TextStyle(color: Colors.white),
                    defaultDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    defaultTextStyle: TextStyle(color: Colors.black),
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
            const SizedBox(height: 16.0),
            Expanded(child: _buildAttendanceList()),
          ],
        ),
      ),
      floatingActionButton: CustomFAB(
        icon: Icons.calendar_today,
        onPressed: () {
          showCustomModalBottomSheet(
            context: context,
            child: MarkAttendanceScreen(selectedDate: _selectedDate),
          ).then((success) {
            if (success != null && success) {
              _fetchForMonth(); // Re-fetch attendances after marking
            }
          });
        },
      ),
    );
  }

  // Build day container with attendance count, holidays, and weekdays
  Widget _buildDayContainer(DateTime date,
      {bool isToday = false,
      bool isSelected = false,
      bool isWeekday = false,
      bool isHoliday = false}) {
    DateTime dateTrimmed = DateTime(date.year, date.month, date.day);

    List<Attendance> attendancesForDate = _attendanceList
        .where((attendance) =>
            DateTime(
                attendance.attendanceDate.year,
                attendance.attendanceDate.month,
                attendance.attendanceDate.day) ==
            dateTrimmed)
        .toList();

    int attendanceCount = attendancesForDate.length;

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.redAccent
            : (isHoliday || isWeekday ? Colors.grey[300] : Colors.transparent),
        shape: BoxShape.circle,
        border: isToday
            ? Border.all(color: Colors.black, width: 1)
            : null, // Border for today
      ),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Center(
            child: Text(
              '${date.day}',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (attendanceCount > 0)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$attendanceCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Build a list of attendance records
  Widget _buildAttendanceList() {
    return ListView.builder(
      itemCount: _attendanceList.length,
      itemBuilder: (context, index) {
        final attendance = _attendanceList[index];

        return CustomCard(
          child: Container(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attendance.ownedBy.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEE, d MMM y')
                        .format(attendance.attendanceDate),
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
