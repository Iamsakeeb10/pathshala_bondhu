/// Question Card Widget
/// Displays a single question in the list with actions

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../shared/utils/app_colors.dart';
import '../../data/models/question_model.dart';
import '../../utils/question_type_icons.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const QuestionCard({
    super.key,
    required this.question,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeData = QuestionTypeCardData(question.questionType);

    return Dismissible(
      key: Key('question_${question.id}'),
      background: _buildSwipeBackground(
        alignment: Alignment.centerLeft,
        color: AppColors.primary,
        icon: Icons.edit,
      ),
      secondaryBackground: _buildSwipeBackground(
        alignment: Alignment.centerRight,
        color: AppColors.error,
        icon: Icons.delete,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onEdit();
          return false;
        } else {
          onDelete();
          return false;
        }
      },
      child: GestureDetector(
        onTap: onTap,
        onLongPress: () => _showContextMenu(context),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with type badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: typeData.backgroundColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12.r),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: typeData.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Icon(
                        typeData.icon,
                        size: 18.sp,
                        color: typeData.color,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        question.questionType.getDisplayName(
                          Localizations.localeOf(context).languageCode == 'bn',
                        ),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: typeData.color,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: typeData.color,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '${question.marks} marks',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Question content
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question text preview
                    Text(
                      question.previewText,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12.h),

                    // Metadata row
                    Row(
                      children: [
                        // Class badge
                        _buildMetadataBadge(
                          icon: Icons.class_outlined,
                          label: question.className,
                          isDark: isDark,
                        ),
                        SizedBox(width: 8.w),

                        // Subject badge
                        _buildMetadataBadge(
                          icon: Icons.book_outlined,
                          label: question.subjectName,
                          isDark: isDark,
                        ),

                        const Spacer(),

                        // Time
                        if (question.createdAt != null)
                          Text(
                            _formatTime(question.createdAt!),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isDark
                                  ? AppColors.textDarkSecondary
                                  : AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions row
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: Icon(Icons.edit_outlined, size: 18.sp),
                      label: const Text('Edit'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: Icon(Icons.delete_outline, size: 18.sp),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({
    required AlignmentGeometry alignment,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(icon, color: color, size: 28.sp),
    );
  }

  Widget _buildMetadataBadge({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey700 : AppColors.grey100,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.sp,
            color: isDark
                ? AppColors.textDarkSecondary
                : AppColors.textSecondary,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark
                  ? AppColors.textDarkSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return timeago.format(date);
    } catch (e) {
      return dateString;
    }
  }

  void _showContextMenu(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.visibility_outlined),
                title: const Text('View'),
                onTap: () {
                  Navigator.pop(context);
                  onTap();
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  onEdit();
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy_outlined),
                title: const Text('Duplicate'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement duplicate
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                ),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
