import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'utils/shared_pref.dart';

import 'app.dart' as app;

Future<void> main() async {
  // Ensure Flutter bindings are initialized before running any other code
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load the correct .env file based on the environment
    await dotenv.load(fileName: ".env");
    log('Environment variables loaded: ${dotenv.env}');
  } catch (e) {
    log('Error loading .env file: $e');
  }

  // Initialize shared preferences
  await sharedPrefs.init();

  // Run the app
  runApp(const app.MyApp());
}
