import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingsController extends GetxController {
  final storage = GetStorage();

  // persisted values
  final isDark = false.obs;
  final themeMode = ThemeMode.system.obs;
  final notificationsEnabled = true.obs;
  final breakingNewsEnabled = true.obs;
  final language = 'en'.obs;

  // PageController
  late final PageController pageController;

  // Current page index
  final currentPage = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();

    // Initialize PageController
    pageController = PageController(initialPage: 0);

    // Defer theme and locale application until after build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyTheme();
      _applyLocale();
    });
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void _loadSettings() {
    // Load theme mode
    final savedThemeMode = storage.read('themeMode');
    if (savedThemeMode != null) {
      themeMode.value = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == savedThemeMode,
        orElse: () => ThemeMode.system,
      );
    }
    isDark.value = storage.read('isDark') ?? false;

    notificationsEnabled.value = storage.read('notifications') ?? true;
    breakingNewsEnabled.value = storage.read('breakingNews') ?? true;
    language.value = storage.read('language') ?? 'en';
  }

  void _applyTheme() {
    if (themeMode.value == ThemeMode.system) {
      Get.changeThemeMode(ThemeMode.system);
    } else if (themeMode.value == ThemeMode.dark) {
      Get.changeThemeMode(ThemeMode.dark);
      isDark.value = true;
    } else {
      Get.changeThemeMode(ThemeMode.light);
      isDark.value = false;
    }
  }

  void _applyLocale() {
    final locale = Locale(language.value);
    Get.updateLocale(locale);
  }

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    storage.write('themeMode', mode.toString());
    _applyTheme();
  }

  void toggleDarkMode() {
    isDark.value = !isDark.value;
    storage.write('isDark', isDark.value);
    final mode = isDark.value ? ThemeMode.dark : ThemeMode.light;
    setThemeMode(mode);
  }

  void toggleNotifications() {
    notificationsEnabled.value = !notificationsEnabled.value;
    storage.write('notifications', notificationsEnabled.value);
  }

  void toggleBreakingNews() {
    breakingNewsEnabled.value = !breakingNewsEnabled.value;
    storage.write('breakingNews', breakingNewsEnabled.value);
  }

  void setLanguage(String lang) {
    language.value = lang;
    storage.write('language', lang);
    _applyLocale();
  }

  // Navigate to specific page
  void setPage(int index) {
    currentPage.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> clearCache() async {
    // Clear cache but keep login and settings
    final loginBefore = storage.read('loginBefore');
    final savedThemeMode = storage.read('themeMode');
    final savedLanguage = storage.read('language');
    final savedNotifications = storage.read('notifications');
    final savedBreakingNews = storage.read('breakingNews');
    final savedFontSize = storage.read('fontSize');

    await storage.erase();

    // Restore important settings
    if (loginBefore != null) storage.write('loginBefore', loginBefore);
    if (savedThemeMode != null) storage.write('themeMode', savedThemeMode);
    if (savedLanguage != null) storage.write('language', savedLanguage);
    if (savedNotifications != null) {
      storage.write('notifications', savedNotifications);
    }
    if (savedBreakingNews != null) {
      storage.write('breakingNews', savedBreakingNews);
    }
    if (savedFontSize != null) storage.write('fontSize', savedFontSize);

    Get.snackbar(
      'Cache Cleared',
      'Cache has been cleared successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void logout() {
    storage.remove('loginBefore');
    Get.offAllNamed('/welcome');
  }

  String getAppVersion() {
    // You can use package_info_plus to get actual version
    return '1.0.0';
  }
}
