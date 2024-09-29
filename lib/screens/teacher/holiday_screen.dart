import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:padmayoga/providers/holiday_provider.dart';
import 'package:padmayoga/providers/weekday_provider.dart'; // Import the weekday provider
import 'package:padmayoga/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/holiday.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_fab.dart';
import '../../widgets/show_custom_bottom_modal.dart';
import 'weekday_edit.dart';
import 'widgets/add_holiday.dart';

class HolidayScreen extends StatefulWidget {
  const HolidayScreen({super.key});

  @override
  _HolidayScreenState createState() => _HolidayScreenState();
}

class _HolidayScreenState extends State<HolidayScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  List<Holiday> _holidays = [];
  bool _isLoading = false;
  List<bool> _isWeekdaySelected = List.filled(7, false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchHolidaysForVisibleRange();
      _fetchWeekdays(); // Fetch weekdays
    });
  }

  void _fetchHolidaysForVisibleRange() async {
    _setLoading(true);
    final holidayProvider =
        Provider.of<HolidayProvider>(context, listen: false);
    DateTime startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
    DateTime endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);

    try {
      await holidayProvider.fetchHolidays(
          startDate: startDate, endDate: endDate);
      setState(() {
        _holidays = holidayProvider.holidays;
      });
    } catch (error) {
      log('Error fetching holidays: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to fetch holiday data: ${error.toString()}')),
      );
    } finally {
      _setLoading(false);
    }
  }

  void _fetchWeekdays() async {
    final weekdayProvider =
        Provider.of<WeekdayProvider>(context, listen: false);
    try {
      await weekdayProvider.fetchWeekdays(); // Fetch weekdays from the provider
      setState(() {
        _isWeekdaySelected = List.generate(
            7, (index) => weekdayProvider.weekdays.contains(index));
      });
    } catch (error) {
      log('Error fetching weekdays: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to fetch weekdays: ${error.toString()}')),
      );
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
      _fetchHolidaysForVisibleRange();
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDate = selectedDay;
      _focusedDate = focusedDay;
    });
  }

  void _editWeekdays() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WeekdayEditorDialog(
          isSelected: _isWeekdaySelected, // Pass the selected weekdays
        );
      },
    ).then((selected) {
      if (selected != null) {
        setState(() {
          _isWeekdaySelected = selected; // Update the local selection
        });

        // Process selected weekdays for backend update
        final weekdayProvider =
            Provider.of<WeekdayProvider>(context, listen: false);
        List<int> selectedWeekdays = [];
        for (int i = 0; i < _isWeekdaySelected.length; i++) {
          if (_isWeekdaySelected[i]) {
            selectedWeekdays.add(i);
          }
        }

        // Update weekdays in backend
        weekdayProvider.setWeekdays(selectedWeekdays).then((_) {
          showCustomSnackBar(context, 'Weekdays updated successfully!');
        }).catchError((error) {
          showCustomSnackBar(
              context, 'Failed to update weekdays: ${error.toString()}');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Holiday? existingHoliday;

    bool holidayExists = _holidays
        .any((holiday) => isSameDay(holiday.holidayDate, _selectedDate));

    if (holidayExists) {
      existingHoliday = _holidays.firstWhere(
        (holiday) => isSameDay(holiday.holidayDate, _selectedDate),
        orElse: () => Holiday(holidayDate: _selectedDate, reason: ''),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Holidays'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 400,
                    child: TableCalendar(
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
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDate, day),
                      onDaySelected: _onDaySelected,
                      onPageChanged: _onPageChanged,
                      calendarBuilders: CalendarBuilders(
                        selectedBuilder: (context, date, _) =>
                            _buildDayContainer(date, isSelected: true),
                        todayBuilder: (context, date, _) =>
                            _buildDayContainer(date, isToday: true),
                        defaultBuilder: (context, date, _) =>
                            _buildDayContainer(
                                date,
                                isWeekday:
                                    _isWeekdaySelected[date.weekday % 7]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Expanded(
                    child: _buildHolidayList(),
                  )
                ],
              ),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomFAB(
            heroTag: 'holiday',
            icon: holidayExists ? Icons.edit : Icons.add,
            onPressed: () {
              showCustomModalBottomSheet(
                context: context,
                child: AddHolidayScreen(
                  selectedDate: _selectedDate,
                  reason: existingHoliday?.reason ?? '',
                ),
              ).then((result) async {
                if (result != null) {
                  DateTime selectedDate = result['date'];
                  String reason = result['reason'];
                  await _addHolidayToBackend(selectedDate, reason);
                  _fetchHolidaysForVisibleRange();
                }
              });
            },
          ),
          const SizedBox(height: 16), // Spacing between buttons
          CustomFAB(
            icon: Icons.calendar_today,
            onPressed: _editWeekdays, // Edit weekdays
          ),
        ],
      ),
    );
  }

  Future<void> _addHolidayToBackend(DateTime date, String reason) async {
    final holidayProvider =
        Provider.of<HolidayProvider>(context, listen: false);
    try {
      await holidayProvider.addHoliday(date, reason);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Holiday added successfully!')),
      );
    } catch (error) {
      showCustomSnackBar(context, 'Failed to add holiday: ${error.toString()}');
    }
  }

  Widget _buildDayContainer(DateTime date,
      {bool isSelected = false, bool isToday = false, bool isWeekday = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.redAccent
            : isToday
                ? Colors.blueAccent
                : isWeekday
                    ? Colors.grey[300] // Color for selected weekdays
                    : Colors.transparent,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        date.day.toString(),
        style: TextStyle(
          color:
              isSelected || isToday || isWeekday ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHolidayList() {
    return ListView.builder(
      itemCount: _holidays.length,
      itemBuilder: (context, index) {
        final holiday = _holidays[index];
        CustomCard(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Text(holiday.reason),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.date_range, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEE, d MMM y').format(holiday.holidayDate),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ));
      },
    );
  }
}
