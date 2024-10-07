import 'package:flutter/material.dart';
import 'package:padmayoga/models/owned_by.dart';
import 'package:padmayoga/widgets/custom_section_title.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../models/attendance.dart';
import '../../../providers/attendance_provider.dart';
import '../../../providers/student_provider.dart';
import '../../../utils/handle_errors.dart';
import '../../../utils/show_custom_center_modal.dart';
import '../../../widgets/custom_card.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/search_bar.dart';
import '../../../widgets/sort_modal.dart';

class MarkAttendanceScreen extends StatefulWidget {
  final DateTime selectedDate;

  const MarkAttendanceScreen({super.key, required this.selectedDate});

  @override
  _MarkAttendanceScreenState createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  String? _searchQuery;
  int _page = 0;
  bool _isLoadingMore = false;

  List<Attendance> _attendances = [];
  final Map<int, bool> _attendedStudentsMap = {};
  final List<OwnedBy> _attendedStudents = [];

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedName; // Use a string to hold the selected name

  String _selectedSortField = 'name';
  bool _isAscending = true;

  static const Map<String, String> _sortFieldLabels = {
    'name': 'Name',
    'mobile': 'Mobile Number',
    'dob': 'Date of Birth',
    'joiningDate': 'Joining Date',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialAttendance();
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreStudents();
      }
    });
  }

  Future<void> _loadInitialAttendance() async {
    final attendanceProvider =
        Provider.of<AttendanceProvider>(context, listen: false);

    DateTime startDate = DateTime(widget.selectedDate.year,
        widget.selectedDate.month, widget.selectedDate.day);
    DateTime endDate = startDate.add(const Duration(days: 1));
    try {
      await attendanceProvider.fetchAttendances(
          startDate: startDate, endDate: endDate);

      List<Attendance> filteredAttendances =
          attendanceProvider.attendances.where((attendance) {
        DateTime attendanceDate = DateTime(attendance.attendanceDate.year,
            attendance.attendanceDate.month, attendance.attendanceDate.day);
        return isSameDay(attendanceDate, widget.selectedDate);
      }).toList();

      setState(() {
        _attendances = filteredAttendances;
        for (var attendance in _attendances) {
          _attendedStudentsMap[attendance.ownedBy.id] = true;
          _attendedStudents.add(attendance.ownedBy);
        }
      });

      _loadMoreStudents();
    } catch (e) {
      handleErrors(context, e);
    }
  }

  Future<void> _loadMoreStudents() async {
    final studentProvider =
        Provider.of<StudentProvider>(context, listen: false);

    setState(() {
      _isLoadingMore = true;
    });

    _page++;

    await studentProvider.fetchStudents(
        name: _searchQuery, page: _page, sort: 'name', order: 'ASC');

    setState(() {
      _isLoadingMore = false;
      for (var student in studentProvider.students) {
        if (!_attendedStudentsMap.containsKey(student.id)) {
          _attendedStudentsMap[student.id] = false;
        }
      }
    });
  }

  Future<void> _submitAttendance() async {
    final attendanceProvider =
        Provider.of<AttendanceProvider>(context, listen: false);
    final toAdd = <int>[];
    final toRemove = <int>[];

    for (var studentEntry in _attendedStudentsMap.entries) {
      final studentExists =
          _attendedStudents.any((student) => student.id == studentEntry.key);
      if (!studentExists && studentEntry.value) {
        toAdd.add(studentEntry.key);
      } else if (!studentEntry.value && studentExists) {
        toRemove.add(studentEntry.key);
      }
    }

    try {
      for (var studentId in toAdd) {
        await attendanceProvider.addAttendance(studentId, widget.selectedDate);
      }

      for (var studentId in toRemove) {
        await attendanceProvider.deleteAttendance(
            studentId, widget.selectedDate);
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      handleErrors(context, e);
    }
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
      try {
        studentProvider.resetAndFetch(
          name: _selectedName,
          sort: _selectedSortField,
          order: _isAscending ? 'ASC' : 'DESC',
        );
      } catch (e) {
        handleErrors(context, e);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider =
        Provider.of<StudentProvider>(context, listen: false);
    final students = studentProvider.students;

    final markedStudents = students
        .where((s) => _attendedStudentsMap[s.id] == true)
        .map((student) => OwnedBy(
              id: student.id,
              name: student.name,
            ))
        .toList();
    final unmarkedStudents = students
        .where((s) => _attendedStudentsMap[s.id] != true)
        .map((student) => OwnedBy(
              id: student.id,
              name: student.name,
            ))
        .toList();

    final rearrangedStudents = [...markedStudents, ...unmarkedStudents];

    return Center(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const CustomSectionTitle(title: "Mark attendance"),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GenericSearchBar(
                    controller: _searchController,
                    onChanged: (value) async {
                      setState(() {
                        _selectedName = value;
                      });
                      try {
                        await studentProvider.resetAndFetch(
                          name: _selectedName,
                          sort: _selectedSortField,
                          order: _isAscending ? 'ASC' : 'DESC',
                        );
                      } catch (e) {
                        handleErrors(context, e);
                      }
                    },
                    onClear: () async {
                      setState(() {
                        _selectedName = null;
                      });
                      try {
                        await studentProvider.resetAndFetch(
                          name: _selectedName,
                          sort: _selectedSortField,
                          order: _isAscending ? 'ASC' : 'DESC',
                        );
                      } catch (e) {
                        if (e is Exception) {
                          handleErrors(context, e);
                        } else {
                          handleErrors(context,
                              Exception('An unexpected error occurred'));
                        }
                      }
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
              child: GridView.builder(
                controller: _scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 1.5,
                ),
                itemCount: rearrangedStudents.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (ctx, index) {
                  if (index == rearrangedStudents.length && _isLoadingMore) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final student = rearrangedStudents[index];
                  final isPresent = _attendedStudentsMap[student.id] ?? false;

                  return CustomCard(
                    onTap: () {
                      setState(() {
                        _attendedStudentsMap[student.id] = !isPresent;
                      });
                    },
                    isSelected: isPresent,
                    child: Center(
                      child: Text(
                        student.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isPresent ? Colors.blueAccent : Colors.black,
                          fontWeight:
                              isPresent ? FontWeight.bold : FontWeight.normal,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            CustomElevatedButton(
              onPressed: _submitAttendance,
              text: 'Submit',
            ),
          ],
        ),
      ),
    );
  }
}
