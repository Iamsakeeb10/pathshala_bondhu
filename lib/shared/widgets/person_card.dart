import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';

/// Reusable person card widget for teachers and parents lists.
/// 
/// This card displays a person's information in a consistent style
/// following the app's design system.
class PersonCard extends StatelessWidget {
  /// Primary name/title (e.g., Teacher name, Father name)
  final String title;

  /// Secondary text (e.g., Department, Mother name)
  final String? subtitle;

  /// Additional info displayed as chips
  final List<PersonCardChip> chips;

  /// Optional avatar URL
  final String? avatarUrl;

  /// Card accent color for avatar background
  final Color accentColor;

  /// Optional onTap callback
  final VoidCallback? onTap;

  const PersonCard({
    super.key,
    required this.title,
    this.subtitle,
    this.chips = const [],
    this.avatarUrl,
    this.accentColor = const Color(0xFFEFC45D),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                // Avatar
                _buildAvatar(),
                SizedBox(width: 14.w),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Subtitle (if provided)
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: accentColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // Chips (if provided)
                      if (chips.isNotEmpty) ...[
                        SizedBox(height: 10.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 6.h,
                          children: chips
                              .map((chip) => _buildChip(chip))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),

                // Arrow indicator
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16.sp,
                  color: AppColors.grey400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;

    return Container(
      width: 52.w,
      height: 52.w,
      decoration: BoxDecoration(
        gradient: hasAvatar
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor.withOpacity(0.3),
                  accentColor.withOpacity(0.15),
                ],
              ),
        borderRadius: BorderRadius.circular(14.r),
        image: hasAvatar
            ? DecorationImage(
                image: NetworkImage(avatarUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: hasAvatar
          ? null
          : Center(
              child: Text(
                title.isNotEmpty ? title[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ),
    );
  }

  Widget _buildChip(PersonCardChip chip) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            chip.icon,
            size: 12.sp,
            color: AppColors.textSecondary,
          ),
          SizedBox(width: 5.w),
          Flexible(
            child: Text(
              chip.label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip data for PersonCard
class PersonCardChip {
  final IconData icon;
  final String label;

  const PersonCardChip({
    required this.icon,
    required this.label,
  });
}
