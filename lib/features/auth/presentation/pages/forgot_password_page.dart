import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/core/constants/app_const.dart';
import 'package:mega_news_app/core/custom/text_form_fileds_widget.dart';
import 'package:mega_news_app/core/theme/app_colors.dart';
import 'package:mega_news_app/core/theme/app_theme_helper.dart';
import 'package:mega_news_app/core/utils/app_context_helper.dart';
import 'package:mega_news_app/core/utils/validator.dart';
import 'package:mega_news_app/features/auth/presentation/controller/auth_controller.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final appTheme = AppThemeHelper(context);
    final app = AppContextHelper(context);
    final s = app.s;
    final validator = Validator(app);

    return SingleChildScrollView(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              Icon(
                Icons.lock_reset_rounded,
                color: appTheme.colorScheme.primary,
                size: app.screenWidth * 0.18,
              ),
              AppConst.h24,

              // Title
              Text(
                s.forgotPasswordTitle,
                textAlign: TextAlign.center,
                style: appTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: appTheme.colorScheme.onBackground,
                ),
              ),
              AppConst.h12,

              // Description
              Text(
                s.forgotPasswordSubtitle,
                textAlign: TextAlign.center,
                style: appTheme.textTheme.bodyMedium?.copyWith(
                  color: appTheme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              AppConst.h40,

              // Email Field
              textFieldWidget(
                controller: controller.emailController,
                label: s.labelEmail,
                hint: s.hintEmail,
                icon: Icons.email_outlined,
                inputType: TextInputType.emailAddress,
                validator: (value) => validator.validateEmail(value ?? ''),
              ),
              AppConst.h24,

              // Send Reset Link Button
              Obx(
                () => SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appTheme.colorScheme.primary,
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                            if (controller.formKey.currentState!.validate()) {
                              controller.isLoading.value = true;
                              await controller.resetPassword();
                              controller.isLoading.value = false;
                            }
                          },
                    child: controller.isLoading.value
                        ? CircularProgressIndicator(
                            color: appTheme.colorScheme.onPrimary,
                          )
                        : Text(
                            s.buttonSendResetLink,
                            style: appTheme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.background,
                              fontSize: 18,
                            ),
                          ),
                  ),
                ),
              ),
              AppConst.h24,

              // Back to Login
              Center(
                child: GestureDetector(
                  onTap: controller.backFromForgotPass,
                  child: RichText(
                    text: TextSpan(
                      text: "${s.rememberPassword} ",
                      style: appTheme.textTheme.bodyMedium?.copyWith(
                        color: appTheme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      children: [
                        TextSpan(
                          text: s.buttonLogin,
                          style: appTheme.textTheme.bodyMedium?.copyWith(
                            color: appTheme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
