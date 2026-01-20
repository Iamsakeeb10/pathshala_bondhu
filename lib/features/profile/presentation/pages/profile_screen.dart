import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/providers/auth_provider.dart';
import '../../../../core/services/logout_service.dart';
import '../../../../shared/localization/app_localizations.dart';
import '../../../../shared/utils/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          localizations.translate('logout'),
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          localizations.translate('are_you_sure_logout'),
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              localizations.translate('cancel'),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              localizations.translate('logout'),
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Use centralized LogoutService for complete cleanup
      await LogoutService.logout(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Gradient Header with Profile
            Builder(
              builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              const Color(0xFF283447), // Professional dark blue-gray
                              const Color(0xFF1F2937), // backgroundDark
                              const Color(0xFF111827), // darker shade
                            ]
                          : [
                              AppColors.primary,
                              AppColors.primaryDark,
                              AppColors.accent,
                            ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32.r),
                      bottomRight: Radius.circular(32.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.4)
                            : AppColors.primary.withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 32.h),
                  child: Column(
                    children: [
                      // Avatar with premium styling
                      Stack(
                        children: [
                          Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                            ),
                            child: Container(
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: CircleAvatar(
                                radius: 50.r,
                                backgroundColor: AppColors.primary.withOpacity(
                                  0.15,
                                ),
                                backgroundImage: user?.avatarUrl != null
                                    ? NetworkImage(user!.avatarUrl!)
                                    : null,
                                child: user?.avatarUrl == null
                                    ? Text(
                                        (user?.name.isNotEmpty ?? false)
                                            ? user!.name[0].toUpperCase()
                                            : '?',
                                        style: TextStyle(
                                          fontSize: 36.sp,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.success.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.verified,
                                color: Colors.white,
                                size: 16.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        user?.name ?? 'User',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.3,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: Offset(0, 2.h),
                              blurRadius: 8.r,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          user?.role.name.toUpperCase() ?? '',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
                );
              },
            ),

            // Menu Items
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(localizations.translate('account')),
                  SizedBox(height: 12.h),
                  _buildMenuItem(
                    context,
                    icon: Icons.person_outline,
                    title: localizations.translate('personal_information'),
                    subtitle: localizations.translate('view_edit_profile'),
                    onTap: () => context.push('/profile/details'),
                  ),
                  SizedBox(height: 12.h),
                  _buildMenuItem(
                    context,
                    icon: Icons.lock_outline,
                    title: localizations.translate('change_password'),
                    subtitle: localizations.translate('update_password'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(localizations.translate('coming_soon'))),
                      );
                    },
                  ),
                  SizedBox(height: 24.h),
                  _buildSectionHeader(localizations.translate('preferences')),
                  SizedBox(height: 12.h),
                  _buildMenuItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: localizations.translate('settings'),
                    subtitle: localizations.translate('app_preferences'),
                    onTap: () => context.push('/settings'),
                  ),
                  SizedBox(height: 12.h),
                  _buildMenuItem(
                    context,
                    icon: Icons.notifications_outlined,
                    title: localizations.translate('notifications'),
                    subtitle: localizations.translate('manage_notification_settings'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(localizations.translate('coming_soon'))),
                      );
                    },
                  ),
                  SizedBox(height: 24.h),
                  _buildSectionHeader(localizations.translate('support')),
                  SizedBox(height: 12.h),
                  _buildMenuItem(
                    context,
                    icon: Icons.help_outline,
                    title: localizations.translate('help_support'),
                    subtitle: localizations.translate('get_help_account'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(localizations.translate('coming_soon'))),
                      );
                    },
                  ),
                  SizedBox(height: 12.h),
                  _buildMenuItem(
                    context,
                    icon: Icons.info_outline,
                    title: localizations.translate('about'),
                    subtitle: localizations.translate('app_version_info'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(localizations.translate('coming_soon'))),
                      );
                    },
                  ),
                  SizedBox(height: 24.h),
                  _buildMenuItem(
                    context,
                    icon: Icons.logout_rounded,
                    title: localizations.translate('logout'),
                    subtitle: localizations.translate('sign_out_account'),
                    isDestructive: true,
                    onTap: () => _handleLogout(context),
                  ),
                  SizedBox(height: 32.h),
                  // App Version
                  Center(
                    child: Text(
                      '${localizations.translate('version')} 1.0.0',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.grey500,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildSectionHeader(String title) {
    return Builder(
      builder: (context) => Padding(
        padding: EdgeInsets.only(left: 4.w, bottom: 4.h),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDestructive
                  ? AppColors.error.withOpacity(0.2)
                  : (Theme.of(context).brightness == Brightness.dark
                      ? AppColors.borderDark
                      : AppColors.grey200.withOpacity(0.6)),
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
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDestructive
                        ? [
                            AppColors.error.withOpacity(0.15),
                            AppColors.error.withOpacity(0.08),
                          ]
                        : [
                            AppColors.primary.withOpacity(0.15),
                            AppColors.primary.withOpacity(0.08),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: isDestructive
                          ? AppColors.error.withOpacity(0.15)
                          : AppColors.primary.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: isDestructive ? AppColors.error : AppColors.primary,
                  size: 22.sp,
                ),
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
                        color: isDestructive
                            ? AppColors.error
                            : (Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textPrimary),
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
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.sp,
                color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.grey400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
