import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../shared/localization/app_localizations.dart';
import '../../../shared/utils/app_colors.dart';
import '../providers/teacher_attendance_list_provider.dart';
import '../widgets/attendance_skeleton_loader.dart';
import '../widgets/date_selector_widget.dart';
import '../widgets/empty_attendance_widget.dart';
import '../widgets/teacher_attendance_card.dart';

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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.translate('teacher_attendance')),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_month),
              onPressed: () => _selectDate(context),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _provider.refresh(),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => _provider.refresh(),
          child: Column(
            children: [
              // Date selector
              Consumer<TeacherAttendanceListProvider>(
                builder: (context, provider, _) {
                  return DateSelectorWidget(
                    selectedDate: provider.selectedDate,
                    onPreviousDay: provider.previousDay,
                    onNextDay: provider.nextDay,
                    onDateTap: () => _selectDate(context),
                    canGoForward: !provider.isToday,
                  );
                },
              ),

              // Warning banner for past dates
              Consumer<TeacherAttendanceListProvider>(
                builder: (context, provider, _) {
                  if (provider.isPastDate) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      color: Colors.orange.shade100,
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange.shade700,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              localizations.translate('past_record_warning'),
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              SizedBox(height: 16.h),

              // My Attendance Card
              Expanded(
                child: Consumer<TeacherAttendanceListProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoadingList) {
                      return const AttendanceSkeletonLoader();
                    }

                    if (provider.errorMessage != null) {
                      return EmptyAttendanceWidget(
                        icon: Icons.error_outline,
                        title: localizations.translate('error'),
                        subtitle: provider.errorMessage,
                        action: ElevatedButton(
                          onPressed: () => provider.refresh(),
                          child: Text(localizations.translate('retry')),
                        ),
                      );
                    }

                    if (provider.filteredAttendances.isEmpty) {
                      return EmptyAttendanceWidget(
                        icon: Icons.assignment_outlined,
                        title: localizations.translate('attendance_not_marked'),
                        subtitle: provider.isPastDate
                            ? 'No attendance record for this date'
                            : 'Tap the button below to mark your attendance',
                      );
                    }

                    // Show only the first attendance (current teacher's record)
                    final attendance = provider.filteredAttendances.first;
                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.translate('my_attendance'),
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          TeacherAttendanceCard(
                            attendance: attendance,
                            onTap: () => _handleAttendanceTap(attendance),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Consumer<TeacherAttendanceListProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const SizedBox.shrink();
            }

            // Show update button if attendance is already marked
            if (provider.filteredAttendances.isNotEmpty) {
              final attendance = provider.filteredAttendances.first;
              return FloatingActionButton.extended(
                onPressed: () => _handleAttendanceTap(attendance),
                icon: const Icon(Icons.edit),
                label: Text(localizations.translate('update')),
                backgroundColor: AppColors.primary,
              );
            }

            // Show mark button if not marked yet and can mark
            if (provider.canMarkAttendance) {
              return FloatingActionButton.extended(
                onPressed: () => _navigateToMarkAttendance(),
                icon: const Icon(Icons.add),
                label: Text(localizations.translate('mark_attendance')),
              );
            }

            return const SizedBox.shrink();
          },
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

  void _handleAttendanceTap(attendance) {
    // Navigate to mark/update screen
    context.push(
      '/teacher-attendance/mark',
      extra: {'attendance': attendance, 'date': _provider.selectedDate},
    );
  }

  void _navigateToMarkAttendance() {
    context.push(
      '/teacher-attendance/mark',
      extra: {'date': _provider.selectedDate},
    );
  }
}
