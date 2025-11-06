import 'package:get/get.dart';
import 'package:mega_news_app/core/layout/main_layout.dart';
import 'package:mega_news_app/features/auth/presentation/pages/auth_page.dart';
import 'package:mega_news_app/features/home/presentation/pages/home_page.dart';
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
    GetPage(
      name: homePage,
      page: () => HomePage(),
      transition: Transition.rightToLeft,
    ),
    // GetPage(
    //   name: forgotPassPage,
    //   page: () => ForgotPasswordPage(),
    //   transition: Transition.fadeIn,
    // ),
    // GetPage(
    //   name: createNewPassPage,
    //   page: () => CreateNewPasswordPage(),
    //   transition: Transition.fadeIn,
    // ),
    GetPage(
      name: loyoutPage,
      page: () => MainLayout(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: settingsPage,
      page: () => SettingsPage(),
      transition: Transition.fadeIn,
    ),
  ];
}
