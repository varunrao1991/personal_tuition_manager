import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../constants/app_constants.dart';
import '../../models/attendance.dart';
import '../../providers/teacher/attendance_provider.dart';
import '../../providers/teacher/holiday_provider.dart';
import '../../providers/teacher/student_provider.dart';
import '../../providers/teacher/weekday_provider.dart';
import '../../utils/handle_errors.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_fab.dart';
import '../../utils/show_custom_bottom_modal.dart';
import '../common/app_scaffold.dart';
import 'widgets/mark_attendance.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  bool _loading = false;

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
      Provider.of<StudentProvider>(context, listen: false).loadStudentsExists();
    });
  }

  void _fetchForMonth(DateTime startDate, DateTime endDate) async {
    setState(() {
      _loading = true;
    });

    final attendanceProvider =
        Provider.of<AttendanceProvider>(context, listen: false);
    final holidayProvider =
        Provider.of<HolidayProvider>(context, listen: false);
    try {
      await holidayProvider.fetchHolidays(
          startDate: startDate, endDate: endDate);
      await attendanceProvider.fetchAttendances(
          startDate: startDate, endDate: endDate, forceRefresh: true);
    } catch (e) {
      handleErrors(context, e);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
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
    return AppScaffold(
      title: 'Attendances',
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
                    CalendarFormat.month: 'Month'
                  },
                  headerStyle: const HeaderStyle(titleCentered: true),
                  calendarFormat: CalendarFormat.month,
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
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
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    weekendDecoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    weekendTextStyle: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                    outsideDecoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    outsideTextStyle: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.3),
                    ),
                    holidayDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.2),
                    ),
                    holidayTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
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
                        (holiday) => isSameDay(holiday.holidayDate, date),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16.0),
            Consumer<AttendanceProvider>(
              builder: (context, attendanceProvider, child) {
                final attendancesForSelectedDate = attendanceProvider
                    .attendances
                    .where((attendance) =>
                        isSameDay(attendance.attendanceDate, _selectedDate))
                    .toList();

                return Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildAttendanceList(attendancesForSelectedDate),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: CustomFAB(
        icon: Icons.calendar_today,
        isEnabled:
            Provider.of<StudentProvider>(context, listen: true).anyUserExists,
        onPressed: () {
          showCustomModalBottomSheet(
            context: context,
            child: MarkAttendanceScreen(selectedDate: _selectedDate),
          ).then((success) async {
            if (success != null && success) {
              DateTime startDate =
                  DateTime(_focusedDate.year, _focusedDate.month, 1);
              DateTime endDate =
                  DateTime(_focusedDate.year, _focusedDate.month + 1, 0);
              _fetchForMonth(startDate, endDate);
            }
          });
        },
      ),
    );
  }

  Widget _buildDayContainer(DateTime date,
      {bool isToday = false,
      bool isSelected = false,
      bool isWeekday = true,
      bool isHoliday = false}) {
    DateTime dateTrimmed = DateTime(date.year, date.month, date.day);
    final attendanceProvider =
        Provider.of<AttendanceProvider>(context, listen: false);
    int attendanceCount = attendanceProvider.attendances
        .where(
            (attendance) => isSameDay(attendance.attendanceDate, dateTrimmed))
        .length;

    // Determine the background color based on the day's status
    Color backgroundColor;
    if (isSelected) {
      backgroundColor = Colors.redAccent;
    } else if (isHoliday || !isWeekday) {
      backgroundColor =
          Theme.of(context).colorScheme.onSurface.withOpacity(0.2);
    } else {
      backgroundColor = Colors.transparent;
    }

    // Determine the text color based on the day's status
    Color textColor;
    if (isSelected) {
      textColor = Colors.white;
    } else if (isToday) {
      textColor = Theme.of(context).colorScheme.primary;
    } else if (isHoliday || !isWeekday) {
      textColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.7);
    } else {
      textColor = Theme.of(context).colorScheme.onSurface;
    }

    return Container(
      margin: const EdgeInsets.all(4),
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Text(
              '${date.day}',
              style: TextStyle(
                color: textColor,
                fontWeight: (isToday || isSelected)
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
          if (attendanceCount > 0)
            Positioned(
              top: -4,
              right: -0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green[600],
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Center(
                  child: Text(
                    '$attendanceCount',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList(List<Attendance> attendanceList) {
    if (attendanceList.isEmpty) {
      return Center(
        child: Text(
          'No attendances for the selected date.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Number of columns
        crossAxisSpacing: 2, // Horizontal space between items
        mainAxisSpacing: 2, // Vertical space between items
        childAspectRatio: 1.2, // Width/height ratio for each item
      ),
      itemCount: attendanceList.length,
      itemBuilder: (context, index) {
        final attendance = attendanceList[index];

        return CustomCard(
          child: Center(
            child: Text(
              attendance.ownedBy.name,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}
