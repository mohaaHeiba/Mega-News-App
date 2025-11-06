import 'package:flutter/material.dart';

class AppThemeHelper {
  final BuildContext context;
  AppThemeHelper(this.context);

  ThemeData get theme => Theme.of(context);

  ColorScheme get colorScheme => theme.colorScheme;

  TextTheme get textTheme => theme.textTheme;

  Brightness get brightness => theme.brightness;

  bool get isDarkMode => brightness == Brightness.dark;

  Color get primary => colorScheme.primary;
  Color get onPrimary => colorScheme.onPrimary;
  Color get background => colorScheme.background;
  Color get surface => colorScheme.surface;
  Color get onBackground => colorScheme.onBackground;
  Color get onSurface => colorScheme.onSurface;

  Color get primaryTextColor =>
      isDarkMode ? Colors.white : const Color(0xFF212121);
}
