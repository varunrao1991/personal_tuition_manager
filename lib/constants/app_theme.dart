import 'package:flutter/material.dart';

class MaterialTheme {
  const MaterialTheme();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: Color(0xff17a194), // --primary-color
      onPrimary: Colors.white,
      primaryContainer: Color(0xffb4eae3),
      onPrimaryContainer: Color(0xff00201d),
      secondary: Color(0xff7d99d7), // --secondary-color
      onSecondary: Colors.white,
      secondaryContainer: Color(0xffdae2ff),
      onSecondaryContainer: Color(0xff0f1b37),
      tertiary: Color(0xffffc374), // --accent-color
      onTertiary: Colors.black,
      error: Color(0xffba1a1a),
      onError: Colors.white,
      background: Color(0xfff9f9f9), // --light-bg
      onBackground: Color(0xff444444), // --text-color-light
      surface: Color(0xfff9f9f9), // --light-bg
      onSurface: Color(0xff444444), // --text-color-light
      surfaceVariant: Colors.white, // --light-card
      outline: Color(0xffdddddd), // --border-color-light
    ),
    // Scaffold
    scaffoldBackgroundColor: const Color(0xfff9f9f9),
    // App Bar
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xfff9f9f9),
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Color(0xff17a194), // --heading-color-light
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    // Cards
    cardTheme: CardTheme(
      color: Colors.white, // --light-card
      surfaceTintColor: Colors.white,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.08), // --shadow-light
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            const BorderSide(color: Color(0xffdddddd)), // --border-color-light
      ),
    ),
    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff17a194), // primary color
        foregroundColor: Colors.white,
        disabledBackgroundColor:
            Colors.grey[300], // Dull background for disabled
        disabledForegroundColor: Colors.grey[600], // Dull text for disabled
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xff17a194), // primary color
        disabledForegroundColor: Colors.grey[600], // Dull text for disabled
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xff17a194), // primary color
        disabledForegroundColor: Colors.grey[600], // Dull text for disabled
        side: const BorderSide(color: Color(0xff17a194)), // Default border
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ).copyWith(
        side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(
                color: Colors.grey[400]!); // Dull border for disabled
          }
          return null; // Use the default side for other states
        }),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xff17a194), // primary color
      foregroundColor: Colors.white,
      disabledElevation: 0,
      elevation: 4,
      shape: CircleBorder(),
    ),
    // Inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color(0xffdddddd)), // --border-color-light
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color(0xffdddddd)), // --border-color-light
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xff17a194)), // primary color
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffba1a1a)),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color(0xffdddddd).withOpacity(0.5)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    // Dividers
    dividerTheme: const DividerThemeData(
      color: Color(0xffdddddd), // --border-color-light
      thickness: 1,
      space: 1,
    ),
    // Other
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xffe0e0e0),
      disabledColor: const Color(0xffe0e0e0).withOpacity(0.5),
      selectedColor: const Color(0xff17a194), // primary color
      secondarySelectedColor: const Color(0xff7d99d7), // secondary color
      labelStyle: const TextStyle(color: Colors.black),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      brightness: Brightness.light,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: Color(0xff7d99d7), // --secondary-color (reversed)
      onPrimary: Colors.white,
      primaryContainer: Color(0xff5f75bd),
      onPrimaryContainer: Color(0xffdae2ff),
      secondary: Color(0xff17a194), // --primary-color (reversed)
      onSecondary: Colors.white,
      secondaryContainer: Color(0xff00887b),
      onSecondaryContainer: Color(0xffb4eae3),
      tertiary: Color(0xffffc374), // --accent-color
      onTertiary: Colors.black,
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      background: Color(0xff121212), // --dark-bg
      onBackground: Color(0xffe0e0e0), // --text-color-dark
      surface: Color(0xff121212), // --dark-bg
      onSurface: Color(0xffe0e0e0), // --text-color-dark
      surfaceVariant: Color(0xff1e1e1e), // --dark-card
      outline: Color(0xff333333), // --border-color-dark
    ),
    // Scaffold
    scaffoldBackgroundColor: const Color(0xff121212),
    // App Bar
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xff121212),
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Color(0xff7d99d7), // --heading-color-dark
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    // Cards
    cardTheme: CardTheme(
      color: const Color(0xff1e1e1e), // --dark-card
      surfaceTintColor: const Color(0xff1e1e1e),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.2), // --shadow-dark
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xff333333)), // --border-color-dark
      ),
    ),
    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff7d99d7), // primary color (reversed)
        foregroundColor: Colors.white,
        disabledBackgroundColor:
            Colors.grey[800], // Dull background for disabled
        disabledForegroundColor: Colors.grey[600], // Dull text for disabled
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xff7d99d7), // primary color (reversed)
        disabledForegroundColor: Colors.grey[600], // Dull text for disabled
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xff7d99d7), // primary color (reversed)
        disabledForegroundColor: Colors.grey[600], // Dull text for disabled
        side: const BorderSide(color: Color(0xff7d99d7)), // Default border
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ).copyWith(
        side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(
                color: Colors.grey[700]!); // Dull border for disabled
          }
          return null; // Use the default side for other states
        }),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xff7d99d7), // primary color (reversed)
      foregroundColor: Colors.white,
      disabledElevation: 0,
      elevation: 4,
      shape: CircleBorder(),
    ),
    // Inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xff1e1e1e), // --dark-card
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color(0xff333333)), // --border-color-dark
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color(0xff333333)), // --border-color-dark
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
            color: Color(0xff7d99d7)), // primary color (reversed)
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffffb4ab)),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color(0xff333333).withOpacity(0.5)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    // Dividers
    dividerTheme: const DividerThemeData(
      color: Color(0xff333333), // --border-color-dark
      thickness: 1,
      space: 1,
    ),
    // Other
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xff333333),
      disabledColor: const Color(0xff333333).withOpacity(0.5),
      selectedColor: const Color(0xff7d99d7), // primary color (reversed)
      secondarySelectedColor:
          const Color(0xff17a194), // secondary color (reversed)
      labelStyle: const TextStyle(color: Colors.white),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      brightness: Brightness.dark,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );

  ThemeData light() {
    return ThemeData.light();
  }

  ThemeData dark() {
    return ThemeData.dark();
  }

  // Gradient button decoration (for both themes)
  static BoxDecoration gradientButtonDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      gradient: LinearGradient(
        colors: isDark
            ? [
                const Color(0xff7d99d7),
                const Color(0xff17a194)
              ] // reversed in dark
            : [const Color(0xff17a194), const Color(0xff7d99d7)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      boxShadow: [
        if (isDark)
          BoxShadow(
            color: const Color(0xff7d99d7).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        else
          BoxShadow(
            color: const Color(0xff17a194).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
      ],
    );
  }

  // Card hover effects
  static var cardHoverTransform = Matrix4.translationValues(0, -5, 0);
  static const cardHoverShadow = BoxShadow(
    color: Colors.black,
    blurRadius: 30,
    spreadRadius: -5,
    offset: Offset(0, 15),
  );
}
