import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../shared/localization/app_localizations.dart';
import '../../../../shared/utils/app_colors.dart';
import '../../../../shared/widgets/custom_appbar.dart';
import '../../data/models/teacher_diary_model.dart';
import '../../provider/teacher_diary_provider.dart';

class TeacherDiaryListScreen extends StatefulWidget {
  const TeacherDiaryListScreen({super.key});

  @override
  State<TeacherDiaryListScreen> createState() => _TeacherDiaryListScreenState();
}

class _TeacherDiaryListScreenState extends State<TeacherDiaryListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherDiaryProvider>().fetchDiaries(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<TeacherDiaryProvider>().fetchDiaries();
    }
  }

  Future<void> _refresh() async {
    await context.read<TeacherDiaryProvider>().fetchDiaries(refresh: true);
  }

  List<TeacherDiary> _filterDiaries(List<TeacherDiary> diaries) {
    if (_searchQuery.isEmpty) return diaries;

    return diaries.where((diary) {
      final titleLower = diary.title.toLowerCase();
      final queryLower = _searchQuery.toLowerCase();
      final subject = diary.subject?.name?.toLowerCase() ?? '';
      final className = diary.diaryClass?.name?.toLowerCase() ?? '';

      return titleLower.contains(queryLower) ||
          subject.contains(queryLower) ||
          className.contains(queryLower);
    }).toList();
  }

  void _confirmDelete(BuildContext context, int id) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          localizations.translate('delete_diary'),
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          localizations.translate('are_you_sure_delete_diary'),
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              localizations.translate('cancel'),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await context.read<TeacherDiaryProvider>().deleteDiary(id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        localizations.translate('diary_deleted_successfully'),
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${localizations.translate('error')}: $e'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  );
                }
              }
            },
            child: Text(
              localizations.translate('delete'),
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/teacher/diaries/create');
        },
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          localizations.translate('add_diary'),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15.sp,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: Column(
        children: [
          CustomAppBar(
            title: localizations.translate('class_diary'),
            showBackButton: true,
          ),
          _buildHeader(context, localizations),
          Expanded(
            child: Consumer<TeacherDiaryProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.diaries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          localizations.translate('loading_diaries'),
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

                if (provider.errorMessage != null && provider.diaries.isEmpty) {
                  return _buildErrorState(localizations, provider);
                }

                if (provider.diaries.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    color: AppColors.primary,
                    child: Stack(
                      children: [ListView(), _buildEmptyState(localizations)],
                    ),
                  );
                }

                final filteredDiaries = _filterDiaries(provider.diaries);

                if (filteredDiaries.isEmpty && _searchQuery.isNotEmpty) {
                  return _buildNoSearchResults(localizations);
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  color: AppColors.primary,
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 96.h),
                    itemCount:
                        filteredDiaries.length +
                        (provider.isMoreLoading && _searchQuery.isEmpty
                            ? 1
                            : 0),
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 16.h),
                    itemBuilder: (context, index) {
                      if (index == filteredDiaries.length) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.h),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                              strokeWidth: 2.5,
                            ),
                          ),
                        );
                      }
                      return _buildDiaryCard(
                        filteredDiaries[index],
                        localizations,
                      );
                    },
                  ),
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
          Consumer<TeacherDiaryProvider>(
            builder: (context, provider, child) {
              if (provider.diaries.isEmpty && !provider.isLoading) {
                return const SizedBox.shrink();
              }

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
                        Icons.book_rounded,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${provider.diaries.length} ${localizations.translate('diaries')}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Total class diaries',
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
                hintText: 'Search diaries by title, subject or class...',
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

  Widget _buildDiaryCard(TeacherDiary diary, AppLocalizations localizations) {
    bool isPublished = diary.status.toLowerCase() == 'published';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : Colors.transparent,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.04,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.push('/teacher/diaries/${diary.id}');
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and menu
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        diary.title,
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).textTheme.titleLarge?.color ??
                              AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    _buildOptionsMenu(diary),
                  ],
                ),

                SizedBox(height: 14.h),

                // Status and Class badges
                Row(
                  children: [
                    _buildStatusBadge(isPublished, diary.status),
                    SizedBox(width: 10.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.class_outlined,
                            size: 14.sp,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            diary.diaryClass?.name ??
                                localizations.translate('unknown'),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 14.h),
                Divider(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.borderDark
                      : AppColors.grey200,
                  height: 1,
                ),
                SizedBox(height: 12.h),

                // Subject and Date info
                Row(
                  children: [
                    Icon(
                      Icons.book_outlined,
                      size: 16.sp,
                      color:
                          Theme.of(context).textTheme.bodySmall?.color ??
                          AppColors.textSecondary,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        diary.subject?.name ??
                            '${localizations.translate('unknown')} ${localizations.translate('subject')}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color:
                              Theme.of(context).textTheme.bodySmall?.color ??
                              AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14.sp,
                      color:
                          Theme.of(context).textTheme.bodySmall?.color ??
                          AppColors.textSecondary,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      _formatDate(diary.diaryDate),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color:
                            Theme.of(context).textTheme.bodySmall?.color ??
                            AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (diary.academicSession != null) ...[
                      SizedBox(width: 12.w),
                      Container(
                        width: 4.w,
                        height: 4.w,
                        decoration: BoxDecoration(
                          color: AppColors.grey400,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          diary.academicSession!.title,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color:
                                Theme.of(context).textTheme.bodySmall?.color ??
                                AppColors.grey500,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsMenu(TeacherDiary diary) {
    return Container(
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
      child: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            context.push('/teacher/diaries/edit/${diary.id}', extra: diary);
          } else if (value == 'delete') {
            _confirmDelete(context, diary.id);
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: [
                Icon(
                  Icons.edit_outlined,
                  size: 18.sp,
                  color: AppColors.primary,
                ),
                SizedBox(width: 12.w),
                Text(
                  AppLocalizations.of(context)!.translate('edit'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color:
                        Theme.of(context).textTheme.bodyLarge?.color ??
                        AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline_rounded,
                  size: 18.sp,
                  color: AppColors.error,
                ),
                SizedBox(width: 12.w),
                Text(
                  AppLocalizations.of(context)!.translate('delete'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
        icon: Icon(
          Icons.more_vert_rounded,
          size: 20.sp,
          color: AppColors.primary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        offset: Offset(0, 8.h),
      ),
    );
  }

  Widget _buildStatusBadge(bool isPublished, String statusText) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isPublished
            ? AppColors.success.withOpacity(0.12)
            : AppColors.warning.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isPublished
              ? AppColors.success.withOpacity(0.3)
              : AppColors.warning.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: isPublished ? AppColors.success : AppColors.warning,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            statusText.toUpperCase(),
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: isPublished ? AppColors.success : AppColors.warning,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations localizations) {
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
                Icons.book_outlined,
                size: 56.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              localizations.translate('no_diaries_yet'),
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
              localizations.translate('start_creating_diaries'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color:
                    Theme.of(context).textTheme.bodySmall?.color ??
                    AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    AppLocalizations localizations,
    TeacherDiaryProvider provider,
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
              localizations.translate('error_loading_diaries'),
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
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(localizations.translate('retry')),
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

  Widget _buildNoSearchResults(AppLocalizations localizations) {
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
            'No Diaries Found',
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

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
