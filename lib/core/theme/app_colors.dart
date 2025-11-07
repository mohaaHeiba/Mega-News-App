import 'package:flutter/material.dart';

class AppColors {
  // 🔵 Brand Colors
  static const Color primary = Color(0xFF1E88E5); // Primary Blue
  static const Color primaryLight = Color(
    0xFF42A5F5,
  ); // Light Blue for secondary buttons / hover
  static const Color primaryDark = Color(
    0xFF1565C0,
  ); // Dark Blue for AppBar or highlights

  // ⚫ Dark Mode Backgrounds
  static const Color background = Color(0xFF212121); // Dark Background
  static const Color surface = Color(0xFF1E1E1E); // Card background
  static const Color overlay = Color(0xFF262626); // Elevated surfaces / footer

  // ⚪ Light Mode Backgrounds
  static const Color lightBackground = Color(0xFFF8F9FA); // Light Background
  static const Color lightSurface = Color(0xFFFFFFFF); // Card background
  static const Color lightOverlay = Color(0xFFF1F3F5); // Elevated surfaces

  // ⚪ Text Colors
  static const Color textPrimary = Colors.white; // Dark mode main text
  static const Color textSecondary = Color(0xFFB0B0B0); // Secondary / subtitles
  static const Color textFaint = Color(0xFF8A8A8A); // Faint text / timestamps

  static const Color textPrimaryLight = Color(
    0xFF212121,
  ); // Light mode main text
  static const Color textSecondaryLight = Color(
    0xFF555555,
  ); // Secondary text / subtitles
  static const Color textFaintLight = Color(
    0xFF9E9E9E,
  ); // Faint text / timestamps

  // 🟢 Status / Indicator Colors
  static const Color success = Color(0xFF4CAF50); // Green for success
  static const Color error = Color(0xFFE53935); // Red for error
  static const Color warning = Color(0xFFFFB300); // Yellow for warning / alerts

  // 🧊 Shadows & Glow
  static BoxShadow glow(Color color, {double opacity = 0.4}) => BoxShadow(
    color: color.withOpacity(opacity), // Glow color with opacity
    blurRadius: 25,
    spreadRadius: 2,
    offset: const Offset(0, 0),
  );

  static const BoxShadow subtleShadow = BoxShadow(
    color: Colors.black26, // Subtle shadow
    blurRadius: 6,
    offset: Offset(2, 2),
  );

  static const BoxShadow lightShadow = BoxShadow(
    color: Colors.black12, // Light shadow
    blurRadius: 10,
    offset: Offset(3, 3),
  );
}
