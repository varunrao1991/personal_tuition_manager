import "package:flutter/material.dart";

class MaterialTheme {
  const MaterialTheme();

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff36618e),
      surfaceTint: Color(0xff36618e),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffd1e4ff),
      onPrimaryContainer: Color(0xff001d36),
      secondary: Color(0xff8d4a5a),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffffd9df),
      onSecondaryContainer: Color(0xff3a0718),
      tertiary: Color(0xff775a0b),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffffdf9e),
      onTertiaryContainer: Color(0xff261a00),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff410002),
      surface: Color(0xfff8f9ff),
      onSurface: Color(0xff191c20),
      onSurfaceVariant: Color(0xff3f484a),
      outline: Color(0xff6f797a),
      outlineVariant: Color(0xffbfc8ca),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2e3135),
      inversePrimary: Color(0xffa0cafd),
      primaryFixed: Color(0xffd1e4ff),
      onPrimaryFixed: Color(0xff001d36),
      primaryFixedDim: Color(0xffa0cafd),
      onPrimaryFixedVariant: Color(0xff194975),
      secondaryFixed: Color(0xffffd9df),
      onSecondaryFixed: Color(0xff3a0718),
      secondaryFixedDim: Color(0xffffb1c1),
      onSecondaryFixedVariant: Color(0xff713343),
      tertiaryFixed: Color(0xffffdf9e),
      onTertiaryFixed: Color(0xff261a00),
      tertiaryFixedDim: Color(0xffe9c16c),
      onTertiaryFixedVariant: Color(0xff5b4300),
      surfaceDim: Color(0xffd8dae0),
      surfaceBright: Color(0xfff8f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff2f3fa),
      surfaceContainer: Color(0xffeceef4),
      surfaceContainerHigh: Color(0xffe6e8ee),
      surfaceContainerHighest: Color(0xffe1e2e8),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffa0cafd),
      surfaceTint: Color(0xffa0cafd),
      onPrimary: Color(0xff003258),
      primaryContainer: Color(0xff194975),
      onPrimaryContainer: Color(0xffd1e4ff),
      secondary: Color(0xffffb1c1),
      onSecondary: Color(0xff551d2d),
      secondaryContainer: Color(0xff713343),
      onSecondaryContainer: Color(0xffffd9df),
      tertiary: Color(0xffe9c16c),
      onTertiary: Color(0xff3f2e00),
      tertiaryContainer: Color(0xff5b4300),
      onTertiaryContainer: Color(0xffffdf9e),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff111418),
      onSurface: Color(0xffe1e2e8),
      onSurfaceVariant: Color(0xffbfc8ca),
      outline: Color(0xff899294),
      outlineVariant: Color(0xff3f484a),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe1e2e8),
      inversePrimary: Color(0xff36618e),
      primaryFixed: Color(0xffd1e4ff),
      onPrimaryFixed: Color(0xff001d36),
      primaryFixedDim: Color(0xffa0cafd),
      onPrimaryFixedVariant: Color(0xff194975),
      secondaryFixed: Color(0xffffd9df),
      onSecondaryFixed: Color(0xff3a0718),
      secondaryFixedDim: Color(0xffffb1c1),
      onSecondaryFixedVariant: Color(0xff713343),
      tertiaryFixed: Color(0xffffdf9e),
      onTertiaryFixed: Color(0xff261a00),
      tertiaryFixedDim: Color(0xffe9c16c),
      onTertiaryFixedVariant: Color(0xff5b4300),
      surfaceDim: Color(0xff111418),
      surfaceBright: Color(0xff36393e),
      surfaceContainerLowest: Color(0xff0b0e13),
      surfaceContainerLow: Color(0xff191c20),
      surfaceContainer: Color(0xff1d2024),
      surfaceContainerHigh: Color(0xff272a2f),
      surfaceContainerHighest: Color(0xff32353a),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        textTheme: const TextTheme().apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
        scaffoldBackgroundColor: colorScheme.surface,
        canvasColor: colorScheme.surface,
        cardTheme: CardTheme(
          color: colorScheme.surfaceContainerHighest,
          shadowColor: colorScheme.onSurface,
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: colorScheme.primary,
          textTheme: ButtonTextTheme.primary,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
