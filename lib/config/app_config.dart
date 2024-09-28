// lib/config/config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  String apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:5000';
}
