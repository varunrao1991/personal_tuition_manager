import 'package:flutter/material.dart';
import '../../widgets/notification_widget.dart';
import 'attendance_screen.dart';
import 'course_screen.dart';
import 'widgets/custom_drawer.dart';
import 'student_screen.dart';
import 'payment_screen.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  _TeacherHomeScreenState createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  int _selectedIndex = 0;

  final Map<int, IconData> _iconMap = {
    1: Icons.payment,
    2: Icons.check_circle_outline,
    3: Icons.people,
    4: Icons.book,
  };

  Widget _getViewer() {
    switch (_selectedIndex) {
      case 1:
        return const PaymentScreen();
      case 3:
        return const StudentScreen();
      case 4:
        return const CourseScreen();
      default:
        return const AttendanceScreen();
    }
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
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _iconMap.entries.map((entry) {
          int index = entry.key;
          IconData icon = entry.value;

          return IconButton(
            icon: Icon(icon),
            color: _selectedIndex == index
                ? Theme.of(context).colorScheme.primary
                : null,
            onPressed: () {
              setState(() {
                _selectedIndex = index;
              });
            },
          );
        }).toList(),
      ),
    );
  }
}
