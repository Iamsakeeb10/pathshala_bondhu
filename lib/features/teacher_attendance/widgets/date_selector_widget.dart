import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../shared/localization/app_localizations.dart';

/// Date selector widget for attendance screens
class DateSelectorWidget extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;
  final VoidCallback onDateTap;
  final bool canGoForward;

  const DateSelectorWidget({
    super.key,
    required this.selectedDate,
    required this.onPreviousDay,
    required this.onNextDay,
    required this.onDateTap,
    this.canGoForward = true,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isToday = DateUtils.isSameDay(selectedDate, DateTime.now());

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        children: [
          // Previous day button
          IconButton(
            onPressed: onPreviousDay,
            icon: const Icon(Icons.chevron_left),
            style: IconButton.styleFrom(
              backgroundColor: isDark
                  ? Colors.grey.shade800
                  : Colors.grey.shade100,
            ),
          ),

          SizedBox(width: 12.w),

          // Date display
          Expanded(
            child: InkWell(
              onTap: onDateTap,
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16.sp,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          DateFormat('dd MMMM yyyy').format(selectedDate),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                    if (isToday) ...[
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          localizations.translate('today'),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ] else ...[
                      SizedBox(height: 4.h),
                      Text(
                        _getDayOfWeek(selectedDate, localizations),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // Next day button
          IconButton(
            onPressed: canGoForward ? onNextDay : null,
            icon: const Icon(Icons.chevron_right),
            style: IconButton.styleFrom(
              backgroundColor: canGoForward
                  ? (isDark ? Colors.grey.shade800 : Colors.grey.shade100)
                  : (isDark ? Colors.grey.shade900 : Colors.grey.shade200),
            ),
          ),
        ],
      ),
    );
  }

  String _getDayOfWeek(DateTime date, AppLocalizations localizations) {
    final days = [
      localizations.translate('monday'),
      localizations.translate('tuesday'),
      localizations.translate('wednesday'),
      localizations.translate('thursday'),
      localizations.translate('friday'),
      localizations.translate('saturday'),
      localizations.translate('sunday'),
    ];

    return days[date.weekday - 1];
  }
}
