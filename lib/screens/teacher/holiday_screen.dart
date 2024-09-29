import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:padmayoga/providers/holiday_provider.dart';
import 'package:padmayoga/providers/weekday_provider.dart'; // Import the weekday provider
import 'package:padmayoga/widgets/custom_snackbar.dart';
import 'package:padmayoga/widgets/custom_swipe_card.dart';
import 'package:padmayoga/widgets/show_custom_center_modal.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/holiday.dart';
import '../../widgets/confirmation_modal.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_fab.dart';
import '../../widgets/show_custom_bottom_modal.dart';
import 'widgets/weekday_edit.dart';
import 'widgets/holiday_form.dart';

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
      showCustomSnackBar(
          context, 'Failed to fetch holiday data: ${error.toString()}');
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
      showCustomSnackBar(
          context, 'Failed to fetch weekdays: ${error.toString()}');
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
    showCustomModalBottomSheet(
        context: context,
        child: WeekdayEditorDialog(
          isSelected: _isWeekdaySelected, // Pass the selected weekdays
        )).then((selected) {
      if (selected != null) {
        setState(() {
          _isWeekdaySelected = selected;
        });

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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 350,
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
                            _buildDayContainer(date,
                                isWeekday: _isWeekdaySelected[date.weekday % 7],
                                isHoliday: _holidays.any((holiday) =>
                                    isSameDay(holiday.holidayDate, date))),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2.0),
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
                child: HolidayForm(
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
      showCustomSnackBar(context, 'Holiday added successfully!');
    } catch (error) {
      showCustomSnackBar(context, 'Failed to add holiday: ${error.toString()}');
    }
  }

  Future<void> _deleteHolidayFromBackend(DateTime date) async {
    final holidayProvider =
        Provider.of<HolidayProvider>(context, listen: false);
    try {
      await holidayProvider.deleteHoliday(date);
      _fetchHolidaysForVisibleRange();
      showCustomSnackBar(context, 'Holiday delete successfully!');
    } catch (error) {
      showCustomSnackBar(context, 'Failed to add holiday: ${error.toString()}');
    }
  }

  Widget _buildDayContainer(DateTime date,
      {bool isSelected = false,
      bool isToday = false,
      bool isWeekday = false,
      bool isHoliday = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.redAccent
            : isToday
                ? Colors.blueAccent
                : isHoliday
                    ? Colors.indigoAccent.shade700
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
              isSelected || isToday || isHoliday ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, DateTime holidayDate) {
    showCustomDialog(
      context: context,
      child: const ConfirmationDialog(
        message: 'Are you sure you want to delete this holiday?',
        confirmButtonText: 'Delete',
        cancelButtonText: 'Cancel',
        confirmButtonColor: Colors.redAccent,
        cancelButtonColor: Colors.grey,
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        _deleteHolidayFromBackend(holidayDate);
      }
    });
  }

  Widget _buildHolidayList() {
    return ListView.builder(
      itemCount: _holidays.length,
      itemBuilder: (context, index) {
        final holiday = _holidays[index];

        return CustomSwipeCard(
          onSwipeLeft: () {
            _showDeleteConfirmationDialog(context, holiday.holidayDate);
          },
          onSwipeRight: () {
            showCustomModalBottomSheet(
              context: context,
              child: HolidayForm(
                selectedDate: holiday.holidayDate,
                reason: holiday.reason,
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
          child: Container(
            margin: const EdgeInsets.only(top: 4.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    holiday.reason,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
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
              ),
            ),
          ),
        );
      },
    );
  }
}
