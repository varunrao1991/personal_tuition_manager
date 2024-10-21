import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_constants.dart';
import '../../../models/student_model.dart';
import '../../../providers/student_provider.dart';
import '../../../utils/handle_errors.dart';
import '../../../utils/show_custom_center_modal.dart';
import '../../../widgets/custom_card.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/search_bar.dart';
import '../../../widgets/sort_modal.dart';

class StudentSelector extends StatefulWidget {
  final Function(Student?) onStudentSelected;
  final Student? selectedStudent;

  const StudentSelector({
    Key? key,
    required this.onStudentSelected,
    this.selectedStudent,
  }) : super(key: key);

  @override
  _StudentSelectorState createState() => _StudentSelectorState();
}

class _StudentSelectorState extends State<StudentSelector> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedName;
  String _selectedSortField = 'name';
  bool _isAscending = true;
  late ScrollController _scrollController;
  Student? _selectedStudent;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchStudents();
    });

    if (widget.selectedStudent != null) {
      _selectedStudent = widget.selectedStudent;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openSortModal(BuildContext context) async {
    final result = await showCustomDialog(
      context: context,
      child: SortModal(
        title: 'Sort Students',
        selectedSortField: _selectedSortField,
        sortOptions: const {
          'name': 'Name',
          'mobile': 'Mobile Number',
          'dob': 'Date of Birth',
          'joiningDate': 'Joining Date',
        },
        isAscending: _isAscending,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedSortField = result['field'];
        _isAscending = result['order'];
      });

      _fetchStudents();
    }
  }

  Future<void> _fetchStudents({int page = 1}) async {
    try {
      await context.read<StudentProvider>().fetchStudents(
            page: page,
            name: _selectedName,
            sort: _selectedSortField,
            order: _isAscending ? 'ASC' : 'DESC',
          );
    } catch (e) {
      handleErrors(context, e);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !context.read<StudentProvider>().isLoading &&
        context.read<StudentProvider>().currentPage <
            context.read<StudentProvider>().totalPages) {
      _fetchStudents(page: context.read<StudentProvider>().currentPage + 1);
    }
  }

  void _handleNext() {
    if (_selectedStudent != null) {
      widget.onStudentSelected(_selectedStudent!.copy());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppPaddings.mediumPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Select Student',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GenericSearchBar(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _selectedName = value;
                      });
                      _fetchStudents();
                    },
                    onClear: () {
                      setState(() {
                        _selectedName = null;
                        _searchController.clear();
                      });
                      _fetchStudents();
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
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Consumer<StudentProvider>(
                builder: (context, studentProvider, _) {
                  return studentProvider.isLoading &&
                          studentProvider.students.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : GridView.builder(
                          controller: _scrollController,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 4.0,
                            mainAxisSpacing: 16.0,
                            childAspectRatio: 1.3,
                          ),
                          itemCount: studentProvider.students.length +
                              (studentProvider.isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == studentProvider.students.length) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            final student = studentProvider.students[index];
                            return _buildStudentCard(student);
                          },
                        );
                },
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedStudent != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text('Selected Student: ${_selectedStudent!.name}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
            const SizedBox(height: 10),
            CustomElevatedButton(
              onPressed: _handleNext,
              text: 'Next',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(Student student) {
    bool isSelected = _selectedStudent?.id == student.id;

    return CustomCard(
        onTap: () {
          setState(() {
            _selectedStudent = student;
          });
        },
        isSelected: isSelected,
        child: Text(
          student.name,
          textAlign: TextAlign.center,
          style: isSelected
              ? Theme.of(context).textTheme.bodyMedium
              : Theme.of(context).textTheme.bodyMedium,
        ));
  }
}
