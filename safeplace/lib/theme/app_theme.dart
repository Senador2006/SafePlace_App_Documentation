import 'package:flutter/material.dart';
import 'package:safeplace/theme/colors.dart';

abstract final class SafePlaceTheme {
  static ThemeData dark() {
    const textTheme = TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w700,
        fontSize: 40,
        letterSpacing: -0.5,
        color: SafePlaceColors.white,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w700,
        fontSize: 24,
        color: SafePlaceColors.white,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w600,
        fontSize: 16,
        letterSpacing: 2.4,
        color: SafePlaceColors.lightGray,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
        fontSize: 16,
        height: 1.5,
        color: SafePlaceColors.lightGray,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
        fontSize: 14,
        height: 1.45,
        color: SafePlaceColors.mediumGray,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w600,
        fontSize: 15,
        letterSpacing: 0.4,
        color: SafePlaceColors.white,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SafePlaceColors.nightBlue,
      colorScheme: const ColorScheme.dark(
        primary: SafePlaceColors.safeBlue,
        secondary: SafePlaceColors.alertPurple,
        surface: SafePlaceColors.nightBlue,
        onPrimary: SafePlaceColors.white,
        onSurface: SafePlaceColors.white,
      ),
      textTheme: textTheme,
      fontFamily: 'Inter',
    );
  }
}
