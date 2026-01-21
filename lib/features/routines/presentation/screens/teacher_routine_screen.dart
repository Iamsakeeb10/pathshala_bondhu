import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../shared/localization/app_localizations.dart';
import '../../../../shared/utils/app_colors.dart';
import '../../../../shared/widgets/custom_appbar.dart';
import '../../data/models/teacher_routine_model.dart';
import '../../provider/teacher_routine_provider.dart';

class TeacherRoutineScreen extends StatefulWidget {
  const TeacherRoutineScreen({super.key});

  @override
  State<TeacherRoutineScreen> createState() => _TeacherRoutineScreenState();
}

class _TeacherRoutineScreenState extends State<TeacherRoutineScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<String> _getDays(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return [
      localizations.translate('sunday'),
      localizations.translate('monday'),
      localizations.translate('tuesday'),
      localizations.translate('wednesday'),
      localizations.translate('thursday'),
      localizations.translate('saturday'),
    ];
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherRoutineProvider>().fetchRoutines();
    });
  }

  void _setInitialDay(List<String> days) {
    final today = DateFormat('EEEE').format(DateTime.now());
    final dayMap = {
      'Sunday': days[0],
      'Monday': days[1],
      'Tuesday': days[2],
      'Wednesday': days[3],
      'Thursday': days[4],
      'Saturday': days[5],
    };
    final index = days.indexWhere((d) => d == dayMap[today]);
    if (index != -1) {
      _tabController.index = index;
    } else if (today == 'Friday') {
      _tabController.index = 0;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _isCurrentClass(TeacherRoutine routine) {
    final now = DateTime.now();
    try {
      final start = DateFormat("HH:mm:ss").parse(routine.startTime);
      final end = DateFormat("HH:mm:ss").parse(routine.endTime);
      final currentTime = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
        now.minute,
      );
      final startTime = DateTime(
        now.year,
        now.month,
        now.day,
        start.hour,
        start.minute,
      );
      final endTime = DateTime(
        now.year,
        now.month,
        now.day,
        end.hour,
        end.minute,
      );

      return currentTime.isAfter(
            startTime.subtract(const Duration(minutes: 1)),
          ) &&
          currentTime.isBefore(endTime);
    } catch (e) {
      return false;
    }
  }

  bool _isUpcomingClass(TeacherRoutine routine) {
    final now = DateTime.now();
    try {
      final start = DateFormat("HH:mm:ss").parse(routine.startTime);
      final startTime = DateTime(
        now.year,
        now.month,
        now.day,
        start.hour,
        start.minute,
      );
      final currentTime = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
        now.minute,
      );

      // Upcoming if starts within next hour
      return startTime.isAfter(currentTime) &&
          startTime.difference(currentTime).inMinutes <= 60;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final days = _getDays(context);

    if (_tabController.length != days.length) {
      _tabController.dispose();
      _tabController = TabController(length: days.length, vsync: this);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setInitialDay(days);
      });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          CustomAppBar(
            title: localizations.translate('my_routine'),
            showBackButton: true,
          ),
          _buildHeader(context, localizations),
          _buildDayTabs(context, days),
          Expanded(child: _buildRoutineContent(context, days)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations localizations) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            offset: Offset(0, 2.h),
            blurRadius: 20.r,
            spreadRadius: 4.r,
          ),
        ],
      ),
      child: Row(
        children: [
          // Current Date Info
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('dd').format(DateTime.now()),
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                Text(
                  DateFormat('MMM').format(DateTime.now()),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),

          // Today's Info
          Expanded(
            child: Consumer<TeacherRoutineProvider>(
              builder: (context, provider, child) {
                final today = DateFormat('EEEE').format(DateTime.now());
                final routines = provider.getRoutinesForDay(today);
                final currentClass = routines.firstWhere(
                  (r) => _isCurrentClass(r),
                  orElse: () => routines.first,
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      routines.isEmpty
                          ? localizations.translate('no_classes_today')
                          : '${routines.length} ${routines.length == 1 ? 'class' : 'classes'} today',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Schedule Icon
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayTabs(BuildContext context, List<String> days) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
      height: 50.h,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : Colors.transparent,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.04,
            ),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: Colors.white,
        unselectedLabelColor:
            Theme.of(context).textTheme.bodySmall?.color ??
            AppColors.textSecondary,
        labelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
        ),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelPadding: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.all(4.w),
        tabAlignment: TabAlignment.start,
        dividerColor: Colors.transparent,
        tabs: days.map((day) {
          final today = DateFormat('EEEE').format(DateTime.now());
          final dayMap = {
            'Sunday': days[0],
            'Monday': days[1],
            'Tuesday': days[2],
            'Wednesday': days[3],
            'Thursday': days[4],
            'Saturday': days[5],
          };
          final isToday = day == dayMap[today];
          return Tab(
            height: 42.h,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(day.substring(0, 3)),
                if (isToday) ...[
                  SizedBox(width: 6.w),
                  Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRoutineContent(BuildContext context, List<String> days) {
    final localizations = AppLocalizations.of(context)!;
    return Consumer<TeacherRoutineProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  strokeWidth: 3,
                ),
                SizedBox(height: 16.h),
                Text(
                  localizations.translate('loading_routine'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color:
                        Theme.of(context).textTheme.bodySmall?.color ??
                        AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        if (provider.errorMessage != null) {
          return _buildErrorState(localizations, provider);
        }

        return TabBarView(
          controller: _tabController,
          children: days.map((day) {
            final dayMap = {
              localizations.translate('sunday'): 'Sunday',
              localizations.translate('monday'): 'Monday',
              localizations.translate('tuesday'): 'Tuesday',
              localizations.translate('wednesday'): 'Wednesday',
              localizations.translate('thursday'): 'Thursday',
              localizations.translate('saturday'): 'Saturday',
            };
            final englishDay = dayMap[day] ?? day;
            final routines = provider.getRoutinesForDay(englishDay);
            if (routines.isEmpty) {
              return _buildEmptyState(day, context);
            }
            return ListView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
              itemCount: routines.length,
              itemBuilder: (context, index) {
                return _buildRoutineCard(routines[index], index, context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildEmptyState(String day, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final today = DateFormat('EEEE').format(DateTime.now());
    final dayMap = {
      'Sunday': localizations.translate('sunday'),
      'Monday': localizations.translate('monday'),
      'Tuesday': localizations.translate('tuesday'),
      'Wednesday': localizations.translate('wednesday'),
      'Thursday': localizations.translate('thursday'),
      'Saturday': localizations.translate('saturday'),
    };
    final isToday = day == dayMap[today];

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isToday
                    ? Icons.beach_access_rounded
                    : Icons.event_busy_outlined,
                size: 56.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              isToday
                  ? localizations.translate('no_classes_today')
                  : localizations.translate('no_classes_scheduled'),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color:
                    Theme.of(context).textTheme.titleLarge?.color ??
                    AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              isToday
                  ? localizations.translate('enjoy_free_day')
                  : '${localizations.translate('for_day')} $day',
              style: TextStyle(
                fontSize: 15.sp,
                color:
                    Theme.of(context).textTheme.bodySmall?.color ??
                    AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineCard(
    TeacherRoutine routine,
    int index,
    BuildContext context,
  ) {
    final localizations = AppLocalizations.of(context)!;
    final isOngoing = _isCurrentClass(routine);
    final isUpcoming = !isOngoing && _isUpcomingClass(routine);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isOngoing
              ? AppColors.success
              : isUpcoming
              ? AppColors.warning
              : Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : Colors.transparent,
          width: isOngoing || isUpcoming ? 2 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isOngoing
                ? AppColors.success.withOpacity(0.2)
                : isUpcoming
                ? AppColors.warning.withOpacity(0.15)
                : Colors.black.withOpacity(
                    Theme.of(context).brightness == Brightness.dark
                        ? 0.3
                        : 0.04,
                  ),
            blurRadius: isOngoing ? 16 : 10,
            offset: Offset(0, isOngoing ? 6 : 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showClassDetails(routine, context, localizations);
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with time and status
                Row(
                  children: [
                    // Time badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withOpacity(0.15),
                            AppColors.primary.withOpacity(0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 16.sp,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            '${_formatTime(routine.startTime)} - ${_formatTime(routine.endTime)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),

                    // Status badge
                    if (isOngoing)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6.w,
                              height: 6.w,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              localizations.translate('ongoing'),
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (isUpcoming)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AppColors.warning.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'UP NEXT',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 14.h),

                // Subject name
                Text(
                  routine.subject?.name ?? 'Unknown Subject',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color:
                        Theme.of(context).textTheme.titleLarge?.color ??
                        AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 14.h),
                Divider(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.borderDark
                      : AppColors.grey200,
                  height: 1,
                ),
                SizedBox(height: 12.h),

                // Class and Room info
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.class_outlined,
                        'Class',
                        routine.routineClass?.name ?? 'Unknown',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 30.h,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.borderDark
                          : AppColors.grey200,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.meeting_room_outlined,
                        'Room',
                        routine.roomNumber ?? 'N/A',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18.sp,
          color:
              Theme.of(context).textTheme.bodySmall?.color ??
              AppColors.textSecondary,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color:
                      Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withOpacity(0.7) ??
                      AppColors.grey500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color:
                      Theme.of(context).textTheme.bodyMedium?.color ??
                      AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showClassDetails(
    TeacherRoutine routine,
    BuildContext context,
    AppLocalizations localizations,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),

            Text(
              routine.subject?.name ?? 'Unknown Subject',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color:
                    Theme.of(context).textTheme.titleLarge?.color ??
                    AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),

            _buildDetailRow(
              Icons.schedule_rounded,
              'Time',
              '${_formatTime(routine.startTime)} - ${_formatTime(routine.endTime)}',
            ),
            SizedBox(height: 16.h),
            _buildDetailRow(
              Icons.class_outlined,
              'Class',
              routine.routineClass?.name ?? 'Unknown',
            ),
            SizedBox(height: 16.h),
            _buildDetailRow(
              Icons.meeting_room_outlined,
              'Room',
              routine.roomNumber ?? 'Not assigned',
            ),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.grey100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color:
                      Theme.of(context).textTheme.bodySmall?.color ??
                      AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color:
                      Theme.of(context).textTheme.bodyLarge?.color ??
                      AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    AppLocalizations localizations,
    TeacherRoutineProvider provider,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48.sp,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              localizations.translate('oops_something_went_wrong'),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color:
                    Theme.of(context).textTheme.titleLarge?.color ??
                    AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              provider.errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color:
                    Theme.of(context).textTheme.bodySmall?.color ??
                    AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () {
                provider.fetchRoutines();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String time) {
    try {
      final parsed = DateFormat("HH:mm:ss").parse(time);
      return DateFormat("hh:mm a").format(parsed);
    } catch (e) {
      return time;
    }
  }
}
