import 'package:flutter/material.dart';

abstract final class SafePlaceColors {
  static const Color nightBlue = Color(0xFF0D1321);
  static const Color indigo = Color(0xFF1E2A78);
  static const Color safeBlue = Color(0xFF4A6CFF);
  static const Color alertPurple = Color(0xFF8B5CF6);
  static const Color safeGreen = Color(0xFF22C55E);
  static const Color lightGray = Color(0xFFE5E7EB);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color mediumRisk = Color(0xFFEAB308);
  static const Color highRisk = Color(0xFFEF4444);
  static const Color white = Color(0xFFF8FAFC);
  static const Color panel = Color(0xFF121A33);

  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [safeBlue, alertPurple],
  );

  static const LinearGradient wordmark = LinearGradient(
    colors: [safeBlue, alertPurple],
  );
}
