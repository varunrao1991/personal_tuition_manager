import 'package:flutter/material.dart';
import 'package:padmayoga/screens/teacher/attendance_screen.dart';
import 'package:padmayoga/screens/teacher/course_screen.dart';
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

  Widget _getViewer() {
    switch (_selectedIndex) {
      case 0:
        return _buildEmptyHomeScreen(); // Empty home screen
      case 1:
        return const PaymentScreen(); // Navigate to PaymentScreen
      case 2:
        return const AttendanceScreen(); // Navigate to AttendanceScreen
      case 3:
        return const StudentScreen(); // Navigate to StudentScreen
      case 4:
        return const CourseScreen(); // Navigate to CourseScreen
      default:
        return _buildEmptyHomeScreen(); // Default to home screen
    }
  }

  Widget _buildEmptyHomeScreen() {
    return const Center(
      child: Text(
        'Welcome to Teacher Dashboard',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0), // Set a smaller height
        child: AppBar(
          title: const Text("Teacher Dashboard"),
          toolbarHeight: 50, // Make it smaller
        ),
      ),
      drawer: const CustomDrawer(), // Drawer for navigation
      body: _getViewer(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0, // Reduced margin to make the notch sharper
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Side Navigation Items
          IconButton(
            icon: Icon(
              Icons.payment,
              color: _selectedIndex == 1 ? Colors.blue : Colors.grey,
            ),
            iconSize: 30, // Increased size for visibility
            onPressed: () {
              setState(() {
                _selectedIndex = 1; // Navigate to PaymentScreen
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.check_circle_outline,
              color: _selectedIndex == 2 ? Colors.blue : Colors.grey,
            ),
            iconSize: 30, // Increased size for visibility
            onPressed: () {
              setState(() {
                _selectedIndex = 2; // Navigate to AttendanceScreen
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.home,
              color: _selectedIndex == 0 ? Colors.blue : Colors.grey,
            ),
            iconSize: 36, // Slightly larger home icon
            onPressed: () {
              setState(() {
                _selectedIndex = 0; // Navigate back to home screen
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.people,
              color: _selectedIndex == 3 ? Colors.blue : Colors.grey,
            ),
            iconSize: 30, // Increased size for visibility
            onPressed: () {
              setState(() {
                _selectedIndex = 3; // Navigate to StudentScreen
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.book,
              color: _selectedIndex == 4 ? Colors.blue : Colors.grey,
            ),
            iconSize: 30, // Increased size for visibility
            onPressed: () {
              setState(() {
                _selectedIndex = 4; // Navigate to CourseScreen
              });
            },
          ),
        ],
      ),
    );
  }
}
