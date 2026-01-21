import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../shared/utils/app_colors.dart';
import '../../../../shared/utils/image_url_helper.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../data/models/teacher_attendance_models.dart';
import '../../provider/teacher_attendance_provider.dart';

class MarkAttendanceTab extends StatelessWidget {
  final VoidCallback? onSubmitted;
  
  const MarkAttendanceTab({super.key, this.onSubmitted});

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

        if (provider.isAlreadySubmitted) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_outline_rounded,
                      size: 64.sp,
                      color: AppColors.success,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Attendance Already Submitted',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color ??
                          AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Attendance for today has already been submitted.\nYou can view it in the History tab.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).textTheme.bodyMedium?.color ??
                          AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
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
                          backgroundImage: ImageUrlHelper.resolveAvatarUrl(student.user.avatar).isNotEmpty
                              ? NetworkImage(ImageUrlHelper.resolveAvatarUrl(student.user.avatar))
                              : null,
                          child: ImageUrlHelper.resolveAvatarUrl(student.user.avatar).isEmpty
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Roll: ${student.rollNo} • ID: ${student.studentId}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Toggle Buttons and Remarks
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
                            if (!isPresent) ...[
                              SizedBox(width: 8.w),
                              _RemarksButton(
                                hasRemarks: provider.getRemarks(student.id) != null,
                                onTap: () => _showRemarksDialog(
                                  context,
                                  provider,
                                  student,
                                ),
                              ),
                            ],
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
                            // Refresh history for today so it shows in history tab
                            await provider.fetchHistory(DateTime.now());
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Attendance submitted successfully',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                            
                            // Switch to history tab to show submitted attendance
                            if (onSubmitted != null) {
                              onSubmitted!();
                            }
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

class _RemarksButton extends StatelessWidget {
  final bool hasRemarks;
  final VoidCallback onTap;

  const _RemarksButton({
    required this.hasRemarks,
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
          color: hasRemarks
              ? AppColors.warning.withOpacity(0.15)
              : AppColors.grey200.withOpacity(0.5),
          border: Border.all(
            color: hasRemarks ? AppColors.warning : AppColors.grey300,
            width: hasRemarks ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          hasRemarks ? Icons.note_rounded : Icons.note_outlined,
          size: 20.sp,
          color: hasRemarks ? AppColors.warning : AppColors.grey600,
        ),
      ),
    );
  }
}

void _showRemarksDialog(
  BuildContext context,
  TeacherAttendanceProvider provider,
  TeacherStudent student,
) {
  showDialog(
    context: context,
    builder: (context) => _RemarksDialog(
      provider: provider,
      student: student,
    ),
  );
}

class _RemarksDialog extends StatefulWidget {
  final TeacherAttendanceProvider provider;
  final TeacherStudent student;

  const _RemarksDialog({
    required this.provider,
    required this.student,
  });

  @override
  State<_RemarksDialog> createState() => _RemarksDialogState();
}

class _RemarksDialogState extends State<_RemarksDialog> {
  late TextEditingController _remarksController;

  @override
  void initState() {
    super.initState();
    _remarksController = TextEditingController(
      text: widget.provider.getRemarks(widget.student.id) ?? '',
    );
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  void _handleClear() {
    // Dismiss keyboard first
    FocusScope.of(context).unfocus();
    widget.provider.setRemarks(widget.student.id, null);
    // Use a small delay to ensure keyboard is dismissed before closing dialog
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  void _handleSave() {
    // Dismiss keyboard first
    FocusScope.of(context).unfocus();
    widget.provider.setRemarks(
      widget.student.id,
      _remarksController.text,
    );
    // Use a small delay to ensure keyboard is dismissed before closing dialog
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.note_rounded,
                      color: AppColors.warning,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Remarks',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.titleLarge?.color ??
                                AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          widget.student.user.name,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Theme.of(context).textTheme.bodySmall?.color ??
                                AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      });
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20.sp,
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              // Text Field
              CustomTextField(
                label: 'Reason for Absence (Optional)',
                hint: 'Enter reason why student is absent...',
                controller: _remarksController,
                maxLines: 4,
                prefixIcon: Icon(
                  Icons.edit_note_rounded,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
              ),
              SizedBox(height: 24.h),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _handleClear,
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
