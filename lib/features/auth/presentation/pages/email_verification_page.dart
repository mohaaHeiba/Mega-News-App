import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/core/constants/app_const.dart';
import 'package:mega_news_app/core/theme/app_theme_helper.dart';
import 'package:mega_news_app/core/utils/app_context_helper.dart';

class EmailVerificationPage extends StatelessWidget {
  const EmailVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final email = Get.arguments;
    final appTheme = AppThemeHelper(context);
    final app = AppContextHelper(context);
    final s = app.s;

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: appTheme.primary),
                AppConst.h24,

                // Verification message
                Text(
                  '${s.emailVerificationMessage} $email',
                  textAlign: TextAlign.center,
                  style: appTheme.textTheme.bodyLarge?.copyWith(
                    color: appTheme.colorScheme.onBackground,
                  ),
                ),
                AppConst.h12,

                // Instruction text
                Text(
                  '${s.emailVerificationInstruction} $email',
                  textAlign: TextAlign.center,
                  style: appTheme.textTheme.bodyMedium?.copyWith(
                    color: appTheme.colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
