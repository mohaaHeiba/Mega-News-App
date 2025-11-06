import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/core/constants/app_const.dart';
import 'package:mega_news_app/core/custom/textfileds/text_form_fileds_widget.dart';
import 'package:mega_news_app/core/utils/validator.dart';
import 'package:mega_news_app/features/auth/presentation/controller/auth_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 🔹 Logo / Header
          Icon(
            Icons.lock_outline_rounded,
            color: theme.colorScheme.primary,
            size: size.width * 0.18,
          ),
          AppConst.h24,

          Text(
            'Welcome Back!',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: theme.colorScheme.onBackground,
            ),
          ),
          AppConst.h12,

          Text(
            'Log in to your account to continue',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 15,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          AppConst.h40,

          // 🔹 Email field
          textFieldWidget(
            controller: controller.emailController,
            hint: 'Email Address',
            icon: Icons.email_outlined,
            inputType: TextInputType.emailAddress,
            validator: (value) =>
                Validator().validateEmail(controller.emailController.text),
          ),
          AppConst.h18,

          // 🔹 Password field
          textFieldPasswordWidget(
            controller: controller.passController,
            hint: 'Password',
            icon: Icons.lock_outline,
            isObsure: controller.isPasswordObscure,
            validator: (value) =>
                Validator().validatePassword(controller.passController.text),
          ),

          // 🔹 Forgot Password? link
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: controller.goToForgotPass,
              child: Text(
                'Forgot Password?',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: theme.colorScheme.primary,
                  fontSize: 13,
                ),
              ),
            ),
          ),

          AppConst.h12,

          // 🔹 Log In button
          SizedBox(
            height: 54,
            child: Obx(
              () => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                ),
                onPressed: controller.isLoading.value
                    ? null
                    : () async {
                        if (controller.formKey.currentState!.validate()) {
                          await controller.signIn(
                            email: controller.emailController.text,
                            password: controller.passController.text,
                          );
                        }
                      },
                child: controller.isLoading.value
                    ? CircularProgressIndicator(
                        color: theme.colorScheme.onPrimary,
                      )
                    : Text(
                        'Log In',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 30),

          // 🔹 Divider
          Row(
            children: [
              Expanded(child: Divider(color: theme.dividerColor, thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'or continue with',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 14,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                  ),
                ),
              ),
              Expanded(child: Divider(color: theme.dividerColor, thickness: 1)),
            ],
          ),
          const SizedBox(height: 24),

          // 🔹 Google Sign-In Button
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: controller.googleSignIn,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: theme.colorScheme.surface.withOpacity(0.08),
              ),
              icon: Image.asset(
                'assets/images/logo_google.png',
                height: 24,
                width: 24,
              ),
              label: Text(
                'Sign in with Google',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 🔹 Sign Up Link
          Center(
            child: GestureDetector(
              onTap: controller.goToRegister,
              child: RichText(
                text: TextSpan(
                  text: "Don’t have an account? ",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.85),
                    fontSize: 15,
                  ),
                  children: [
                    TextSpan(
                      text: 'Sign Up',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
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
