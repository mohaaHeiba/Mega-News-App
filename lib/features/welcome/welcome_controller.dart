import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mega_news_app/generated/l10n.dart';

class WelcomeController extends GetxController {
  final PageController imageController = PageController();
  final PageController textController = PageController();
  final currentIndex = 0.obs;

  final loginBefore = GetStorage().write('loginBefore', true);

  List<Map<String, dynamic>> getPages(BuildContext context) {
    final s = S.of(context);
    return [
      {
        "title": s.welcomeTitle1,
        "subtitle": s.welcomeSubtitle1,
        "image": "assets/images/news_aggregation.png",
      },
      {
        "title": s.welcomeTitle2,
        "subtitle": s.welcomeSubtitle2,
        "image": "assets/images/search_summary.png",
      },
      {
        "title": s.welcomeTitle3,
        "subtitle": s.welcomeSubtitle3,
        "image": "assets/images/favorites.png",
      },
      {
        "title": s.welcomeTitle4,
        "subtitle": s.welcomeSubtitle4,
        "image": "assets/images/notifications.png",
      },
    ];
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
    textController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void onClose() {
    imageController.dispose();
    textController.dispose();
    super.onClose();
  }
}
