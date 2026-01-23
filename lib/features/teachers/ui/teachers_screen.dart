import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../shared/localization/app_localizations.dart';
import '../../../../shared/utils/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/person_card.dart';
import '../../../shared/utils/image_url_helper.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../chat/screens/chat_screen.dart';
import '../data/models/teacher_model.dart';
import '../provider/teachers_provider.dart';

/// Screen displaying list of all teachers
///
/// Shared between Parent and Teacher roles with professional design
class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Fetch teachers on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TeachersProvider>();
      if (provider.teachers.isEmpty && !provider.isLoading) {
        provider.fetchTeachers(refresh: true);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TeacherListModel> _filterTeachers(List<TeacherListModel> teachers) {
    if (_searchQuery.isEmpty) return teachers;

    return teachers.where((teacher) {
      final nameLower = teacher.name.toLowerCase();
      final queryLower = _searchQuery.toLowerCase();
      final department = teacher.teacher?.department?.toLowerCase() ?? '';
      final specialization =
          teacher.teacher?.specialization?.toLowerCase() ?? '';

      return nameLower.contains(queryLower) ||
          department.contains(queryLower) ||
          specialization.contains(queryLower);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: Column(
        children: [
          CustomAppBar(
            title: localizations.translate('teachers'),
            showBackButton: false,
          ),
          _buildHeader(context, localizations),
          Expanded(
            child: Consumer<TeachersProvider>(
              builder: (context, provider, child) {
                // Loading state
                if (provider.isLoading && provider.teachers.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(16.w),
                    child: LoadingShimmer.list(itemCount: 5, itemHeight: 100),
                  );
                }

                // Error state
                if (provider.errorMessage != null &&
                    provider.teachers.isEmpty) {
                  return ErrorState(
                    message: provider.errorMessage!,
                    onRetry: provider.retry,
                  );
                }

                // Empty state
                if (provider.isEmpty) {
                  return EmptyState(
                    icon: Icons.school_outlined,
                    message: localizations.translate('no_teachers_found'),
                    subMessage: localizations.translate('teachers_list_empty'),
                  );
                }

                // Filter teachers based on search
                final filteredTeachers = _filterTeachers(provider.teachers);

                // No results for search
                if (filteredTeachers.isEmpty && _searchQuery.isNotEmpty) {
                  return _buildNoSearchResults();
                }

                // Data state
                return RefreshIndicator(
                  onRefresh: () => provider.fetchTeachers(refresh: true),
                  color: AppColors.primary,
                  child: _buildTeachersList(provider, filteredTeachers),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations localizations) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Card
          Consumer<TeachersProvider>(
            builder: (context, provider, child) {
              if (provider.teachers.isEmpty) return const SizedBox.shrink();

              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.people_rounded,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${provider.teachers.length} ${localizations.translate('teachers')}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Available to connect',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          SizedBox(height: 16.h),

          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: TextStyle(
                fontSize: 14.sp,
                color:
                    Theme.of(context).textTheme.bodyLarge?.color ??
                    AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search teachers by name or department...',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color:
                      Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withOpacity(0.6) ??
                      AppColors.grey400,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                  size: 22.sp,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color:
                              Theme.of(context).textTheme.bodySmall?.color ??
                              AppColors.grey400,
                          size: 20.sp,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeachersList(
    TeachersProvider provider,
    List<TeacherListModel> teachers,
  ) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Load more when reaching near the end
        if (notification is ScrollEndNotification && _searchQuery.isEmpty) {
          final metrics = notification.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent - 200) {
            provider.loadMore();
          }
        }
        return false;
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount:
            teachers.length +
            (provider.isLoadingMore && _searchQuery.isEmpty ? 1 : 0),
        itemBuilder: (context, index) {
          // Show loading indicator at the end
          if (index == teachers.length) {
            return Padding(
              padding: EdgeInsets.all(16.w),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            );
          }

          final teacher = teachers[index];
          return _buildTeacherCard(teacher);
        },
      ),
    );
  }

  Widget _buildTeacherCard(TeacherListModel teacher) {
    // Build chips from teacher details
    final chips = <PersonCardChip>[];

    if (teacher.teacher?.specialization != null &&
        teacher.teacher!.specialization!.isNotEmpty) {
      chips.add(
        PersonCardChip(
          icon: Icons.star_outline_rounded,
          label: teacher.teacher!.specialization!,
        ),
      );
    }

    if (teacher.school != null && teacher.school!.name.isNotEmpty) {
      chips.add(
        PersonCardChip(
          icon: Icons.school_outlined,
          label: teacher.school!.name,
        ),
      );
    }

    return PersonCard(
      title: teacher.name,
      subtitle: teacher.teacher?.department,
      chips: chips,
      avatarUrl: ImageUrlHelper.resolveAvatarUrl(teacher.avatar),
      accentColor: AppColors.teacher,
      // Chat action button
      actionIcon: Icons.chat_bubble_outline_rounded,
      actionTooltip: 'Chat with ${teacher.name}',
      onActionTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              otherUserId: teacher.id,
              otherUserName: teacher.name,
              otherUserAvatar: teacher.avatar,
            ),
          ),
        );
      },
      onTap: () {
        // Show teacher details or navigate to profile
        _showTeacherDetails(teacher);
      },
    );
  }

  void _showTeacherDetails(TeacherListModel teacher) {
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
              teacher.name,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color:
                    Theme.of(context).textTheme.titleLarge?.color ??
                    AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            if (teacher.teacher?.department != null)
              Text(
                teacher.teacher!.department!,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.teacher,
                  fontWeight: FontWeight.w600,
                ),
              ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      otherUserId: teacher.id,
                      otherUserName: teacher.name,
                      otherUserAvatar: teacher.avatar,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              label: const Text('Start Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
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
              Icons.search_off_rounded,
              size: 56.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'No Teachers Found',
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
            'Try searching with different keywords',
            style: TextStyle(
              fontSize: 14.sp,
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
