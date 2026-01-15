import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../shared/utils/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../students/provider/student_provider.dart';
import '../data/models/attendance_models.dart';
import '../provider/attendance_provider.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().fetchAttendance();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildFilters(provider),
              Expanded(child: _buildContent(provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilters(AttendanceProvider provider) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey300),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: provider.selectedMonth,
                  isExpanded: true,
                  items: List.generate(12, (index) {
                    final monthNum = index + 1;
                    final monthName = AttendanceProvider.months[index];
                    return DropdownMenuItem(
                      value: monthNum,
                      child: Text(monthName),
                    );
                  }),
                  onChanged: (value) {
                    if (value != null) provider.setMonth(value);
                  },
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey300),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: provider.selectedYear,
                  isExpanded: true,
                  items: List.generate(5, (i) => DateTime.now().year - 2 + i)
                      .map((year) {
                        return DropdownMenuItem(
                          value: year,
                          child: Text(year.toString()),
                        );
                      })
                      .toList(),
                  onChanged: (value) {
                    if (value != null) provider.setYear(value);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AttendanceProvider provider) {
    if (provider.isLoading) {
      return Padding(
        padding: EdgeInsets.all(16.w),
        child: LoadingShimmer.list(itemCount: 4),
      );
    }

    if (provider.errorMessage != null) {
      return ErrorState(
        message: provider.errorMessage!,
        onRetry: provider.retry,
      );
    }

    if (provider.isEmpty) {
      return const EmptyState(
        icon: Icons.event_available,
        message: 'No attendance records',
        subMessage: 'No records for selected month and year.',
      );
    }

    if (provider.hasData) {
      return _buildAttendanceList(provider.data!);
    }

    return const SizedBox.shrink();
  }

  Widget _buildAttendanceList(AttendanceResponse data) {
    final studentProvider = context.watch<StudentProvider>();
    final selectedStudent = studentProvider.selectedStudent;

    List<ChildAttendance> attendanceToShow = data.childrenAttendance;
    if (selectedStudent != null && studentProvider.hasMultipleStudents) {
      attendanceToShow = data.childrenAttendance
          .where((a) => a.studentId == selectedStudent.studentId)
          .toList();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: attendanceToShow
            .map((child) => _buildStudentCard(child))
            .toList(),
      ),
    );
  }

  Widget _buildStudentCard(ChildAttendance child) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.person, color: AppColors.primary, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child.studentName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${child.classInfo} • ID: ${child.studentId}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildSummaryRow(child.summary),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(12.w),
            itemCount: child.attendanceLog.length,
            itemBuilder: (context, index) =>
                _buildLogItem(child.attendanceLog[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(AttendanceSummary summary) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            'Present',
            summary.present.toString(),
            Colors.green,
          ),
          _buildSummaryItem('Absent', summary.absent.toString(), Colors.red),
          _buildSummaryItem('Late', summary.late.toString(), Colors.orange),
          _buildSummaryItem('Rate', summary.attendanceRate, AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildLogItem(AttendanceLog log) {
    DateTime? date;
    try {
      date = DateTime.parse(log.date);
    } catch (_) {}

    Color statusColor = log.status == 'Present'
        ? Colors.green
        : log.status == 'Absent'
        ? Colors.red
        : Colors.orange;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            log.status == 'Present' ? Icons.check_circle : Icons.cancel,
            color: statusColor,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date != null
                      ? DateFormat('MMM dd, yyyy').format(date)
                      : log.date,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  log.status,
                  style: TextStyle(fontSize: 13.sp, color: statusColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
