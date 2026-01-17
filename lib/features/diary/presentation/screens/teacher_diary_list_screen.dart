import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../shared/utils/app_colors.dart';
import '../../data/models/teacher_diary_model.dart';
import '../../provider/teacher_diary_provider.dart';

class TeacherDiaryListScreen extends StatefulWidget {
  const TeacherDiaryListScreen({super.key});

  @override
  State<TeacherDiaryListScreen> createState() => _TeacherDiaryListScreenState();
}

class _TeacherDiaryListScreenState extends State<TeacherDiaryListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherDiaryProvider>().fetchDiaries(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<TeacherDiaryProvider>().fetchDiaries();
    }
  }

  Future<void> _refresh() async {
    await context.read<TeacherDiaryProvider>().fetchDiaries(refresh: true);
  }

  void _confirmDelete(BuildContext context, int id) {
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
                await context.read<TeacherDiaryProvider>().deleteDiary(id);
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
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Class Diary'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/teacher/diaries/create');
        },
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Add Diary',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15.sp,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: Consumer<TeacherDiaryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.diaries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Loading diaries...',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          if (provider.errorMessage != null && provider.diaries.isEmpty) {
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
                      'Error Loading Diaries',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton.icon(
                      onPressed: _refresh,
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

          if (provider.diaries.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.primary,
              child: Stack(children: [ListView(), _buildEmptyState()]),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primary,
            child: ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.all(16.w),
              itemCount:
                  provider.diaries.length + (provider.isMoreLoading ? 1 : 0),
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                if (index == provider.diaries.length) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.h),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        strokeWidth: 2.5,
                      ),
                    ),
                  );
                }
                return _buildDiaryCard(provider.diaries[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.book_outlined,
                size: 56.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'No Diaries Yet',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Start creating class diaries by tapping\nthe "Add Diary" button below.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiaryCard(TeacherDiary diary) {
    bool isPublished = diary.status.toLowerCase() == 'published';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.grey200.withOpacity(0.6),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.push('/teacher/diaries/${diary.id}');
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        diary.title,
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    _buildOptionsMenu(diary),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    _buildStatusBadge(isPublished, diary.status),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.class_outlined,
                                  size: 14.sp,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  diary.diaryClass?.name ?? 'Unknown',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.book_outlined,
                        size: 16.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          diary.subject?.name ?? 'Unknown Subject',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Container(
                        width: 4.w,
                        height: 4.w,
                        decoration: BoxDecoration(
                          color: AppColors.grey400,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        _formatDate(diary.diaryDate),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (diary.academicSession != null) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 12.sp,
                        color: AppColors.grey400,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        diary.academicSession!.title,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.grey500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsMenu(TeacherDiary diary) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            context.push('/teacher/diaries/edit/${diary.id}', extra: diary);
          } else if (value == 'delete') {
            _confirmDelete(context, diary.id);
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
        icon: Icon(
          Icons.more_vert_rounded,
          size: 20.sp,
          color: AppColors.grey600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        offset: Offset(0, 8.h),
      ),
    );
  }

  Widget _buildStatusBadge(bool isPublished, String statusText) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
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
              fontSize: 10.sp,
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
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
