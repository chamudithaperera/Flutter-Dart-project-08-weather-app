import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryDark = Color(0xFF2D2F3A);
  static const Color primary = Color(0xFF494D5F);

  // Accent Colors
  static const Color accent = Color(0xFF64B5F6); // Blue accent
  static const Color accentLight = Color(0xFF90CAF9);

  // Background Colors
  static const Color background = Color(0xFF494D5F);
  static const Color cardBackground = Colors.white;

  // Text Colors
  static const Color textDark = Color(0xFF2D2F3A);
  static const Color textLight = Colors.white;
  static const Color textGrey = Color(0xFF9E9E9E);

  // Progress Colors
  static const Color progress = Color(0xFFFF6B6B);
  static const Color progressBackground = Color(
    0x33FFFFFF,
  ); // White with 20% opacity

  // Gradient Colors
  static final List<Color> backgroundGradient = [
    const Color(0xFF64B5F6), // Light Blue
    const Color(0xFF1976D2), // Dark Blue
  ];
}
