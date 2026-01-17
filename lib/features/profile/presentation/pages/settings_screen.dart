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
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(langProvider.translate('settings')),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Appearance'),
            SizedBox(height: 12.h),
            _buildThemeCard(context, themeProvider, langProvider),
            SizedBox(height: 24.h),
            _buildSectionHeader(langProvider.translate('language')),
            SizedBox(height: 12.h),
            _buildLanguageCard(context, langProvider),
            SizedBox(height: 24.h),
            _buildSectionHeader('Notifications'),
            SizedBox(height: 12.h),
            _buildNotificationCard(context),
            SizedBox(height: 24.h),
            _buildSectionHeader('About'),
            SizedBox(height: 12.h),
            _buildAboutCard(context, langProvider),
            SizedBox(height: 24.h),
            _buildDeleteAccountCard(context),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 4.h),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 20.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(
    BuildContext context,
    ThemeProvider themeProvider,
    LanguageProvider langProvider,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.grey200.withOpacity(0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => themeProvider.toggleTheme(!themeProvider.isDarkMode),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withOpacity(0.15),
                        AppColors.primary.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    themeProvider.isDarkMode
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: AppColors.primary,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        langProvider.translate('dark_mode'),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.1,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        themeProvider.isDarkMode
                            ? 'Dark theme enabled'
                            : 'Light theme enabled',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.grey500,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 0.9,
                  child: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) => themeProvider.toggleTheme(value),
                    activeColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard(
    BuildContext context,
    LanguageProvider langProvider,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.grey200.withOpacity(0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: LanguageProvider.supportedLocales.asMap().entries.map((
          entry,
        ) {
          final index = entry.key;
          final locale = entry.value;
          final isSelected =
              langProvider.currentLocale.languageCode == locale.languageCode;

          return Column(
            children: [
              if (index > 0)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.grey200.withOpacity(0.5),
                ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => langProvider.changeLanguage(locale),
                  borderRadius: index == 0
                      ? BorderRadius.vertical(top: Radius.circular(16.r))
                      : index == LanguageProvider.supportedLocales.length - 1
                      ? BorderRadius.vertical(bottom: Radius.circular(16.r))
                      : BorderRadius.zero,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isSelected
                                  ? [
                                      AppColors.primary.withOpacity(0.15),
                                      AppColors.primary.withOpacity(0.08),
                                    ]
                                  : [
                                      AppColors.grey300.withOpacity(0.3),
                                      AppColors.grey200.withOpacity(0.2),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.language_rounded,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.grey500,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Text(
                            LanguageProvider.getLanguageName(
                              locale.languageCode,
                            ),
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                          )
                        else
                          Container(
                            width: 20.w,
                            height: 20.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.grey300,
                                width: 2,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.grey200.withOpacity(0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildNotificationItem(
            icon: Icons.notifications_rounded,
            title: 'Push Notifications',
            subtitle: 'Receive push notifications',
            value: true,
            isFirst: true,
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.grey200.withOpacity(0.5),
          ),
          _buildNotificationItem(
            icon: Icons.email_rounded,
            title: 'Email Notifications',
            subtitle: 'Receive email updates',
            value: true,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: isFirst
            ? BorderRadius.vertical(top: Radius.circular(16.r))
            : isLast
            ? BorderRadius.vertical(bottom: Radius.circular(16.r))
            : BorderRadius.zero,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.15),
                      AppColors.primary.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.1,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.grey500,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.9,
                child: Switch(
                  value: value,
                  onChanged: (val) {},
                  activeColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context, LanguageProvider langProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.grey200.withOpacity(0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAboutItem(
            icon: Icons.info_rounded,
            title: 'App Version',
            subtitle: '1.0.0',
            isFirst: true,
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.grey200.withOpacity(0.5),
          ),
          _buildAboutItem(
            icon: Icons.privacy_tip_rounded,
            title: langProvider.translate('privacy_policy'),
            hasArrow: true,
            onTap: () {},
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.grey200.withOpacity(0.5),
          ),
          _buildAboutItem(
            icon: Icons.description_rounded,
            title: langProvider.translate('terms_conditions'),
            hasArrow: true,
            isLast: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAboutItem({
    required IconData icon,
    required String title,
    String? subtitle,
    bool hasArrow = false,
    bool isFirst = false,
    bool isLast = false,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: isFirst
            ? BorderRadius.vertical(top: Radius.circular(16.r))
            : isLast
            ? BorderRadius.vertical(bottom: Radius.circular(16.r))
            : BorderRadius.zero,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.15),
                      AppColors.primary.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.1,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 3.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.grey500,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (hasArrow)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16.sp,
                  color: AppColors.grey400,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.error.withOpacity(0.2), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                title: Text(
                  'Delete Account',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  'Are you sure you want to delete your account? This action cannot be undone.',
                  style: TextStyle(fontSize: 14.sp),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.error.withOpacity(0.15),
                        AppColors.error.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.delete_rounded,
                    color: AppColors.error,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delete Account',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                          letterSpacing: 0.1,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        'Permanently delete your account',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.grey500,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16.sp,
                  color: AppColors.error.withOpacity(0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
