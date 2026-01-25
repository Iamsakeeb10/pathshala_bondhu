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

/// Screen for managing notification permission settings
/// 
/// Displays current permission status and provides actions to:
/// - Enable notifications (if denied but retryable)
/// - Open system settings (if permanently denied)
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    // Register lifecycle observer to detect permission changes
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
      // Check if permission changed while app was in background
      _checkPermissionOnResume();
    }
  }

  Future<void> _checkPermissionOnResume() async {
    if (!mounted) return;

    final provider = context.read<NotificationPermissionProvider>();
    final previousStatus = provider.status;

    await provider.onAppResumed();

    if (!mounted) return;

    // Show success message if permission was just enabled
    if (previousStatus != NotificationPermissionStatus.granted &&
        provider.status == NotificationPermissionStatus.granted) {
      _showSuccessSnackbar();
    }
  }

  void _showSuccessSnackbar() {
    final loc = AppLocalizations.of(context)!;
    ModernAlert.show(
      context: context,
      type: AlertType.success,
      title: loc.translate('notifications_enabled'),
      message: loc.translate('notifications_enabled_desc'),
      confirmText: loc.translate('ok'),
    );
  }

  void _showDeniedSnackbar() {
    final loc = AppLocalizations.of(context)!;
    ModernAlert.show(
      context: context,
      type: AlertType.warning,
      title: loc.translate('permission_denied'),
      message: loc.translate('notification_permission_denied_desc'),
      confirmText: loc.translate('ok'),
    );
  }

  void _showOpenSettingsSnackbar() {
    final loc = AppLocalizations.of(context)!;
    ModernAlert.show(
      context: context,
      type: AlertType.info,
      title: loc.translate('open_settings'),
      message: loc.translate('enable_notifications_in_settings'),
      confirmText: loc.translate('ok'),
    );
  }

  Future<void> _handleEnableNotifications() async {
    final provider = context.read<NotificationPermissionProvider>();

    final result = await provider.requestPermission();

    if (!mounted) return;

    if (result == NotificationPermissionStatus.granted) {
      _showSuccessSnackbar();
    } else {
      _showDeniedSnackbar();
    }
  }

  Future<void> _handleOpenSettings() async {
    final provider = context.read<NotificationPermissionProvider>();
    await provider.openSettings();

    if (!mounted) return;

    _showOpenSettingsSnackbar();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Only show on Android
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
                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Card
                        _buildHeaderCard(context, provider, isDark),
                        SizedBox(height: 24.h),

                        // Status Card
                        _buildStatusCard(context, provider, isDark, loc),
                        SizedBox(height: 24.h),

                        // Information Card
                        _buildInfoCard(context, isDark, loc),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    NotificationPermissionProvider provider,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.primary.withOpacity(0.3),
                  AppColors.accent.withOpacity(0.2),
                ]
              : [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.accent.withOpacity(0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getStatusColor(provider.status).withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              _getStatusIcon(provider.status),
              size: 48.sp,
              color: _getStatusColor(provider.status),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            _getStatusTitle(provider.status),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _getStatusDescription(provider.status),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    NotificationPermissionProvider provider,
    bool isDark,
    AppLocalizations loc,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: _getStatusColor(provider.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.notifications_rounded,
                    color: _getStatusColor(provider.status),
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.translate('push_notifications'),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color: _getStatusColor(provider.status),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            provider.getStatusDisplayText(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _getStatusColor(provider.status),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Action Button
            _buildActionButton(context, provider, loc),

            // Denial count info (for debugging/transparency)
            if (provider.denialCount > 0 && 
                provider.status != NotificationPermissionStatus.granted) ...[
              SizedBox(height: 12.h),
              Text(
                '${loc.translate('denial_count')}: ${provider.denialCount}/${NotificationPermissionConfig.maxDenialCount}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark 
                      ? AppColors.textDarkSecondary 
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    NotificationPermissionProvider provider,
    AppLocalizations loc,
  ) {
    final status = provider.status;
    final isLoading = provider.isRequestingPermission;

    // Granted - Show disabled "Enabled" button
    if (status == NotificationPermissionStatus.granted) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: null,
          icon: Icon(Icons.check_circle_rounded, size: 20.sp),
          label: Text(loc.translate('notifications_enabled')),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.success.withOpacity(0.6),
            disabledForegroundColor: Colors.white.withOpacity(0.8),
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
      );
    }

    // Permanently Denied - Show "Open Settings" button
    if (status == NotificationPermissionStatus.permanentlyDenied) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: isLoading ? null : _handleOpenSettings,
          icon: Icon(Icons.settings_rounded, size: 20.sp),
          label: Text(loc.translate('open_settings')),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.warning,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
      );
    }

    // Denied or Not Determined - Show "Enable" button
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : _handleEnableNotifications,
        icon: isLoading
            ? SizedBox(
                width: 20.sp,
                height: 20.sp,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(Icons.notifications_active_rounded, size: 20.sp),
        label: Text(
          isLoading 
              ? loc.translate('requesting_permission') 
              : loc.translate('enable_notifications'),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    bool isDark,
    AppLocalizations loc,
  ) {
    return Card(
      elevation: 1,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppColors.info.withOpacity(0.2),
                    AppColors.info.withOpacity(0.1),
                  ]
                : [
                    AppColors.info.withOpacity(0.1),
                    AppColors.info.withOpacity(0.05),
                  ],
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: AppColors.info,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.translate('why_notifications'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    loc.translate('notifications_benefits'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      height: 1.5,
                      color: isDark
                          ? AppColors.textDarkSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(NotificationPermissionStatus status) {
    switch (status) {
      case NotificationPermissionStatus.granted:
        return Icons.notifications_active_rounded;
      case NotificationPermissionStatus.denied:
        return Icons.notifications_off_rounded;
      case NotificationPermissionStatus.permanentlyDenied:
        return Icons.notifications_paused_rounded;
      case NotificationPermissionStatus.notDetermined:
        return Icons.notifications_none_rounded;
    }
  }

  Color _getStatusColor(NotificationPermissionStatus status) {
    switch (status) {
      case NotificationPermissionStatus.granted:
        return AppColors.success;
      case NotificationPermissionStatus.denied:
        return AppColors.warning;
      case NotificationPermissionStatus.permanentlyDenied:
        return AppColors.error;
      case NotificationPermissionStatus.notDetermined:
        return AppColors.info;
    }
  }

  String _getStatusTitle(NotificationPermissionStatus status) {
    final loc = AppLocalizations.of(context)!;
    switch (status) {
      case NotificationPermissionStatus.granted:
        return loc.translate('notifications_active');
      case NotificationPermissionStatus.denied:
        return loc.translate('notifications_disabled');
      case NotificationPermissionStatus.permanentlyDenied:
        return loc.translate('notifications_blocked');
      case NotificationPermissionStatus.notDetermined:
        return loc.translate('notifications_setup');
    }
  }

  String _getStatusDescription(NotificationPermissionStatus status) {
    final loc = AppLocalizations.of(context)!;
    switch (status) {
      case NotificationPermissionStatus.granted:
        return loc.translate('notifications_active_desc');
      case NotificationPermissionStatus.denied:
        return loc.translate('notifications_disabled_desc');
      case NotificationPermissionStatus.permanentlyDenied:
        return loc.translate('notifications_blocked_desc');
      case NotificationPermissionStatus.notDetermined:
        return loc.translate('notifications_setup_desc');
    }
  }
}
