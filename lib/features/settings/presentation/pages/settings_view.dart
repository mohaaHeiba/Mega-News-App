import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/features/settings/presentation/controller/settings_controller.dart';
import 'package:mega_news_app/features/settings/presentation/pages/profile_page.dart';
import 'package:mega_news_app/features/settings/presentation/pages/settings_page.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(SettingsController());

    return Scaffold(
      body: PageView(
        controller: ctrl.pageController,
        children: const [ProfilePage(), SettingsPage()],
      ),
    );
  }
}
