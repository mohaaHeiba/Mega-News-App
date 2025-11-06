// import 'package:egx/core/constants/app_const.dart';
// import 'package:egx/core/custom/textfileds/text_form_fileds_widget.dart';
// import 'package:egx/core/utils/validator.dart';
// import 'package:egx/features/auth/presentaion/controller/auth_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../../../core/theme/app_colors.dart';

// class CreateNewPasswordPage extends StatelessWidget {
//   const CreateNewPasswordPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<AuthController>();
//     final size = MediaQuery.of(context).size;
//     final theme = Theme.of(context);

//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // 🔹 Header Icon
//           Icon(
//             Icons.lock_reset_rounded,
//             color: theme.colorScheme.primary,
//             size: size.width * 0.18,
//           ),
//           AppConst.h24,

//           // 🔹 Title
//           Text(
//             'Create New Password',
//             textAlign: TextAlign.center,
//             style: theme.textTheme.headlineMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           AppConst.h12,

//           // 🔹 Description
//           Text(
//             'Set a strong new password to secure your account.',
//             textAlign: TextAlign.center,
//             style: theme.textTheme.bodyMedium?.copyWith(
//               color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
//             ),
//           ),
//           AppConst.h40,

//           // 🔹 New Password
//           textFieldPasswordWidget(
//             controller: controller.passController,
//             hint: 'New Password',
//             icon: Icons.lock_outline,
//             isObsure: controller.isPasswordObscure,
//             validator: (value) => Validator().validatePassword(value ?? ''),
//           ),
//           AppConst.h18,

//           // 🔹 Confirm New Password
//           textFieldPasswordWidget(
//             controller: controller.confirmPassController,
//             hint: 'Confirm New Password',
//             icon: Icons.lock_outline,
//             isObsure: controller.isConfirmPasswordObscure,
//             validator: (value) => Validator().validateConfirmPassword(
//               controller.passController.text,
//               controller.confirmPassController.text,
//             ),
//           ),
//           AppConst.h24,

//           // 🔹 Submit button
//           SizedBox(
//             height: 54,
//             child: Obx(
//               () => ElevatedButton(
//                 onPressed: controller.isLoding.value
//                     ? null
//                     : () async {
//                         if (controller.formKey.currentState!.validate()) {
//                           final newPassword = controller.passController.text
//                               .trim();
//                           await controller.updatePassword(newPassword);
//                         }
//                       },
//                 child: controller.isLoding.value
//                     ? CircularProgressIndicator(
//                         color: theme.colorScheme.onPrimary,
//                       )
//                     : Text(
//                         'Update Password',
//                         style: theme.textTheme.labelLarge?.copyWith(
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.background,
//                           fontSize: 18,
//                         ),
//                       ),
//               ),
//             ),
//           ),
//           AppConst.h32,

//           // 🔹 Back to Login
//           Center(
//             child: GestureDetector(
//               onTap: controller.goToLogin,
//               child: RichText(
//                 text: TextSpan(
//                   text: "Remembered your password? ",
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
//                   ),
//                   children: [
//                     TextSpan(
//                       text: 'Log In',
//                       style: theme.textTheme.bodyMedium?.copyWith(
//                         color: theme.colorScheme.primary,
//                         fontWeight: FontWeight.bold,
//                         decoration: TextDecoration.underline,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
