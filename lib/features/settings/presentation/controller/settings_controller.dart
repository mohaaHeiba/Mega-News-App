import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mega_news_app/core/theme/app_theme.dart';

class SettingsController extends GetxController {
  final storage = GetStorage();

  // persisted values
  final isDark = false.obs;
  final notificationsEnabled = true.obs;
  final language = 'en'.obs;

  @override
  void onInit() {
    super.onInit();
    isDark.value = storage.read('isDark') ?? false;
    notificationsEnabled.value = storage.read('notifications') ?? true;
    language.value = storage.read('language') ?? 'en';

    // apply theme at startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.changeTheme(isDark.value ? AppTheme.dark : AppTheme.light);
    });
  }

  void toggleDarkMode() {
    isDark.value = !isDark.value;
    storage.write('isDark', isDark.value);
    Get.changeTheme(isDark.value ? AppTheme.dark : AppTheme.light);
  }

  void toggleNotifications() {
    notificationsEnabled.value = !notificationsEnabled.value;
    storage.write('notifications', notificationsEnabled.value);
  }

  void setLanguage(String lang) {
    language.value = lang;
    storage.write('language', lang);
    // Optional: implement locale change via Get.updateLocale if desired
  }

  Future<void> clearCache() async {
    await storage.erase();
    // reset observables to defaults
    isDark.value = false;
    notificationsEnabled.value = true;
    language.value = 'en';
    // apply default theme
    Get.changeTheme(AppTheme.light);
  }

  void logout() {
    storage.remove('loginBefore');
    // navigate back to auth or welcome page if desired
    Get.offAllNamed('/welcome');
  }
}
