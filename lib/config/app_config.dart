import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  final String appDb = dotenv.env['DB_NAME'] ?? 'APP_DB';
  final String appName = dotenv.env['APP_NAME'] ?? 'MyApp';
}
