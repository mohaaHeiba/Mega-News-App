import 'package:flutter/material.dart';
import 'package:mega_news_app/core/theme/app_colors.dart';
import 'package:mega_news_app/core/theme/app_gradients.dart';

class AppTheme {
  // =============== Dark Theme ====================
  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.primaryLight,
      surface: AppColors.surface,
      background: AppColors.background,
      error: AppColors.error,
    ),

    // =============== Gradients ====================
    extensions: const <ThemeExtension<dynamic>>[AppGradients.dark],

    cardColor: AppColors.surface,
    dialogBackgroundColor: AppColors.overlay,

    // =============== Text ====================
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
        letterSpacing: 2.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.textSecondary),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary),
      labelSmall: TextStyle(fontSize: 12, color: AppColors.textFaint),
    ),

    // =============== Button ====================
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: AppColors.primary.withOpacity(0.25),
        elevation: 8,
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    ),

    // =============== TextField ====================
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.overlay,
      hintStyle: const TextStyle(color: AppColors.textFaint),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.textFaint, width: 0.8),
      ),
    ),
  );

  // =============== Light Theme ====================
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    primaryColor: AppColors.primary,

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.primaryDark,
      surface: AppColors.lightSurface,
      background: AppColors.lightBackground,
      error: AppColors.error,
    ),

    // =============== Gradients ====================
    extensions: <ThemeExtension<dynamic>>[AppGradients.light],

    cardColor: AppColors.lightSurface,
    dialogBackgroundColor: AppColors.lightOverlay,

    // =============== Text ====================
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimaryLight,
        letterSpacing: 2.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.textSecondaryLight),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondaryLight),
      labelSmall: TextStyle(fontSize: 12, color: AppColors.textFaintLight),
    ),

    // =============== Button ====================
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: AppColors.primary.withOpacity(0.2),
        elevation: 5,
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    ),

    // =============== TextField ====================
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightOverlay,
      hintStyle: const TextStyle(color: AppColors.textFaintLight, fontSize: 14),
      labelStyle: const TextStyle(
        color: AppColors.textFaint,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
      floatingLabelStyle: const TextStyle(
        color: AppColors.primaryDark,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.textFaintLight,
          width: 0.8,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
