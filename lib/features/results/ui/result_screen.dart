import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../shared/localization/app_localizations.dart';
import '../../../shared/utils/app_colors.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../../../shared/widgets/modern_alert.dart';
import '../../students/provider/student_provider.dart';
import '../data/models/result_models.dart';
import '../provider/result_provider.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResultProvider>().fetchResults();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          CustomAppBar(
            title: localizations.translate('result'),
            showBackButton: true,
          ),
          Expanded(
            child: Consumer<ResultProvider>(
              builder: (context, provider, child) {
                return _buildContent(provider, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ResultProvider provider, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    if (provider.isLoading) {
      return Padding(
        padding: EdgeInsets.all(16.w),
        child: LoadingShimmer.list(itemCount: 3),
      );
    }

    if (provider.error != null) {
      return ErrorState(
        message: provider.error!,
        onRetry: () => provider.fetchResults(),
      );
    }

    if (!provider.hasResults) {
      return RefreshIndicator(
        onRefresh: () async {
          await provider.fetchResults();
        },
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: EmptyState(
              icon: Icons.emoji_events_outlined,
              message: localizations.translate('no_results_found'),
              subMessage: localizations.translate('no_results_available'),
            ),
          ),
        ),
      );
    }

    final response = provider.resultResponse!;
    return _buildResultsList(response, context);
  }

  Widget _buildResultsList(ResultResponse data, BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final selectedStudent = studentProvider.selectedStudent;

    List<ChildResult> resultsToShow = data.childrenResults;
    if (selectedStudent != null && studentProvider.hasMultipleStudents) {
      resultsToShow = data.childrenResults
          .where((r) => r.studentId == selectedStudent.studentId)
          .toList();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<ResultProvider>().fetchResults();
      },
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: resultsToShow.map((child) {
            return _buildStudentResults(child, context);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStudentResults(ChildResult child, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context)!;

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: isDark
            ? Border.all(color: AppColors.borderDark, width: 1.2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student Header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        AppColors.primary.withOpacity(0.3),
                        AppColors.primaryDark.withOpacity(0.2),
                      ]
                    : [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.person, color: Colors.white, size: 28.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child.studentName,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        child.classInfo,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${localizations.translate('academic_session')}: ${child.academicSession}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Exams List
          if (child.exams.isEmpty)
            Padding(
              padding: EdgeInsets.all(32.w),
              child: Center(
                child: Text(
                  localizations.translate('no_results_available'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            )
          else
            ...child.exams.map((exam) => _buildExamCard(exam, context)),

          // Download PDF Button
          // Padding(
          //   padding: EdgeInsets.all(16.w),
          //   child: SizedBox(
          //     width: double.infinity,
          //     child: ElevatedButton.icon(
          //       onPressed: () => _handleDownloadPdf(context),
          //       icon: const Icon(Icons.picture_as_pdf),
          //       label: Text(localizations.translate('download_pdf')),
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: AppColors.primary,
          //         foregroundColor: Colors.white,
          //         padding: EdgeInsets.symmetric(vertical: 14.h),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(12.r),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildExamCard(ExamResult exam, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark.withOpacity(0.5)
            : AppColors.grey50,
        borderRadius: BorderRadius.circular(12.r),
        border: isDark
            ? Border.all(color: AppColors.borderDark.withOpacity(0.5))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exam Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.examName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(exam.status),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            exam.status,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Overall Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  localizations.translate('total_marks'),
                  '${exam.totalMarks}',
                  Icons.grade,
                  AppColors.primary,
                  context,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  localizations.translate('grade'),
                  exam.averageGpa.toStringAsFixed(2),
                  Icons.stars,
                  AppColors.accent,
                  context,
                ),
              ),
            ],
          ),

          // Subject-wise Results
          if (exam.subjects.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Text(
              localizations.translate('subject_wise_results'),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            SizedBox(height: 12.h),
            ...exam.subjects.map(
              (subject) => _buildSubjectRow(subject, context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.15) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: isDark
            ? Border.all(color: color.withOpacity(0.3), width: 1)
            : null,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectRow(SubjectResult subject, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: isDark
            ? Border.all(color: AppColors.borderDark.withOpacity(0.3))
            : Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(Icons.book, color: AppColors.primary, size: 16.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.subject,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${subject.marks} marks • GPA: ${subject.gpa}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _getGradeColor(subject.grade),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              subject.grade,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A+':
      case 'A':
        return AppColors.success;
      case 'B':
        return AppColors.primary;
      case 'C':
        return AppColors.warning;
      case 'D':
      case 'F':
        return AppColors.error;
      default:
        return AppColors.grey400;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'passed':
        return AppColors.success;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  void _handleDownloadPdf(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    ModernAlert.show(
      context: context,
      type: AlertType.info,
      title: localizations.translate('coming_soon'),
      message: localizations.translate('pdf_download_coming_soon'),
      confirmText: localizations.translate('ok'),
    );
  }
}
