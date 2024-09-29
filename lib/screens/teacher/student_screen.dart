import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/student_model.dart';
import '../../models/student_update.dart';
import '../../providers/student_provider.dart';
import '../../widgets/custom_fab.dart';
import '../../widgets/search_bar.dart';
import '../../widgets/show_custom_bottom_modal.dart';
import '../../widgets/show_custom_center_modal.dart';
import '../../widgets/sort_modal.dart';
import 'widgets/student_form.dart';
import 'widgets/student_card.dart';
import '../../widgets/confirmation_modal.dart';

class StudentViewer extends StatefulWidget {
  const StudentViewer({super.key});

  @override
  _StudentViewerState createState() => _StudentViewerState();
}

class _StudentViewerState extends State<StudentViewer> {
  late ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();

  static const Map<String, String> _sortFieldLabels = {
    'name': 'Name',
    'mobile': 'Mobile Number',
    'dob': 'Date of Birth',
    'joiningDate': 'Joining Date',
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
    await studentProvider.fetchStudents(
        page: 1,
        sort: _selectedSortField,
        order: _isAscending ? 'ASC' : 'DESC',
        name: _selectedName);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final studentProvider =
          Provider.of<StudentProvider>(context, listen: false);
      if (!studentProvider.isLoading &&
          studentProvider.currentPage < studentProvider.totalPages) {
        studentProvider.fetchStudents(
          page: studentProvider.currentPage + 1,
          sort: _selectedSortField,
          order: _isAscending ? 'ASC' : 'DESC',
          name:
              _searchController.text.isNotEmpty ? _searchController.text : null,
        );
      }
    }
  }

  Future<void> _openStudentForm({StudentUpdate? student}) async {
    // This method opens the form for adding or editing a student.
    await showCustomModalBottomSheet(
      context: context,
      child: StudentForm(
        student: student, // Pass student if editing
      ),
    );
    // After closing the modal, refresh the student list.
    _fetchStudents();
  }

  Future<void> _deleteStudent(int studentId) async {
    final studentProvider =
        Provider.of<StudentProvider>(context, listen: false);
    await studentProvider.deleteStudent(studentId);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: GenericSearchBar(
                    controller: _searchController,
                    onClear: () async {
                      setState(() {
                        _selectedName = null;
                      });
                      _searchController.clear();
                      await studentProvider.resetAndFetch(
                        name: _selectedName,
                        sort: _selectedSortField,
                        order: _isAscending ? 'ASC' : 'DESC',
                      );
                    },
                    onChanged: (value) async {
                      setState(() {
                        _selectedName = value;
                      });
                      await studentProvider.resetAndFetch(
                        name: _selectedName,
                        sort: _selectedSortField,
                        order: _isAscending ? 'ASC' : 'DESC',
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.filter_alt),
                  onPressed: () => _openSortModal(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: studentProvider.isLoading && studentProvider.students.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchStudents,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: studentProvider.students.length +
                          (studentProvider.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == studentProvider.students.length) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        Student student = studentProvider.students[index];
                        StudentUpdate studentUpdate =
                            StudentUpdate.fromStudent(student);
                        return StudentCard(
                          student: student,
                          onEdit: () => _openStudentForm(
                              student: studentUpdate), // Open form for editing
                          onDelete: () async {
                            showCustomDialog(
                              context: context,
                              child: const ConfirmationDialog(
                                message: 'Delete this student?',
                                confirmButtonText: 'Delete',
                                cancelButtonText: 'Cancel',
                              ),
                            ).then((success) => {
                                  if (success != null && success)
                                    {_deleteStudent(student.id)}
                                });
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: CustomFAB(
        icon: Icons.add,
        onPressed: () {
          _openStudentForm(); // Open form for adding a new student
        },
      ),
    );
  }

  void _openSortModal(BuildContext context) {
    showCustomDialog(
      context: context,
      child: SortModal(
        title: 'Sort Students',
        selectedSortField: _selectedSortField,
        sortOptions: _sortFieldLabels,
        isAscending: _isAscending,
        onSortFieldChange: (newSortField) {
          if (newSortField != null) {
            setState(() {
              _selectedSortField = newSortField;
            });
          }
          Navigator.of(context).pop();
        },
        onSortOrderChange: (isAscending) {
          setState(() {
            _isAscending = isAscending;
          });
          Navigator.of(context).pop();
        },
      ),
    ).then((value) {
      final studentProvider =
          Provider.of<StudentProvider>(context, listen: false);
      studentProvider.resetAndFetch(
        name: _selectedName,
        sort: _selectedSortField,
        order: _isAscending ? 'ASC' : 'DESC',
      );
    });
  }
}
