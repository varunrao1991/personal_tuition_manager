import 'package:flutter/material.dart';
import '../../widgets/notification_widget.dart';
import 'attendance_screen.dart';
import 'course_screen.dart';
import 'widgets/custom_drawer.dart';
import 'student_screen.dart';
import 'payment_screen.dart';
import '../../widgets/navigation_bar.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  _TeacherHomeScreenState createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  int _selectedIndex = 0;
  final List<NavItem> _navItems = [
    const NavItem(icon: Icons.payment, label: 'Payments'),
    const NavItem(icon: Icons.check_circle_outline, label: 'Attendance'),
    const NavItem(icon: Icons.people, label: 'Students'),
    const NavItem(icon: Icons.book, label: 'Courses'),
  ];

  Widget _getViewer() {
    switch (_selectedIndex) {
      case 0:
        return const PaymentScreen();
      case 1:
        return const AttendanceScreen();
      case 2:
        return const StudentScreen();
      case 3:
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
          "Teacher Dashboard",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: const [NotificationHandlerWidget()],
      ),
      drawer: const CustomDrawer(),
      body: _getViewer(),
      bottomNavigationBar: CustomBottomNavigationBar(
        navItems: _navItems,
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemSelected,
      ),
    );
  }
}
