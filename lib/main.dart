import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'utils/shared_pref.dart';

import 'app.dart' as app;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const String environment =
      String.fromEnvironment('ENV', defaultValue: 'development');

  try {
    await dotenv.load(fileName: ".env.$environment");
    log('Environment variables loaded: ${dotenv.env}');
  } catch (e) {
    log('Error loading .env file: $e');
  }
  await sharedPrefs.init();

    WidgetsFlutterBinding.ensureInitialized();
    runApp(const app.MyApp());
}
