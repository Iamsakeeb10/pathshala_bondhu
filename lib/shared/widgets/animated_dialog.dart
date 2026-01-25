import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/app_colors.dart';

/// A beautiful animated responsive reusable dialog widget
class AnimatedDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final IconData? icon;
  final Color? iconColor;
  final Color? confirmColor;
  final bool isDestructive;
  final Widget? customContent;

  const AnimatedDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.icon,
    this.iconColor,
    this.confirmColor,
    this.isDestructive = false,
    this.customContent,
  });

  /// Show the dialog with animation
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    IconData? icon,
    Color? iconColor,
    Color? confirmColor,
    bool isDestructive = false,
    Widget? customContent,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AnimatedDialog(
          title: title,
          message: message,
          confirmText: confirmText,
          cancelText: cancelText,
          onConfirm: onConfirm,
          onCancel: onCancel,
          icon: icon,
          iconColor: iconColor,
          confirmColor: confirmColor,
          isDestructive: isDestructive,
          customContent: customContent,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // Fade animation
        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );

        // Scale animation
        final scaleAnimation = Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultIconColor = isDestructive
        ? AppColors.error
        : (iconColor ?? AppColors.primary);
    final defaultConfirmColor = confirmColor ??
        (isDestructive ? AppColors.error : AppColors.primary);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 400.w,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.5 : 0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Section
                if (icon != null) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 16.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          defaultIconColor.withOpacity(0.1),
                          defaultIconColor.withOpacity(0.05),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: defaultIconColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            size: 48.sp,
                            color: defaultIconColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Content Section
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24.w, icon != null ? 0 : 32.h, 24.w, 24.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textDark
                                : AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12.h),

                        // Message or Custom Content
                        if (customContent != null)
                          customContent!
                        else
                          Text(
                            message,
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: isDark
                                  ? AppColors.textDarkSecondary
                                  : AppColors.textSecondary,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),

                        SizedBox(height: 32.h),

                        // Action Buttons
                        Row(
                          children: [
                            // Cancel Button
                            if (onCancel != null || cancelText != null) ...[
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: onCancel ??
                                      () => Navigator.of(context).pop(false),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 14.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    side: BorderSide(
                                      color: isDark
                                          ? AppColors.borderDark
                                          : AppColors.grey300,
                                      ),
                                  ),
                                  child: Text(
                                    cancelText ?? 'Cancel',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.textDarkSecondary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                            ],

                            // Confirm Button
                            Expanded(
                              flex: onCancel != null || cancelText != null ? 1 : 1,
                              child: ElevatedButton(
                                onPressed: onConfirm ??
                                    () => Navigator.of(context).pop(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: defaultConfirmColor,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                child: Text(
                                  confirmText ?? 'Confirm',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
