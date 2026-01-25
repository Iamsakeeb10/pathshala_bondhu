import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/notification_permission_constants.dart';
import '../../../../core/providers/notification_permission_provider.dart';
import '../../../../shared/localization/app_localizations.dart';
import '../../../../shared/utils/app_colors.dart';
import '../../../../shared/widgets/custom_appbar.dart';
import '../../../../shared/widgets/modern_alert.dart';

/// Minimal notification settings screen focused on clear UX
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _checkPermissionOnResume();
    }
  }

  Future<void> _checkPermissionOnResume() async {
    if (!mounted) return;
    final provider = context.read<NotificationPermissionProvider>();
    final previousStatus = provider.status;
    await provider.onAppResumed();
    if (!mounted) return;

    if (previousStatus != NotificationPermissionStatus.granted &&
        provider.status == NotificationPermissionStatus.granted) {
      _showAlert(
        AlertType.success,
        'notifications_enabled',
        'notifications_enabled_desc',
      );
    }
  }

  void _showAlert(AlertType type, String titleKey, String messageKey) {
    final loc = AppLocalizations.of(context)!;
    ModernAlert.show(
      context: context,
      type: type,
      title: loc.translate(titleKey),
      message: loc.translate(messageKey),
      confirmText: loc.translate('ok'),
    );
  }

  Future<void> _handleEnableNotifications() async {
    final provider = context.read<NotificationPermissionProvider>();
    final result = await provider.requestPermission();
    if (!mounted) return;

    if (result == NotificationPermissionStatus.granted) {
      _showAlert(
        AlertType.success,
        'notifications_enabled',
        'notifications_enabled_desc',
      );
    } else {
      _showAlert(
        AlertType.warning,
        'permission_denied',
        'notification_permission_denied_desc',
      );
    }
  }

  Future<void> _handleOpenSettings() async {
    final provider = context.read<NotificationPermissionProvider>();
    await provider.openSettings();
    if (!mounted) return;
    _showAlert(
      AlertType.info,
      'open_settings',
      'enable_notifications_in_settings',
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!Platform.isAndroid) {
      return Scaffold(
        body: Column(
          children: [
            CustomAppBar(title: loc.translate('notification_settings')),
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Text(
                    loc.translate('notification_settings_ios'),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: loc.translate('notification_settings')),
          Expanded(
            child: Consumer<NotificationPermissionProvider>(
              builder: (context, provider, _) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                      // Status Icon
                      _buildStatusIcon(provider, isDark),
                      SizedBox(height: 32.h),

                      // Status Text
                      _buildStatusText(provider, isDark, loc),
                      SizedBox(height: 16.h),

                      // Description
                      _buildDescription(provider, isDark, loc),

                      const Spacer(flex: 2),

                      // Action Button
                      _buildActionButton(provider, loc),
                      SizedBox(height: 16.h),

                      // Helper Text
                      if (provider.status !=
                          NotificationPermissionStatus.granted)
                        _buildHelperText(provider, isDark, loc),

                      SizedBox(height: 40.h),
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

  Widget _buildStatusIcon(
    NotificationPermissionProvider provider,
    bool isDark,
  ) {
    final isEnabled = provider.status == NotificationPermissionStatus.granted;
    final color = isEnabled ? AppColors.success : AppColors.primary;

    return Container(
      width: 120.w,
      height: 120.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(isDark ? 0.15 : 0.1),
      ),
      child: Center(
        child: Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(isDark ? 0.25 : 0.15),
          ),
          child: Icon(
            isEnabled
                ? Icons.notifications_active_rounded
                : Icons.notifications_off_outlined,
            size: 40.sp,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusText(
    NotificationPermissionProvider provider,
    bool isDark,
    AppLocalizations loc,
  ) {
    final isEnabled = provider.status == NotificationPermissionStatus.granted;

    return Text(
      isEnabled
          ? loc.translate('notifications_active')
          : loc.translate('notifications_disabled'),
      style: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : AppColors.textPrimary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(
    NotificationPermissionProvider provider,
    bool isDark,
    AppLocalizations loc,
  ) {
    String text;
    switch (provider.status) {
      case NotificationPermissionStatus.granted:
        text = loc.translate('notifications_active_desc');
        break;
      case NotificationPermissionStatus.permanentlyDenied:
        text = loc.translate('notifications_blocked_desc');
        break;
      default:
        text = loc.translate('notifications_setup_desc');
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15.sp,
          color: isDark ? AppColors.textDarkSecondary : AppColors.textSecondary,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildActionButton(
    NotificationPermissionProvider provider,
    AppLocalizations loc,
  ) {
    final status = provider.status;
    final isLoading = provider.isRequestingPermission;

    // Already enabled - show success state
    if (status == NotificationPermissionStatus.granted) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.success.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 22.sp,
            ),
            SizedBox(width: 10.w),
            Text(
              loc.translate('notifications_enabled'),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      );
    }

    // Permanently denied - open settings
    if (status == NotificationPermissionStatus.permanentlyDenied) {
      return SizedBox(
        width: double.infinity,
        height: 54.h,
        child: ElevatedButton(
          onPressed: isLoading ? null : _handleOpenSettings,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
          child: Text(
            loc.translate('open_settings'),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    // Default - enable notifications
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleEnableNotifications,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24.sp,
                height: 24.sp,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                loc.translate('enable_notifications'),
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _buildHelperText(
    NotificationPermissionProvider provider,
    bool isDark,
    AppLocalizations loc,
  ) {
    // Show denial count only if relevant
    if (provider.denialCount > 0 &&
        provider.status != NotificationPermissionStatus.permanentlyDenied) {
      return Padding(
        padding: EdgeInsets.only(top: 8.h),
        child: Text(
          '${loc.translate('denial_count')}: ${provider.denialCount}/${NotificationPermissionConfig.maxDenialCount}',
          style: TextStyle(fontSize: 13.sp, color: AppColors.warning),
        ),
      );
    }

    if (provider.status == NotificationPermissionStatus.permanentlyDenied) {
      return Padding(
        padding: EdgeInsets.only(top: 8.h),
        child: Text(
          loc.translate('enable_notifications_in_settings'),
          style: TextStyle(
            fontSize: 13.sp,
            color: isDark
                ? AppColors.textDarkSecondary
                : AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
