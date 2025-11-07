import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/core/utils/app_context_helper.dart';
import 'package:mega_news_app/features/settings/presentation/controller/settings_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    final theme = Theme.of(context);
    final helper = AppContextHelper(context);

    return Scaffold(
      appBar: AppBar(title: Text(helper.s.settings), centerTitle: true),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildThemeSection(controller, theme, helper),
            const SizedBox(height: 24),
            _buildLanguageSection(controller, theme, helper),
            const SizedBox(height: 24),
            _buildNotificationsSection(controller, theme, helper),
            const SizedBox(height: 24),
            _buildStorageSection(controller, theme, helper),
            const SizedBox(height: 24),
            _buildAboutSection(controller, theme, helper),
            const SizedBox(height: 32),
            _buildLogoutButton(controller, theme, helper),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSection(
    SettingsController controller,
    ThemeData theme,
    AppContextHelper helper,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            helper.s.theme,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildThemeOption(
                  controller,
                  theme,
                  helper.s.light,
                  ThemeMode.light,
                  Icons.wb_sunny,
                ),
              ),
              Expanded(
                child: _buildThemeOption(
                  controller,
                  theme,
                  helper.s.dark,
                  ThemeMode.dark,
                  Icons.nightlight_round,
                ),
              ),
              Expanded(
                child: _buildThemeOption(
                  controller,
                  theme,
                  helper.s.system,
                  ThemeMode.system,
                  Icons.brightness_auto,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    SettingsController controller,
    ThemeData theme,
    String label,
    ThemeMode mode,
    IconData icon,
  ) {
    final isSelected = controller.themeMode.value == mode;
    return InkWell(
      onTap: () => controller.setThemeMode(mode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : theme.colorScheme.onSurface.withOpacity(0.6),
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSection(
    SettingsController controller,
    ThemeData theme,
    AppContextHelper helper,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            helper.s.language,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildLanguageOption(
                  controller,
                  theme,
                  helper.s.english,
                  'en',
                ),
              ),
              Expanded(
                child: _buildLanguageOption(
                  controller,
                  theme,
                  helper.s.arabic,
                  'ar',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageOption(
    SettingsController controller,
    ThemeData theme,
    String label,
    String code,
  ) {
    final isSelected = controller.language.value == code;
    return InkWell(
      onTap: () => controller.setLanguage(code),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsSection(
    SettingsController controller,
    ThemeData theme,
    AppContextHelper helper,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            helper.s.notifications,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              SwitchListTile(
                value: controller.notificationsEnabled.value,
                onChanged: (_) => controller.toggleNotifications(),
                title: Text(helper.s.enableNotifications),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
              ),
              Divider(height: 1, indent: 16, endIndent: 16),
              SwitchListTile(
                value: controller.breakingNewsEnabled.value,
                onChanged: (_) => controller.toggleBreakingNews(),
                title: Text(helper.s.enableBreakingNews),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStorageSection(
    SettingsController controller,
    ThemeData theme,
    AppContextHelper helper,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            helper.s.general,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const Icon(Icons.delete_outline),
            title: Text(helper.s.clearCache),
            subtitle: Text(
              helper.s.clearCacheDescription,
              style: theme.textTheme.bodySmall,
            ),
            trailing: const Icon(Icons.chevron_right),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            onTap: () async {
              final confirmed = await Get.dialog<bool>(
                AlertDialog(
                  title: Text(helper.s.clearCache),
                  content: Text(helper.s.clearCacheDescription),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: Text(helper.s.cancel),
                    ),
                    TextButton(
                      onPressed: () => Get.back(result: true),
                      child: Text(helper.s.confirm),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await controller.clearCache();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(
    SettingsController controller,
    ThemeData theme,
    AppContextHelper helper,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            helper.s.about,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(helper.s.appVersion),
                trailing: Text(
                  controller.getAppVersion(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
              ),
              Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(helper.s.privacyPolicy),
                trailing: const Icon(Icons.chevron_right),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                onTap: () {
                  Get.snackbar(
                    helper.s.privacyPolicy,
                    'Privacy policy page coming soon',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
              Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(helper.s.termsOfService),
                trailing: const Icon(Icons.chevron_right),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                onTap: () {
                  Get.snackbar(
                    helper.s.termsOfService,
                    'Terms of service page coming soon',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(
    SettingsController controller,
    ThemeData theme,
    AppContextHelper helper,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () async {
          final confirmed = await Get.dialog<bool>(
            AlertDialog(
              title: Text(helper.s.logout),
              content: Text(helper.s.logoutConfirmation),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: Text(helper.s.cancel),
                ),
                TextButton(
                  onPressed: () => Get.back(result: true),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                  child: Text(helper.s.confirm),
                ),
              ],
            ),
          );
          if (confirmed == true) {
            controller.logout();
          }
        },
        icon: const Icon(Icons.logout),
        label: Text(helper.s.logout),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.error,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
