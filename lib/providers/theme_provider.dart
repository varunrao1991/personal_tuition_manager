import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class ThemeProvider extends ChangeNotifier {
  final ThemeService _themeService = ThemeService();
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> loadThemePreference() async {
    try {
      final theme = await _themeService.getTheme();
      if (theme == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (theme == 'light') {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.system;
      }
    } catch (e) {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> toggleTheme(ThemeMode mode) async {
    _themeMode = mode;
    await _themeService.saveTheme(mode == ThemeMode.dark
        ? 'dark'
        : mode == ThemeMode.light
            ? 'light'
            : 'system');
    notifyListeners();
  }
}
