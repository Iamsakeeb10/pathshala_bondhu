import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';

/// Reusable gradient button widget
/// Supports loading state, custom gradient colors, icons, and border radius
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? startColor;
  final Color? endColor;
  final Color? textColor;
  final IconData? icon;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? iconSize;
  final double? iconSpacing;
  final AlignmentGeometry? gradientBegin;
  final AlignmentGeometry? gradientEnd;
  final bool enableShadow;
  final double? shadowBlurRadius;
  final Offset? shadowOffset;
  final double? shadowOpacity;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.startColor,
    this.endColor,
    this.textColor,
    this.icon,
    this.width,
    this.height,
    this.borderRadius,
    this.fontSize,
    this.fontWeight,
    this.iconSize,
    this.iconSpacing,
    this.gradientBegin,
    this.gradientEnd,
    this.enableShadow = true,
    this.shadowBlurRadius,
    this.shadowOffset,
    this.shadowOpacity,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStartColor = startColor ?? AppColors.primary;
    final effectiveEndColor = endColor ?? AppColors.primaryDark;
    final effectiveTextColor = textColor ?? Colors.white;
    final effectiveHeight = height ?? 54.h;
    final effectiveWidth = width ?? double.infinity;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(16.r);
    final effectiveFontSize = fontSize ?? 17.sp;
    final effectiveFontWeight = fontWeight ?? FontWeight.bold;
    final effectiveIconSize = iconSize ?? 24.sp;
    final effectiveIconSpacing = iconSpacing ?? 10.w;

    return Container(
      width: effectiveWidth,
      height: effectiveHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: gradientBegin ?? Alignment.topLeft,
          end: gradientEnd ?? Alignment.bottomRight,
          colors: [effectiveStartColor, effectiveEndColor],
        ),
        borderRadius: effectiveBorderRadius,
        boxShadow: enableShadow
            ? [
                BoxShadow(
                  color: effectiveStartColor.withOpacity(shadowOpacity ?? 0.4),
                  blurRadius: shadowBlurRadius ?? 16,
                  offset: shadowOffset ?? const Offset(0, 8),
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: effectiveBorderRadius,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: CircularProgressIndicator(
                      color: effectiveTextColor,
                      strokeWidth: 2.5,
                    ),
                  )
                : _buildContent(
                    effectiveTextColor,
                    effectiveFontSize,
                    effectiveFontWeight,
                    effectiveIconSize,
                    effectiveIconSpacing,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    Color textColor,
    double fontSize,
    FontWeight fontWeight,
    double iconSize,
    double iconSpacing,
  ) {
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: iconSize),
          SizedBox(width: iconSpacing),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: textColor,
        letterSpacing: 0.5,
      ),
    );
  }
}
