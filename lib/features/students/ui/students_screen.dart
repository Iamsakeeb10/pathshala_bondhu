import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../shared/utils/app_colors.dart';
import '../../../../shared/utils/image_url_helper.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/modern_alert.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../auth/data/models/parent_models.dart';
import '../provider/student_provider.dart';

/// Students screen - displays all students for the parent
class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<StudentProvider>();
      if (provider.students.isEmpty) {
        provider.fetchStudents();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: Column(
        children: [
          CustomAppBar(
            title: 'Students',
            showBackButton: false, // optional, default is true
          ),
          Expanded(
            child: Consumer<StudentProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return Padding(
                    padding: EdgeInsets.all(16.w),
                    child: LoadingShimmer.list(itemCount: 3, itemHeight: 140),
                  );
                }

                if (provider.errorMessage != null) {
                  return ErrorState(
                    message: provider.errorMessage!,
                    onRetry: provider.fetchStudents,
                  );
                }

                if (provider.hasNoStudents) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      await provider.fetchStudents();
                    },
                    color: AppColors.primary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: const EmptyState(
                          icon: Icons.people_outline,
                          message: 'No students found',
                          subMessage: 'No students are linked to your account.',
                        ),
                      ),
                    ),
                  );
                }

                return _buildStudentList(provider.students, provider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList(
    List<StudentInfo> students,
    StudentProvider provider,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await provider.fetchStudents();
      },
      color: AppColors.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        itemCount: students.length,
        itemBuilder: (context, index) {
          return _buildStudentCard(students[index], provider);
        },
      ),
    );
  }

  Widget _buildStudentCard(StudentInfo student, StudentProvider provider) {
    final isSelected = provider.selectedStudent?.studentId == student.studentId;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: isSelected
            ? Border.all(color: AppColors.primary, width: 2)
            : Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.borderDark
                    : Colors.transparent,
                width: 1.2,
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.06,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            provider.selectStudent(student);
            ModernAlert.show(
              context: context,
              type: AlertType.success,
              title: 'Student Selected',
              message:
                  '${student.user?.name ?? 'Student'} from ${student.classInfo.name} has been selected',
              confirmText: 'OK',
            );
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child:
                          student.user != null && student.user!.avatar != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14.r),
                              child: CachedNetworkImage(
                                imageUrl: ImageUrlHelper.resolveAvatarUrl(
                                  student.user!.avatar,
                                ),
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Center(
                                  child: Text(
                                    student.user?.name.isNotEmpty == true
                                        ? student.user!.name[0].toUpperCase()
                                        : 'S',
                                    style: TextStyle(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                student.user?.name.isNotEmpty == true
                                    ? student.user!.name[0].toUpperCase()
                                    : 'S',
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ),
                    SizedBox(width: 14.w),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.user?.name ??
                                'Student ${student.studentId}',
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.color ??
                                  AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            student.classInfo.name,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Selection indicator
                    if (isSelected)
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          size: 16.sp,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Details grid
                Row(
                  children: [
                    _buildDetailChip(Icons.numbers, 'Roll: ${student.rollNo}'),
                    SizedBox(width: 12.w),
                    _buildDetailChip(
                      Icons.calendar_today,
                      'Session: ${student.academicSession.title}',
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

  Widget _buildDetailChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.grey100,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: AppColors.textSecondary),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color:
                  Theme.of(context).textTheme.bodySmall?.color ??
                  AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
