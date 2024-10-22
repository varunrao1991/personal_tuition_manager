import 'package:flutter/material.dart';
import '../screens/student/attendance_screen.dart';
import '../screens/student/course_screen.dart';
import '../screens/student/home_screen.dart';
import '../screens/student/login_screen.dart';

Map<String, WidgetBuilder> studentRoutes = {
  '/login': (context) => const LoginScreen(),
  '/student': (context) => const StudentHomeScreen(),
  '/student/attendances': (context) => const AttendanceScreen(),
  '/student/courses': (context) => const CourseScreen(),
};
