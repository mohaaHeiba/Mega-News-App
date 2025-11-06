import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/features/auth/presentation/controller/auth_controller.dart';
import 'package:mega_news_app/features/auth/presentation/pages/login_page.dart';
import 'package:mega_news_app/features/auth/presentation/pages/register_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController(), permanent: true);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Form(
        key: controller.formKey,
        child: Stack(
          children: [
            PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              children: const [
                LoginPage(),
                RegisterPage(),
                // ForgotPasswordPage(),
                // CreateNewPasswordPage(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
