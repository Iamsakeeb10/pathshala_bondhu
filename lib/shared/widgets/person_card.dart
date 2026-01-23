import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';

/// Reusable person card widget for teachers and parents lists.
///
/// This card displays a person's information in a professional style
/// following the app's design system with improved UX.
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

  /// Optional action button icon (e.g., chat icon)
  final IconData? actionIcon;

  /// Optional action button callback
  final VoidCallback? onActionTap;

  /// Optional action button tooltip
  final String? actionTooltip;

  const PersonCard({
    super.key,
    required this.title,
    this.subtitle,
    this.chips = const [],
    this.avatarUrl,
    this.accentColor = const Color(0xFFEFC45D),
    this.onTap,
    this.actionIcon,
    this.onActionTap,
    this.actionTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : Colors.transparent,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.04,
            ),
            blurRadius: 10,
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
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Row(
                  children: [
                    // Avatar with enhanced styling
                    _buildAvatar(),
                    SizedBox(width: 16.w),

                    // Info section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.color ??
                                  AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // Subtitle (if provided)
                          if (subtitle != null && subtitle!.isNotEmpty) ...[
                            SizedBox(height: 6.h),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: accentColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    subtitle!,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: accentColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Action button (e.g., Chat)
                    if (actionIcon != null && onActionTap != null) ...[
                      SizedBox(width: 12.w),
                      _buildActionButton(),
                    ],
                  ],
                ),

                // Chips section (if provided)
                if (chips.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  Divider(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.borderDark
                        : AppColors.grey200,
                    height: 1,
                  ),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: chips
                        .map((chip) => _buildChip(context, chip))
                        .toList(),
                  ),
                ],
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
      width: 56.w,
      height: 56.w,
      decoration: BoxDecoration(
        gradient: hasAvatar
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor.withOpacity(0.25),
                  accentColor.withOpacity(0.12),
                ],
              ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: accentColor.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: hasAvatar
          ? ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: CachedNetworkImage(
                imageUrl: avatarUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColor.withOpacity(0.25),
                        accentColor.withOpacity(0.12),
                      ],
                    ),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColor.withOpacity(0.25),
                        accentColor.withOpacity(0.12),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      title.isNotEmpty ? title[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                title.isNotEmpty ? title[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onActionTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Icon(actionIcon, size: 20.sp, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, PersonCardChip chip) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.grey100,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark.withOpacity(0.5)
              : AppColors.grey200,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            chip.icon,
            size: 14.sp,
            color:
                Theme.of(context).textTheme.bodySmall?.color ??
                AppColors.textSecondary,
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              chip.label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color:
                    Theme.of(context).textTheme.bodySmall?.color ??
                    AppColors.textSecondary,
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

  const PersonCardChip({required this.icon, required this.label});
}
