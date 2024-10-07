import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './app.dart';
import 'utils/shared_pref.dart';

Future<void> main() async {
  // Ensure that widgets binding is initialized before loading .env files
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
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
