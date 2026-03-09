import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF2563EB);
  static const primaryDark = Color(0xFF1E40AF);
  static const primaryLight = Color(0xFF60A5FA);

  static const accent = Color(0xFF10B981);

  static const background = Color(0xFFF9FAFB);
  static const surface = Colors.white;
  static const surfaceAlt = Color(0xFFF3F4F6);

  static const divider = Color(0xFFE5E7EB);

  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textHint = Color(0xFF9CA3AF);

  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF22C55E);

  static const starFilled = Color(0xFFFACC15);

  static const chipCafe = Color(0xFFFDE68A);
  static const chipHospital = Color(0xFFFCA5A5);
  static const chipPharmacy = Color(0xFFA7F3D0);
  static const chipPolice = Color(0xFFBFDBFE);
  static const chipPark = Color(0xFFBBF7D0);
  static const chipLibrary = Color(0xFFE9D5FF);
  static const chipRestaurant = Color(0xFFFECACA);
  static const chipTourist = Color(0xFFDDD6FE);
  static const Color warning = Color(0xFFF57F17);
}

class AppTextStyles {
  static const displayLarge =
      TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
  static const displayMedium =
      TextStyle(fontSize: 28, fontWeight: FontWeight.bold);

  static const titleLarge =
      TextStyle(fontSize: 22, fontWeight: FontWeight.bold);
  static const titleMedium =
      TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  static const titleSmall =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

  static const bodyLarge = TextStyle(fontSize: 16);
  static const bodyMedium = TextStyle(fontSize: 14);

  static const labelLarge =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w500);

  static const caption = TextStyle(fontSize: 12, color: Colors.grey);

  static const button = TextStyle(fontSize: 14, fontWeight: FontWeight.bold);
}

class AppTheme {
  static final theme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      background: AppColors.background,
      surface: AppColors.surface,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceAlt,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
    ),
  );
}
