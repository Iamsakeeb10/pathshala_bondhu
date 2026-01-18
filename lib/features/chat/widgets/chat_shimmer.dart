import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../shared/utils/app_colors.dart';

class ChatShimmer extends StatelessWidget {
  final int itemCount;

  const ChatShimmer({super.key, this.itemCount = 10});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.grey700 : AppColors.grey200,
      highlightColor: isDark ? AppColors.grey600 : AppColors.grey100,
      child: ListView.builder(
        reverse: true,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          final isMe = index % 3 != 0; // Alternating pattern
          return _buildShimmerBubble(isDark, isMe);
        },
      ),
    );
  }

  Widget _buildShimmerBubble(bool isDark, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 80.w : 12.w,
          right: isMe ? 12.w : 80.w,
          bottom: 8.h,
        ),
        height: 40.h,
        width: 180.w,
        decoration: BoxDecoration(
          color: isDark ? AppColors.grey600 : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }
}
