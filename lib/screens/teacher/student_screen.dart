import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../models/teacher/student_model.dart';
import '../../models/teacher/student_update.dart';
import '../../providers/teacher/student_provider.dart';
import '../../utils/handle_errors.dart';
import '../../widgets/custom_fab.dart';
import '../../widgets/search_bar.dart';
import '../../utils/show_custom_bottom_modal.dart';
import '../../utils/show_custom_center_modal.dart';
import '../../widgets/sort_modal.dart';
import 'widgets/student_form.dart';
import 'widgets/student_card.dart';
import '../../widgets/confirmation_modal.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  late ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();

  static const Map<String, String> _sortFieldLabels = {
    'name': 'Name',
    'mobile': 'Mobile Number',
    'createdAt': 'Joining Date',
  };

  String _selectedSortField = 'name';
  String? _selectedName;
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchStudents();
    });
  }

  Future<void> _fetchStudents() async {
    final studentProvider =
        Provider.of<StudentProvider>(context, listen: false);
    try {
      await studentProvider.fetchStudents(
          page: 1,
          sort: _selectedSortField,
          order: _isAscending ? 'ASC' : 'DESC',
          name: _selectedName);
    } catch (e) {
      handleErrors(context, e);
    }
  }

  void _onScroll() {
    final studentProvider =
        Provider.of<StudentProvider>(context, listen: false);

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (!studentProvider.isLoading &&
          studentProvider.currentPage < studentProvider.totalPages) {
        try {
          studentProvider.fetchStudents(
            page: studentProvider.currentPage + 1,
            sort: _selectedSortField,
            order: _isAscending ? 'ASC' : 'DESC',
            name: _searchController.text.isNotEmpty
                ? _searchController.text
                : null,
          );
        } catch (e) {
          handleErrors(context, e);
        }
      }
    }
  }

  Future<void> _openStudentForm({StudentUpdate? student}) async {
    await showCustomModalBottomSheet(
      context: context,
      child: StudentForm(
        student: student,
      ),
    );
    _fetchStudents();
  }

  Future<void> _deleteStudent(int studentId) async {
    final studentProvider =
        Provider.of<StudentProvider>(context, listen: false);
    try {
      await studentProvider.deleteStudent(studentId);
    } catch (e) {
      handleErrors(context, e);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildSearchAndFilterRow(context),
          _buildStudentList(),
        ],
      ),
      floatingActionButton: CustomFAB(
        icon: Icons.add,
        onPressed: _openStudentForm,
      ),
    );
  }

  Widget _buildSearchAndFilterRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppPaddings.mediumPadding),
      child: Row(
        children: [
          Expanded(
            child: GenericSearchBar(
              controller: _searchController,
              onClear: () => _resetSearch(context),
              onChanged: (value) => _performSearch(context, value),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => _openSortModal(context),
          ),
        ],
      ),
    );
  }

  Future<void> _resetSearch(BuildContext context) async {
    setState(() {
      _selectedName = null;
    });
    _searchController.clear();
    await _fetchStudentsWithCurrentFilters(context);
  }

  Future<void> _performSearch(BuildContext context, String value) async {
    setState(() {
      _selectedName = value;
    });
    try {
      await _fetchStudentsWithCurrentFilters(context);
    } catch (e) {
      handleErrors(context, e);
    }
  }

  Future<void> _fetchStudentsWithCurrentFilters(BuildContext context) async {
    try {
      await Provider.of<StudentProvider>(context, listen: false).resetAndFetch(
        name: _selectedName,
        sort: _selectedSortField,
        order: _isAscending ? 'ASC' : 'DESC',
      );
    } catch (e) {
      handleErrors(context, e);
    }
  }

  Widget _buildStudentList() {
    return Expanded(
      child: Consumer<StudentProvider>(
        builder: (context, studentProvider, child) {
          if (studentProvider.isLoading && studentProvider.students.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
              padding: const EdgeInsets.all(AppPaddings.smallPadding),
              child: RefreshIndicator(
                onRefresh: _fetchStudents,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: studentProvider.students.length +
                      (studentProvider.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == studentProvider.students.length) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return _buildStudentCard(studentProvider.students[index]);
                  },
                ),
              ));
        },
      ),
    );
  }

  Widget _buildStudentCard(Student student) {
    StudentUpdate studentUpdate = StudentUpdate.fromStudent(student);
    return StudentCard(
      student: student,
      onEdit: () => _openStudentForm(student: studentUpdate),
      onDelete: () async {
        bool? success = await _showDeleteConfirmationDialog(context);
        if (success == true) {
          _deleteStudent(student.id);
        }
      },
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showCustomDialog(
      context: context,
      child: const ConfirmationDialog(
        message: 'Delete the student?',
        confirmButtonText: 'Delete',
        cancelButtonText: 'Cancel',
      ),
    );
  }

  void _openSortModal(BuildContext context) async {
    final result = await showCustomDialog(
      context: context,
      child: SortModal(
        title: 'Sort Students',
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

      final studentProvider =
          Provider.of<StudentProvider>(context, listen: false);
      try {
        await studentProvider.resetAndFetch(
          name: _selectedName,
          sort: _selectedSortField,
          order: _isAscending ? 'ASC' : 'DESC',
        );
      } catch (e) {
        handleErrors(context, e);
      }
    }
  }
}
