import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../shared/utils/app_colors.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../provider/teacher_attendance_provider.dart';

class MarkAttendanceTab extends StatelessWidget {
  const MarkAttendanceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherAttendanceProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Padding(
            padding: EdgeInsets.all(16.w),
            child: LoadingShimmer.list(itemCount: 6),
          );
        }

        if (provider.errorMessage != null && provider.students.isEmpty) {
          return Center(child: Text(provider.errorMessage!));
        }

        if (provider.students.isEmpty) {
          return const Center(child: Text('No students found for this class'));
        }

        return Column(
          children: [
            // Top Controls
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => provider.markAll('present'),
                      icon: const Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                      ),
                      label: Text(
                        'All Present',
                        style: TextStyle(color: Colors.green, fontSize: 13.sp),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.green),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => provider.markAll('absent'),
                      icon: const Icon(
                        Icons.cancel_outlined,
                        color: Colors.red,
                      ),
                      label: Text(
                        'All Absent',
                        style: TextStyle(color: Colors.red, fontSize: 13.sp),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Students List
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: provider.students.length,
                separatorBuilder: (c, i) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final student = provider.students[index];
                  // If status not set, default to present (or whatever initialize set)
                  final status =
                      provider.attendanceMap[student.id] ?? 'present';
                  final isPresent = status == 'present';

                  return Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isPresent
                            ? Colors.green.withOpacity(0.3)
                            : Colors.red.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 20.r,
                          backgroundColor: AppColors.primaryLight,
                          backgroundImage: student.user.avatar != null
                              ? NetworkImage(student.user.avatar!)
                              : null,
                          child: student.user.avatar == null
                              ? Text(
                                  student.user.name.substring(0, 1),
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        SizedBox(width: 12.w),

                        // Name & Roll
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.user.name,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Roll: ${student.rollNo} • ID: ${student.studentId}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Toggle Buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _AttendanceToggleButton(
                              icon: Icons.check,
                              isActive: isPresent,
                              color: Colors.green,
                              onTap: () =>
                                  provider.markStudent(student.id, 'present'),
                            ),
                            SizedBox(width: 8.w),
                            _AttendanceToggleButton(
                              icon: Icons.close,
                              isActive: !isPresent,
                              color: Colors.red,
                              onTap: () =>
                                  provider.markStudent(student.id, 'absent'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Submit Button Area
            Container(
              padding: EdgeInsets.fromLTRB(
                16.w,
                16.w,
                16.w,
                MediaQuery.of(context).padding.bottom + 16.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.isSubmitting
                      ? null
                      : () async {
                          final date = DateFormat(
                            'yyyy-MM-dd',
                          ).format(DateTime.now());
                          final success = await provider.submitAttendance(date);
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Attendance submitted successfully',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(
                              context,
                            ); // Go back after success? Or stay? Plan didn't specify, likely stay or go back.
                            // Requirement says "Submit & Navigate". Usually submit closes or shows success.
                            // Let's pop.
                          } else if (context.mounted &&
                              provider.errorMessage != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(provider.errorMessage!),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: provider.isSubmitting
                      ? SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Submit Attendance',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AttendanceToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _AttendanceToggleButton({
    required this.icon,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.transparent,
          border: Border.all(color: isActive ? color : AppColors.grey300),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          icon,
          size: 20.sp,
          color: isActive ? Colors.white : AppColors.grey400,
        ),
      ),
    );
  }
}
