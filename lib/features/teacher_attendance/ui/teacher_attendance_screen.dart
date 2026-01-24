import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../shared/localization/app_localizations.dart';
import '../../../../shared/utils/app_colors.dart';
import '../provider/teacher_attendance_provider.dart';
import 'widgets/attendance_history_tab.dart';
import 'widgets/mark_attendance_tab.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  final int classId;
  final int sessionId;
  final String className;
  final String sessionName;

  const TeacherAttendanceScreen({
    super.key,
    required this.classId,
    required this.sessionId,
    required this.className,
    required this.sessionName,
  });

  @override
  State<TeacherAttendanceScreen> createState() =>
      _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherAttendanceProvider>().initializeAttendanceScreen(
        widget.classId,
        widget.sessionId,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: Column(
        children: [
          CustomAppBarWithTabs(
            title: localizations.translate('attendance'),
            subtitle: '${widget.className} • ${widget.sessionName}',
            tabController: _tabController,
            tabs: [
              Tab(
                height: 44.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_note_rounded, size: 20.sp),
                    SizedBox(width: 6.w),
                    Text(localizations.translate('mark')),
                  ],
                ),
              ),
              Tab(
                height: 44.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_rounded, size: 20.sp),
                    SizedBox(width: 6.w),
                    Text(localizations.translate('history')),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    await context.read<TeacherAttendanceProvider>().initializeAttendanceScreen(
                      widget.classId,
                      widget.sessionId,
                    );
                  },
                  color: AppColors.primary,
                  child: MarkAttendanceTab(
                    onSubmitted: () {
                      // Switch to history tab after successful submission
                      _tabController.animateTo(1);
                    },
                  ),
                ),
                RefreshIndicator(
                  onRefresh: () async {
                    final provider = context.read<TeacherAttendanceProvider>();
                    await provider.initializeAttendanceScreen(
                      widget.classId,
                      widget.sessionId,
                    );
                    await provider.fetchHistory(provider.selectedHistoryDate);
                  },
                  color: AppColors.primary,
                  child: const AttendanceHistoryTab(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Extension to CustomAppBar that supports TabBar
class CustomAppBarWithTabs extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? leading;
  final List<Widget>? actions;
  final List<Color>? gradientColors;
  final double? height;

  /// TabBar configuration
  final TabController tabController;
  final List<Tab> tabs;
  final Color? tabBackgroundColor;
  final Color? tabIndicatorColor;
  final Color? selectedTabColor;
  final Color? unselectedTabColor;

  const CustomAppBarWithTabs({
    Key? key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.onBackPressed,
    this.leading,
    this.actions,
    this.gradientColors,
    this.height,
    required this.tabController,
    required this.tabs,
    this.tabBackgroundColor,
    this.tabIndicatorColor,
    this.selectedTabColor,
    this.unselectedTabColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(top: statusBarHeight),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              gradientColors ??
              [AppColors.primary, AppColors.primaryDark, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (gradientColors?.first ?? AppColors.primary).withOpacity(
              0.2,
            ),
            offset: Offset(0, 2.h),
            blurRadius: 20.r,
            spreadRadius: 4.r,
          ),
        ],
      ),
      child: Column(
        children: [
          // Top bar with title and actions
          Container(
            height: height ?? 60.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                // Leading widget (back button or custom widget)
                if (leading != null)
                  leading!
                else if (showBackButton)
                  _buildBackButton(context),

                if (leading != null || showBackButton) SizedBox(width: 12.w),

                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Actions
                if (actions != null) ...actions!,
              ],
            ),
          ),

          // TabBar
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: tabBackgroundColor ?? AppColors.grey100,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: TabBar(
              controller: tabController,
              indicator: BoxDecoration(
                color: tabIndicatorColor ?? Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: selectedTabColor ?? AppColors.primary,
              unselectedLabelColor: unselectedTabColor ?? AppColors.grey600,
              labelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              tabs: tabs,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return InkWell(
      onTap: onBackPressed ?? () => _handleBackPress(context),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 18.sp,
        ),
      ),
    );
  }

  void _handleBackPress(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/dashboard');
    }
  }
}
