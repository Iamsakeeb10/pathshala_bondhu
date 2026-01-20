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

/// Exam Routine screen
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
          CustomAppBar(
            title: 'Exam Routine',
            showBackButton: true, // optional, default is true
          ),
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
                  return const EmptyState(
                    icon: Icons.event_note_outlined,
                    message: 'No exam routines found',
                    subMessage: 'There are no exams scheduled yet.',
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

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(data),
          SizedBox(height: 20.h),
          ...routinesToShow.map((child) => _buildStudentExam(child)),
        ],
      ),
    );
  }

  Widget _buildHeader(ExamRoutineResponse data) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.schoolName,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Parent: ${data.parentName}',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withOpacity(0.9),
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
              Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05,
            ),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.person, color: AppColors.primary, size: 20.sp),
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
                          color: Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${child.classInfo} • ID: ${child.studentId}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            itemCount: child.examRoutines.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              return _buildExamCard(child.examRoutines[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExamCard(ExamEntry exam) {
    DateTime? examDate;
    try {
      examDate = DateTime.parse(exam.date);
    } catch (e) {
      // Handle parse error
    }

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.grey50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : AppColors.grey200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  exam.examName,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              if (examDate != null)
                Text(
                  DateFormat('MMM dd, yyyy').format(examDate),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            exam.subject,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16.sp,
                color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary,
              ),
              SizedBox(width: 6.w),
              Text(
                '${exam.startTime} - ${exam.endTime}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(
                Icons.room,
                size: 16.sp,
                color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary,
              ),
              SizedBox(width: 6.w),
              Text(
                'Room: ${exam.roomNumber}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
