import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../app/providers/language_provider.dart';
import '../../../../app/theme/providers/theme_provider.dart';
import '../../../../shared/utils/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final langProvider = context.watch<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(langProvider.translate('settings'))),
      body: ListView(
        children: [
          Text(
            'Appearance',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          Card(
            child: SwitchListTile(
              secondary: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: AppColors.primary,
              ),
              title: Text(langProvider.translate('dark_mode')),
              subtitle: Text(
                themeProvider.isDarkMode
                    ? 'Dark theme enabled'
                    : 'Light theme enabled',
              ),
              value: themeProvider.isDarkMode,
              onChanged: (value) => themeProvider.toggleTheme(value),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            langProvider.translate('language'),
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          Card(
            child: Column(
              children: LanguageProvider.supportedLocales.map((locale) {
                return RadioListTile<String>(
                  secondary: const Icon(
                    Icons.language,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    LanguageProvider.getLanguageName(locale.languageCode),
                  ),
                  value: locale.languageCode,
                  groupValue: langProvider.currentLocale.languageCode,
                  onChanged: (value) {
                    if (value != null) {
                      langProvider.changeLanguage(Locale(value));
                    }
                  },
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Notifications',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(
                    Icons.notifications,
                    color: AppColors.primary,
                  ),
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive push notifications'),
                  value: true,
                  onChanged: (value) {},
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.email, color: AppColors.primary),
                  title: const Text('Email Notifications'),
                  subtitle: const Text('Receive email updates'),
                  value: true,
                  onChanged: (value) {},
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'About',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info, color: AppColors.primary),
                  title: const Text('App Version'),
                  subtitle: const Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.privacy_tip,
                    color: AppColors.primary,
                  ),
                  title: Text(langProvider.translate('privacy_policy')),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.description,
                    color: AppColors.primary,
                  ),
                  title: Text(langProvider.translate('terms_conditions')),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Card(
            color: Colors.red.withOpacity(0.1),
            child: ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Account',
                style: TextStyle(color: Colors.red),
              ),
              subtitle: const Text('Permanently delete your account'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Account'),
                    content: const Text(
                      'Are you sure you want to delete your account? This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
