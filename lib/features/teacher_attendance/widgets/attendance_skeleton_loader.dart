import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton loader for attendance list
class AttendanceSkeletonLoader extends StatelessWidget {
  final int itemCount;

  const AttendanceSkeletonLoader({
    super.key,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          child: Shimmer.fromColors(
            baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
            highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 16.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            width: 150.w,
                            height: 12.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status badge
                    Container(
                      width: 70.w,
                      height: 28.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton loader for summary cards
class SummarySkeletonLoader extends StatelessWidget {
  const SummarySkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 110.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Shimmer.fromColors(
              baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
              highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
              child: Container(
                width: 100.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
