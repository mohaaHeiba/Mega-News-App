import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/core/routes/app_pages.dart';
import 'package:mega_news_app/core/theme/app_theme.dart';
import 'package:mega_news_app/features/welcome/welcome_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // final loginBefore = GetStorage().read('loginBefore') ?? false;
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: WelcomePage(),
      // initialRoute: AppPages.loyoutPage,
      // // loginBefore ? : AppPages.welcomePage,
      // getPages: AppPages.routes,
    );
  }
}
