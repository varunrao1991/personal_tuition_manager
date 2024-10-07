import 'package:flutter/material.dart';
import 'package:padmayoga/widgets/custom_card.dart';
import 'package:padmayoga/widgets/custom_elevated_button.dart';
import 'package:padmayoga/widgets/custom_section_title.dart';
import 'package:padmayoga/widgets/search_bar.dart';
import 'package:padmayoga/widgets/sort_modal.dart';
import 'package:padmayoga/utils/handle_errors.dart';
import 'package:provider/provider.dart';
import '../../../models/student_model.dart';
import '../../../providers/student_provider.dart';
import '../../../utils/show_custom_center_modal.dart';

class StudentSelector extends StatefulWidget {
  final Function(Student?) onStudentSelected;
  final Student? selectedStudent;

  const StudentSelector({
    super.key,
    required this.onStudentSelected,
    this.selectedStudent,
  });

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

  static const Map<String, String> _sortFieldLabels = {
    'name': 'Name',
    'mobile': 'Mobile Number',
    'dob': 'Date of Birth',
    'joiningDate': 'Joining Date',
  };

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchStudents();
    });

    if (widget.selectedStudent != null) {
      _selectedStudent =
          widget.selectedStudent; // Store the full Student object
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
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
      _fetchStudents();
    });
  }

  void _fetchStudents({int page = 1}) async {
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
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !context.read<StudentProvider>().isLoading &&
        context.read<StudentProvider>().currentPage <
            context.read<StudentProvider>().totalPages) {
      _fetchStudents(page: context.read<StudentProvider>().currentPage + 1);
    }
  }

  void _handleNext() {
    if (_selectedStudent != null) {
      widget.onStudentSelected(_selectedStudent!
          .copy()); // Assuming you have a copy method in your Student model
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const CustomSectionTitle(title: 'Select Student'),
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
        Expanded(
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
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 1.5,
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
        if (_selectedStudent != null) // Check if selectedStudent is not null
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Text(
              'Selected Student: ${_selectedStudent!.name}', // Display the student's name
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        const SizedBox(height: 10),
        CustomElevatedButton(
          onPressed: _handleNext,
          text: 'Next',
        ),
      ],
    );
  }

  Widget _buildStudentCard(Student student) {
    bool isSelected =
        _selectedStudent?.id == student.id; // Compare with Student object

    return CustomCard(
      onTap: () {
        setState(() {
          _selectedStudent =
              student; // Set the selected student object directly
        });
      },
      isSelected: isSelected,
      child: Text(
        student.name,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
