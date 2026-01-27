import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../shared/utils/app_colors.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../data/models/teacher_attendance_models.dart';
import '../../provider/teacher_attendance_provider.dart';

class ClassSelectionBottomSheet extends StatefulWidget {
  final Function(TeacherClass, TeacherAcademicSession) onConfirmed;

  const ClassSelectionBottomSheet({super.key, required this.onConfirmed});

  static Future<void> show(
    BuildContext context, {
    required Function(TeacherClass, TeacherAcademicSession) onConfirmed,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ClassSelectionBottomSheet(onConfirmed: onConfirmed),
    );
  }

  @override
  State<ClassSelectionBottomSheet> createState() =>
      _ClassSelectionBottomSheetState();
}

class _ClassSelectionBottomSheetState extends State<ClassSelectionBottomSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherAttendanceProvider>().fetchInitialData();
    });
  }

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
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      child: Consumer<TeacherAttendanceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Container(
              height: 200.h,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (provider.errorMessage != null) {
            return Container(
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 40.sp),
                  SizedBox(height: 10.h),
                  Text(
                    'Error loading data',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 15.h),
                  GradientButton(
                    text: 'Retry',
                    onPressed: provider.fetchInitialData,
                    width: 120.w,
                    height: 44.h,
                  ),
                ],
              ),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.symmetric(vertical: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Attendance',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Academic Session Dropdown
                    Text(
                      'Academic Session',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey300),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<TeacherAcademicSession>(
                          value: provider.selectedSession,
                          isExpanded: true,
                          hint: const Text('Select Session'),
                          items: provider.sessions.map((session) {
                            return DropdownMenuItem(
                              value: session,
                              child: Text(
                                session.title +
                                    (session.isCurrent == '1'
                                        ? ' (Current)'
                                        : ''),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) provider.selectSession(val);
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Class Dropdown
                    Text(
                      'Class',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey300),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<TeacherClass>(
                          value: provider.selectedClass,
                          isExpanded: true,
                          hint: const Text('Select Class'),
                          items: provider.classes.map((cls) {
                            return DropdownMenuItem(
                              value: cls,
                              child: Text(cls.name),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) provider.selectClass(val);
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Submit Button
                    GradientButton(
                      text: 'Continue',
                      onPressed:
                          (provider.selectedClass != null &&
                              provider.selectedSession != null)
                          ? () {
                              widget.onConfirmed(
                                provider.selectedClass!,
                                provider.selectedSession!,
                              );
                              Navigator.pop(context);
                            }
                          : null,
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
