import 'package:flutter/material.dart';

abstract final class AppPalette {
  static const background = Color(0xFFF5F1E8);
  static const surface = Color(0xFFFFFCF6);
  static const ink = Color(0xFF1E2A2C);
  static const mutedInk = Color(0xFF687170);
  static const teal = Color(0xFF176C68);
  static const deepTeal = Color(0xFF104C4A);
  static const gold = Color(0xFFC89D4D);
  static const softGold = Color(0xFFE6C77E);
  static const border = Color(0xFFE6DED0);
  static const unread = Color(0xFFE46D52);

  // Canonical Modern Legal Editorial tokens
  static const canvas = Color(0xFFF7F5F2);
  static const primaryGreen = Color(0xFF1F3D2B);
  static const deepGreen = Color(0xFF13382E);
  static const accentGold = Color(0xFFCCA046);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textMuted = Color(0xFF6B665E);
  static const cardBackground = Color(0xFFFFFFFF);
  static const borderLight = Color(0xFFE5DFD7);
}

abstract final class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppPalette.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppPalette.teal,
      brightness: Brightness.light,
      surface: AppPalette.surface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.background,
      foregroundColor: AppPalette.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    dividerColor: AppPalette.border,
  );
}
