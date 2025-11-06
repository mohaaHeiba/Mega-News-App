import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/core/constants/app_const.dart';
import 'package:mega_news_app/core/custom/textfileds/text_form_fileds_widget.dart';
import 'package:mega_news_app/core/theme/app_colors.dart';
import 'package:mega_news_app/core/theme/app_theme_helper.dart';
import 'package:mega_news_app/core/utils/app_context_helper.dart';
import 'package:mega_news_app/core/utils/validator.dart';
import 'package:mega_news_app/features/auth/presentation/controller/auth_controller.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final appTheme = AppThemeHelper(context);
    final app = AppContextHelper(context);
    final s = app.s;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Icon
          Icon(
            Icons.person_add_alt_1_rounded,
            color: appTheme.primary.withOpacity(0.9),
            size: app.screenWidth * 0.18,
          ),
          AppConst.h24,

          // Title
          Text(
            s.registerTitle,
            textAlign: TextAlign.center,
            style: appTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: appTheme.colorScheme.onBackground,
            ),
          ),
          AppConst.h12,

          // Description
          Text(
            s.registerSubtitle,
            textAlign: TextAlign.center,
            style: appTheme.textTheme.bodyMedium?.copyWith(
              color: appTheme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          AppConst.h40,

          // Full Name
          textFieldWidget(
            controller: controller.nameController,
            hint: s.hintFullName,
            label: s.labelFullName,
            icon: Icons.person_outline,
            validator: (value) =>
                Validator().validateName(controller.nameController.text),
          ),
          AppConst.h18,

          // Email
          textFieldWidget(
            controller: controller.emailController,
            hint: s.hintEmail,
            label: s.labelEmail,
            icon: Icons.email_outlined,
            inputType: TextInputType.emailAddress,
            validator: (value) =>
                Validator().validateEmail(controller.emailController.text),
          ),
          AppConst.h18,

          // Password
          textFieldPasswordWidget(
            controller: controller.passController,
            hint: s.hintPassword,
            label: s.labelPassword,
            icon: Icons.lock_outline,
            isObsure: controller.isPasswordObscure,
            validator: (value) =>
                Validator().validatePassword(controller.passController.text),
          ),
          AppConst.h18,

          // Confirm Password
          textFieldPasswordWidget(
            controller: controller.confirmPassController,
            hint: s.hintConfirmPassword,
            label: s.labelConfirmPassword,
            icon: Icons.lock_outline,
            isObsure: controller.isConfirmPasswordObscure,
            validator: (value) => Validator().validateConfirmPassword(
              controller.passController.text,
              controller.confirmPassController.text,
            ),
          ),
          AppConst.h24,

          // Sign Up button
          SizedBox(
            height: 54,
            child: Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () async {
                        if (controller.formKey.currentState!.validate()) {
                          try {
                            controller.isLoading.value = true;
                            await controller.signUp(
                              controller.nameController.text,
                              controller.emailController.text,
                              controller.passController.text,
                            );
                          } finally {
                            controller.isLoading.value = false;
                          }
                        }
                      },
                child: controller.isLoading.value
                    ? CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    : Text(
                        s.buttonSignUp,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.background,
                        ),
                      ),
              ),
            ),
          ),
          AppConst.h32,

          // Already have an account
          Center(
            child: GestureDetector(
              onTap: controller.goToLogin,
              child: RichText(
                text: TextSpan(
                  text: "${s.alreadyHaveAccount} ",
                  style: appTheme.textTheme.bodyMedium?.copyWith(
                    color: appTheme.textTheme.bodyMedium?.color?.withOpacity(
                      0.85,
                    ),
                    fontSize: 15,
                  ),
                  children: [
                    TextSpan(
                      text: s.buttonLogin,
                      style: TextStyle(
                        color: appTheme.primary,
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
    );
  }
}
