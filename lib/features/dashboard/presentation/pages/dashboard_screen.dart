import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/providers/auth_provider.dart';
import '../../../../shared/utils/app_colors.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../parents/ui/parents_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../../../students/ui/students_screen.dart';
import '../../../teachers/ui/teachers_screen.dart';

/// Dashboard screen with role-based bottom navigation.
///
/// Handles different navigation items based on user role:
/// - Parent: Home | Students | Teachers | Profile
/// - Teacher: Home | Teachers | Parents | Profile
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Build pages and nav items based on role
    final List<Widget> pages = _buildPages(authProvider);
    final List<FlashyTabBarItem> navItems = _buildNavItems(authProvider);

    // CRITICAL: Clamp currentIndex to prevent assertion error on logout
    // When user logs out and pages list changes, ensure index is valid
    final clampedIndex = _currentIndex.clamp(0, pages.length - 1);
    if (clampedIndex != _currentIndex) {
      // Schedule state update for next frame to avoid build-time setState
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _currentIndex = 0);
        }
      });
    }

    return Scaffold(
      body: IndexedStack(index: clampedIndex, children: pages),
      bottomNavigationBar: FlashyTabBar(
        selectedIndex: clampedIndex,
        showElevation: true,
        height: 65,
        iconSize: 24,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF283447)
            : Theme.of(context).cardColor,
        animationDuration: const Duration(milliseconds: 250),
        animationCurve: Curves.easeInOutCubic,
        shadows: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
        onItemSelected: (index) => setState(() => _currentIndex = index),
        items: navItems,
      ),
    );
  }

  /// Build pages list based on user role
  ///
  /// Parent: Home | Students | Teachers | Profile
  /// Teacher: Home | Teachers | Parents | Profile
  List<Widget> _buildPages(AuthProvider authProvider) {
    if (authProvider.isTeacher) {
      return const [
        HomeScreen(),
        TeachersScreen(),
        ParentsScreen(),
        ProfileScreen(),
      ];
    }

    // Parent role (or default)
    return const [
      HomeScreen(),
      StudentsScreen(),
      TeachersScreen(),
      ProfileScreen(),
    ];
  }

  /// Build navigation items based on user role with professional styling
  /// All tabs use the same active color for consistency
  List<FlashyTabBarItem> _buildNavItems(AuthProvider authProvider) {
    if (authProvider.isTeacher) {
      return [
        FlashyTabBarItem(
          icon: const Icon(Icons.home_rounded),
          title: const Text(
            'Home',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
          activeColor: AppColors.primary,
          inactiveColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.textDarkSecondary
              : AppColors.textSecondary,
        ),
        FlashyTabBarItem(
          icon: const Icon(Icons.school_rounded),
          title: const Text(
            'Teachers',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
          activeColor: AppColors.primary,
          inactiveColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.textDarkSecondary
              : AppColors.textSecondary,
        ),
        FlashyTabBarItem(
          icon: const Icon(Icons.family_restroom_rounded),
          title: const Text(
            'Parents',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
          activeColor: AppColors.primary,
          inactiveColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.textDarkSecondary
              : AppColors.textSecondary,
        ),
        FlashyTabBarItem(
          icon: const Icon(Icons.person_rounded),
          title: const Text(
            'Profile',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
          activeColor: AppColors.primary,
          inactiveColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.textDarkSecondary
              : AppColors.textSecondary,
        ),
      ];
    }

    // Parent role (or default)
    return [
      FlashyTabBarItem(
        icon: const Icon(Icons.home_rounded),
        title: Text(
          'Home',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
        ),
        activeColor: AppColors.primary,
        inactiveColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.textDarkSecondary
            : AppColors.textSecondary,
      ),
      FlashyTabBarItem(
        icon: const Icon(Icons.people_rounded),
        title: Text(
          'Students',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
        ),
        activeColor: AppColors.primary,
        inactiveColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.textDarkSecondary
            : AppColors.textSecondary,
      ),
      FlashyTabBarItem(
        icon: const Icon(Icons.school_rounded),
        title: Text(
          'Teachers',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
        ),
        activeColor: AppColors.primary,
        inactiveColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.textDarkSecondary
            : AppColors.textSecondary,
      ),
      FlashyTabBarItem(
        icon: const Icon(Icons.person_rounded),
        title: Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
        ),
        activeColor: AppColors.primary,
        inactiveColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.textDarkSecondary
            : AppColors.textSecondary,
      ),
    ];
  }
}
