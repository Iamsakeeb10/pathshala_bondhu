import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../shared/localization/app_localizations.dart';
import '../../../shared/utils/app_colors.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../models/teacher_attendance_model.dart';
import '../providers/teacher_attendance_list_provider.dart';
import '../widgets/date_selector_widget.dart';
import '../widgets/empty_attendance_widget.dart';

/// Teacher Attendance List Screen
/// Shows teacher's own attendance record for selected dates
class TeacherAttendanceListScreen extends StatefulWidget {
  const TeacherAttendanceListScreen({super.key});

  @override
  State<TeacherAttendanceListScreen> createState() =>
      _TeacherAttendanceListScreenState();
}

class _TeacherAttendanceListScreenState
    extends State<TeacherAttendanceListScreen> {
  late TeacherAttendanceListProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = TeacherAttendanceListProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadAttendanceData();
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  // Convert 24-hour format to 12-hour format with AM/PM
  String _formatTime(String? time24) {
    if (time24 == null || time24.isEmpty) return '';
    try {
      final parts = time24.split(':');
      if (parts.length < 2) return time24;

      var hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';

      if (hour > 12) {
        hour -= 12;
      } else if (hour == 0) {
        hour = 12;
      }

      return '$hour:$minute $period';
    } catch (e) {
      return time24;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            CustomAppBar(
              title: localizations.translate('my_attendance'),
              actions: [
                IconAction(
                  icon: Icons.calendar_month,
                  onTap: () => _selectDate(context),
                  tooltip: localizations.translate('select_date'),
                ),
                SizedBox(width: 8.w),
                IconAction(
                  icon: Icons.refresh,
                  onTap: () => _provider.refresh(),
                  tooltip: localizations.translate('refresh'),
                ),
              ],
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _provider.refresh(),
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16.w),
                  child: Consumer<TeacherAttendanceListProvider>(
                    builder: (context, provider, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDateSelector(provider, localizations),
                          SizedBox(height: 16.h),
                          if (provider.isPastDate)
                            _buildPastDateWarning(localizations),
                          if (provider.isPastDate) SizedBox(height: 16.h),
                          _buildAttendanceContent(provider, localizations),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(
    TeacherAttendanceListProvider provider,
    AppLocalizations localizations,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DateSelectorWidget(
        selectedDate: provider.selectedDate,
        onPreviousDay: provider.previousDay,
        onNextDay: provider.nextDay,
        onDateTap: () => _selectDate(context),
        canGoForward: !provider.isToday,
      ),
    );
  }

  Widget _buildPastDateWarning(AppLocalizations localizations) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              localizations.translate('past_record_warning'),
              style: TextStyle(fontSize: 13.sp, color: Colors.orange.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceContent(
    TeacherAttendanceListProvider provider,
    AppLocalizations localizations,
  ) {
    if (provider.isLoadingList) {
      return _buildShimmerLoader();
    }

    if (provider.errorMessage != null) {
      return EmptyAttendanceWidget(
        icon: Icons.error_outline,
        title: localizations.translate('error'),
        subtitle: provider.errorMessage,
        action: GradientButton(
          text: localizations.translate('retry'),
          icon: Icons.refresh,
          onPressed: () => provider.refresh(),
        ),
      );
    }

    if (provider.filteredAttendances.isEmpty) {
      return Column(
        children: [
          SizedBox(height: 40.h),
          EmptyAttendanceWidget(
            icon: Icons.assignment_outlined,
            title: localizations.translate('attendance_not_marked'),
            subtitle: provider.isPastDate
                ? 'No attendance record for this date'
                : 'Mark your attendance for today',
          ),
          if (provider.canMarkAttendance) ...[
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: GradientButton(
                text: localizations.translate('mark_attendance'),
                icon: Icons.add_circle_outline,
                onPressed: () => _navigateToMarkAttendance(),
              ),
            ),
          ],
        ],
      );
    }

    final attendance = provider.filteredAttendances.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAttendanceCard(attendance, localizations),
        SizedBox(height: 20.h),
        if (provider.isToday)
          GradientButton(
            text: localizations.translate('update_attendance'),
            icon: Icons.update_rounded,
            onPressed: () => _handleAttendanceTap(attendance),
          )
        else
          _buildOutlinedButton(
            text: localizations.translate('view_details'),
            icon: Icons.visibility,
            onPressed: () => _handleAttendanceTap(attendance),
          ),
      ],
    );
  }

  Widget _buildOutlinedButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 54.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16.r),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColors.primary, size: 24.sp),
                SizedBox(width: 10.w),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header shimmer
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        width: 150.w,
                        height: 16.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 70.w,
                    height: 28.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ],
              ),
            ),

            // Body shimmer
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date row
                  _buildShimmerInfoRow(),
                  SizedBox(height: 12.h),
                  // Check-in row
                  _buildShimmerInfoRow(),
                  SizedBox(height: 12.h),
                  // Check-out row
                  _buildShimmerInfoRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerInfoRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18.w,
          height: 18.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60.w,
                height: 12.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                width: double.infinity,
                height: 14.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceCard(
    TeacherAttendanceModel attendance,
    AppLocalizations localizations,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
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
          // Header
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, color: Colors.white, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      attendance.teacher.fullName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(attendance, localizations),
              ],
            ),
          ),

          // Body
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  Icons.calendar_today,
                  localizations.translate('date'),
                  DateFormat('dd MMMM yyyy').format(attendance.date),
                  isDark,
                ),
                if (attendance.checkInTime != null) ...[
                  SizedBox(height: 12.h),
                  _buildInfoRow(
                    Icons.login,
                    localizations.translate('check_in'),
                    _formatTime(attendance.checkInTime),
                    isDark,
                  ),
                ],
                if (attendance.checkOutTime != null) ...[
                  SizedBox(height: 12.h),
                  _buildInfoRow(
                    Icons.logout,
                    localizations.translate('check_out'),
                    _formatTime(attendance.checkOutTime),
                    isDark,
                  ),
                ],
                if (attendance.remarks != null &&
                    attendance.remarks!.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  _buildInfoRow(
                    Icons.note,
                    localizations.translate('remarks'),
                    attendance.remarks!,
                    isDark,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.sp, color: AppColors.primary.withOpacity(0.7)),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(
    TeacherAttendanceModel attendance,
    AppLocalizations localizations,
  ) {
    String statusText;

    if (attendance.isPresent) {
      statusText = localizations.translate('present');
    } else if (attendance.isAbsent) {
      statusText = localizations.translate('absent');
    } else if (attendance.isLeave) {
      statusText = localizations.translate('leave');
    } else {
      statusText = localizations.translate('pending');
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _provider.selectedDate,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      helpText: localizations.translate('select_date'),
    );

    if (selected != null) {
      _provider.changeDate(selected);
    }
  }

  void _handleAttendanceTap(TeacherAttendanceModel attendance) async {
    // Navigate to mark/update screen
    final result = await context.push(
      '/teacher-attendance/mark',
      extra: {'attendance': attendance, 'date': _provider.selectedDate},
    );

    // Refresh if attendance was updated
    if (result == true && mounted) {
      _provider.refresh();
    }
  }

  void _navigateToMarkAttendance() async {
    final result = await context.push(
      '/teacher-attendance/mark',
      extra: {'date': _provider.selectedDate},
    );

    // Refresh if attendance was marked
    if (result == true && mounted) {
      _provider.refresh();
    }
  }
}
