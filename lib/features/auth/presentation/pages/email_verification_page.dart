// import 'package:egx/core/custom/background/widget_and_custompaint/custom_background.dart';
// import 'package:egx/features/auth/presentaion/controller/auth_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class EmailVerificationPage extends StatelessWidget {
//   const EmailVerificationPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final email = Get.arguments;
//     final controller = Get.find<AuthController>();
//     final theme = Theme.of(context);

//     return Scaffold(
//       body: Stack(
//         children: [
//           Positioned.fill(child: customBackground(context)),
//           Center(
//             child: controller.isVerified.value
//                 ? Icon(
//                     Icons.check_circle,
//                     color: theme.colorScheme.primary,
//                     size: 80,
//                   )
//                 : Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       CircularProgressIndicator(
//                         color: theme.colorScheme.primary,
//                       ),
//                       const SizedBox(height: 24),
//                       Text(
//                         "We've sent a verification link to\n$email",
//                         textAlign: TextAlign.center,
//                         style: theme.textTheme.bodyLarge?.copyWith(
//                           color: theme.colorScheme.onBackground,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       Text(
//                         "Please verify your email to continue...",
//                         textAlign: TextAlign.center,
//                         style: theme.textTheme.bodyMedium?.copyWith(
//                           color: theme.colorScheme.onBackground.withOpacity(
//                             0.7,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }
