import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../shared/localization/app_localizations.dart';
import '../../../shared/utils/app_colors.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../profile/providers/profile_provider.dart';
import '../models/teacher_attendance_model.dart';
import '../services/teacher_attendance_service.dart';

/// Mark/Update Teacher Attendance Screen
class MarkAttendanceScreen extends StatefulWidget {
  final TeacherAttendanceModel? attendance;
  final DateTime date;

  const MarkAttendanceScreen({super.key, this.attendance, required this.date});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _checkInController = TextEditingController();
  final _checkOutController = TextEditingController();
  final _remarksController = TextEditingController();

  String _selectedStatus = 'present';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _ensureProfileLoaded();
  }

  Future<void> _ensureProfileLoaded() async {
    final profileProvider = context.read<ProfileProvider>();

    // If teacher profile is not loaded, fetch it
    if (profileProvider.teacherProfile == null) {
      await profileProvider.fetchProfile(ProfileType.teacher);
    }
  }

  void _initializeForm() {
    if (widget.attendance != null) {
      _selectedStatus = widget.attendance!.status;
      // Convert 24-hour format from API to 12-hour format for display
      if (widget.attendance!.checkInTime != null) {
        _checkInController.text = _convert24To12Hour(
          widget.attendance!.checkInTime!,
        );
      }
      if (widget.attendance!.checkOutTime != null) {
        _checkOutController.text = _convert24To12Hour(
          widget.attendance!.checkOutTime!,
        );
      }
      _remarksController.text = widget.attendance!.remarks ?? '';
    } else {
      // Default to current time for check-in
      final now = TimeOfDay.now();
      _checkInController.text = _formatTimeOfDay(now);
    }
  }

  @override
  void dispose() {
    _checkInController.dispose();
    _checkOutController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isUpdate = widget.attendance != null;
    final teacher = widget.attendance?.teacher;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          CustomAppBar(
            title: isUpdate
                ? localizations.translate('update_attendance')
                : localizations.translate('mark_attendance'),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Teacher info card (if updating)
                      if (teacher != null) ...[
                        _buildTeacherInfoCard(teacher, localizations),
                        SizedBox(height: 16.h),
                      ],

                      // Date field
                      _buildDateCard(localizations),
                      SizedBox(height: 16.h),

                      // Status selection
                      _buildStatusSelection(localizations),
                      SizedBox(height: 16.h),

                      // Time fields (only if present)
                      if (_selectedStatus == 'present') ...[
                        _buildTimeFields(localizations),
                        SizedBox(height: 16.h),
                      ],

                      // Remarks field (only for absent/leave)
                      if (_selectedStatus == 'absent' ||
                          _selectedStatus == 'leave') ...[
                        _buildRemarksCard(localizations),
                        SizedBox(height: 16.h),
                      ],

                      SizedBox(height: 8.h),

                      // Past date warning
                      if (_isPastDate()) ...[
                        _buildPastDateWarning(localizations),
                        SizedBox(height: 16.h),
                      ],

                      // Submit button
                      _buildSubmitButton(localizations, isUpdate, teacher),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherInfoCard(
    TeacherBasicModel teacher,
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
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 30.r,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: teacher.avatar != null
                ? ClipOval(
                    child: Image.network(
                      teacher.avatar!,
                      width: 60.w,
                      height: 60.w,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildInitialsAvatar(teacher);
                      },
                    ),
                  )
                : _buildInitialsAvatar(teacher),
          ),
          SizedBox(width: 16.w),

          // Teacher details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacher.fullName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(
                      Icons.business_outlined,
                      size: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      teacher.displayDepartment,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color:
                            Theme.of(context).textTheme.bodySmall?.color ??
                            AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        teacher.email,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color:
                              Theme.of(context).textTheme.bodySmall?.color ??
                              AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialsAvatar(TeacherBasicModel teacher) {
    final name = teacher.fullName;
    final initials = name.isNotEmpty
        ? (name.split(' ').length > 1
              ? '${name.split(' ')[0][0]}${name.split(' ')[1][0]}'
              : name[0])
        : '?';

    return Text(
      initials.toUpperCase(),
      style: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildDateCard(AppLocalizations localizations) {
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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.calendar_today,
              color: AppColors.primary,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.translate('date'),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                DateFormat('dd MMMM yyyy').format(widget.date),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSelection(AppLocalizations localizations) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_box_outlined,
                size: 16.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 6.w),
              Text(
                localizations.translate('status'),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color:
                      Theme.of(context).textTheme.titleMedium?.color ??
                      AppColors.textPrimary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildStatusOption(
                  'present',
                  localizations.translate('present'),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatusOption(
                  'absent',
                  localizations.translate('absent'),
                  Icons.cancel,
                  Colors.red,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatusOption(
                  'leave',
                  localizations.translate('leave'),
                  Icons.event_busy,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOption(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedStatus == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedStatus = value;
          // Clear time fields if not present
          if (value != 'present') {
            _checkInController.clear();
            _checkOutController.clear();
          } else {
            // Set default check-in time
            if (_checkInController.text.isEmpty) {
              final now = TimeOfDay.now();
              _checkInController.text = _formatTimeOfDay(now);
            }
          }
        });
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey.shade400,
              size: 32.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFields(AppLocalizations localizations) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, size: 16.sp, color: AppColors.primary),
              SizedBox(width: 6.w),
              Text(
                localizations.translate('time'),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color:
                      Theme.of(context).textTheme.titleMedium?.color ??
                      AppColors.textPrimary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildTimeField(
            controller: _checkInController,
            label: '${localizations.translate('check_in_time')} *',
            icon: Icons.login,
            localizations: localizations,
            isRequired: true,
          ),
          SizedBox(height: 16.h),
          _buildTimeField(
            controller: _checkOutController,
            label: localizations.translate('check_out_time'),
            icon: Icons.logout,
            localizations: localizations,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required AppLocalizations localizations,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color:
                Theme.of(context).textTheme.bodyMedium?.color ??
                AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () => _selectTime(controller),
          style: TextStyle(
            fontSize: 15.sp,
            color:
                Theme.of(context).textTheme.bodyLarge?.color ??
                AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'HH:mm',
            hintStyle: TextStyle(
              color:
                  Theme.of(context).textTheme.bodySmall?.color ??
                  AppColors.grey400,
              fontSize: 14.sp,
            ),
            prefixIcon: Icon(icon, size: 20.sp),
            suffixIcon: IconButton(
              icon: const Icon(Icons.access_time),
              onPressed: () => _selectTime(controller),
            ),
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceDark
                : AppColors.grey100,
            filled: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.borderDark
                    : AppColors.grey200.withOpacity(0.6),
                width: 1.2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.borderDark
                    : AppColors.grey200.withOpacity(0.6),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppColors.error, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
            errorStyle: TextStyle(
              fontSize: 12.sp,
              color: AppColors.error,
              fontWeight: FontWeight.w500,
            ),
          ),
          validator: (value) {
            if (isRequired &&
                _selectedStatus == 'present' &&
                (value == null || value.isEmpty)) {
              return localizations.translate('check_in_required');
            }
            if (!isRequired && value != null && value.isNotEmpty) {
              final checkIn = _checkInController.text;
              if (checkIn.isNotEmpty) {
                final checkInTime = _parseTimeString(checkIn);
                final checkOutTime = _parseTimeString(value);
                if (_isTimeBefore(checkOutTime, checkInTime)) {
                  return localizations.translate(
                    'check_out_must_be_after_check_in',
                  );
                }
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRemarksCard(AppLocalizations localizations) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note_outlined, size: 16.sp, color: AppColors.primary),
              SizedBox(width: 6.w),
              Text(
                localizations.translate('remarks'),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color:
                      Theme.of(context).textTheme.titleMedium?.color ??
                      AppColors.textPrimary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          TextFormField(
            controller: _remarksController,
            maxLines: 3,
            maxLength: 200,
            buildCounter:
                (
                  context, {
                  required currentLength,
                  required isFocused,
                  maxLength,
                }) => null,
            style: TextStyle(
              fontSize: 14.sp,
              color:
                  Theme.of(context).textTheme.bodyLarge?.color ??
                  AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: localizations.translate('add_remarks'),
              hintStyle: TextStyle(
                color:
                    Theme.of(context).textTheme.bodySmall?.color ??
                    AppColors.grey400,
                fontSize: 13.sp,
              ),
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.surfaceDark
                  : AppColors.grey100,
              filled: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 12.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.borderDark
                      : AppColors.grey200.withOpacity(0.6),
                  width: 1.2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.borderDark
                      : AppColors.grey200.withOpacity(0.6),
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(
    AppLocalizations localizations,
    bool isUpdate,
    TeacherBasicModel? teacher,
  ) {
    // Determine button state based on attendance
    String buttonText;
    IconData buttonIcon;
    Color buttonStartColor;
    Color buttonEndColor;

    if (!isUpdate) {
      // Case 1: No attendance marked - Show Check In
      buttonText = 'Check In';
      buttonIcon = Icons.login_rounded;
      buttonStartColor = Colors.green.shade600;
      buttonEndColor = Colors.green.shade800;
    } else if (widget.attendance?.checkInTime != null &&
        widget.attendance?.checkOutTime == null) {
      // Case 2: Checked in but not checked out - Show Check Out
      buttonText = 'Check Out';
      buttonIcon = Icons.logout_rounded;
      buttonStartColor = Colors.orange.shade600;
      buttonEndColor = Colors.orange.shade800;
    } else {
      // Case 3: Update existing attendance
      buttonText = 'Update Attendance';
      buttonIcon = Icons.update_rounded;
      buttonStartColor = AppColors.primary;
      buttonEndColor = AppColors.primaryDark;
    }

    return GradientButton(
      text: buttonText,
      icon: buttonIcon,
      onPressed: _submitAttendance,
      isLoading: _isSubmitting,
      startColor: buttonStartColor,
      endColor: buttonEndColor,
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
          Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              localizations.translate('updating_past_record'),
              style: TextStyle(fontSize: 13.sp, color: Colors.orange.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final initialTime = controller.text.isNotEmpty
        ? _parseTimeString(controller.text)
        : TimeOfDay.now();

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (selectedTime != null) {
      setState(() {
        controller.text = _formatTimeOfDay(selectedTime);
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  TimeOfDay _parseTimeString(String timeString) {
    try {
      // Handle 12-hour format with AM/PM
      if (timeString.contains('AM') || timeString.contains('PM')) {
        final parts = timeString.split(' ');
        final timeParts = parts[0].split(':');
        var hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        final isPM = parts[1] == 'PM';

        if (isPM && hour != 12) hour += 12;
        if (!isPM && hour == 12) hour = 0;

        return TimeOfDay(hour: hour, minute: minute);
      }
      // Fallback for 24-hour format
      final parts = timeString.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return TimeOfDay.now();
    }
  }

  bool _isTimeBefore(TimeOfDay time1, TimeOfDay time2) {
    if (time1.hour < time2.hour) return true;
    if (time1.hour == time2.hour && time1.minute < time2.minute) return true;
    return false;
  }

  bool _isPastDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
    );
    return selected.isBefore(today);
  }

  Future<void> _submitAttendance() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // Get teacher ID from ProfileProvider
      final profileProvider = context.read<ProfileProvider>();
      final teacherId = profileProvider.teacherProfile?.teacher?.id;

      if (teacherId == null) {
        throw Exception('Teacher ID not found. Please login again.');
      }

      final service = TeacherAttendanceService();
      final dateStr = DateFormat('yyyy-MM-dd').format(widget.date);

      // Convert 12-hour time to 24-hour format for API
      String? checkInTime24;
      String? checkOutTime24;

      if (_selectedStatus == 'present') {
        if (_checkInController.text.isNotEmpty) {
          checkInTime24 = _convert12To24Hour(_checkInController.text);
        }
        if (_checkOutController.text.isNotEmpty) {
          checkOutTime24 = _convert12To24Hour(_checkOutController.text);
        }
      }

      print('📤 Submitting attendance:');
      print('  Teacher ID: $teacherId');
      print('  Date: $dateStr');
      print('  Status: $_selectedStatus');
      print('  Check In: $checkInTime24');
      print('  Check Out: $checkOutTime24');

      // Call API to mark attendance with teacher_id
      await service.markAttendance(
        teacherId: teacherId,
        date: dateStr,
        status: _selectedStatus,
        checkInTime: checkInTime24,
        checkOutTime: checkOutTime24,
        remarks: _remarksController.text.trim().isEmpty
            ? null
            : _remarksController.text.trim(),
      );

      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.attendance != null
                  ? localizations.translate('attendance_updated_successfully')
                  : localizations.translate('attendance_marked_successfully'),
            ),
            backgroundColor: Colors.green,
          ),
        );

        context.pop(true); // Return true to indicate success
      }
    } catch (e) {
      print('❌ Error submitting attendance: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // Convert 12-hour format (e.g., "9:30 AM") to 24-hour format (e.g., "09:30")
  String _convert12To24Hour(String time12) {
    try {
      final parts = time12.split(' ');
      if (parts.length != 2) return time12;

      final timeParts = parts[0].split(':');
      if (timeParts.length < 2) return time12;

      var hour = int.parse(timeParts[0]);
      final minute = int.parse(
        timeParts[1],
      ); // Parse as int to strip any trailing chars
      final period = parts[1].toUpperCase();

      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return time12;
    }
  }

  // Convert 24-hour format (e.g., "09:30" or "09:30:00") to 12-hour format (e.g., "9:30 AM")
  String _convert24To12Hour(String time24) {
    try {
      // Remove seconds if present
      final timeParts = time24.split(':');
      if (timeParts.isEmpty) return time24;

      var hour = int.parse(timeParts[0]);
      final minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;

      final period = hour >= 12 ? 'PM' : 'AM';

      if (hour > 12) {
        hour -= 12;
      } else if (hour == 0) {
        hour = 12;
      }

      return '$hour:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return time24;
    }
  }
}
