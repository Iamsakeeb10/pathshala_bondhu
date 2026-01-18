import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../shared/utils/app_colors.dart';

class ConversationsShimmer extends StatelessWidget {
  final int itemCount;

  const ConversationsShimmer({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.grey700 : AppColors.grey200,
      highlightColor: isDark ? AppColors.grey600 : AppColors.grey100,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        itemCount: itemCount,
        itemBuilder: (context, index) => _buildShimmerItem(isDark),
      ),
    );
  }

  Widget _buildShimmerItem(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 54.w,
            height: 54.w,
            decoration: BoxDecoration(
              color: isDark ? AppColors.grey600 : Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Container(
                  height: 14.h,
                  width: 140.w,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.grey600 : Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 8.h),
                // Message
                Container(
                  height: 12.h,
                  width: 200.w,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.grey600 : Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          ),
          // Time
          Container(
            height: 10.h,
            width: 40.w,
            decoration: BoxDecoration(
              color: isDark ? AppColors.grey600 : Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ],
      ),
    );
  }
}
