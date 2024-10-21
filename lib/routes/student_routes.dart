import 'package:flutter/material.dart';
import '../screens/student/student_home_screen.dart';

Map<String, WidgetBuilder> studentRoutes = {
  '/student': (context) => const StudentHomeScreen(),
};
