import 'dart:developer';
import '../utils/shared_pref.dart';

class ThemeService {
  static const String _themeKey = 'themeMode';

  Future<void> saveTheme(String themeMode) async {
    if (themeMode != 'light' && themeMode != 'dark' && themeMode != 'system') {
      throw ArgumentError('Invalid theme mode: $themeMode');
    }
    await sharedPrefs.saveString(_themeKey, themeMode);
    log("Saved theme: $themeMode");
  }

  Future<String> getTheme() async {
    final theme = await sharedPrefs.getString(_themeKey);
    return theme ?? 'system';
  }

  Future<void> clearTheme() async {
    await sharedPrefs.clear(_themeKey);
    log("Cleared theme preference");
  }
}
