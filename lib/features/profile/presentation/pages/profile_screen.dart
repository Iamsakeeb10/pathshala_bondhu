import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/providers/auth_provider.dart';
import '../../../../shared/utils/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 24.h),
             // Header Section
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40.r,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: user?.avatarUrl != null 
                        ? NetworkImage(user!.avatarUrl!) 
                        : null,
                    child: user?.avatarUrl == null
                        ? Text(
                            (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : '?',
                            style: TextStyle(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    user?.name ?? 'User',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    user?.role.name.toUpperCase() ?? '',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.grey600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            
            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.person_outline,
                    title: 'Personal Information',
                    subtitle: 'View and edit profile details',
                    onTap: () => context.push('/profile/details'),
                  ),
                  SizedBox(height: 12.h),
                  _buildMenuItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () => context.push('/settings'),
                  ),
                  SizedBox(height: 12.h),
                  _buildMenuItem(
                    context,
                    icon: Icons.logout,
                    title: 'Logout',
                    isDestructive: true,
                    onTap: () => _handleLogout(context),
                  ),
                ],
              ),
            ),
          ],
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
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.grey300.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: isDestructive 
                      ? Colors.red.withOpacity(0.1) 
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: isDestructive ? Colors.red : AppColors.primary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: isDestructive ? Colors.red : AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: AppColors.grey400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
