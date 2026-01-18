import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../shared/utils/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../students/provider/student_provider.dart';
import '../data/models/fees_models.dart';
import '../provider/fees_provider.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeesProvider>().fetchFees();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,

      body: Column(
        children: [
          CustomAppBar(
            title: 'Fees',
            showBackButton: true, // optional, default is true
          ),
          Expanded(
            child: Consumer<FeesProvider>(
              builder: (context, provider, child) {
                return Column(
                  children: [
                    _buildYearFilter(provider),
                    Expanded(child: _buildContent(provider)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearFilter(FeesProvider provider) {
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
          Text(
            'Academic Year:',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
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

  Widget _buildContent(FeesProvider provider) {
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
        icon: Icons.payment,
        message: 'No fee records',
        subMessage: 'No fee records for selected year.',
      );
    }

    if (provider.hasData) {
      return _buildFeesList(provider.data!);
    }

    return const SizedBox.shrink();
  }

  Widget _buildFeesList(FeesResponse data) {
    final studentProvider = context.watch<StudentProvider>();
    final selectedStudent = studentProvider.selectedStudent;

    List<ChildFees> feesToShow = data.childrenFees;
    if (selectedStudent != null && studentProvider.hasMultipleStudents) {
      feesToShow = data.childrenFees
          .where((f) => f.studentId == selectedStudent.studentId)
          .toList();
    }

    // Filter months to show only up to current month if year is current year
    final currentYear = DateTime.now().year;
    final currentMonth = DateTime.now().month;

    // Only filter if it's the current year (or future years where we shouldn't show anything yet?)
    // Requirement says "Future months fees dont show", assuming for current year.
    // If year is past, show all. If year is future, show none.

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: feesToShow.map((child) {
          // Clone the object or just filter the list in the UI builder?
          // Since models are final, we can't modify them easily without copyWith.
          // But we can just pass the filtered list to a modified _buildStudentFees or handle it there.
          // Let's handle it by passing a filtered list to _buildStudentFees if possible,
          // or just modify _buildStudentFees to accept max month.

          List<MonthlyFee> monthlyBreakdown = child.monthlyBreakdown;
          if (data.academicYear == currentYear) {
            monthlyBreakdown = child.monthlyBreakdown
                .take(currentMonth)
                .toList();
          } else if (data.academicYear > currentYear) {
            monthlyBreakdown = [];
          }

          return _buildStudentFees(child, monthlyBreakdown);
        }).toList(),
      ),
    );
  }

  Widget _buildStudentFees(
    ChildFees child, [
    List<MonthlyFee>? overrideMonthlyBreakdown,
  ]) {
    final monthlyBreakdown = overrideMonthlyBreakdown ?? child.monthlyBreakdown;
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
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '৳${child.totalPaidYear}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(12.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.2,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
            ),
            itemCount: monthlyBreakdown.length,
            itemBuilder: (context, index) =>
                _buildMonthCard(monthlyBreakdown[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCard(MonthlyFee fee) {
    final isPaid = fee.isPaid;
    final color = isPaid ? Colors.green : Colors.red;

    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            fee.monthName.substring(0, 3),
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4.h),
          Text(
            '৳${fee.paidAmount}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            isPaid ? 'Paid' : 'Unpaid',
            style: TextStyle(fontSize: 10.sp, color: color),
          ),
        ],
      ),
    );
  }
}
