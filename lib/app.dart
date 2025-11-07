import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mega_news_app/core/routes/app_pages.dart';
import 'package:mega_news_app/core/theme/app_theme.dart';
import 'package:mega_news_app/generated/l10n.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    final loginBefore = storage.read('loginBefore') ?? false;
    
    // Load saved theme mode
    final savedThemeMode = storage.read('themeMode');
    ThemeMode themeMode = ThemeMode.system;
    if (savedThemeMode != null) {
      themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == savedThemeMode,
        orElse: () => ThemeMode.system,
      );
    }
    
    // Load saved locale
    final savedLanguage = storage.read('language') ?? 'en';
    final locale = Locale(savedLanguage);
    
    return GetMaterialApp(
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      locale: locale,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      initialRoute: loginBefore ? AppPages.loyoutPage : AppPages.welcomePage,
      getPages: AppPages.routes,
    );
  }
}
