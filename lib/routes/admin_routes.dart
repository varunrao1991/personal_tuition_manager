import 'package:flutter/material.dart';
import '../screens/admin/home_screen.dart';
import '../screens/admin/login_screen.dart';

Map<String, WidgetBuilder> adminRoutes = {
  '/login': (context) => const LoginScreen(),
  '/admin': (context) => const HomeScreen(),
};
