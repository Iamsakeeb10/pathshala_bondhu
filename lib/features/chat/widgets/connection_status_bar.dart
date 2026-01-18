import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/utils/app_colors.dart';

class ConnectionStatusBar extends StatelessWidget {
  final bool isConnected;
  final VoidCallback? onRetry;
  final String? errorMessage;

  const ConnectionStatusBar({
    super.key,
    required this.isConnected,
    this.onRetry,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (isConnected) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      color: AppColors.warning.withOpacity(0.9),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 18.sp,
              color: AppColors.textPrimary,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                errorMessage ?? 'Connecting...',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (onRetry != null)
              GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
