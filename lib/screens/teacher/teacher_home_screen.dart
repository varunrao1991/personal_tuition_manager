import 'package:flutter/material.dart';
import 'package:padmayoga/screens/teacher/attendance_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'widgets/bottom_navigation_bar.dart';
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getViewer() {
    switch (_selectedIndex) {
      case 2:
        return const StudentViewer();
      case 0:
        return const PaymentViewer();
      case 1:
        return const AttendanceScreen();
      default:
        return const StudentViewer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Dashboard"),
      ),
      drawer: const CustomDrawer(),
      body: _getViewer(),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
