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
