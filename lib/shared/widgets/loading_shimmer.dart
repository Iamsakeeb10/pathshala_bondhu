import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/app_colors.dart';

/// Reusable shimmer loading widget
/// Use this for loading states across all features
class LoadingShimmer extends StatelessWidget {
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;

  const LoadingShimmer({
    super.key,
    this.height,
    this.width,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.grey200,
      highlightColor: AppColors.grey100,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8.r),
        ),
      ),
    );
  }

  /// List shimmer for list views
  static Widget list({
    int itemCount = 5,
    double itemHeight = 80,
    double spacing = 12,
  }) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => SizedBox(height: spacing.h),
      itemBuilder: (_, __) => LoadingShimmer(
        height: itemHeight.h,
        width: double.infinity,
      ),
    );
  }

  /// Card shimmer
  static Widget card({
    double height = 120,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin,
      child: LoadingShimmer(
        height: height.h,
        width: double.infinity,
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }
}
