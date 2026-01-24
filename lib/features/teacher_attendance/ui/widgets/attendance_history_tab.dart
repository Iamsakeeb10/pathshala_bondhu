import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../shared/utils/app_colors.dart';
import '../../../../shared/utils/image_url_helper.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../provider/teacher_attendance_provider.dart';

class AttendanceHistoryTab extends StatefulWidget {
  const AttendanceHistoryTab({super.key});

  @override
  State<AttendanceHistoryTab> createState() => _AttendanceHistoryTabState();
}

class _AttendanceHistoryTabState extends State<AttendanceHistoryTab> {
  
  @override
  void initState() {
    super.initState();
    // Fetch info for initial date (today) when tab opens?
    // Or let user pick date. Provider init doesn't fetch history.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherAttendanceProvider>().fetchHistory(DateTime.now());
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final provider = context.read<TeacherAttendanceProvider>();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedHistoryDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != provider.selectedHistoryDate) {
      provider.fetchHistory(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherAttendanceProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Date Filter
            Container(
              padding: EdgeInsets.all(16.w),
              color: Colors.white,
              child: InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(10.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.grey300),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 20.sp, color: AppColors.primary),
                      SizedBox(width: 12.w),
                      Text(
                        DateFormat('MMMM dd, yyyy').format(provider.selectedHistoryDate),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            ),
            
            // Content
            Expanded(
              child: provider.isLoadingHistory
                  ? Padding(
                      padding: EdgeInsets.all(16.w),
                      child: LoadingShimmer.list(itemCount: 6),
                    )
                  : provider.historyRecords.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.event_busy, size: 48.sp, color: AppColors.grey300),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'No attendance records found',
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16.sp),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.all(16.w),
                          itemCount: provider.historyRecords.length,
                          separatorBuilder: (c, i) => SizedBox(height: 12.h),
                          itemBuilder: (context, index) {
                            final record = provider.historyRecords[index];
                            final isPresent = record.status.toLowerCase() == 'present';
                            
                            return Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20.r,
                                    backgroundColor: AppColors.primaryLight,
                                    child: ImageUrlHelper.resolveAvatarUrl(record.student.user.avatar).isNotEmpty
                                        ? ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl: ImageUrlHelper.resolveAvatarUrl(record.student.user.avatar),
                                              width: 40.w,
                                              height: 40.w,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => Container(
                                                width: 40.w,
                                                height: 40.w,
                                                color: AppColors.primaryLight,
                                                child: Center(
                                                  child: SizedBox(
                                                    width: 16.w,
                                                    height: 16.w,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor: AlwaysStoppedAnimation<Color>(
                                                        AppColors.primary,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              errorWidget: (context, url, error) => Container(
                                                width: 40.w,
                                                height: 40.w,
                                                color: AppColors.primaryLight,
                                                child: Center(
                                                  child: Text(
                                                    record.student.user.name.substring(0, 1).toUpperCase(),
                                                    style: TextStyle(
                                                      color: AppColors.primary,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16.sp,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Text(
                                            record.student.user.name.substring(0, 1).toUpperCase(),
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.sp,
                                            ),
                                          ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          record.student.user.name,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Roll: ${record.student.rollNo}',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                    decoration: BoxDecoration(
                                      color: isPresent 
                                          ? Colors.green.withOpacity(0.1) 
                                          : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Text(
                                      record.status.toUpperCase(),
                                      style: TextStyle(
                                        color: isPresent ? Colors.green : Colors.red,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }
}
