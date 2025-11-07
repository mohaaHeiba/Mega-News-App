import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/core/routes/app_pages.dart';
import 'package:mega_news_app/core/utils/app_context_helper.dart';
import 'package:mega_news_app/features/settings/presentation/pages/profile_page.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final helper = AppContextHelper(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          helper.s.profile,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () {
              Get.toNamed(AppPages.settingsPage);
            },
            tooltip: helper.s.settings,
          ),
        ],
      ),
      body: const ProfilePage(),
    );
  }
}

