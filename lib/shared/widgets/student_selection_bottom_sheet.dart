import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../features/auth/data/models/parent_models.dart';
import '../utils/app_colors.dart';

/// Reusable modal bottom sheet for student selection
/// Shows list of students with name, class, and roll number
class StudentSelectionBottomSheet extends StatelessWidget {
  final List<StudentInfo> students;
  final Function(StudentInfo) onStudentSelected;

  const StudentSelectionBottomSheet({
    super.key,
    required this.students,
    required this.onStudentSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Title with icon
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                Icon(
                  Icons.person_search,
                  size: 36.sp,
                  color: AppColors.primary,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Select a Student',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Choose which student\'s data to view',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Student list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            itemCount: students.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final student = students[index];
              return _buildStudentCard(context, student);
            },
          ),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, StudentInfo student) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onStudentSelected(student);
          Navigator.of(context).pop();
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.grey200,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.8),
                      AppColors.primaryDark,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    student.userId.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(width: 14.w),

              // Student details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Student ID: ${student.studentId}',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${student.classInfo.name} • Roll: ${student.rollNo}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Session: ${student.academicSession.title}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show the bottom sheet
  static Future<void> show(
    BuildContext context, {
    required List<StudentInfo> students,
    required Function(StudentInfo) onStudentSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StudentSelectionBottomSheet(
        students: students,
        onStudentSelected: onStudentSelected,
      ),
    );
  }
}
