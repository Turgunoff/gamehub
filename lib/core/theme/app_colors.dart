import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF5849C4);
  static const Color primaryLight = Color(0xFF8B7FF0);

  // Background Colors
  static const Color bgPrimary = Color(0xFF0A0E1A);
  static const Color bgDark = Color(0xFF0A0E1A);
  static const Color bgCard = Color(0xFF1A1F2E);
  static const Color bgCardLight = Color(0xFF242938);

  // Accent Colors
  static const Color accent = Color(0xFF00D9FF);
  static const Color success = Color(0xFF00FB94);
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFFF4757);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8BCC8);
  static const Color textTertiary = Color(0xFF7C7F88);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [bgCard, bgCardLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
