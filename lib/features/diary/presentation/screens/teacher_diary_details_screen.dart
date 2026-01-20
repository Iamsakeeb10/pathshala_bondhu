import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../shared/utils/app_colors.dart';
import '../../data/models/teacher_diary_model.dart';
import '../../provider/teacher_diary_provider.dart';

class TeacherDiaryDetailsScreen extends StatefulWidget {
  final int diaryId;

  const TeacherDiaryDetailsScreen({super.key, required this.diaryId});

  @override
  State<TeacherDiaryDetailsScreen> createState() =>
      _TeacherDiaryDetailsScreenState();
}

class _TeacherDiaryDetailsScreenState extends State<TeacherDiaryDetailsScreen> {
  TeacherDiary? _diary;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final diary = await context.read<TeacherDiaryProvider>().getDiary(
      widget.diaryId,
    );

    if (mounted) {
      if (diary != null) {
        setState(() {
          _diary = diary;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load diary details';
          _isLoading = false;
        });
      }
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Delete Diary',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete this diary?',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await context.read<TeacherDiaryProvider>().deleteDiary(
                  _diary!.id,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Diary deleted successfully'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  );
                  context.pop(); // Go back to list
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  );
                }
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Diary Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_diary != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  context.push(
                    '/teacher/diaries/edit/${_diary!.id}',
                    extra: _diary,
                  );
                } else if (value == 'delete') {
                  _confirmDelete(context);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 18.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        size: 18.sp,
                        color: AppColors.error,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 3,
            ),
            SizedBox(height: 16.h),
            Text(
              'Loading diary details...',
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 48.sp,
                  color: AppColors.error,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Error Loading Details',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 24.h),
              ElevatedButton.icon(
                onPressed: _fetchDetails,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_diary == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: AppColors.grey200.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 56.sp,
                  color: AppColors.grey500,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Diary Not Found',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'The diary you are looking for\ncould not be found.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(),
          SizedBox(height: 16.h),
          _buildDescriptionCard(),
          SizedBox(height: 16.h),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    bool isPublished = _diary!.status.toLowerCase() == 'published';

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : AppColors.grey200.withOpacity(0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStatusBadge(isPublished, _diary!.status),
              const Spacer(),
              Icon(
                Icons.calendar_today_outlined,
                size: 14.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 6.w),
              Text(
                _formatDate(_diary!.diaryDate),
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            _diary!.title,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textPrimary,
              letterSpacing: 0.1,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : AppColors.grey200.withOpacity(0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.description_outlined,
                  size: 18.sp,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              _diary!.description ?? 'No description provided.',
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : AppColors.grey200.withOpacity(0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 18.sp,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Details',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildInfoRow(
            icon: Icons.class_outlined,
            label: 'Class',
            value: _diary!.diaryClass?.name ?? 'N/A',
            color: AppColors.primary,
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(
            icon: Icons.book_outlined,
            label: 'Subject',
            value: _diary!.subject?.name ?? 'N/A',
            color: AppColors.accent,
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(
            icon: Icons.school_outlined,
            label: 'Academic Session',
            value: _diary!.academicSession?.title ?? 'N/A',
            color: AppColors.secondary,
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(
            icon: Icons.event_outlined,
            label: 'Submission Date',
            value: _formatDate(_diary!.submissionDate),
            color: AppColors.info,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 16.sp, color: color),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.grey500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleMedium?.color ?? AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isPublished, String statusText) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPublished
              ? [
                  AppColors.success.withOpacity(0.15),
                  AppColors.success.withOpacity(0.08),
                ]
              : [
                  AppColors.warning.withOpacity(0.15),
                  AppColors.warning.withOpacity(0.08),
                ],
        ),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isPublished
              ? AppColors.success.withOpacity(0.3)
              : AppColors.warning.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: isPublished ? AppColors.success : AppColors.warning,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            statusText.toUpperCase(),
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: isPublished ? AppColors.success : AppColors.warning,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
