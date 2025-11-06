import 'package:flutter/material.dart';

class AppColors {
  // 🔵 Brand
  static const Color primary = Color(0xFF1E88E5); // أزرق هادئ وموثوق
  static const Color primaryLight = Color(
    0xFF42A5F5,
  ); // لأزرار secondary و hove
  static const Color primaryDark = Color(
    0xFF1565C0,
  ); // Dark AppBar أو highlights

  // ⚫ Backgrounds (Dark Mode)
  static const Color background = Color.fromARGB(
    255,
    33,
    33,
    33,
  ); // دارك مود أساسي
  static const Color surface = Color(0xFF1E1E1E); // Cards
  static const Color overlay = Color(0xFF262626); // Elevated surfaces أو footer

  // ⚪ Backgrounds (Light Mode)
  static const Color lightBackground = Color(0xFFF8F9FA); // خلفية فاتحة
  static const Color lightSurface = Color(0xFFFFFFFF); // Cards
  static const Color lightOverlay = Color(0xFFF1F3F5); // Elevated surfaces

  // ⚪ Text
  static const Color textPrimary = Colors.white; // Dark mode main text
  static const Color textSecondary = Color(0xFFB0B0B0); // Secondary / subtitles
  static const Color textFaint = Color(0xFF8A8A8A); // faint / timestamps

  static const Color textPrimaryLight = Color(
    0xFF212121,
  ); // Light mode main text
  static const Color textSecondaryLight = Color(0xFF555555); // subtitles
  static const Color textFaintLight = Color(0xFF9E9E9E); // faint / timestamps

  // 🟢 Status / Indicators
  static const Color success = Color(0xFF4CAF50); // success
  static const Color error = Color(0xFFE53935); // error
  static const Color warning = Color(0xFFFFB300); // warning / alerts

  // 🧊 Shadows & Glow
  static BoxShadow glow(Color color, {double opacity = 0.4}) => BoxShadow(
    color: color.withOpacity(opacity),
    blurRadius: 25,
    spreadRadius: 2,
    offset: const Offset(0, 0),
  );

  static const BoxShadow subtleShadow = BoxShadow(
    color: Colors.black26,
    blurRadius: 6,
    offset: Offset(2, 2),
  );

  static const BoxShadow lightShadow = BoxShadow(
    color: Colors.black12,
    blurRadius: 10,
    offset: Offset(3, 3),
  );
}
