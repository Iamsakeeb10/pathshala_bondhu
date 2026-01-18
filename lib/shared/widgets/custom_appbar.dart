import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../utils/app_colors.dart';

/// A highly reusable AppBar widget that maintains the PathShala Bondhu design system.
///
/// Features:
/// - Automatic status bar padding handling
/// - Gradient background with shadow
/// - Optional back button with smart navigation
/// - Optional actions (widgets on the right)
/// - Customizable title
/// - Consistent styling across the app
///
/// Example usage:
/// ```dart
/// // Simple usage
/// CustomAppBar(title: 'My Screen')
///
/// // With actions
/// CustomAppBar(
///   title: 'Notifications',
///   actions: [
///     MarkAllReadButton(),
///   ],
/// )
///
/// // Custom back navigation
/// CustomAppBar(
///   title: 'Profile',
///   onBackPressed: () => context.go('/settings'),
/// )
///
/// // Without back button
/// CustomAppBar(
///   title: 'Dashboard',
///   showBackButton: false,
/// )
/// ```
class CustomAppBar extends StatelessWidget {
  /// The title text displayed in the AppBar
  final String title;

  /// Whether to show the back button (default: true)
  final bool showBackButton;

  /// Custom back button press handler
  /// If null, uses smart navigation (pop if possible, otherwise go to dashboard)
  final VoidCallback? onBackPressed;

  /// Optional leading widget (replaces back button if provided)
  final Widget? leading;

  /// Optional actions displayed on the right side
  final List<Widget>? actions;

  /// Custom title widget (overrides title text if provided)
  final Widget? titleWidget;

  /// Custom gradient colors (uses AppColors if null)
  final List<Color>? gradientColors;

  /// Custom height (default: 60.h)
  final double? height;

  /// Additional padding for the content area
  final EdgeInsetsGeometry? contentPadding;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.leading,
    this.actions,
    this.titleWidget,
    this.gradientColors,
    this.height,
    this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      padding:
          contentPadding ??
          EdgeInsets.only(top: statusBarHeight, left: 16.w, right: 16.w),
      height: (height ?? 60.h) + statusBarHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              gradientColors ??
              [AppColors.primary, AppColors.primaryDark, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (gradientColors?.first ?? AppColors.primary).withOpacity(
              0.2,
            ),
            offset: Offset(0, 2.h),
            blurRadius: 20.r,
            spreadRadius: 4.r,
          ),
        ],
      ),
      child: Row(
        children: [
          // Leading widget (back button or custom widget)
          if (leading != null)
            leading!
          else if (showBackButton)
            _buildBackButton(context),

          if (leading != null || showBackButton) SizedBox(width: 12.w),

          // Title
          if (titleWidget != null)
            titleWidget!
          else
            Text(
              title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

          const Spacer(),

          // Actions
          if (actions != null) ...actions!,
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return InkWell(
      onTap: onBackPressed ?? () => _handleBackPress(context),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 18.sp,
        ),
      ),
    );
  }

  void _handleBackPress(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/dashboard');
    }
  }
}

/// Pre-built action widgets for common use cases

/// A "Mark all as read" action button
class MarkAllReadAction extends StatelessWidget {
  final VoidCallback onTap;
  final bool show;

  const MarkAllReadAction({Key? key, required this.onTap, this.show = true})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: Tooltip(
        message: 'Mark all as read',
        child: InkWell(
          borderRadius: BorderRadius.circular(50.r),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.done_all_rounded, color: Colors.white, size: 18.sp),
                SizedBox(width: 4.w),
                Text(
                  'Mark all read',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A simple icon action button
class IconAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final double? size;

  const IconAction({
    Key? key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final button = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, color: Colors.white, size: size ?? 18.sp),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}

/// A badge action button (e.g., notification count)
class BadgeAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int count;
  final String? tooltip;

  const BadgeAction({
    Key? key,
    required this.icon,
    required this.onTap,
    required this.count,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final button = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Icon(icon, color: Colors.white, size: 18.sp),
            ),
            if (count > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  constraints: BoxConstraints(minWidth: 16.r, minHeight: 16.r),
                  child: Center(
                    child: Text(
                      count > 99 ? '99+' : count.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
