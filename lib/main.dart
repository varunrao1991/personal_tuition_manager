import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'utils/background_handler.dart';
import 'utils/local_notification_handler.dart';
import 'utils/shared_pref.dart';

import 'student_app.dart' as student;
import 'teacher_app.dart' as teacher;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  initializeLocalNotifications();

  const String userType =
      String.fromEnvironment('USER_TYPE', defaultValue: 'student');

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
    runApp(const teacher.MyApp());
  } else {
    runApp(const student.MyApp());
  }
}
