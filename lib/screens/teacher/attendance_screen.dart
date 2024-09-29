import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:padmayoga/models/attendance.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/custom_fab.dart';
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAttendanceCountsForVisibleRange();
    });
  }

  void _fetchAttendanceCountsForVisibleRange() async {
    _setLoading(true);
    final attendanceProvider =
        Provider.of<AttendanceProvider>(context, listen: false);
    DateTime startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
    DateTime endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);

    try {
      await attendanceProvider.fetchAttendances(
          startDate: startDate, endDate: endDate);
      setState(() {
        _attendanceList = attendanceProvider.attendances;
      });
    } catch (error) {
      log('Error fetching attendances: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Failed to fetch attendance data: ${error.toString()}')),
      );
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDate = focusedDay;
      final today = DateTime.now();
      if (today.month == focusedDay.month && today.year == focusedDay.year) {
        _selectedDate = DateTime(today.year, today.month, today.day);
      } else {
        _selectedDate = DateTime(_focusedDate.year, _focusedDate.month, 1);
      }
      _fetchAttendanceCountsForVisibleRange();
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDate = selectedDay;
      _focusedDate = focusedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: TableCalendar(
                focusedDay: _focusedDate,
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.now(),
                availableCalendarFormats: const {CalendarFormat.month: 'Month'},
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
                  defaultBuilder: (context, date, _) =>
                      _buildDayContainer(date),
                ),
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
              _fetchAttendanceCountsForVisibleRange();
            }
          });
        },
      ),
    );
  }

  void _fetchAttendanceForSelectedDay() async {
    final attendanceProvider =
        Provider.of<AttendanceProvider>(context, listen: false);

    DateTime startDate =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    DateTime endDate = startDate.add(const Duration(days: 1));

    try {
      await attendanceProvider.fetchAttendances(
          startDate: startDate, endDate: endDate);
      setState(() {
        _attendanceList = attendanceProvider.attendances;
      });
    } catch (error) {
      log('Error fetching attendances: $error');
    }
  }

  Widget _buildDayContainer(DateTime date,
      {bool isToday = false, bool isSelected = false}) {
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
            : (isToday ? Colors.blueAccent : Colors.transparent),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Center(
            child: Text(
              '${date.day}',
              style: TextStyle(
                color: isSelected || isToday ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (attendanceCount > 0)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 6), // Slightly larger padding
                decoration: BoxDecoration(
                  color: Colors.orangeAccent,
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
}
