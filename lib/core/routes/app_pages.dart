import 'package:get/get.dart';
import 'package:mega_news_app/core/layout/main_layout.dart';
import 'package:mega_news_app/features/auth/presentation/pages/auth_page.dart';
import 'package:mega_news_app/features/auth/presentation/pages/create_new_password_page.dart';
import 'package:mega_news_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:mega_news_app/features/favorites/presentation/pages/favorites_page.dart';
import 'package:mega_news_app/features/search/pages/show_search_page.dart';
import 'package:mega_news_app/features/settings/presentation/pages/settings_page.dart';
import 'package:mega_news_app/features/welcome/welcome_page.dart';

class AppPages {
  static const welcomePage = '/welcome';
  static const authPage = '/auth';
  static const homePage = '/home';
  static const forgotPassPage = '/forgotPass';
  static const createNewPassPage = '/newPass';
  static const settingsPage = '/settingsPage';

  static const loyoutPage = '/loyoutPage';
  static const searchPage = '/searchPage';
  static const favoritesPage = '/favoritesPage';

  static List<GetPage> routes = [
    GetPage(
      name: welcomePage,
      page: () => const WelcomePage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 700),
    ),
    GetPage(
      name: authPage,
      page: () => AuthPage(),
      transition: Transition.fadeIn,
    ),
    // GetPage(
    //   name: homePage,
    //   page: () => HomePage(),
    //   transition: Transition.rightToLeft,
    // ),
    GetPage(
      name: forgotPassPage,
      page: () => ForgotPasswordPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: createNewPassPage,
      page: () => CreateNewPasswordPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: loyoutPage,
      page: () => MainLayout(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: settingsPage,
      page: () => const SettingsPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: searchPage,
      page: () => const ShowSearchPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 700),
    ),
    GetPage(
      name: favoritesPage,
      page: () => const FavoritesPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
