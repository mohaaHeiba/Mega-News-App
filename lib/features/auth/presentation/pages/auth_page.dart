import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mega_news_app/core/routes/app_pages.dart';
import 'package:mega_news_app/core/theme/app_theme_helper.dart';
import 'package:mega_news_app/features/auth/presentation/controller/auth_controller.dart';
import 'package:mega_news_app/features/auth/presentation/pages/create_new_password_page.dart';
import 'package:mega_news_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:mega_news_app/features/auth/presentation/pages/login_page.dart';
import 'package:mega_news_app/features/auth/presentation/pages/register_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController(), permanent: true);
    final appTheme = AppThemeHelper(context);

    return Scaffold(
      backgroundColor: appTheme.background,

      // AppBar with Guest Button
      appBar: AppBar(
        backgroundColor: appTheme.background,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () async {
              await GetStorage().write('loginBefore', true);

              Get.offAllNamed(AppPages.loyoutPage);
            },
            icon: const Icon(Icons.person_outline),
            label: const Text('Guest'),
            style: TextButton.styleFrom(
              foregroundColor: appTheme.colorScheme.primary,
              textStyle: appTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),

      body: Form(
        key: controller.formKey,
        child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: controller.pageController,
          onPageChanged: controller.onPageChanged,
          children: const [
            LoginPage(),
            RegisterPage(),
            ForgotPasswordPage(),
            CreateNewPasswordPage(),
          ],
        ),
      ),
    );
  }
}
