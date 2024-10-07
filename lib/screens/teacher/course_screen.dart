import 'package:flutter/material.dart';
import 'package:padmayoga/models/create_course.dart';
import 'package:padmayoga/screens/teacher/widgets/edit_course.dart';
import 'package:provider/provider.dart';
import '../../models/course.dart';
import '../../providers/course_provider.dart';
import '../../utils/handle_errors.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_fab.dart';
import '../../utils/show_custom_bottom_modal.dart';
import '../../utils/show_custom_center_modal.dart';
import '../../widgets/sort_modal.dart';
import '../../widgets/confirmation_modal.dart';
import 'widgets/course_card.dart';
import 'widgets/add_course.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  _CourseScreenState createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  late ScrollController _scrollController;

  static const Map<String, String> _sortFieldLabels = {
    'startDate': 'Start Date',
    'endDate': 'End Date',
    'totalClasses': 'Total Classes',
  };
  static const Map<String, String> _courseFilters = {
    'ongoing': 'Ongoing',
    'waitlist': 'Waitlist',
    'closed': 'Closed',
  };

  String _selectedSortField = 'totalClasses';
  String _selectedFilter = 'waitlist'; // Default status filter
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCourses();
    });
  }

  Future<void> _fetchCourses() async {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    try {
      await courseProvider.fetchCourses(
        page: 1,
        sort: _selectedSortField,
        order: _isAscending ? 'ASC' : 'DESC',
        filterBy: _selectedFilter,
      );
    } catch (e) {
      handleErrors(context, e);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreCourses();
    }
  }

  Future<void> _loadMoreCourses() async {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    if (!courseProvider.isLoading &&
        courseProvider.currentPage < courseProvider.totalPages) {
      try {
        await courseProvider.fetchCourses(
          page: courseProvider.currentPage + 1,
          sort: _selectedSortField,
          order: _isAscending ? 'ASC' : 'DESC',
          filterBy: _selectedFilter,
        );
      } catch (e) {
        handleErrors(context, e);
      }
    }
  }

  Future<void> _openCourseForm() async {
    try {
      await showCustomModalBottomSheet<CourseCreate>(
        context: context,
        child: const AddStudentCourseProcessWidget(), // Pass course if editing
      ).then((course) async {
        if (course != null) {
          final courseProvider =
              Provider.of<CourseProvider>(context, listen: false);
          await courseProvider.addCourse(course.paymentId, course.totalClasses);
          _fetchCourses();
        }
      });
    } catch (e) {
      handleErrors(context, e);
    }
  }

  Future<void> _editCourseForm(Course course) async {
    try {
      final courseNew = await showCustomModalBottomSheet<Course>(
        context: context,
        child: EditCourseWidget(course: course),
      );
      if (courseNew != null) {
        await _updateCourse(courseNew);
      }
      _fetchCourses();
    } catch (e) {
      handleErrors(context, e);
    }
  }

  Future<void> _updateCourse(Course courseNew) async {
    await Provider.of<CourseProvider>(context, listen: false).updateCourse(
      courseNew.paymentId,
      totalClasses: courseNew.totalClasses,
      startDate: courseNew.startDate,
    );
  }

  Future<void> _deleteCourse(int courseId) async {
    try {
      final courseProvider =
          Provider.of<CourseProvider>(context, listen: false);
      await courseProvider.deleteCourse(courseId);
      _fetchCourses();
    } catch (e) {
      handleErrors(context, e);
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
      body: Column(
        children: [_buildFilterAndSortRow(), _buildCourseList()],
      ),
      floatingActionButton: CustomFAB(
        icon: Icons.add,
        onPressed: _openCourseForm,
      ),
    );
  }

  Widget _buildFilterAndSortRow() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: CustomDropdownButton(
              selectedSortField: _selectedFilter,
              sortOptions: _courseFilters,
              onSortFieldChange: _onFilterChange,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => _openSortModal(context),
          ),
        ],
      ),
    );
  }

  void _onFilterChange(String? newFilterField) {
    if (newFilterField != null) {
      setState(() {
        _selectedFilter = newFilterField;
      });
      _fetchCourses();
    }
  }

  Widget _buildCourseList() {
    return Consumer<CourseProvider>(
      builder: (context, courseProvider, child) {
        return Expanded(
          child: courseProvider.isLoading && courseProvider.courses.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _fetchCourses,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), // Added padding here
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: courseProvider.courses.length +
                          (courseProvider.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == courseProvider.courses.length) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        Course course = courseProvider.courses[index];
                        return CourseCard(
                          course: course,
                          onEdit: () => _editCourseForm(course),
                          onDelete: () =>
                              _confirmDeleteCourse(course.paymentId),
                        );
                      },
                    ),
                  ),
                ),
        );
      },
    );
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
      if (success != null && success) {
        _deleteCourse(courseId);
      }
    });
  }

  void _openSortModal(BuildContext context) {
    showCustomDialog(
      context: context,
      child: SortModal(
        title: 'Sort Courses',
        selectedSortField: _selectedSortField,
        sortOptions: _sortFieldLabels,
        isAscending: _isAscending,
        onSortFieldChange: _onSortFieldChange,
        onSortOrderChange: _onSortOrderChange,
      ),
    ).then((value) {
      try {
        final courseProvider =
            Provider.of<CourseProvider>(context, listen: false);
        courseProvider.resetAndFetch(
          sort: _selectedSortField,
          order: _isAscending ? 'ASC' : 'DESC',
          filterBy: _selectedFilter, // Refetch based on the current status
        );
      } catch (e) {
        handleErrors(context, e);
      }
    });
  }

  void _onSortFieldChange(String? newSortField) {
    if (newSortField != null) {
      setState(() {
        _selectedSortField = newSortField;
      });
    }
    Navigator.of(context).pop();
  }

  void _onSortOrderChange(bool isAscending) {
    setState(() {
      _isAscending = isAscending;
    });
    Navigator.of(context).pop();
  }
}
