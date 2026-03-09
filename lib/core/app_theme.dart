// lib/utils/app_theme.dart
// PURPOSE: Single source of truth for all visual design.
// Change here → whole app updates automatically.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  AppColors._();
  static const Color primary        = Color(0xFF1B6B3A);
  static const Color primaryDark    = Color(0xFF124A28);
  static const Color primaryLight   = Color(0xFF4CAF71);
  static const Color accent         = Color(0xFFE07B39);
  static const Color accentLight    = Color(0xFFFFF3EC);
  static const Color background     = Color(0xFFF4F6F9);
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color surfaceAlt     = Color(0xFFF0F4F0);
  static const Color divider        = Color(0xFFEEEEEE);
  static const Color textPrimary    = Color(0xFF1A1A2E);
  static const Color textSecondary  = Color(0xFF6B7280);
  static const Color textHint       = Color(0xFFB0B8C4);
  static const Color success        = Color(0xFF2E7D32);
  static const Color error          = Color(0xFFD32F2F);
  static const Color warning        = Color(0xFFF57F17);
  static const Color starFilled     = Color(0xFFFFC107);
  static const Color starEmpty      = Color(0xFFE0E0E0);
  static const Color chipCafe       = Color(0xFFFFF8E1);
  static const Color chipHospital   = Color(0xFFE8F5E9);
  static const Color chipPharmacy   = Color(0xFFE3F2FD);
  static const Color chipPolice     = Color(0xFFFCE4EC);
  static const Color chipPark       = Color(0xFFF1F8E9);
  static const Color chipLibrary    = Color(0xFFEDE7F6);
  static const Color chipRestaurant = Color(0xFFFFF3E0);
  static const Color chipTourist    = Color(0xFFE0F7FA);
}

class AppTextStyles {
  AppTextStyles._();
  static const TextStyle displayLarge = TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.8, height: 1.2);
  static const TextStyle displayMedium = TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.4);
  static const TextStyle titleLarge = TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.2);
  static const TextStyle titleMedium = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const TextStyle titleSmall = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const TextStyle bodyLarge = TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.6);
  static const TextStyle bodyMedium = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.5);
  static const TextStyle labelLarge = TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: 0.2);
  static const TextStyle caption = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary, letterSpacing: 0.3);
  static const TextStyle button = TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.3);
}

class AppTheme {
  AppTheme._();
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3),
        iconTheme: IconThemeData(color: Colors.white, size: 22),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 16,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.divider, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider, width: 1.2)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider, width: 1.2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error, width: 1.5)),
        hintStyle: AppTextStyles.bodyMedium,
        labelStyle: AppTextStyles.bodyMedium,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, foregroundColor: Colors.white,
          elevation: 0, minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: AppTextStyles.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: AppTextStyles.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
        elevation: 4, shape: CircleBorder(),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1, space: 0),
      fontFamily: 'Roboto',
    );
  }
}
