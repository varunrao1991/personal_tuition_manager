
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../constants/app_constants.dart';
import '../../models/holiday.dart';
import '../../providers/teacher/holiday_provider.dart';
import '../../providers/teacher/weekday_provider.dart';
import '../../utils/handle_errors.dart';
import '../../utils/show_custom_center_modal.dart';
import '../../widgets/confirmation_modal.dart';
import '../../widgets/custom_fab.dart';
import '../../utils/show_custom_bottom_modal.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/custom_swipe_card.dart';
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
  bool _isLoading = false;
  List<int> _weekdays = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchHolidaysForVisibleRange();
      _fetchWeekdays();
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
    } catch (e) {
      handleErrors(context, e);
    } finally {
      _setLoading(false);
    }
  }

  void _fetchWeekdays() async {
    final weekdayProvider =
        Provider.of<WeekdayProvider>(context, listen: false);
    try {
      await weekdayProvider.fetchWeekdays();
      setState(() {
        _weekdays = weekdayProvider.weekdays;
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

  Future<void> _editWeekdays() async {
    showCustomModalBottomSheet(
        context: context,
        child: WeekdayEditorDialog(
          enabledWeekdayIds: _weekdays,
        )).then((selected) async {
      if (selected != null) {
        setState(() {
          _weekdays = selected;
        });
        try {
          final weekdayProvider =
              Provider.of<WeekdayProvider>(context, listen: false);
          await weekdayProvider.setWeekdays(_weekdays);
        } catch (e) {
          handleErrors(context, e);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Holidays',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(AppPaddings.smallPadding),
              child: Column(
                children: [
                  TableCalendar(
                    focusedDay: _focusedDate,
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.now().add(const Duration(days: 30)),
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
                      selectedBuilder: (context, date, _) => _buildDayContainer(
                          date,
                          isSelected: true,
                          isWeekday: _weekdays.contains(date.weekday)),
                      todayBuilder: (context, date, _) => _buildDayContainer(
                          date,
                          isToday: true,
                          isWeekday: _weekdays.contains(date.weekday)),
                      defaultBuilder: (context, date, _) => _buildDayContainer(
                          date,
                          isWeekday: _weekdays.contains(date.weekday),
                          isHoliday: Provider.of<HolidayProvider>(context,
                                  listen: false)
                              .holidays
                              .any((holiday) =>
                                  isSameDay(holiday.holidayDate, date))),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Consumer<HolidayProvider>(
                    builder: (context, holidayProvider, child) {
                      return Expanded(
                          child: _buildHolidayList(holidayProvider));
                    },
                  ),
                ],
              ),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomFAB(
            heroTag: 'holiday',
            icon: Provider.of<HolidayProvider>(context, listen: false)
                    .holidays
                    .any((holiday) =>
                        isSameDay(holiday.holidayDate, _selectedDate))
                ? Icons.edit
                : Icons.add,
            onPressed: () {
              Holiday? existingHoliday;

              bool holidayExists =
                  Provider.of<HolidayProvider>(context, listen: false)
                      .holidays
                      .any((holiday) =>
                          isSameDay(holiday.holidayDate, _selectedDate));

              if (holidayExists) {
                existingHoliday =
                    Provider.of<HolidayProvider>(context, listen: false)
                        .holidays
                        .firstWhere(
                          (holiday) =>
                              isSameDay(holiday.holidayDate, _selectedDate),
                          orElse: () =>
                              Holiday(holidayDate: _selectedDate, reason: ''),
                        );
              }
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
          const SizedBox(height: 16),
          CustomFAB(
            icon: Icons.calendar_today,
            onPressed: _editWeekdays,
          ),
        ],
      ),
    );
  }

  Widget _buildDayContainer(DateTime date,
      {bool isSelected = false,
      bool isToday = false,
      bool isWeekday = false,
      bool isHoliday = false}) {
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

    Color backgroundColor;
    if (isSelected) {
      backgroundColor = Colors.redAccent;
    } else if (isHoliday || !isWeekday) {
      backgroundColor =
          Theme.of(context).colorScheme.onSurface.withOpacity(0.2);
    } else {
      backgroundColor = Colors.transparent;
    }

    return Container(
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
      child: Center(
        child: Text(
          date.day.toString(),
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: textColor,
                fontWeight: (isSelected || isToday)
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
        ),
      ),
    );
  }

  Widget _buildHolidayList(HolidayProvider holidayProvider) {
    if (holidayProvider.holidays.isEmpty) {
      return Center(
        child: Text(
          'No holidays in this month.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1, // Slightly taller cards
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: holidayProvider.holidays.length,
      itemBuilder: (context, index) {
        final holiday = holidayProvider.holidays[index];
        final reasonText =
            holiday.reason.isEmpty ? 'No reason provided' : holiday.reason;

        return CustomSwipeCard(
          onSwipeLeft: () =>
              _showDeleteConfirmationDialog(context, holiday.holidayDate),
          onSwipeRight: () => _showEditHolidaySheet(context, holiday),
          child: Container(
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date section at top
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    // Big day number
                    Text(
                      DateFormat('d').format(holiday.holidayDate),
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(width: 6),
                    // Small month abbreviation
                    Text(DateFormat('MMM').format(holiday.holidayDate),
                        style: Theme.of(context).textTheme.headlineSmall),
                  ],
                ),

                // Reason centered below date
                Expanded(
                  child: Center(
                    child: Text(
                      reasonText,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).hintColor,
                          ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditHolidaySheet(BuildContext context, Holiday holiday) {
    showCustomModalBottomSheet(
      context: context,
      child: HolidayForm(
        selectedDate: holiday.holidayDate,
        reason: holiday.reason,
      ),
    ).then((result) async {
      if (result != null) {
        await _addHolidayToBackend(result['date'], result['reason']);
        _fetchHolidaysForVisibleRange();
      }
    });
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

  Future<void> _deleteHolidayFromBackend(DateTime date) async {
    final holidayProvider =
        Provider.of<HolidayProvider>(context, listen: false);
    try {
      await holidayProvider.deleteHoliday(date);
      _fetchHolidaysForVisibleRange();
      showCustomSnackBar(context, 'Holiday delete successfully!');
    } catch (e) {
      handleErrors(context, e);
    }
  }

  Future<void> _addHolidayToBackend(
      DateTime selectedDate, String reason) async {
    try {
      await Provider.of<HolidayProvider>(context, listen: false)
          .addHoliday(selectedDate, reason);
      showCustomSnackBar(context, 'Holiday added successfully.');
    } catch (e) {
      handleErrors(context, e);
    }
  }
}
