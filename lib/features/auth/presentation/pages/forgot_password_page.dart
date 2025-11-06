// import 'package:egx/core/constants/app_const.dart';
// import 'package:egx/core/custom/textfileds/text_form_fileds_widget.dart';
// import 'package:egx/core/theme/app_colors.dart';
// import 'package:egx/core/utils/validator.dart';
// import 'package:egx/features/auth/presentaion/controller/auth_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class ForgotPasswordPage extends StatelessWidget {
//   const ForgotPasswordPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<AuthController>();
//     final size = MediaQuery.of(context).size;
//     final theme = Theme.of(context);

//     return SingleChildScrollView(
//       child: Align(
//         alignment: Alignment.topCenter,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Icon(
//                 Icons.lock_reset_rounded,
//                 color: theme.colorScheme.primary,
//                 size: size.width * 0.18,
//               ),
//               AppConst.h24,
//               Text(
//                 'Forgot Password?',
//                 textAlign: TextAlign.center,
//                 style: theme.textTheme.headlineSmall?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 0.5,
//                   color: theme.colorScheme.onBackground,
//                 ),
//               ),
//               AppConst.h12,
//               Text(
//                 'Enter your email below and we’ll send you a link to reset your password.',
//                 textAlign: TextAlign.center,
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   color: theme.colorScheme.onSurface.withOpacity(0.8),
//                 ),
//               ),
//               AppConst.h40,

//               /// 🔹 Email Field
//               textFieldWidget(
//                 controller: controller.emailController,
//                 hint: 'Email Address',
//                 icon: Icons.email_outlined,
//                 inputType: TextInputType.emailAddress,
//                 validator: (value) => Validator().validateEmail(value ?? ''),
//               ),
//               AppConst.h24,

//               /// 🔹 Send Reset Link
//               Obx(
//                 () => SizedBox(
//                   height: 54,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: theme.colorScheme.primary,
//                     ),
//                     onPressed: controller.isLoding.value
//                         ? null
//                         : () async {
//                             if (controller.formKey.currentState!.validate()) {
//                               controller.isLoding.value = true;
//                               await controller.resetPassword();
//                               controller.isLoding.value = false;
//                             }
//                           },
//                     child: controller.isLoding.value
//                         ? CircularProgressIndicator(
//                             color: theme.colorScheme.onPrimary,
//                           )
//                         : Text(
//                             'Send Reset Link',
//                             style: theme.textTheme.titleMedium?.copyWith(
//                               fontWeight: FontWeight.w600,
//                               color: AppColors.background,
//                               fontSize: 18,
//                             ),
//                           ),
//                   ),
//                 ),
//               ),
//               AppConst.h24,

//               /// 🔹 Back to Login
//               Center(
//                 child: GestureDetector(
//                   onTap: controller.backfromForgotPass,
//                   child: RichText(
//                     text: TextSpan(
//                       text: "Remember your password? ",
//                       style: theme.textTheme.bodyMedium?.copyWith(
//                         color: theme.colorScheme.onSurface.withOpacity(0.7),
//                       ),
//                       children: [
//                         TextSpan(
//                           text: 'Log In',
//                           style: theme.textTheme.bodyMedium?.copyWith(
//                             color: theme.colorScheme.primary,
//                             fontWeight: FontWeight.bold,
//                             decoration: TextDecoration.underline,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
