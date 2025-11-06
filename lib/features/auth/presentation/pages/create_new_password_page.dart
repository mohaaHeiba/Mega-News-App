import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/core/constants/app_const.dart';
import 'package:mega_news_app/core/custom/textfileds/text_form_fileds_widget.dart';
import 'package:mega_news_app/core/theme/app_colors.dart';
import 'package:mega_news_app/core/theme/app_theme_helper.dart';
import 'package:mega_news_app/core/utils/app_context_helper.dart';
import 'package:mega_news_app/core/utils/validator.dart';
import 'package:mega_news_app/features/auth/presentation/controller/auth_controller.dart';

class CreateNewPasswordPage extends StatelessWidget {
  const CreateNewPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final appTheme = AppThemeHelper(context);

    final app = AppContextHelper(context);
    final s = app.s;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //  Header Icon
            Icon(Icons.lock_reset_rounded, color: appTheme.primary, size: 200),
            AppConst.h24,

            // Title
            Text(
              s.create,
              textAlign: TextAlign.center,
              style: appTheme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            AppConst.h12,

            // Description
            Text(
              s.set_strong_password,
              textAlign: TextAlign.center,
              style: appTheme.textTheme.bodyMedium?.copyWith(
                color: appTheme.textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
            ),
            AppConst.h40,

            // New Password
            textFieldPasswordWidget(
              controller: controller.passController,
              hint: s.new_password,
              icon: Icons.lock_outline,
              isObsure: controller.isPasswordObscure,
              validator: (value) => Validator().validatePassword(value ?? ''),
            ),
            AppConst.h18,

            // Confirm New Password
            textFieldPasswordWidget(
              controller: controller.confirmPassController,
              hint: s.confirm_new_password,
              icon: Icons.lock_outline,
              isObsure: controller.isConfirmPasswordObscure,
              validator: (value) => Validator().validateConfirmPassword(
                controller.passController.text,
                controller.confirmPassController.text,
              ),
            ),
            AppConst.h24,

            // Submit button
            SizedBox(
              height: 54,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                          if (controller.formKey.currentState!.validate()) {
                            final newPassword = controller.passController.text
                                .trim();
                            await controller.updatePassword(newPassword);
                          }
                        },
                  child: controller.isLoading.value
                      ? CircularProgressIndicator(
                          color: appTheme.colorScheme.onPrimary,
                        )
                      : Text(
                          s.update_password,
                          style: appTheme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.background,
                            fontSize: 18,
                          ),
                        ),
                ),
              ),
            ),
            AppConst.h32,

            // Back to Login
            Center(
              child: GestureDetector(
                onTap: controller.goToLogin,
                child: RichText(
                  text: TextSpan(
                    text: s.remembered_password,
                    style: appTheme.textTheme.bodyMedium?.copyWith(
                      color: appTheme.textTheme.bodyMedium?.color?.withOpacity(
                        0.7,
                      ),
                    ),
                    children: [
                      TextSpan(
                        text: s.log_in,
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
    );
  }
}
