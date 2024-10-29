import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(8.0), // Add some padding around icons
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.light_mode),
            tooltip: 'Light Theme',
            onPressed: () {
              themeProvider.toggleTheme(ThemeMode.light);
            },
          ),
          IconButton(
            icon: const Icon(Icons.dark_mode),
            tooltip: 'Dark Theme',
            onPressed: () {
              themeProvider.toggleTheme(ThemeMode.dark);
            },
          ),
          IconButton(
            icon: const Icon(Icons.brightness_auto),
            tooltip: 'System Default',
            onPressed: () {
              themeProvider.toggleTheme(ThemeMode.system);
            },
          ),
        ],
      ),
    );
  }
}
