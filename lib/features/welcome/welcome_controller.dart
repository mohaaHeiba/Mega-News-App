import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mega_news_app/core/utils/app_context_helper.dart';

class WelcomeController extends GetxController {
  final PageController imageController = PageController();
  final PageController textController = PageController();
  final currentIndex = 0.obs;
  final loginBefore = GetStorage().write('loginBefore', true);

  var showContent = false.obs;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(milliseconds: 300), () {
      showContent.value = true;
    });
  }

  List<Map<String, dynamic>> getPages(BuildContext context) {
    final helper = AppContextHelper(context);
    return [
      {
        "title": helper.s.welcomeTitle1,
        "subtitle": helper.s.welcomeSubtitle1,
        "image": "assets/images/news_aggregation.png",
      },
      {
        "title": helper.s.welcomeTitle2,
        "subtitle": helper.s.welcomeSubtitle2,
        "image": "assets/images/search_summary.png",
      },
      {
        "title": helper.s.welcomeTitle3,
        "subtitle": helper.s.welcomeSubtitle3,
        "image": "assets/images/favorites.png",
      },
      {
        "title": helper.s.welcomeTitle4,
        "subtitle": helper.s.welcomeSubtitle4,
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
