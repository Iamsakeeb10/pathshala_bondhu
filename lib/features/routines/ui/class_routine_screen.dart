import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../shared/utils/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../students/provider/student_provider.dart';
import '../data/models/routine_models.dart';
import '../provider/routine_provider.dart';

/// Class Routine screen
class ClassRoutineScreen extends StatefulWidget {
  const ClassRoutineScreen({super.key});

  @override
  State<ClassRoutineScreen> createState() => _ClassRoutineScreenState();
}

class _ClassRoutineScreenState extends State<ClassRoutineScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoutineProvider>().fetchRoutines();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: Column(
        children: [
          CustomAppBar(
            title: 'Class Routine',
            showBackButton: true, // optional, default is true
          ),
          Expanded(
            child: Consumer<RoutineProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return _buildLoadingState();
                }

                if (provider.errorMessage != null) {
                  return ErrorState(
                    message: provider.errorMessage!,
                    onRetry: provider.retry,
                  );
                }

                if (provider.isEmpty) {
                  return const EmptyState(
                    icon: Icons.calendar_today_outlined,
                    message: 'No routines found',
                    subMessage: 'There are no class routines assigned yet.',
                  );
                }

                if (provider.hasData) {
                  return _buildRoutineList(provider.data!);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: LoadingShimmer.list(itemCount: 5),
    );
  }

  Widget _buildRoutineList(RoutineResponse data) {
    final studentProvider = context.watch<StudentProvider>();
    final selectedStudent = studentProvider.selectedStudent;

    // Filter routines for selected student if applicable
    List<ChildRoutine> routinesToShow = data.childrenRoutines;
    if (selectedStudent != null && studentProvider.hasMultipleStudents) {
      routinesToShow = data.childrenRoutines
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
          ...routinesToShow.map((child) => _buildStudentRoutine(child)),
        ],
      ),
    );
  }

  Widget _buildHeader(RoutineResponse data) {
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

  Widget _buildStudentRoutine(ChildRoutine child) {
    // Group routines by day
    final routinesByDay = <String, List<RoutineEntry>>{};
    for (var routine in child.routines) {
      routinesByDay.putIfAbsent(routine.day, () => []).add(routine);
    }

    final days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Saturday',
    ];

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
          // Student header
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

          // Routines by day
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: days.map((day) {
                final dayRoutines = routinesByDay[day] ?? [];
                if (dayRoutines.isEmpty) return const SizedBox.shrink();

                return _buildDaySection(day, dayRoutines);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySection(String day, List<RoutineEntry> routines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            day,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        ...routines.map((routine) => _buildRoutineCard(routine)),
        SizedBox(height: 12.h),
      ],
    );
  }

  Widget _buildRoutineCard(RoutineEntry routine) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.schedule, color: AppColors.primary, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routine.subject,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleMedium?.color ?? AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${routine.startTime} - ${routine.endTime}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Teacher: ${routine.teacherName}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary,
                  ),
                ),
                if (routine.roomNumber != '---')
                  Text(
                    'Room: ${routine.roomNumber}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary,
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
