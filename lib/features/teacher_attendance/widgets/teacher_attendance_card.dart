import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/localization/app_localizations.dart';
import '../models/teacher_attendance_model.dart';

/// Teacher attendance card widget for list display
class TeacherAttendanceCard extends StatelessWidget {
  final TeacherAttendanceModel attendance;
  final VoidCallback onTap;

  const TeacherAttendanceCard({
    super.key,
    required this.attendance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              // Avatar
              _buildAvatar(isDark),
              SizedBox(width: 12.w),

              // Teacher info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attendance.teacher.fullName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      attendance.teacher.displayDepartment,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                    if (attendance.isPresent && attendance.checkInTime != null)
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Row(
                          children: [
                            Icon(
                              Icons.login,
                              size: 14.sp,
                              color: Colors.green.shade600,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              attendance.checkInTime!,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.green.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (attendance.hasCheckOut) ...[
                              SizedBox(width: 12.w),
                              Icon(
                                Icons.logout,
                                size: 14.sp,
                                color: Colors.orange.shade600,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                attendance.checkOutTime!,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.orange.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Status badge
              _buildStatusBadge(localizations, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isDark) {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: attendance.getStatusBackgroundColor(isDark),
        shape: BoxShape.circle,
      ),
      child: attendance.teacher.avatar != null
          ? ClipOval(
              child: Image.network(
                attendance.teacher.avatar!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildInitialsAvatar();
                },
              ),
            )
          : _buildInitialsAvatar(),
    );
  }

  Widget _buildInitialsAvatar() {
    final name = attendance.teacher.fullName;
    final initials = name.isNotEmpty
        ? (name.split(' ').length > 1
              ? '${name.split(' ')[0][0]}${name.split(' ')[1][0]}'
              : name[0])
        : '?';

    return Center(
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: attendance.getStatusColor(false),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(AppLocalizations localizations, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: attendance.getStatusBackgroundColor(isDark),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        attendance.getStatusLabel(localizations.translate),
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: attendance.getStatusColor(isDark),
        ),
      ),
    );
  }
}
