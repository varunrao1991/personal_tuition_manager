import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../constants/app_constants.dart';
import '../../models/holiday.dart';
import '../../models/student_course.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/holiday_provider.dart';
import '../../providers/student_course_provider.dart';
import '../../providers/weekday_provider.dart';
import '../../utils/handle_errors.dart';
import '../../utils/show_custom_center_modal.dart';
import '../../widgets/sort_modal.dart';
import '../common/student_calender.dart';
import 'widgets/closed_student_course_card.dart';
import 'widgets/ongoing_student_course_card.dart';
import 'widgets/waitlist_student_course_card.dart';

class StudentCourseScreen extends StatefulWidget {
  const StudentCourseScreen({super.key});

  @override
  _StudentCourseScreenState createState() => _StudentCourseScreenState();
}

class _StudentCourseScreenState extends State<StudentCourseScreen> {
  late ScrollController _scrollController;
  int? _showCourseId;
  bool _isLoading = false;
  bool _isCalendarLoading = false;
  bool _isCourseIdInitialized = false;

  static const Map<String, String> _sortFieldLabels = {
    'startDate': 'Start Date',
    'endDate': 'End Date',
    'totalClasses': 'Total Classes',
  };

  String _selectedSortField = 'startDate';
  bool _isAscending = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    await _fetchCourses();
    await Provider.of<WeekdayProvider>(context, listen: false).fetchWeekdays();
  }

  Future<void> _fetchCourses() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final studentCourseProvider =
          Provider.of<StudentCourseProvider>(context, listen: false);
      await studentCourseProvider.fetchCourses(
        page: 1,
        sort: _selectedSortField,
        order: _isAscending ? 'ASC' : 'DESC',
      );

      await _fetchHolidayData(studentCourseProvider.courses);
    } catch (e) {
      handleErrors(context, e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchHolidayData(List<StudentCourse> courses) async {
    if (courses.isEmpty) return;

    final holidayProvider =
        Provider.of<HolidayProvider>(context, listen: false);
    final weekdayProvider =
        Provider.of<WeekdayProvider>(context, listen: false);

    DateTime lowestStartDate = courses.first.startDate!;
    DateTime highestEndDate = _calculatePossibleEndDate(courses.first);

    for (var course in courses.skip(1)) {
      if (course.startDate!.isBefore(lowestStartDate)) {
        lowestStartDate = course.startDate!;
      }

      DateTime currentEndDate = _calculatePossibleEndDate(course);
      if (currentEndDate.isAfter(highestEndDate)) {
        highestEndDate = currentEndDate;
      }
    }

    await Future.wait([
      holidayProvider.fetchHolidays(
          startDate: lowestStartDate, endDate: highestEndDate),
      weekdayProvider.fetchWeekdays(),
    ]);
  }

  DateTime _calculatePossibleEndDate(StudentCourse course) {
    return course.endDate ??
        course.startDate!.add(Duration(days: 2 * course.totalClasses));
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

    final studentCourseProvider =
        Provider.of<StudentCourseProvider>(context, listen: false);

    try {
      if (studentCourseProvider.currentPage <
          studentCourseProvider.totalPages) {
        await studentCourseProvider.fetchCourses(
          page: studentCourseProvider.currentPage + 1,
          sort: _selectedSortField,
          order: _isAscending ? 'ASC' : 'DESC',
        );
      }
    } catch (e) {
      handleErrors(context, e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildSortButton(),
            Expanded(child: _buildCourseList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSortButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPaddings.smallPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _openSortModal(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseList() {
    return Consumer<StudentCourseProvider>(
      builder: (context, studentCourseProvider, child) {
        final courses = studentCourseProvider.courses;

        if (_isLoading && courses.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (courses.isEmpty) {
          return Center(
            child: Text(
              'No courses found',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        if (!_isCourseIdInitialized) {
          _showCourseId = courses
              .where((course) => course.startDate != null)
              .reduce((a, b) => a.startDate!.isAfter(b.startDate!) ? a : b)
              .paymentId;
          _isCourseIdInitialized = true;
        }

        return RefreshIndicator(
          onRefresh: _fetchCourses,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
                horizontal: AppPaddings.smallPadding),
            controller: _scrollController,
            itemCount: courses.length + (_isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < courses.length) {
                return _buildCourseCard(courses[index]);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildCourseCard(StudentCourse course) {
    final holidayProvider =
        Provider.of<HolidayProvider>(context, listen: false);
    final weekdayProvider =
        Provider.of<WeekdayProvider>(context, listen: false);

    if (course.startDate != null && course.endDate == null) {
      return OngoingStudentCourseCard(
        startDate: course.startDate!,
        completedDays: _calculateCompletedDays(
            course, holidayProvider.holidays, weekdayProvider.weekdays),
        paymentDate: course.payment.paymentDate,
        totalClasses: course.totalClasses,
        child: _showCourseId == course.paymentId
            ? _buildCourseCalendar(course)
            : null,
        onTap: () => _handleCourseTap(course),
      );
    } else if (course.startDate != null && course.endDate != null) {
      return ClosedStudentCourseCard(
        startDate: course.startDate!,
        endDate: course.endDate!,
        paymentDate: course.payment.paymentDate,
        totalClasses: course.totalClasses,
        child: _showCourseId == course.paymentId
            ? _buildCourseCalendar(course)
            : null,
        onTap: () => _handleCourseTap(course),
      );
    } else {
      return WaitlistStudentCourseCard(
        totalClasses: course.totalClasses,
        paymentDate: course.payment.paymentDate,
      );
    }
  }

  int _calculateCompletedDays(
      StudentCourse course, List<Holiday> holidays, List<int> weekdays) {
    int totalDays = 0;
    DateTime endDate = DateTime.now();
    for (DateTime date = course.startDate!;
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

  Widget _buildCourseCalendar(StudentCourse course) {
    if (_isCalendarLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final holidayProvider =
        Provider.of<HolidayProvider>(context, listen: false);
    final weekdayProvider =
        Provider.of<WeekdayProvider>(context, listen: false);
    final attendanceProvider =
        Provider.of<AttendanceProvider>(context, listen: false);

    final holidays = holidayProvider.holidays;
    final weekdays = weekdayProvider.weekdays;
    final attendanceRecords = attendanceProvider.attendances
        .map((attendance) => attendance.attendanceDate)
        .toList();

    DateTime endDate = course.endDate ??
        _calculateEndDate(
          startDate: course.startDate!,
          totalClasses: course.totalClasses,
          holidays: holidays,
          weekdays: weekdays,
        );

    return Container(
      margin: const EdgeInsets.all(AppMargins.tinyMargin),
      child: StudentCalendar(
        startDate: course.startDate!,
        endDate: endDate,
        holidays: holidays,
        weekdays: weekdays,
        attendanceRecords: attendanceRecords,
      ),
    );
  }

  DateTime _calculateEndDate({
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
      if (!_isHolidayOrInvalidWeekday(endDate, holidays, weekdays)) {
        classesCount++;
      }
    }
    return endDate;
  }

  bool _isHolidayOrInvalidWeekday(
      DateTime date, List<Holiday> holidays, List<int> weekdays) {
    return holidays.any((holiday) => isSameDay(holiday.holidayDate, date)) ||
        !weekdays.contains(date.weekday);
  }

  Future<void> _handleCourseTap(StudentCourse course) async {
    setState(() => _isCalendarLoading = true);

    try {
      if (_showCourseId != course.paymentId) {
        await _fetchCalendarData(course);
        setState(() => _showCourseId = course.paymentId);
      } else {
        setState(() => _showCourseId = null);
      }
    } catch (e) {
      handleErrors(context, e);
    } finally {
      setState(() => _isCalendarLoading = false);
    }
  }

  Future<void> _fetchCalendarData(StudentCourse course) async {
    final attendanceProvider =
        Provider.of<AttendanceProvider>(context, listen: false);
    final holidayProvider =
        Provider.of<HolidayProvider>(context, listen: false);
    final weekdayProvider =
        Provider.of<WeekdayProvider>(context, listen: false);

    DateTime endDate = course.endDate ??
        _calculateEndDate(
          startDate: course.startDate!,
          totalClasses: course.totalClasses,
          holidays: holidayProvider.holidays,
          weekdays: weekdayProvider.weekdays,
        );

    await attendanceProvider.fetchAttendances(
      startDate: course.startDate!,
      endDate: endDate,
      myAttendance: true,
    );
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
      });
      await _fetchCourses();
    }
  }
}
