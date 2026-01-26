import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../shared/localization/app_localizations.dart';
import '../../../shared/utils/app_colors.dart';
import '../providers/teacher_attendance_list_provider.dart';
import '../widgets/attendance_skeleton_loader.dart';
import '../widgets/attendance_summary_card.dart';
import '../widgets/date_selector_widget.dart';
import '../widgets/empty_attendance_widget.dart';
import '../widgets/teacher_attendance_card.dart';

/// Teacher Attendance List Screen
/// Shows attendance summary and list for a selected date
class TeacherAttendanceListScreen extends StatefulWidget {
  const TeacherAttendanceListScreen({super.key});

  @override
  State<TeacherAttendanceListScreen> createState() =>
      _TeacherAttendanceListScreenState();
}

class _TeacherAttendanceListScreenState
    extends State<TeacherAttendanceListScreen> {
  late TeacherAttendanceListProvider _provider;
  final TextEditingController _searchController = TextEditingController();

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
    _searchController.dispose();
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

              SizedBox(height: 12.h),

              // Summary cards
              Consumer<TeacherAttendanceListProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoadingSummary) {
                    return const SummarySkeletonLoader();
                  }

                  if (provider.summary == null) {
                    return const SizedBox.shrink();
                  }

                  return _buildSummarySection(provider, localizations);
                },
              ),

              SizedBox(height: 16.h),

              // Search and filters
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    // Search bar
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: localizations.translate('search_teacher'),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _provider.setSearchQuery('');
                                },
                              )
                            : null,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                      onChanged: (value) => _provider.setSearchQuery(value),
                    ),

                    SizedBox(height: 12.h),

                    // Status filter chips
                    Consumer<TeacherAttendanceListProvider>(
                      builder: (context, provider, _) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip(
                                'all',
                                localizations.translate('all_status'),
                                provider,
                              ),
                              SizedBox(width: 8.w),
                              _buildFilterChip(
                                'present',
                                localizations.translate('present'),
                                provider,
                                color: Colors.green,
                              ),
                              SizedBox(width: 8.w),
                              _buildFilterChip(
                                'absent',
                                localizations.translate('absent'),
                                provider,
                                color: Colors.red,
                              ),
                              SizedBox(width: 8.w),
                              _buildFilterChip(
                                'leave',
                                localizations.translate('leave'),
                                provider,
                                color: Colors.orange,
                              ),
                              SizedBox(width: 8.w),
                              _buildFilterChip(
                                'pending',
                                localizations.translate('pending'),
                                provider,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              // Attendance list
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

                    if (provider.summary?.hasNoTeachers == true) {
                      return EmptyAttendanceWidget(
                        icon: Icons.people_outline,
                        title: localizations.translate('no_teachers_found'),
                        subtitle: 'Contact admin to add teachers',
                      );
                    }

                    if (provider.filteredAttendances.isEmpty) {
                      if (provider.searchQuery.isNotEmpty ||
                          provider.selectedStatus != 'all') {
                        return EmptyAttendanceWidget(
                          icon: Icons.filter_list_off,
                          title: localizations.translate('no_match_filter'),
                          subtitle: 'Try adjusting your filters',
                          action: TextButton(
                            onPressed: () {
                              _searchController.clear();
                              provider.resetFilters();
                            },
                            child: Text(
                              localizations.translate('clear_filters'),
                            ),
                          ),
                        );
                      }

                      return EmptyAttendanceWidget(
                        icon: Icons.assignment_outlined,
                        title: localizations.translate('attendance_not_marked'),
                        subtitle: 'Start marking attendance for today',
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.only(bottom: 80.h),
                      itemCount: provider.filteredAttendances.length,
                      itemBuilder: (context, index) {
                        final attendance = provider.filteredAttendances[index];
                        return TeacherAttendanceCard(
                          attendance: attendance,
                          onTap: () => _handleAttendanceTap(attendance),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Consumer<TeacherAttendanceListProvider>(
          builder: (context, provider, _) {
            if (!provider.canMarkAttendance || provider.isLoading) {
              return const SizedBox.shrink();
            }

            return FloatingActionButton.extended(
              onPressed: () => _navigateToMarkAttendance(),
              icon: const Icon(Icons.add),
              label: Text(localizations.translate('mark_attendance')),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummarySection(
    TeacherAttendanceListProvider provider,
    AppLocalizations localizations,
  ) {
    final summary = provider.summary!;

    return SizedBox(
      height: 110.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [
          AttendanceSummaryCard(
            label: localizations.translate('total_teachers'),
            value: summary.totalTeachers.toString(),
            icon: Icons.people,
            color: AppColors.primary,
            isSelected: provider.selectedStatus == 'all',
            onTap: () => provider.setStatusFilter('all'),
          ),
          SizedBox(width: 12.w),
          AttendanceSummaryCard(
            label: localizations.translate('marked'),
            value: summary.markedAttendance.toString(),
            icon: Icons.check_circle,
            color: Colors.blue,
          ),
          SizedBox(width: 12.w),
          AttendanceSummaryCard(
            label: localizations.translate('pending'),
            value: summary.pendingAttendance.toString(),
            icon: Icons.pending,
            color: Colors.grey,
            isSelected: provider.selectedStatus == 'pending',
            onTap: () => provider.setStatusFilter('pending'),
          ),
          SizedBox(width: 12.w),
          AttendanceSummaryCard(
            label: localizations.translate('present'),
            value: summary.present.toString(),
            icon: Icons.check,
            color: Colors.green,
            isSelected: provider.selectedStatus == 'present',
            onTap: () => provider.setStatusFilter('present'),
          ),
          SizedBox(width: 12.w),
          AttendanceSummaryCard(
            label: localizations.translate('absent'),
            value: summary.absent.toString(),
            icon: Icons.close,
            color: Colors.red,
            isSelected: provider.selectedStatus == 'absent',
            onTap: () => provider.setStatusFilter('absent'),
          ),
          SizedBox(width: 12.w),
          AttendanceSummaryCard(
            label: localizations.translate('leave'),
            value: summary.leave.toString(),
            icon: Icons.event_busy,
            color: Colors.orange,
            isSelected: provider.selectedStatus == 'leave',
            onTap: () => provider.setStatusFilter('leave'),
          ),
          SizedBox(width: 12.w),
          AttendanceSummaryCard(
            label: localizations.translate('attendance_percentage'),
            value: summary.getPercentageDisplay(),
            icon: Icons.analytics,
            color: _getPercentageColor(summary.attendancePercentage),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String status,
    String label,
    TeacherAttendanceListProvider provider, {
    Color? color,
  }) {
    final isSelected = provider.selectedStatus == status;
    final chipColor = color ?? AppColors.primary;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => provider.setStatusFilter(status),
      backgroundColor: Colors.grey.shade100,
      selectedColor: chipColor.withOpacity(0.2),
      checkmarkColor: chipColor,
      labelStyle: TextStyle(
        color: isSelected ? chipColor : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
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
