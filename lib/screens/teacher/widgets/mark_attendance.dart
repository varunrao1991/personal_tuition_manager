import 'package:flutter/material.dart';
import 'package:padmayoga/models/owned_by.dart';
import 'package:padmayoga/widgets/custom_section_title.dart';
import 'package:provider/provider.dart';
import '../../../models/attendance.dart';
import '../../../providers/attendance_provider.dart';
import '../../../providers/student_provider.dart';
import '../../../widgets/custom_card.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/search_bar.dart'; // Import GenericSearchBar

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
    DateTime endDate = startDate
        .add(const Duration(days: 1)); // Fetch only for the selected day

    await attendanceProvider.fetchAttendances(
        startDate: startDate, endDate: endDate);

    setState(() {
      _attendances = attendanceProvider.attendances;
      for (var attendance in _attendances) {
        _attendedStudentsMap[attendance.ownedBy.id] = true;
        _attendedStudents.add(attendance.ownedBy);
      }
    });

    _loadMoreStudents();
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

    for (var studentId in toAdd) {
      await attendanceProvider.addAttendance(studentId, widget.selectedDate);
    }

    for (var studentId in toRemove) {
      await attendanceProvider.deleteAttendance(studentId, widget.selectedDate);
    }

    Navigator.of(context).pop(true);
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

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          children: <Widget>[
            const CustomSectionTitle(title: "Mark attendance"),
            const SizedBox(height: 16),
            GenericSearchBar(
              controller: TextEditingController(text: _searchQuery),
              labelText: 'Search students',
              onClear: () {
                setState(() {
                  _searchQuery = null;
                  _page = 0;
                  _loadMoreStudents();
                });
              },
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _page = 0;
                  _loadMoreStudents();
                });
              },
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
                    elevation: isPresent ? 8.0 : 4.0,
                    borderRadius: 15.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isPresent
                            ? Colors.blueAccent.withOpacity(0.1)
                            : Colors.white,
                        border:
                            isPresent ? Border.all(color: Colors.blue) : null,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      padding: const EdgeInsets.all(4.0),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            student.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  isPresent ? Colors.blueAccent : Colors.black,
                              fontWeight: isPresent
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 16.0,
                            ),
                          ),
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
