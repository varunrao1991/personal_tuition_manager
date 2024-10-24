import 'package:flutter/material.dart';
import '../screens/teacher/attendance_screen.dart';
import '../screens/teacher/course_screen.dart';
import '../screens/teacher/login_screen.dart';
import '../screens/teacher/payment_screen.dart';
import '../screens/teacher/register_screen.dart';
import '../screens/teacher/student_screen.dart';
import '../screens/teacher/home_screen.dart';
import '../screens/teacher/holiday_screen.dart';

Map<String, WidgetBuilder> teacherRoutes = {
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),
  '/teacher': (context) => const TeacherHomeScreen(),
  '/teacher/holidays': (context) => const HolidayScreen(),
  '/teacher/attendances': (context) => const AttendanceScreen(),
  '/teacher/students': (context) => const StudentScreen(),
  '/teacher/payments': (context) => const PaymentScreen(),
  '/teacher/courses': (context) => const CourseScreen(),
};
