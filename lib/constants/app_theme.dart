import 'package:flutter/material.dart';

class MaterialTheme {
  const MaterialTheme();

  // Text styles
  static const TextStyle _baseTextStyle = TextStyle(
    fontFamily:
        'Roboto', // Consider using Google Fonts package for custom fonts
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );

  static TextTheme _buildTextTheme(Color onBackground, Color onSurface) {
    return TextTheme(
      displayLarge: _baseTextStyle.copyWith(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: onBackground,
      ),
      displayMedium: _baseTextStyle.copyWith(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: onBackground,
      ),
      displaySmall: _baseTextStyle.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: onBackground,
      ),
      headlineLarge: _baseTextStyle.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: onBackground,
      ),
      headlineMedium: _baseTextStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: onBackground,
      ),
      headlineSmall: _baseTextStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: onBackground,
      ),
      titleLarge: _baseTextStyle.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: onSurface,
      ),
      titleMedium: _baseTextStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: onSurface,
        letterSpacing: 0.15,
      ),
      titleSmall: _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: onSurface,
        letterSpacing: 0.1,
      ),
      bodyLarge: _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: onBackground,
        letterSpacing: 0.5,
      ),
      bodyMedium: _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: onBackground,
        letterSpacing: 0.25,
      ),
      bodySmall: _baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: onBackground.withOpacity(0.6),
        letterSpacing: 0.4,
      ),
      labelLarge: _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: onBackground,
        letterSpacing: 0.1,
      ),
      labelMedium: _baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: onBackground,
        letterSpacing: 0.5,
      ),
      labelSmall: _baseTextStyle.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: onBackground,
        letterSpacing: 0.5,
      ),
    );
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: Color(0xff17a194),
      onPrimary: Colors.white,
      primaryContainer: Color(0xffb4eae3),
      onPrimaryContainer: Color(0xff00201d),
      secondary: Color(0xff7d99d7),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xffdae2ff),
      onSecondaryContainer: Color(0xff0f1b37),
      tertiary: Color(0xffffc374),
      onTertiary: Colors.black,
      error: Color(0xffba1a1a),
      onError: Colors.white,
      surface: Color(0xfff9f9f9),
      onSurface: Color(0xff444444),
      surfaceContainerHighest: Colors.white,
      outline: Color(0xffdddddd),
    ),
    // Text Theme
    textTheme:
        _buildTextTheme(const Color(0xff444444), const Color(0xff444444)),
    // Scaffold
    scaffoldBackgroundColor: const Color(0xfff9f9f9),
    // App Bar
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xfff9f9f9),
      elevation: 0,
      titleTextStyle:
          _buildTextTheme(const Color(0xff444444), const Color(0xff444444))
              .titleLarge
              ?.copyWith(
                color: const Color(0xff17a194),
                fontWeight: FontWeight.bold,
              ),
      iconTheme: const IconThemeData(color: Color(0xff17a194)),
    ),
    // Cards
    cardTheme: CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.08),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xffdddddd)),
      ),
    ),
    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff17a194),
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey[300],
        disabledForegroundColor: Colors.grey[600],
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: _buildTextTheme(Colors.white, Colors.white).labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xff17a194),
        disabledForegroundColor: Colors.grey[600],
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle:
            _buildTextTheme(const Color(0xff17a194), const Color(0xff17a194))
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xff17a194),
        disabledForegroundColor: Colors.grey[600],
        side: const BorderSide(color: Color(0xff17a194)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle:
            _buildTextTheme(const Color(0xff17a194), const Color(0xff17a194))
                .labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ).copyWith(
        side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(color: Colors.grey[400]!);
          }
          return null;
        }),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xff17a194),
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
        borderSide: const BorderSide(color: Color(0xffdddddd)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffdddddd)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xff17a194)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffba1a1a)),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color(0xffdddddd).withOpacity(0.5)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle:
          _buildTextTheme(const Color(0xff444444), const Color(0xff444444))
              .bodyMedium,
      hintStyle:
          _buildTextTheme(const Color(0xff444444), const Color(0xff444444))
              .bodyMedium
              ?.copyWith(color: const Color(0xff444444).withOpacity(0.6)),
    ),
    // Dividers
    dividerTheme: const DividerThemeData(
      color: Color(0xffdddddd),
      thickness: 1,
      space: 1,
    ),
    // Chips
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xffe0e0e0),
      disabledColor: const Color(0xffe0e0e0).withOpacity(0.5),
      selectedColor: const Color(0xff17a194),
      secondarySelectedColor: const Color(0xff7d99d7),
      labelStyle: _buildTextTheme(Colors.black, Colors.black).bodyMedium,
      secondaryLabelStyle:
          _buildTextTheme(Colors.white, Colors.white).bodyMedium,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    // Tab Bar
    tabBarTheme: TabBarThemeData(
      labelColor: const Color(0xff17a194),
      unselectedLabelColor: const Color(0xff444444).withOpacity(0.6),
      labelStyle:
          _buildTextTheme(const Color(0xff17a194), const Color(0xff17a194))
              .titleMedium,
      unselectedLabelStyle:
          _buildTextTheme(const Color(0xff444444), const Color(0xff444444))
              .titleMedium,
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(
          color: Color(0xff17a194),
          width: 2,
        ),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: Color(0xff7d99d7),
      onPrimary: Colors.white,
      primaryContainer: Color(0xff5f75bd),
      onPrimaryContainer: Color(0xffdae2ff),
      secondary: Color(0xff17a194),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xff00887b),
      onSecondaryContainer: Color(0xffb4eae3),
      tertiary: Color(0xffffc374),
      onTertiary: Colors.black,
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      surface: Color(0xff121212),
      onSurface: Color(0xffe0e0e0),
      surfaceContainerHighest: Color(0xff1e1e1e),
      outline: Color(0xff333333),
    ),
    // Text Theme
    textTheme:
        _buildTextTheme(const Color(0xffe0e0e0), const Color(0xffe0e0e0)),
    // Scaffold
    scaffoldBackgroundColor: const Color(0xff121212),
    // App Bar
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xff121212),
      elevation: 0,
      titleTextStyle:
          _buildTextTheme(const Color(0xffe0e0e0), const Color(0xffe0e0e0))
              .titleLarge
              ?.copyWith(
                color: const Color(0xff7d99d7),
                fontWeight: FontWeight.bold,
              ),
      iconTheme: const IconThemeData(color: Color(0xff7d99d7)),
    ),
    // Cards
    cardTheme: CardThemeData(
      color: const Color(0xff1e1e1e),
      surfaceTintColor: const Color(0xff1e1e1e),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.2),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xff333333)),
      ),
    ),
    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff7d99d7),
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey[800],
        disabledForegroundColor: Colors.grey[600],
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: _buildTextTheme(Colors.white, Colors.white).labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xff7d99d7),
        disabledForegroundColor: Colors.grey[600],
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle:
            _buildTextTheme(const Color(0xff7d99d7), const Color(0xff7d99d7))
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xff7d99d7),
        disabledForegroundColor: Colors.grey[600],
        side: const BorderSide(color: Color(0xff7d99d7)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle:
            _buildTextTheme(const Color(0xff7d99d7), const Color(0xff7d99d7))
                .labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ).copyWith(
        side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(color: Colors.grey[700]!);
          }
          return null;
        }),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xff7d99d7),
      foregroundColor: Colors.white,
      disabledElevation: 0,
      elevation: 4,
      shape: CircleBorder(),
    ),
    // Inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xff1e1e1e),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xff333333)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xff333333)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xff7d99d7)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffffb4ab)),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color(0xff333333).withOpacity(0.5)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle:
          _buildTextTheme(const Color(0xffe0e0e0), const Color(0xffe0e0e0))
              .bodyMedium,
      hintStyle:
          _buildTextTheme(const Color(0xffe0e0e0), const Color(0xffe0e0e0))
              .bodyMedium
              ?.copyWith(color: const Color(0xffe0e0e0).withOpacity(0.6)),
    ),
    // Dividers
    dividerTheme: const DividerThemeData(
      color: Color(0xff333333),
      thickness: 1,
      space: 1,
    ),
    // Chips
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xff333333),
      disabledColor: const Color(0xff333333).withOpacity(0.5),
      selectedColor: const Color(0xff7d99d7),
      secondarySelectedColor: const Color(0xff17a194),
      labelStyle: _buildTextTheme(Colors.white, Colors.white).bodyMedium,
      secondaryLabelStyle:
          _buildTextTheme(Colors.white, Colors.white).bodyMedium,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    // Tab Bar
    tabBarTheme: TabBarThemeData(
      labelColor: const Color(0xff7d99d7),
      unselectedLabelColor: const Color(0xffe0e0e0).withOpacity(0.6),
      labelStyle:
          _buildTextTheme(const Color(0xff7d99d7), const Color(0xff7d99d7))
              .titleMedium,
      unselectedLabelStyle:
          _buildTextTheme(const Color(0xffe0e0e0), const Color(0xffe0e0e0))
              .titleMedium,
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(
          color: Color(0xff7d99d7),
          width: 2,
        ),
      ),
    ),
  );

  // Gradient button decoration
  static BoxDecoration gradientButtonDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      gradient: LinearGradient(
        colors: isDark
            ? [const Color(0xff7d99d7), const Color(0xff17a194)]
            : [const Color(0xff17a194), const Color(0xff7d99d7)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      boxShadow: [
        BoxShadow(
          color: (isDark ? const Color(0xff7d99d7) : const Color(0xff17a194))
              .withOpacity(0.3),
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

  ThemeData light() {
    return ThemeData.light();
  }

  ThemeData dark() {
    return ThemeData.dark();
  }
}
