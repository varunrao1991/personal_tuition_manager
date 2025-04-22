import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../constants/app_constants.dart';
import '../../models/teacher/course.dart';
import '../../models/create_course.dart';
import '../../providers/teacher/attendance_provider.dart';
import '../../providers/teacher/course_provider.dart';
import '../../providers/teacher/holiday_provider.dart';
import '../../providers/teacher/weekday_provider.dart';
import '../../utils/calculate_enddate.dart';
import '../../utils/handle_errors.dart';
import '../../utils/show_custom_center_modal.dart';
import '../../widgets/custom_fab.dart';
import '../../utils/show_custom_bottom_modal.dart';
import '../../widgets/sort_modal.dart';
import '../../widgets/confirmation_modal.dart';
import '../common/app_scaffold.dart';
import 'widgets/add_course.dart';
import 'widgets/closed_course_card.dart';
import 'widgets/edit_course.dart';
import 'widgets/ongoing_course_card.dart';
import '../common/student_calender.dart';
import 'widgets/waitlist_course_card.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  _CourseScreenState createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  DateTime? _endDateToUse;
  late final TabController _tabController;

  static const Map<String, String> _sortFieldLabels = {
    'startDate': 'Start Date',
    'endDate': 'End Date',
    'totalClasses': 'Total Classes',
  };

  static const List<Map<String, String>> _tabs = [
    {'label': 'Ongoing', 'filter': 'ongoing'},
    {'label': 'Not Started', 'filter': 'waitlist'},
    {'label': 'Completed', 'filter': 'closed'},
  ];

  String _selectedSortField = 'startDate';
  bool _isAscending = true;
  bool _isLoading = false;
  int _currentTabIndex = 0;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchInitialData();
    });

    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchInitialData() async {
    final weekdayProvider =
        Provider.of<WeekdayProvider>(context, listen: false);
    try {
      await weekdayProvider.fetchWeekdays();
      await _fetchCourses(_currentTabIndex);
      setState(() => _isFirstLoad = false);
    } catch (e) {
      handleErrors(context, e);
    }
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      log('Tab index is still changing... skipping.');
      return;
    }

    final newIndex = _tabController.index;
    log('Tab changed. New index: $newIndex | Current index: $_currentTabIndex');

    if (newIndex != _currentTabIndex) {
      setState(() {
        _currentTabIndex = newIndex;
        log('Updated _currentTabIndex to $newIndex');
      });
      log('Fetching courses for tab index $newIndex');
      _fetchCourses(newIndex);
    } else {
      log('Same tab selected again. No state update or data fetch.');
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchCourses(int tabIndex) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final selectedFilter = _tabs[tabIndex]['filter']!;

    try {
      await _fetchAndProcessCourses(courseProvider, selectedFilter);
    } catch (e) {
      handleErrors(context, e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchAndProcessCourses(
      CourseProvider courseProvider, String selectedFilter) async {
    await courseProvider.fetchCourses(
      page: 1,
      sort: _selectedSortField,
      order: _isAscending ? 'ASC' : 'DESC',
      filterBy: selectedFilter,
    );

    await courseProvider.existsEligibleStudents();

    if (selectedFilter == 'ongoing' || selectedFilter == 'closed') {
      final courseList = courseProvider.coursesMap[selectedFilter];
      if (courseList != null && courseList.isNotEmpty) {
        await fetchHolidayData(courseList);
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreCourses();
    }
  }

  Future<void> _loadMoreCourses() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    try {
      if (courseProvider.currentPage < courseProvider.totalPages) {
        await courseProvider.fetchCourses(
          page: courseProvider.currentPage + 1,
          sort: _selectedSortField,
          order: _isAscending ? 'ASC' : 'DESC',
          filterBy: _tabs[_currentTabIndex]['filter']!,
        );
      }
    } catch (e) {
      handleErrors(context, e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Courses',
      actions: [
        IconButton(
          icon: const Icon(Icons.sort),
          onPressed: () => _openSortModal(context),
          tooltip: 'Sort courses',
        ),
      ],
      navigationBar: TabBar(
        controller: _tabController,
        tabs: _tabs.map((tab) => Tab(text: tab['label'])).toList(),
        onTap: (index) {
          if (index != _currentTabIndex) {
            _tabController.animateTo(index);
            setState(() => _currentTabIndex = index);
            _fetchCourses(index);
          }
        },
      ),
      body: _isFirstLoad
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              physics: const ClampingScrollPhysics(),
              children:
                  List.generate(_tabs.length, (index) => _buildCourseList()),
            ),
      floatingActionButton: Consumer<CourseProvider>(
        builder: (context, courseProvider, child) {
          return CustomFAB(
            icon: Icons.add,
            onPressed:
                courseProvider.hasEligibleStudents ? _openCourseForm : null,
            isEnabled: courseProvider.hasEligibleStudents,
            tooltip: 'Add new course',
          );
        },
      ),
    );
  }

  Widget _buildCourseList() {
    return Consumer<CourseProvider>(
      builder: (context, courseProvider, child) {
        final courses =
            courseProvider.coursesMap[_tabs[_currentTabIndex]['filter']] ?? [];

        if (_isLoading && courses.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (courses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.class_outlined,
                  size: 48,
                  color: Theme.of(context).disabledColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'No courses found',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).disabledColor,
                      ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _fetchCourses(_currentTabIndex),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: courses.length + (_isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= courses.length) {
                return const Center(child: CircularProgressIndicator());
              }
              return _buildCourseCard(courses[index]);
            },
          ),
        );
      },
    );
  }

  int calculateDaysPassedSinceStartToTodayExcludeOffs(DateTime startDate) {
    final weekdayProvider =
        Provider.of<WeekdayProvider>(context, listen: false);
    final holidayProvider =
        Provider.of<HolidayProvider>(context, listen: false);

    final holidays = holidayProvider.holidays;
    final weekdays = weekdayProvider.weekdays;
    int totalDays = 0;
    DateTime endDate = DateTime.now();

    for (DateTime date = startDate;
        !date.isAfter(endDate);
        date = date.add(const Duration(days: 1))) {
      if (holidays.any((holiday) => isSameDay(date, holiday.holidayDate)) ||
          !weekdays.contains(date.weekday)) {
        continue;
      }
      totalDays++;
    }
    return totalDays;
  }

  Widget _buildCourseCard(Course course) {
    final selectedTabFilter = _tabs[_currentTabIndex]['filter']!;

    switch (selectedTabFilter) {
      case 'ongoing':
        int completedDays =
            calculateDaysPassedSinceStartToTodayExcludeOffs(course.startDate!);
        return OngoingCourseCard(
          name: course.payment.student.name,
          startDate: course.startDate!,
          completedDays: completedDays,
          paymentDate: course.payment.paymentDate,
          totalClasses: course.totalClasses,
          noCredit: course.noCredit ?? false,
          onEdit: () => _editCourseForm(course),
          onDelete: () => _confirmDeleteCourse(course.paymentId),
          onUpdate: () => _startCourse(course.paymentId, course.startDate!),
          onClose: () => _closeCourse(
              course.paymentId, course.startDate!, course.totalClasses),
          onTap: () async {
            await fetchCalendarData(
              course.startDate!,
              course.endDate,
              course.paymentId,
              course.payment.student.id,
              course.totalClasses,
            );
          },
        );

      case 'closed':
        return ClosedCourseCard(
          name: course.payment.student.name,
          totalClasses: course.totalClasses,
          paymentDate: course.payment.paymentDate,
          startDate: course.startDate!,
          endDate: course.endDate!,
          onTap: () async {
            await fetchCalendarData(
              course.startDate!,
              course.endDate,
              course.paymentId,
              course.payment.student.id,
              course.totalClasses,
            );
          },
        );

      default: // 'waitlist'
        return WaitlistCourseCard(
          paymentId: course.paymentId,
          studentName: course.payment.student.name,
          totalClasses: course.totalClasses,
          paymentDate: course.payment.paymentDate,
          canStart: course.canStart ?? false,
          onEdit: () => _editCourseForm(course),
          onDelete: () => _confirmDeleteCourse(course.paymentId),
          onStart: () => _startCourse(
            course.paymentId,
            course.startDate ?? DateTime.now(),
          ),
        );
    }
  }

  DateTime _calculatePossibleEndDate(Course course) {
    return course.endDate ??
        course.startDate!.add(Duration(days: 2 * course.totalClasses));
  }

  Future<void> fetchHolidayData(List<Course> courses) async {
    final holidayProvider =
        Provider.of<HolidayProvider>(context, listen: false);
    final weekdayProvider =
        Provider.of<WeekdayProvider>(context, listen: false);

    if (courses.isEmpty) {
      return;
    }

    DateTime lowestStartDate = courses.first.startDate!;
    DateTime highestEndDate = _calculatePossibleEndDate(courses.first);

    for (var course in courses) {
      if (course.startDate!.isBefore(lowestStartDate)) {
        lowestStartDate = course.startDate!;
      }

      DateTime currentEndDate = _calculatePossibleEndDate(course);

      if (currentEndDate.isAfter(highestEndDate)) {
        highestEndDate = currentEndDate;
      }
    }

    await holidayProvider.fetchHolidays(
        startDate: lowestStartDate, endDate: highestEndDate);
    await weekdayProvider.fetchWeekdays();
  }

  Future<void> fetchCalendarData(DateTime startDate, DateTime? endDate,
      int courseId, int studentId, int totalClasses) async {
    final holidayProvider =
        Provider.of<HolidayProvider>(context, listen: false);
    final attendanceProvider =
        Provider.of<AttendanceProvider>(context, listen: false);
    final weekdayProvider =
        Provider.of<WeekdayProvider>(context, listen: false);

    _endDateToUse = endDate ??
        calculateEndDate(
          startDate: startDate,
          totalClasses: totalClasses,
          holidays: holidayProvider.holidays,
          weekdays: weekdayProvider.weekdays,
        );

    try {
      await attendanceProvider.fetchAttendancesForStudent(
          startDate: startDate, endDate: _endDateToUse!, studentId: studentId);
      await _viewCourseCalender(startDate);
    } catch (e) {
      handleErrors(context, e);
    }
  }

  Future<void> _openSortModal(BuildContext context) async {
    final result = await showCustomDialog<Map<String, dynamic>>(
      context: context,
      child: SortModal(
        title: 'Sort Courses',
        selectedSortField: _selectedSortField,
        sortOptions: _sortFieldLabels,
        isAscending: _isAscending,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedSortField = result['field'];
        _isAscending = result['order'];
        _fetchCourses(_tabController.index);
      });
    }
  }

  Future<void> _viewCourseCalender(DateTime startDate) async {
    try {
      final holidayProvider =
          Provider.of<HolidayProvider>(context, listen: false);
      final weekdayProvider =
          Provider.of<WeekdayProvider>(context, listen: false);
      final attendanceProvider =
          Provider.of<AttendanceProvider>(context, listen: false);

      final holidays = holidayProvider.holidays;
      final weekdays = weekdayProvider.weekdays;
      final attendanceRecords = attendanceProvider.attendanceDatesOfStudent;

      await showCustomModalBottomSheet<int>(
        context: context,
        child: Container(
            margin: const EdgeInsets.all(AppMargins.smallMargin),
            child: StudentCalendar(
              startDate: startDate,
              endDate: _endDateToUse!,
              holidays: holidays,
              weekdays: weekdays,
              attendanceRecords: attendanceRecords,
            )),
      );
    } catch (e) {
      handleErrors(context, e);
    }
  }

  Future<void> _openCourseForm() async {
    try {
      final course = await showCustomModalBottomSheet<CourseCreate>(
        context: context,
        child: const AddStudentCourseProcessWidget(),
      );

      if (course != null) {
        await Provider.of<CourseProvider>(context, listen: false)
            .addCourse(course.paymentId, course.totalClasses);
        _fetchCourses(_tabController.index);
      }
    } catch (e) {
      handleErrors(context, e);
    }
  }

  Future<void> _editCourseForm(Course course) async {
    try {
      final totalClasses = await showCustomModalBottomSheet<int>(
        context: context,
        child: EditCourseWidget(totalClasses: course.totalClasses),
      );
      if (totalClasses != null) {
        final courseProvider =
            Provider.of<CourseProvider>(context, listen: false);
        await courseProvider.updateCourse(course.paymentId, totalClasses);
      }
      _fetchCourses(_tabController.index);
    } catch (e) {
      handleErrors(context, e);
    }
  }

  Future<void> _startCourse(int courseId, DateTime initialStartDate) async {
    try {
      final startDate = await showDatePicker(
        context: context,
        initialDate: initialStartDate,
        lastDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 360)),
      );

      if (startDate != null) {
        await Provider.of<CourseProvider>(context, listen: false).startCourse(
          courseId,
          startDate,
        );
        _fetchCourses(_tabController.index);
      }
    } catch (e) {
      handleErrors(context, e);
    }
  }

  Future<void> _closeCourse(
      int courseId, DateTime courseStartDate, totalClasses) async {
    try {
      final holidayProvider =
          Provider.of<HolidayProvider>(context, listen: false);
      final weekdayProvider =
          Provider.of<WeekdayProvider>(context, listen: false);

      final endDateToUse = calculateEndDate(
        startDate: courseStartDate,
        totalClasses: totalClasses,
        holidays: holidayProvider.holidays,
        weekdays: weekdayProvider.weekdays,
      );

      final endDate = await showDatePicker(
        context: context,
        initialDate: endDateToUse,
        lastDate: DateTime.now(),
        firstDate: courseStartDate,
      );

      if (endDate != null) {
        await Provider.of<CourseProvider>(context, listen: false).endCourse(
          courseId,
          endDate,
        );
        _fetchCourses(_tabController.index);
      }
    } catch (e) {
      handleErrors(context, e);
    }
  }

  void _confirmDeleteCourse(int courseId) {
    showCustomDialog(
      context: context,
      child: const ConfirmationDialog(
        message: 'Delete this course?',
        confirmButtonText: 'Delete',
        cancelButtonText: 'Cancel',
      ),
    ).then((success) {
      if (success == true) {
        _deleteCourse(courseId);
      }
    });
  }

  Future<void> _deleteCourse(int courseId) async {
    try {
      await Provider.of<CourseProvider>(context, listen: false)
          .deleteCourse(courseId);
      _fetchCourses(_tabController.index);
    } catch (e) {
      handleErrors(context, e);
    }
  }
}
