import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/core/routes/app_pages.dart';
import 'package:mega_news_app/features/welcome/welcome_controller.dart';
import 'package:mega_news_app/core/constants/app_const.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WelcomeController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,

      //===================== AppBar ========================
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', width: 60),
            // AppConst.w12,
            Text(
              'MegaNews',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        actions: [
          // Skip button
          if (controller.currentIndex.value < controller.pages.length - 1)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: TextButton(
                onPressed: () {
                  controller.imageController.animateToPage(
                    controller.pages.length - 1,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                  controller.textController.animateToPage(
                    controller.pages.length - 1,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
                child: Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),

      body: Column(
        children: [
          AppConst.h12,
          //===================== PageView للصور ========================
          SizedBox(
            height: AppConst.screenHeight(context) * 0.4,
            child: PageView.builder(
              controller: controller.imageController,
              onPageChanged: controller.onPageChanged,
              itemCount: controller.pages.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    controller.pages[index]["image"]!,
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
          ),
          AppConst.h20,

          //===================== PageView للنصوص ========================
          Expanded(
            child: PageView.builder(
              controller: controller.textController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.pages.length,
              itemBuilder: (context, index) {
                final page = controller.pages[index];
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Text(
                          page["title"]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        AppConst.h12,
                        Text(
                          page["subtitle"]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          //===================== Page Indicator ========================
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  controller.pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: controller.currentIndex.value == index ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: controller.currentIndex.value != index
                          ? theme.colorScheme.primary.withOpacity(0.3)
                          : theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: controller.currentIndex.value == index
                          ? [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.3,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ),

          //===================== Next / Get Started Button ========================
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Obx(
              () => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (controller.currentIndex.value <
                        controller.pages.length - 1) {
                      controller.imageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                      controller.textController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      // Navigate to home
                      Get.toNamed(AppPages.authPage);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 6,
                    shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.currentIndex.value ==
                                controller.pages.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppConst.w4,
                      Icon(
                        controller.currentIndex.value ==
                                controller.pages.length - 1
                            ? Icons.rocket_launch_rounded
                            : Icons.arrow_forward,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          AppConst.h40,
        ],
      ),
    );
  }
}
