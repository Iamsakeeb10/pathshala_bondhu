import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../shared/utils/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../auth/data/models/parent_models.dart';
import '../provider/student_provider.dart';

/// Students screen - displays all students for the parent
class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<StudentProvider>();
      if (provider.students.isEmpty) {
        provider.fetchStudents();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('My Students'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<StudentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Padding(
              padding: EdgeInsets.all(16.w),
              child: LoadingShimmer.list(itemCount: 3, itemHeight: 140),
            );
          }

          if (provider.errorMessage != null) {
            return ErrorState(
              message: provider.errorMessage!,
              onRetry: provider.fetchStudents,
            );
          }

          if (provider.hasNoStudents) {
            return const EmptyState(
              icon: Icons.people_outline,
              message: 'No students found',
              subMessage: 'No students are linked to your account.',
            );
          }

          return _buildStudentList(provider.students, provider);
        },
      ),
    );
  }

  Widget _buildStudentList(
    List<StudentInfo> students,
    StudentProvider provider,
  ) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: students.length,
      itemBuilder: (context, index) {
        return _buildStudentCard(students[index], provider);
      },
    );
  }

  Widget _buildStudentCard(StudentInfo student, StudentProvider provider) {
    final isSelected = provider.selectedStudent?.studentId == student.studentId;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: isSelected
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            provider.selectStudent(student);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${student.classInfo.name} selected'),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 1),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.person,
                          size: 32.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 14.w),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Student ID: ${student.studentId}',
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            student.classInfo.name,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Selection indicator
                    if (isSelected)
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          size: 16.sp,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Details grid
                Row(
                  children: [
                    _buildDetailChip(Icons.numbers, 'Roll: ${student.rollNo}'),
                    SizedBox(width: 12.w),
                    _buildDetailChip(
                      Icons.calendar_today,
                      'Session: ${student.academicSession.title}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: AppColors.textSecondary),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
