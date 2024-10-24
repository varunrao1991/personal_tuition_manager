import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'utils/local_notification_handler.dart';
import 'utils/shared_pref.dart';

import 'student_app.dart' as student;
import 'teacher_app.dart' as teacher;
import 'admin_app.dart' as admin;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initializeLocalNotifications();

  const String userType =
      String.fromEnvironment('USER_TYPE', defaultValue: 'teacher');
  const String environment =
      String.fromEnvironment('ENV', defaultValue: 'development');

  try {
    await dotenv.load(fileName: ".env.$environment");
    log('Environment variables loaded: ${dotenv.env}');
  } catch (e) {
    log('Error loading .env file: $e');
  }
  await sharedPrefs.init();

  if (userType == 'teacher') {
    runApp(const teacher.MyApp(userType: userType));
  } else if (userType == 'student') {
    runApp(const student.MyApp(userType: userType));
  } else {
    runApp(const admin.MyApp(userType: userType));
  }
}
