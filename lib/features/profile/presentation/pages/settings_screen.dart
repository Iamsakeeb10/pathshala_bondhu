import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../app/providers/language_provider.dart';
import '../../../../app/theme/providers/theme_provider.dart';
import '../../../../shared/localization/app_localizations.dart';
import '../../../../shared/utils/app_colors.dart';
import '../../../../shared/widgets/custom_appbar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final langProvider = context.watch<LanguageProvider>();
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: Column(
        children: [
          // Fixed header
          CustomAppBar(
            title: localizations.translate('settings'),
            showBackButton: true,
            actions: [],
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(localizations.translate('appearance')),
                    SizedBox(height: 12.h),
                    _buildThemeCard(context, themeProvider, localizations),
                    SizedBox(height: 24.h),
                    _buildSectionHeader(localizations.translate('language')),
                    SizedBox(height: 12.h),
                    _buildLanguageCard(context, langProvider),
                    SizedBox(height: 24.h),
                    _buildSectionHeader(localizations.translate('notifications')),
                    SizedBox(height: 12.h),
                    _buildNotificationCard(context, localizations),
                    SizedBox(height: 24.h),
                    _buildSectionHeader(localizations.translate('about')),
                    SizedBox(height: 12.h),
                    _buildAboutCard(context, localizations),
                    SizedBox(height: 24.h),
                    _buildDeleteAccountCard(context),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),
        ],
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
    AppLocalizations localizations,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : AppColors.grey200.withOpacity(0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.04,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => themeProvider.toggleTheme(),
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
                        localizations.translate('dark_mode'),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textPrimary,
                          letterSpacing: 0.1,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        themeProvider.isDarkMode
                            ? localizations.translate('dark_theme_enabled')
                            : localizations.translate('light_theme_enabled'),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.grey500,
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
                    onChanged: (_) => themeProvider.toggleTheme(),
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : AppColors.grey200.withOpacity(0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.04,
            ),
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

  Widget _buildNotificationCard(BuildContext context, AppLocalizations localizations) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : AppColors.grey200.withOpacity(0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.04,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildNotificationItem(
            icon: Icons.notifications_rounded,
            title: localizations.translate('push_notifications'),
            subtitle: localizations.translate('receive_push_notifications'),
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
            title: localizations.translate('email_notifications'),
            subtitle: localizations.translate('receive_email_updates'),
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

  Widget _buildAboutCard(BuildContext context, AppLocalizations localizations) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : AppColors.grey200.withOpacity(0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.04,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAboutItem(
            context,
            icon: Icons.info_rounded,
            title: localizations.translate('app_version'),
            subtitle: '1.0.0',
            isFirst: true,
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.borderDark
                : AppColors.grey200.withOpacity(0.5),
          ),
          _buildAboutItem(
            context,
            icon: Icons.privacy_tip_rounded,
            title: localizations.translate('privacy_policy'),
            hasArrow: true,
            onTap: () {},
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.borderDark
                : AppColors.grey200.withOpacity(0.5),
          ),
          _buildAboutItem(
            context,
            icon: Icons.description_rounded,
            title: localizations.translate('terms_conditions'),
            hasArrow: true,
            isLast: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAboutItem(
    BuildContext context, {
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
                          color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.grey500,
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
                  AppLocalizations.of(context)!.translate('delete_account'),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  AppLocalizations.of(context)!.translate('are_you_sure_delete'),
                  style: TextStyle(fontSize: 14.sp),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      AppLocalizations.of(context)!.translate('cancel'),
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
                      AppLocalizations.of(context)!.translate('delete'),
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
                        AppLocalizations.of(context)!.translate('delete_account'),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                          letterSpacing: 0.1,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        AppLocalizations.of(context)!.translate('permanently_delete_account'),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.grey500,
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
