import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './app.dart';
import 'firebase_options.dart';
import 'utils/shared_pref.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  const String environment =
      String.fromEnvironment('ENV', defaultValue: 'development');
  try {
    await dotenv.load(fileName: ".env.$environment");
    log('Environment variables loaded: ${dotenv.env}');
  } catch (e) {
    log('Error loading .env file: $e');
  }
  await sharedPrefs.init();

  runApp(const MyApp());
}
