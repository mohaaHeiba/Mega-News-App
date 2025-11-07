import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients extends ThemeExtension<AppGradients> {
  final LinearGradient logo;
  final LinearGradient background;
  final LinearGradient overlay;

  const AppGradients({
    required this.logo,
    required this.background,
    required this.overlay,
  });

  // ================= Dark Theme Gradients ====================
  static const AppGradients dark = AppGradients(
    logo: LinearGradient(
      colors: [AppColors.primary, AppColors.primaryDark, Colors.white],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ), // Logo gradient
    background: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.background, AppColors.surface, AppColors.overlay],
    ), // Background gradient
    overlay: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.overlay, AppColors.surface, AppColors.background],
      stops: [0.0, 0.6, 1.0],
    ), // Overlay gradient
  );

  // ================= Light Theme Gradients ====================
  static final AppGradients light = AppGradients(
    logo: const LinearGradient(
      colors: [
        AppColors.primary,
        Color.fromARGB(255, 60, 220, 205),
        AppColors.primaryLight,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ), // Logo gradient
    background: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.lightBackground,
        AppColors.lightSurface,
        AppColors.lightOverlay,
      ],
    ), // Background gradient
    overlay: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.lightOverlay.withOpacity(0.9),
        AppColors.lightSurface.withOpacity(0.95),
        AppColors.lightBackground.withOpacity(0.9),
      ],
      stops: const [0.0, 0.5, 1.0],
    ), // Overlay gradient
  );

  // =============== Copy & Lerp ====================
  @override
  AppGradients copyWith({
    LinearGradient? logo,
    LinearGradient? background,
    LinearGradient? overlay,
  }) {
    return AppGradients(
      logo: logo ?? this.logo,
      background: background ?? this.background,
      overlay: overlay ?? this.overlay,
    );
  }

  @override
  AppGradients lerp(ThemeExtension<AppGradients>? other, double t) {
    if (other is! AppGradients) return this;
    return AppGradients(
      logo: LinearGradient.lerp(logo, other.logo, t)!,
      background: LinearGradient.lerp(background, other.background, t)!,
      overlay: LinearGradient.lerp(overlay, other.overlay, t)!,
    );
  }
}
