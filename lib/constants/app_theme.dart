import "package:flutter/material.dart";

class MaterialTheme {
  const MaterialTheme();

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4282474385),
      surfaceTint: Color(4282474385),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4292273151),
      onPrimaryContainer: Color(4278197054),
      secondary: Color(4286208012),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4294958759),
      onSecondaryContainer: Color(4280752384),
      tertiary: Color(4286009219),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4294629375),
      onTertiaryContainer: Color(4281207355),
      error: Color(4290386458),
      onError: Color(4294967295),
      errorContainer: Color(4294957782),
      onErrorContainer: Color(4282449922),
      surface: Color(4294572543),
      onSurface: Color(4279835680),
      onSurfaceVariant: Color(4282664782),
      outline: Color(4285822847),
      outlineVariant: Color(4291086032),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281217078),
      inversePrimary: Color(4289382399),
      primaryFixed: Color(4292273151),
      onPrimaryFixed: Color(4278197054),
      primaryFixedDim: Color(4289382399),
      onPrimaryFixedVariant: Color(4280829815),
      secondaryFixed: Color(4294958759),
      onSecondaryFixed: Color(4280752384),
      secondaryFixedDim: Color(4293771372),
      onSecondaryFixedVariant: Color(4284367360),
      tertiaryFixed: Color(4294629375),
      onTertiaryFixed: Color(4281207355),
      tertiaryFixedDim: Color(4293310193),
      onTertiaryFixedVariant: Color(4284364906),
      surfaceDim: Color(4292467168),
      surfaceBright: Color(4294572543),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294177786),
      surfaceContainer: Color(4293783028),
      surfaceContainerHigh: Color(4293388526),
      surfaceContainerHighest: Color(4293059305),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4280501107),
      surfaceTint: Color(4282474385),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4283987368),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4284038656),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4287852067),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4284101734),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4287587739),
      onTertiaryContainer: Color(4294967295),
      error: Color(4287365129),
      onError: Color(4294967295),
      errorContainer: Color(4292490286),
      onErrorContainer: Color(4294967295),
      surface: Color(4294572543),
      onSurface: Color(4279835680),
      onSurfaceVariant: Color(4282401610),
      outline: Color(4284243815),
      outlineVariant: Color(4286085763),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281217078),
      inversePrimary: Color(4289382399),
      primaryFixed: Color(4283987368),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4282277006),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4287852067),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4286076425),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4287587739),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4285877633),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292467168),
      surfaceBright: Color(4294572543),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294177786),
      surfaceContainer: Color(4293783028),
      surfaceContainerHigh: Color(4293388526),
      surfaceContainerHighest: Color(4293059305),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4278198602),
      surfaceTint: Color(4282474385),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4280501107),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4281278208),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4284038656),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4281733698),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4284101734),
      onTertiaryContainer: Color(4294967295),
      error: Color(4283301890),
      onError: Color(4294967295),
      errorContainer: Color(4287365129),
      onErrorContainer: Color(4294967295),
      surface: Color(4294572543),
      onSurface: Color(4278190080),
      onSurfaceVariant: Color(4280362027),
      outline: Color(4282401610),
      outlineVariant: Color(4282401610),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281217078),
      inversePrimary: Color(4293258495),
      primaryFixed: Color(4280501107),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4278463579),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4284038656),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4282198272),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4284101734),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4282457422),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292467168),
      surfaceBright: Color(4294572543),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294177786),
      surfaceContainer: Color(4293783028),
      surfaceContainerHigh: Color(4293388526),
      surfaceContainerHighest: Color(4293059305),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4289382399),
      surfaceTint: Color(4289382399),
      onPrimary: Color(4278857823),
      primaryContainer: Color(4280829815),
      onPrimaryContainer: Color(4292273151),
      secondary: Color(4293771372),
      onSecondary: Color(4282461440),
      secondaryContainer: Color(4284367360),
      onSecondaryContainer: Color(4294958759),
      tertiary: Color(4293310193),
      onTertiary: Color(4282786130),
      tertiaryContainer: Color(4284364906),
      onTertiaryContainer: Color(4294629375),
      error: Color(4294948011),
      onError: Color(4285071365),
      errorContainer: Color(4287823882),
      onErrorContainer: Color(4294957782),
      surface: Color(4279309080),
      onSurface: Color(4293059305),
      onSurfaceVariant: Color(4291086032),
      outline: Color(4287533209),
      outlineVariant: Color(4282664782),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293059305),
      inversePrimary: Color(4282474385),
      primaryFixed: Color(4292273151),
      onPrimaryFixed: Color(4278197054),
      primaryFixedDim: Color(4289382399),
      onPrimaryFixedVariant: Color(4280829815),
      secondaryFixed: Color(4294958759),
      onSecondaryFixed: Color(4280752384),
      secondaryFixedDim: Color(4293771372),
      onSecondaryFixedVariant: Color(4284367360),
      tertiaryFixed: Color(4294629375),
      onTertiaryFixed: Color(4281207355),
      tertiaryFixedDim: Color(4293310193),
      onTertiaryFixedVariant: Color(4284364906),
      surfaceDim: Color(4279309080),
      surfaceBright: Color(4281809214),
      surfaceContainerLowest: Color(4278980115),
      surfaceContainerLow: Color(4279835680),
      surfaceContainer: Color(4280098852),
      surfaceContainerHigh: Color(4280822319),
      surfaceContainerHighest: Color(4281546042),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4289842175),
      surfaceTint: Color(4289382399),
      onPrimary: Color(4278195764),
      primaryContainer: Color(4285829575),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4294100080),
      onSecondary: Color(4280292352),
      secondaryContainer: Color(4289890877),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4293638902),
      onTertiary: Color(4280812598),
      tertiaryContainer: Color(4289561017),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294949553),
      onError: Color(4281794561),
      errorContainer: Color(4294923337),
      onErrorContainer: Color(4278190080),
      surface: Color(4279309080),
      onSurface: Color(4294703871),
      onSurfaceVariant: Color(4291349204),
      outline: Color(4288717740),
      outlineVariant: Color(4286612364),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293059305),
      inversePrimary: Color(4280895608),
      primaryFixed: Color(4292273151),
      onPrimaryFixed: Color(4278194475),
      primaryFixedDim: Color(4289382399),
      onPrimaryFixedVariant: Color(4279449189),
      secondaryFixed: Color(4294958759),
      onSecondaryFixed: Color(4279897856),
      secondaryFixedDim: Color(4293771372),
      onSecondaryFixedVariant: Color(4282987008),
      tertiaryFixed: Color(4294629375),
      onTertiaryFixed: Color(4280483888),
      tertiaryFixedDim: Color(4293310193),
      onTertiaryFixedVariant: Color(4283180888),
      surfaceDim: Color(4279309080),
      surfaceBright: Color(4281809214),
      surfaceContainerLowest: Color(4278980115),
      surfaceContainerLow: Color(4279835680),
      surfaceContainer: Color(4280098852),
      surfaceContainerHigh: Color(4280822319),
      surfaceContainerHighest: Color(4281546042),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4294703871),
      surfaceTint: Color(4289382399),
      onPrimary: Color(4278190080),
      primaryContainer: Color(4289842175),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4294966007),
      onSecondary: Color(4278190080),
      secondaryContainer: Color(4294100080),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4294965754),
      onTertiary: Color(4278190080),
      tertiaryContainer: Color(4293638902),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294965753),
      onError: Color(4278190080),
      errorContainer: Color(4294949553),
      onErrorContainer: Color(4278190080),
      surface: Color(4279309080),
      onSurface: Color(4294967295),
      onSurfaceVariant: Color(4294703871),
      outline: Color(4291349204),
      outlineVariant: Color(4291349204),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293059305),
      inversePrimary: Color(4278200665),
      primaryFixed: Color(4292732927),
      onPrimaryFixed: Color(4278190080),
      primaryFixedDim: Color(4289842175),
      onPrimaryFixedVariant: Color(4278195764),
      secondaryFixed: Color(4294960055),
      onSecondaryFixed: Color(4278190080),
      secondaryFixedDim: Color(4294100080),
      onSecondaryFixedVariant: Color(4280292352),
      tertiaryFixed: Color(4294696447),
      onTertiaryFixed: Color(4278190080),
      tertiaryFixedDim: Color(4293638902),
      onTertiaryFixedVariant: Color(4280812598),
      surfaceDim: Color(4279309080),
      surfaceBright: Color(4281809214),
      surfaceContainerLowest: Color(4278980115),
      surfaceContainerLow: Color(4279835680),
      surfaceContainer: Color(4280098852),
      surfaceContainerHigh: Color(4280822319),
      surfaceContainerHighest: Color(4281546042),
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
