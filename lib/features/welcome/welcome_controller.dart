import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mega_news_app/core/routes/app_pages.dart';
import 'package:mega_news_app/features/auth/presentation/pages/auth_page.dart';

class WelcomeController extends GetxController {
  final PageController imageController = PageController();
  final PageController textController = PageController();
  final currentIndex = 0.obs;

  final loginBefore = GetStorage().write('loginBefore', true);

  final List<Map<String, dynamic>> pages = [
    {
      "title": "News from Everywhere",
      "subtitle": "Follow news from multiple reliable sources in one app",
      "image": "assets/images/news_aggregation.png",
    },
    {
      "title": "Smart Search & Instant Summaries",
      "subtitle":
          "Search any topic and get a comprehensive summary of related news",
      "image": "assets/images/search_summary.png",
    },
    {
      "title": "Save What Matters",
      "subtitle": "Add important news to favorites and read them anytime",
      "image": "assets/images/favorites.png",
    },
    {
      "title": "Real-time Notifications",
      "subtitle": "Be the first to know breaking news from all sources",
      "image": "assets/images/notifications.png",
    },
  ];

  void onPageChanged(int index) {
    currentIndex.value = index;
    // if (index == 3) {
    //   Get.toNamed(AppPages.authPage);
    // }

    textController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void onClose() {
    // TODO: implement onClose
    imageController.dispose();
    textController.dispose();
    super.onClose();
  }
}
