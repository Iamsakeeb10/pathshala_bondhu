import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';

enum AlertType { success, warning, error, info }

class ModernAlert {
  static Future<void> show({
    required BuildContext context,
    required AlertType type,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Alert',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: animation,
            child: _ModernAlertDialog(
              type: type,
              title: title,
              message: message,
              confirmText: confirmText,
              cancelText: cancelText,
              onConfirm: onConfirm,
              onCancel: onCancel,
            ),
          ),
        );
      },
    );
  }
}

class _ModernAlertDialog extends StatefulWidget {
  final AlertType type;
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const _ModernAlertDialog({
    required this.type,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
  });

  @override
  State<_ModernAlertDialog> createState() => _ModernAlertDialogState();
}

class _ModernAlertDialogState extends State<_ModernAlertDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = _getAlertConfig();

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 28.w),
        constraints: BoxConstraints(maxWidth: 380.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: config.color.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24.r),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Icon
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.rotate(
                        angle: _rotateAnimation.value * math.pi * 0.1,
                        child: Container(
                          width: 80.w,
                          height: 80.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                config.color,
                                config.color.withOpacity(0.7),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: config.color.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            config.icon,
                            color: Colors.white,
                            size: 40.sp,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 24.h),

                // Title
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textDark : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 12.h),

                // Message
                Text(
                  widget.message,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: isDark
                        ? AppColors.textDarkSecondary
                        : AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 28.h),

                // Buttons
                Row(
                  children: [
                    if (widget.cancelText != null) ...[
                      Expanded(
                        child: _buildButton(
                          text: widget.cancelText!,
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.onCancel?.call();
                          },
                          isPrimary: false,
                          color: config.color,
                          isDark: isDark,
                        ),
                      ),
                      SizedBox(width: 12.w),
                    ],
                    Expanded(
                      child: _buildButton(
                        text: widget.confirmText ?? 'ঠিক আছে',
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onConfirm?.call();
                        },
                        isPrimary: true,
                        color: config.color,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
    required Color color,
    required bool isDark,
  }) {
    return Material(
      color: isPrimary ? color : Colors.transparent,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: !isPrimary
                ? Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                    width: 1.5,
                  )
                : null,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: isPrimary
                    ? Colors.white
                    : (isDark
                          ? AppColors.textDarkSecondary
                          : AppColors.textSecondary),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _AlertConfig _getAlertConfig() {
    switch (widget.type) {
      case AlertType.success:
        return _AlertConfig(
          color: AppColors.success,
          icon: Icons.check_circle_rounded,
        );
      case AlertType.warning:
        return _AlertConfig(
          color: AppColors.warning,
          icon: Icons.warning_rounded,
        );
      case AlertType.error:
        return _AlertConfig(color: AppColors.error, icon: Icons.error_rounded);
      case AlertType.info:
        return _AlertConfig(color: AppColors.primary, icon: Icons.info_rounded);
    }
  }
}

class _AlertConfig {
  final Color color;
  final IconData icon;
  _AlertConfig({required this.color, required this.icon});
}
