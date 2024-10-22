import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../constants/app_constants.dart';
import '../../models/teacher/course.dart';
import '../../models/create_course.dart';
import '../../models/holiday.dart';
import '../../providers/teacher/attendance_provider.dart';
import '../../providers/teacher/course_provider.dart';
import '../../providers/teacher/holiday_provider.dart';
import '../../providers/teacher/weekday_provider.dart';
import '../../utils/handle_errors.dart';
import '../../utils/show_custom_center_modal.dart';
import '../../widgets/custom_fab.dart';
import '../../utils/show_custom_bottom_modal.dart';
import '../../widgets/sort_modal.dart';
import '../../widgets/confirmation_modal.dart';
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
  late TabController _tabController;
  DateTime? _endDateToUse;

  static const Map<String, String> _sortFieldLabels = {
    'startDate': 'Start Date',
    'endDate': 'End Date',
    'totalClasses': 'Total Classes',
  };

  static const Map<int, Map<String, String>> _tabs = {
    0: {'label': 'Ongoing', 'filter': 'ongoing'},
    1: {'label': 'Not Started', 'filter': 'waitlist'},
    2: {'label': 'Completed', 'filter': 'closed'},
  };

  String _selectedSortField = 'startDate';
  bool _isAscending = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _fetchCourses(_tabController.index);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchCourses(_tabController.index);
      final weekdayProvider =
          Provider.of<WeekdayProvider>(context, listen: false);
      await weekdayProvider.fetchWeekdays();
    });

    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchCourses(int tabIndex) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    String selectedFilter = _getFilterByTabIndex(tabIndex);

    try {
      await _fetchAndProcessCourses(courseProvider, selectedFilter);
    } catch (e) {
      handleErrors(context, e);
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      if (courseList != null) {
        await fetchHolidayData(courseList);
      }
    }
  }

  String _getFilterByTabIndex(int tabIndex) {
    return _tabs[tabIndex]?['filter'] ?? 'ongoing';
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreCourses();
    }
  }

  Future<void> _loadMoreCourses() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    try {
      if (courseProvider.currentPage < courseProvider.totalPages) {
        await courseProvider.fetchCourses(
          page: courseProvider.currentPage + 1,
          sort: _selectedSortField,
          order: _isAscending ? 'ASC' : 'DESC',
          filterBy: _getFilterByTabIndex(_tabController.index),
        );
      }
    } catch (e) {
      handleErrors(context, e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppPaddings.smallPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    icon: const Icon(Icons.sort),
                    onPressed: () => _openSortModal(context)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.keys.map((index) => _buildCourseList()).toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: TabBar(
        controller: _tabController,
        tabs: _tabs.values.map((tab) => Tab(text: tab['label'])).toList(),
      ),
      floatingActionButton: Consumer<CourseProvider>(
        builder: (context, courseProvider, child) {
          return CustomFAB(
            icon: Icons.add,
            onPressed:
                courseProvider.hasEligibleStudents ? _openCourseForm : null,
            isEnabled: courseProvider.hasEligibleStudents,
          );
        },
      ),
    );
  }

  Widget _buildCourseList() {
    return Consumer<CourseProvider>(
      builder: (context, courseProvider, child) {
        final courses = courseProvider
                .coursesMap[_getFilterByTabIndex(_tabController.index)] ??
            [];
        if (_isLoading) {
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

        return RefreshIndicator(
          onRefresh: () => _fetchCourses(_tabController.index),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: AppPaddings.smallPadding),
            child: Column(
              children: [
                ...List.generate(
                  courses.length,
                  (index) =>
                      _buildCourseCard(courses[index], _tabController.index),
                ),
                if (_isLoading &&
                    courseProvider.currentPage < courseProvider.totalPages)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        );
      },
    );
  }

  DateTime _calculateEndDate({
    required DateTime startDate,
    required int totalClasses,
    required List<DateTime> holidays,
    required List<int> weekdays,
  }) {
    DateTime endDate = startDate.subtract(const Duration(days: 1));
    int classesCount = 0;

    DateTime maxEndDate = startDate.add(Duration(days: totalClasses * 2));

    while (classesCount < totalClasses) {
      endDate = endDate.add(const Duration(days: 1));
      if (!_isHolidayOrInvalidWeekday(endDate, holidays, weekdays)) {
        classesCount++;
      }
      if (endDate.isAfter(maxEndDate)) {
        return maxEndDate;
      }
    }
    return endDate;
  }

  bool _isHolidayOrInvalidWeekday(
      DateTime date, List<DateTime> holidays, List<int> weekdays) {
    return holidays.any((holiday) => isSameDay(holiday, date)) ||
        !weekdays.contains(date.weekday);
  }

  Future<void> _viewCourseCalender(Course course) async {
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
              startDate: course.startDate!,
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

  int calculateDaysPassedSinceStartToTodayExcludeOffs({
    required DateTime startDate,
    required List<Holiday> holidays,
    required List<int> excludedWeekdays,
  }) {
    int totalDays = 0;
    DateTime endDate = DateTime.now();
    for (DateTime date = startDate;
        !date.isAfter(endDate);
        date = date.add(const Duration(days: 1))) {
      if (holidays.any((holiday) => isSameDay(date, holiday.holidayDate)) ||
          !excludedWeekdays.contains(date.weekday)) {
        continue;
      }
      totalDays++;
    }
    return totalDays;
  }

  Widget _buildCourseCard(Course course, int tabIndex) {
    final String studentName = course.payment.student.name;
    final int studentId = course.payment.student.id;
    final int totalClasses = course.totalClasses;
    final DateTime paymentDate = course.payment.paymentDate;
    final bool canStart = course.canStart ?? false;
    final bool noCredit = course.noCreatit ?? false;

    final selectedTabFilter = _getFilterByTabIndex(tabIndex);
    switch (selectedTabFilter) {
      case 'ongoing':
        final weekdayProvider =
            Provider.of<WeekdayProvider>(context, listen: false);
        final holidayProvider =
            Provider.of<HolidayProvider>(context, listen: false);

        final holidays = holidayProvider.holidays;
        final weekdays = weekdayProvider.weekdays;
        int completedDays = calculateDaysPassedSinceStartToTodayExcludeOffs(
          startDate: course.startDate!,
          holidays: holidays,
          excludedWeekdays: weekdays,
        );
        return OngoingCourseCard(
          name: studentName,
          startDate: course.startDate!,
          completedDays: completedDays,
          paymentDate: paymentDate,
          totalClasses: totalClasses,
          noCredit: noCredit,
          onEdit: () => _editCourseForm(course),
          onDelete: () => _confirmDeleteCourse(course.paymentId),
          onUpdate: () => _startCourse(
            course.paymentId,
            course.startDate!,
          ),
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
            _viewCourseCalender(course);
          },
        );

      case 'closed':
        return ClosedCourseCard(
          name: studentName,
          totalClasses: totalClasses,
          paymentDate: paymentDate,
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
            _viewCourseCalender(course);
          },
        );

      default:
        return WaitlistCourseCard(
          studentId: studentId,
          studentName: studentName,
          totalClasses: totalClasses,
          paymentDate: paymentDate,
          canStart: canStart,
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

    final holidayList =
        holidayProvider.holidays.map((holiday) => holiday.holidayDate).toList();

    _endDateToUse = endDate ??
        _calculateEndDate(
          startDate: startDate,
          totalClasses: totalClasses,
          holidays: holidayList,
          weekdays: weekdayProvider.weekdays,
        );

    try {
      await attendanceProvider.fetchAttendancesForStudent(
          startDate: startDate, endDate: _endDateToUse!, studentId: studentId);
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

      final holidayList = holidayProvider.holidays
          .map((holiday) => holiday.holidayDate)
          .toList();

      final endDateToUse = _calculateEndDate(
        startDate: courseStartDate,
        totalClasses: totalClasses,
        holidays: holidayList,
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
