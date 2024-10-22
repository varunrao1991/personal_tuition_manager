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

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff134570),
      surfaceTint: Color(0xff36618e),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff4d77a6),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff6c2f3f),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffa75f70),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff563f00),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff907023),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff8c0009),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffda342e),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff8f9ff),
      onSurface: Color(0xff191c20),
      onSurfaceVariant: Color(0xff3b4446),
      outline: Color(0xff576162),
      outlineVariant: Color(0xff737c7e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2e3135),
      inversePrimary: Color(0xffa0cafd),
      primaryFixed: Color(0xff4d77a6),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff335e8b),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xffa75f70),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff8a4758),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff907023),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff755708),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffd8dae0),
      surfaceBright: Color(0xfff8f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff2f3fa),
      surfaceContainer: Color(0xffeceef4),
      surfaceContainerHigh: Color(0xffe6e8ee),
      surfaceContainerHighest: Color(0xffe1e2e8),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff002341),
      surfaceTint: Color(0xff36618e),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff134570),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff430e1f),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff6c2f3f),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff2e2000),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff563f00),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff4e0002),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff8c0009),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff8f9ff),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff1c2527),
      outline: Color(0xff3b4446),
      outlineVariant: Color(0xff3b4446),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2e3135),
      inversePrimary: Color(0xffe2edff),
      primaryFixed: Color(0xff134570),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff002e52),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff6c2f3f),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff511929),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff563f00),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff3b2a00),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffd8dae0),
      surfaceBright: Color(0xfff8f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff2f3fa),
      surfaceContainer: Color(0xffeceef4),
      surfaceContainerHigh: Color(0xffe6e8ee),
      surfaceContainerHighest: Color(0xffe1e2e8),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
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

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffa6ceff),
      surfaceTint: Color(0xffa0cafd),
      onPrimary: Color(0xff00172d),
      primaryContainer: Color(0xff6a94c4),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffffb8c6),
      onSecondary: Color(0xff330313),
      secondaryContainer: Color(0xffc87a8c),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffedc670),
      onTertiary: Color(0xff1f1500),
      tertiaryContainer: Color(0xffaf8c3d),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffbab1),
      onError: Color(0xff370001),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff111418),
      onSurface: Color(0xfffafaff),
      onSurfaceVariant: Color(0xffc3ccce),
      outline: Color(0xff9ba5a6),
      outlineVariant: Color(0xff7b8587),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe1e2e8),
      inversePrimary: Color(0xff1b4a76),
      primaryFixed: Color(0xffd1e4ff),
      onPrimaryFixed: Color(0xff001225),
      primaryFixedDim: Color(0xffa0cafd),
      onPrimaryFixedVariant: Color(0xff003862),
      secondaryFixed: Color(0xffffd9df),
      onSecondaryFixed: Color(0xff2c000e),
      secondaryFixedDim: Color(0xffffb1c1),
      onSecondaryFixedVariant: Color(0xff5c2232),
      tertiaryFixed: Color(0xffffdf9e),
      onTertiaryFixed: Color(0xff191000),
      tertiaryFixedDim: Color(0xffe9c16c),
      onTertiaryFixedVariant: Color(0xff473300),
      surfaceDim: Color(0xff111418),
      surfaceBright: Color(0xff36393e),
      surfaceContainerLowest: Color(0xff0b0e13),
      surfaceContainerLow: Color(0xff191c20),
      surfaceContainer: Color(0xff1d2024),
      surfaceContainerHigh: Color(0xff272a2f),
      surfaceContainerHighest: Color(0xff32353a),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfffafaff),
      surfaceTint: Color(0xffa0cafd),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffa6ceff),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xfffff9f9),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffffb8c6),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xfffffaf7),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffedc670),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xfffff9f9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffbab1),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff111418),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xfff3fcfe),
      outline: Color(0xffc3ccce),
      outlineVariant: Color(0xffc3ccce),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe1e2e8),
      inversePrimary: Color(0xff002b4e),
      primaryFixed: Color(0xffd9e8ff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffa6ceff),
      onPrimaryFixedVariant: Color(0xff00172d),
      secondaryFixed: Color(0xffffdfe4),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffffb8c6),
      onSecondaryFixedVariant: Color(0xff330313),
      tertiaryFixed: Color(0xffffe4af),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffedc670),
      onTertiaryFixedVariant: Color(0xff1f1500),
      surfaceDim: Color(0xff111418),
      surfaceBright: Color(0xff36393e),
      surfaceContainerLowest: Color(0xff0b0e13),
      surfaceContainerLow: Color(0xff191c20),
      surfaceContainer: Color(0xff1d2024),
      surfaceContainerHigh: Color(0xff272a2f),
      surfaceContainerHighest: Color(0xff32353a),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
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
