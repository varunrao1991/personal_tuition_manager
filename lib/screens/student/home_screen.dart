import 'package:flutter/material.dart';
import '../../widgets/navigation_bar.dart';
import '../../widgets/notification_widget.dart';
import 'attendance_screen.dart';
import 'course_screen.dart';
import 'widgets/custom_drawer.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  _StudentHomeScreenState createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _selectedIndex = 0;
  final List<NavItem> _navItems = [
    const NavItem(icon: Icons.check_circle_outline, label: 'Attendance'),
    const NavItem(icon: Icons.book, label: 'Courses'),
  ];

  Widget _getViewer() {
    switch (_selectedIndex) {
      case 1:
        return const CourseScreen();
      default:
        return const AttendanceScreen();
    }
  }

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Student Dashboard",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: const [NotificationHandlerWidget()],
      ),
      drawer: const StudentCustomDrawer(),
      body: _getViewer(),
      bottomNavigationBar: CustomBottomNavigationBar(
        navItems: _navItems,
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemSelected,
      ),
    );
  }
}
