import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/forgot_password_screen.dart';

Map<String, WidgetBuilder> authRoutes = {
  '/login': (context) => const LoginScreen(),
  '/forgot-password': (context) => const ForgotPasswordScreen(),
};
