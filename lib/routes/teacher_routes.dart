import 'package:flutter/material.dart';
import 'package:personal_tuition_manager/screens/major/teacher_settings_screen.dart';
import '../screens/major/attendance_screen.dart';
import '../screens/major/course_screen.dart';
import '../screens/common/lock_pin_screen.dart';
import '../screens/major/payment_screen.dart';
import '../screens/major/student_screen.dart';
import '../screens/major/home_screen.dart';
import '../screens/major/holiday_screen.dart';

Map<String, WidgetBuilder> teacherRoutes = {
  '/login': (context) => const LockPinScreen(),
  '/home': (context) => const TeacherHomeScreen(),
  '/teacher/edit_settings': (context) => const TeacherSettingsScreen(),
  '/teacher/holidays': (context) => const HolidayScreen(),
  '/teacher/attendances': (context) => const AttendanceScreen(),
  '/teacher/students': (context) => const StudentScreen(),
  '/teacher/payments': (context) => const PaymentScreen(),
  '/teacher/courses': (context) => const CourseScreen(),
};
