import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/core/layout/bottom_nav_bar.dart';
import 'package:mega_news_app/core/layout/layout_controller.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LayoutController());

    final pages = const [Center()];

    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: pages,
        ),
        bottomNavigationBar: const BottomNavBar(),
      ),
    );
  }
}
