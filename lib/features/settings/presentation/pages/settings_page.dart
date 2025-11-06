import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/features/settings/presentation/controller/settings_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController ctrl = Get.put(SettingsController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Obx(() {
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            _sectionHeader('Appearance', theme),
            _settingTile(
              icon: Icons.dark_mode_outlined,
              iconColor: Colors.amber,
              title: 'Dark Mode',
              subtitle: 'Toggle app theme',
              trailing: Switch(
                value: ctrl.isDark.value,
                onChanged: (_) => ctrl.toggleDarkMode(),
              ),
            ),

            const SizedBox(height: 16),
            _sectionHeader('Notifications', theme),
            _settingTile(
              icon: Icons.notifications_active_outlined,
              iconColor: Colors.blueAccent,
              title: 'Push Notifications',
              subtitle: 'Enable or disable app alerts',
              trailing: Switch(
                value: ctrl.notificationsEnabled.value,
                onChanged: (_) => ctrl.toggleNotifications(),
              ),
            ),

            const SizedBox(height: 16),
            _sectionHeader('Preferences', theme),
            _settingTile(
              icon: Icons.language_outlined,
              iconColor: Colors.green,
              title: 'Language',
              subtitle: ctrl.language.value == 'en' ? 'English' : 'العربية',
              onTap: () async {
                final selected = await showModalBottomSheet<String>(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (_) => SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Choose Language',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.language),
                            title: const Text('English'),
                            onTap: () => Navigator.of(context).pop('en'),
                          ),
                          ListTile(
                            leading: const Icon(Icons.translate),
                            title: const Text('العربية'),
                            onTap: () => Navigator.of(context).pop('ar'),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                );
                if (selected != null) ctrl.setLanguage(selected);
              },
            ),

            _settingTile(
              icon: Icons.delete_outline,
              iconColor: Colors.redAccent,
              title: 'Clear Cache',
              subtitle: 'Remove saved data and preferences',
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text('Clear Cache'),
                    content: const Text(
                      'Are you sure you want to clear all cached data?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(c).pop(false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(c).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ctrl.clearCache();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cache cleared successfully'),
                      ),
                    );
                  }
                }
              },
            ),

            const SizedBox(height: 24),
            _sectionHeader('Account', theme),
            ElevatedButton.icon(
              onPressed: () => ctrl.logout(),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      }),
    );
  }

  // --- Helper Widgets ---
  Widget _sectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium!.copyWith(
          color: theme.colorScheme.primary.withOpacity(0.8),
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _settingTile({
    required IconData icon,
    required String title,
    required Color iconColor,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.15),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null
            ? Text(subtitle, style: const TextStyle(fontSize: 13))
            : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
