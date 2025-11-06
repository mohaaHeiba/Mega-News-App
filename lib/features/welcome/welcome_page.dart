import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/core/routes/app_pages.dart';
import 'package:mega_news_app/core/theme/app_theme_helper.dart';
import 'package:mega_news_app/core/utils/app_context_helper.dart';
import 'package:mega_news_app/features/welcome/welcome_controller.dart';
import 'package:mega_news_app/core/constants/app_const.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WelcomeController>();
    final app = AppContextHelper(context);
    final appTheme = AppThemeHelper(context);
    final s = app.s;
    final pages = controller.getPages(context);

    return Scaffold(
      backgroundColor: appTheme.background,
      // ========== AppBar ==========
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', width: 60),
            Text(
              'MegaNews',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: appTheme.textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        actions: [
          Obx(
            () => controller.currentIndex.value < pages.length - 1
                ? Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: TextButton(
                      onPressed: () {
                        controller.imageController.animateToPage(
                          pages.length - 1,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                        controller.textController.animateToPage(
                          pages.length - 1,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text(
                        s.skip,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: appTheme.colorScheme.primary,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      // ========== Body ==========
      body: Column(
        children: [
          AppConst.h12,
          // ===== Images =====
          SizedBox(
            width: double.infinity,
            height: app.screenHeight * 0.4,
            child: PageView.builder(
              controller: controller.imageController,
              onPageChanged: controller.onPageChanged,
              itemCount: pages.length,
              itemBuilder: (context, index) {
                return Image.asset(pages[index]["image"]!, fit: BoxFit.cover);
              },
            ),
          ),
          AppConst.h20,
          // --- Start of Edits ---
          Expanded(
            child: Obx(
              () => AnimatedSlide(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                offset: controller.showContent.value
                    ? Offset.zero
                    : const Offset(0, 0.3),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 800),
                  opacity: controller.showContent.value ? 1.0 : 0.0,

                  child: Column(
                    children: [
                      // ===== Texts =====
                      Expanded(
                        child: PageView.builder(
                          controller: controller.textController,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: pages.length,
                          itemBuilder: (context, index) {
                            final page = pages[index];
                            return SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      page["title"]!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            appTheme.textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                    AppConst.h12,
                                    Text(
                                      page["subtitle"]!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: appTheme
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // ===== Cursor =====
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              pages.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: controller.currentIndex.value == index
                                    ? 28
                                    : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: controller.currentIndex.value == index
                                      ? appTheme.colorScheme.primary
                                      : appTheme.colorScheme.primary
                                            .withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // ===== Buttons =====
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                        child: Obx(
                          () => SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                if (controller.currentIndex.value <
                                    pages.length - 1) {
                                  controller.imageController.nextPage(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                  );
                                  controller.textController.nextPage(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                  );
                                } else {
                                  Get.toNamed(AppPages.authPage);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: appTheme.colorScheme.primary,
                                foregroundColor: appTheme.colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 6,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    controller.currentIndex.value ==
                                            pages.length - 1
                                        ? s.getStarted
                                        : s.next,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  AppConst.w4,
                                  Icon(
                                    controller.currentIndex.value ==
                                            pages.length - 1
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
                      AppConst.h32,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
