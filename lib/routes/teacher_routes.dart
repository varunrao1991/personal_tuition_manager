import 'package:flutter/material.dart';
import 'package:padmayoga/screens/teacher/attendance_screen.dart';
import 'package:padmayoga/screens/teacher/course_screen.dart';
import 'package:padmayoga/screens/teacher/payment_screen.dart';
import 'package:padmayoga/screens/teacher/student_screen.dart';
import '../screens/teacher/teacher_home_screen.dart';
import '../screens/teacher/holiday_screen.dart';

Map<String, WidgetBuilder> teacherRoutes = {
  '/teacher': (context) => const TeacherHomeScreen(),
  '/teacher/holidays': (context) => const HolidayScreen(),
  '/teacher/attendances': (context) => const AttendanceScreen(),
  '/teacher/students': (context) => const StudentScreen(),
  '/teacher/payments': (context) => const PaymentScreen(),
  '/teacher/courses': (context) => const CourseScreen(),
};
