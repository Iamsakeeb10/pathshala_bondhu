import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../shared/utils/app_colors.dart';
import '../../provider/parent_diary_provider.dart';
import '../../data/models/parent_diary_model.dart';

class ParentDiaryScreen extends StatefulWidget {
  final String studentId;

  const ParentDiaryScreen({super.key, required this.studentId});

  @override
  State<ParentDiaryScreen> createState() => _ParentDiaryScreenState();
}

class _ParentDiaryScreenState extends State<ParentDiaryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ParentDiaryProvider>();
      provider.setSelectedStudent(widget.studentId);
      provider.fetchDiaries();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final provider = context.read<ParentDiaryProvider>();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != provider.selectedDate) {
      provider.setSelectedDate(picked);
    }
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
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Consumer<ParentDiaryProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return _buildLoadingState();
                }

                if (provider.errorMessage != null) {
                  return _buildErrorState(provider);
                }

                final diaries = provider.currentStudentDiaries;
                
                if (diaries.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: diaries.length,
                  separatorBuilder: (context, index) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    return _buildDiaryCard(diaries[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<ParentDiaryProvider>(
      builder: (context, provider, child) {
        final studentInfo = provider.currentStudentInfo;
        
        return Container(
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 24.h),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24.r),
              bottomRight: Radius.circular(24.r),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Student Info (if loaded)
              if (studentInfo != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20.r,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Icon(Icons.person, color: Colors.white, size: 20.sp),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            studentInfo.studentName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${studentInfo.classInfo} • ${studentInfo.academicSession}',
                             style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
              // Date Selector
              InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            color: AppColors.primary,
                            size: 20.sp,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            DateFormat('EEEE, d MMMM yyyy').format(provider.selectedDate),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.grey600,
                        size: 24.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDiaryCard(ParentDiaryEntry diary) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.book_outlined, size: 14.sp, color: AppColors.primary),
                      SizedBox(width: 6.w),
                      Text(
                        diary.subject,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  diary.teacherName,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              diary.title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              diary.description,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            if (diary.submissionDate.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Divider(color: AppColors.grey200, height: 1),
              SizedBox(height: 12.h),
              Row(
                children: [
                   Icon(Icons.event_available, size: 16.sp, color: AppColors.success),
                   SizedBox(width: 8.w),
                   Text(
                     'Submission: ${_formatDate(diary.submissionDate)}',
                     style: TextStyle(
                       fontSize: 13.sp,
                       fontWeight: FontWeight.w500,
                       color: AppColors.textSecondary,
                     ),
                   ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('d MMM yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildLoadingState() {
     return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
              Icons.menu_book_rounded,
              size: 56.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'No Diaries Found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'There are no diary entries for this date.',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ParentDiaryProvider provider) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              'Error Loading Data',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              provider.errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
             SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => provider.fetchDiaries(),
              icon: const Icon(Icons.refresh),
               label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
