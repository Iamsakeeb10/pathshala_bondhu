import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../shared/localization/app_localizations.dart';
import '../../../shared/utils/app_colors.dart';
import '../models/teacher_attendance_model.dart';

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
  }

  void _initializeForm() {
    if (widget.attendance != null) {
      _selectedStatus = widget.attendance!.status;
      _checkInController.text = widget.attendance!.checkInTime ?? '';
      _checkOutController.text = widget.attendance!.checkOutTime ?? '';
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
      appBar: AppBar(
        title: Text(
          isUpdate
              ? localizations.translate('update_attendance')
              : localizations.translate('mark_attendance'),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            // Teacher info card (if updating)
            if (teacher != null) ...[
              _buildTeacherInfoCard(teacher, localizations),
              SizedBox(height: 16.h),
            ],

            // Date field
            _buildDateField(localizations),
            SizedBox(height: 16.h),

            // Status selection
            _buildStatusSelection(localizations),
            SizedBox(height: 16.h),

            // Time fields (only if present)
            if (_selectedStatus == 'present') ...[
              _buildTimeFields(localizations),
              SizedBox(height: 16.h),
            ],

            // Remarks field
            _buildRemarksField(localizations),
            SizedBox(height: 16.h),

            // Warning banner for past dates
            if (_isPastDate()) ...[
              _buildPastDateWarning(localizations),
              SizedBox(height: 16.h),
            ],

            // Submit button
            _buildSubmitButton(localizations, isUpdate),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherInfoCard(
    TeacherBasicModel teacher,
    AppLocalizations localizations,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    teacher.displayDepartment,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    teacher.email,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildDateField(AppLocalizations localizations) {
    return TextFormField(
      enabled: false,
      decoration: InputDecoration(
        labelText: localizations.translate('date'),
        prefixIcon: const Icon(Icons.calendar_today),
      ),
      controller: TextEditingController(
        text: DateFormat('dd MMMM yyyy').format(widget.date),
      ),
    );
  }

  Widget _buildStatusSelection(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.translate('status'),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: 12.h),
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
    return Column(
      children: [
        TextFormField(
          controller: _checkInController,
          decoration: InputDecoration(
            labelText: '${localizations.translate('check_in_time')} *',
            prefixIcon: const Icon(Icons.login),
            suffixIcon: IconButton(
              icon: const Icon(Icons.access_time),
              onPressed: () => _selectTime(_checkInController),
            ),
          ),
          readOnly: true,
          onTap: () => _selectTime(_checkInController),
          validator: (value) {
            if (_selectedStatus == 'present' &&
                (value == null || value.isEmpty)) {
              return localizations.translate('check_in_required');
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        TextFormField(
          controller: _checkOutController,
          decoration: InputDecoration(
            labelText: localizations.translate('check_out_time'),
            prefixIcon: const Icon(Icons.logout),
            suffixIcon: IconButton(
              icon: const Icon(Icons.access_time),
              onPressed: () => _selectTime(_checkOutController),
            ),
          ),
          readOnly: true,
          onTap: () => _selectTime(_checkOutController),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final checkIn = _checkInController.text;
              if (checkIn.isNotEmpty) {
                final checkInTime = TimeOfDay.fromDateTime(
                  DateFormat('HH:mm').parse(checkIn),
                );
                final checkOutTime = TimeOfDay.fromDateTime(
                  DateFormat('HH:mm').parse(value),
                );

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

  Widget _buildRemarksField(AppLocalizations localizations) {
    return TextFormField(
      controller: _remarksController,
      decoration: InputDecoration(
        labelText: localizations.translate('remarks'),
        prefixIcon: const Icon(Icons.note),
        hintText: localizations.translate('add_remarks'),
      ),
      maxLines: 3,
      maxLength: 200,
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

  Widget _buildSubmitButton(AppLocalizations localizations, bool isUpdate) {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _submitAttendance,
      style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50.h)),
      child: _isSubmitting
          ? SizedBox(
              height: 20.h,
              width: 20.w,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              isUpdate
                  ? localizations.translate('update_attendance')
                  : localizations.translate('mark_attendance'),
            ),
    );
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final initialTime = controller.text.isNotEmpty
        ? TimeOfDay.fromDateTime(DateFormat('HH:mm').parse(controller.text))
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
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
      // TODO: Call provider to mark/update attendance
      // For now, just show success message and pop
      await Future.delayed(const Duration(seconds: 1));

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

        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
