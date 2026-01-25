import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../shared/utils/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../students/provider/student_provider.dart';
import '../data/models/exam_routine_models.dart';
import '../provider/exam_routine_provider.dart';

/// Exam Routine screen - Bangladesh style
class ExamRoutineScreen extends StatefulWidget {
  const ExamRoutineScreen({super.key});

  @override
  State<ExamRoutineScreen> createState() => _ExamRoutineScreenState();
}

class _ExamRoutineScreenState extends State<ExamRoutineScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExamRoutineProvider>().fetchExamRoutines();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          CustomAppBar(title: 'Exam Routine', showBackButton: true),
          Expanded(
            child: Consumer<ExamRoutineProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return Padding(
                    padding: EdgeInsets.all(16.w),
                    child: LoadingShimmer.list(itemCount: 5),
                  );
                }

                if (provider.errorMessage != null) {
                  return ErrorState(
                    message: provider.errorMessage!,
                    onRetry: provider.retry,
                  );
                }

                if (provider.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      await context.read<ExamRoutineProvider>().fetchExamRoutines();
                    },
                    color: AppColors.primary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: const EmptyState(
                          icon: Icons.event_note_outlined,
                          message: 'No exam routines found',
                          subMessage: 'There are no exams scheduled yet.',
                        ),
                      ),
                    ),
                  );
                }

                if (provider.hasData) {
                  return _buildExamRoutineList(provider.data!);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamRoutineList(ExamRoutineResponse data) {
    final studentProvider = context.watch<StudentProvider>();
    final selectedStudent = studentProvider.selectedStudent;

    List<ChildExamRoutine> routinesToShow = data.childrenExamRoutines;
    if (selectedStudent != null && studentProvider.hasMultipleStudents) {
      routinesToShow = data.childrenExamRoutines
          .where((r) => r.studentId == selectedStudent.studentId)
          .toList();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<ExamRoutineProvider>().fetchExamRoutines();
      },
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSchoolHeader(data),
            SizedBox(height: 20.h),
            ...routinesToShow.map((child) => _buildStudentExam(child)),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolHeader(ExamRoutineResponse data) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.school, size: 40.sp, color: AppColors.primary),
          SizedBox(height: 8.h),
          Text(
            data.schoolName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color:
                  Theme.of(context).textTheme.titleLarge?.color ??
                  AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Parent: ${data.parentName}',
            style: TextStyle(
              fontSize: 14.sp,
              color:
                  Theme.of(context).textTheme.bodyMedium?.color ??
                  AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              'পরীক্ষার রুটিন',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentExam(ChildExamRoutine child) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.person, color: Colors.white, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child.studentName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${child.classInfo} • Roll: ${child.studentId}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Table Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.15),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 80.w,
                  child: Text(
                    'তারিখ ও সময়',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'বিষয় ও কক্ষ',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Exam Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: child.examRoutines.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              thickness: 1,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.shade200,
            ),
            itemBuilder: (context, index) {
              return _buildExamRow(child.examRoutines[index]);
            },
          ),

          // Footer
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.08),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12.r),
                bottomRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.event_note, size: 16.sp, color: AppColors.primary),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Total Exams: ${child.examRoutines.length}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamRow(ExamEntry exam) {
    DateTime? examDate;
    try {
      examDate = DateTime.parse(exam.date);
    } catch (e) {
      // Handle parse error
    }

    // Format date in Bangla style
    String formattedDate = examDate != null
        ? DateFormat('dd/MM/yyyy').format(examDate)
        : exam.date;

    String dayName = examDate != null
        ? DateFormat('EEEE').format(examDate)
        : '';

    final banglaWeekdays = {
      'Sunday': 'রবিবার',
      'Monday': 'সোমবার',
      'Tuesday': 'মঙ্গলবার',
      'Wednesday': 'বুধবার',
      'Thursday': 'বৃহস্পতিবার',
      'Friday': 'শুক্রবার',
      'Saturday': 'শনিবার',
    };

    String banglaDayName = banglaWeekdays[dayName] ?? dayName;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and Time column
          SizedBox(
            width: 80.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                if (banglaDayName.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    banglaDayName,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],

                SizedBox(height: 8.h),

                // Exam name badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    exam.examName,
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                SizedBox(height: 8.h),

                // Time
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exam.startTime,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            exam.endTime,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 12.w),

          // Subject and Room column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subject name with icon
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Icon(
                          Icons.book_outlined,
                          size: 18.sp,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'বিষয়',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              exam.subject,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.titleMedium?.color ??
                                    AppColors.textPrimary,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 8.h),

                // Room number
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.meeting_room_outlined,
                        size: 16.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'কক্ষ নং:',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        exam.roomNumber,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
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
    );
  }
}
