import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../shared/utils/app_colors.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/person_card.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../chat/screens/chat_screen.dart';
import '../data/models/parent_model.dart';
import '../provider/parents_provider.dart';

/// Screen displaying list of parents with search functionality
///
/// Only visible to Teacher role with professional design
class ParentsScreen extends StatefulWidget {
  const ParentsScreen({super.key});

  @override
  State<ParentsScreen> createState() => _ParentsScreenState();
}

class _ParentsScreenState extends State<ParentsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch parents on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ParentsProvider>();
      if (provider.parents.isEmpty && !provider.isLoading) {
        provider.fetchParents(refresh: true);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: Column(
        children: [
          CustomAppBar(title: 'Parents', showBackButton: false),
          _buildHeader(context),
          Expanded(
            child: Consumer<ParentsProvider>(
              builder: (context, provider, child) {
                // Initial loading state
                if (provider.isLoading && provider.parents.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(16.w),
                    child: LoadingShimmer.list(itemCount: 5, itemHeight: 120),
                  );
                }

                // Error state
                if (provider.errorMessage != null && provider.parents.isEmpty) {
                  return ErrorState(
                    message: provider.errorMessage!,
                    onRetry: provider.retry,
                  );
                }

                // Empty state (with search context)
                if (provider.isEmpty) {
                  return _buildEmptyState(provider);
                }

                // Data state
                return RefreshIndicator(
                  onRefresh: () => provider.fetchParents(refresh: true),
                  color: AppColors.primary,
                  child: _buildParentsList(provider),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
          Consumer<ParentsProvider>(
            builder: (context, provider, child) {
              if (provider.parents.isEmpty && !provider.isLoading) {
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
                        Icons.family_restroom_rounded,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${provider.parents.length} Parents',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Connected families',
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
          Consumer<ParentsProvider>(
            builder: (context, provider, child) {
              return Container(
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
                    provider.searchParents(value);
                  },
                  style: TextStyle(
                    fontSize: 14.sp,
                    color:
                        Theme.of(context).textTheme.bodyLarge?.color ??
                        AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search parents by name or phone...',
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color:
                          Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withOpacity(0.6) ??
                          AppColors.grey400,
                    ),
                    prefixIcon: provider.isSearching
                        ? Padding(
                            padding: EdgeInsets.all(12.w),
                            child: SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.search_rounded,
                            color: AppColors.primary,
                            size: 22.sp,
                          ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              color:
                                  Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color ??
                                  AppColors.grey400,
                              size: 20.sp,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              provider.clearSearch();
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
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildParentsList(ParentsProvider provider) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Load more when reaching near the end
        if (notification is ScrollEndNotification) {
          final metrics = notification.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent - 200) {
            provider.loadMore();
          }
        }
        return false;
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: provider.parents.length + (provider.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Show loading indicator at the end
          if (index == provider.parents.length) {
            return Padding(
              padding: EdgeInsets.all(16.w),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            );
          }

          final parent = provider.parents[index];
          return _buildParentCard(parent);
        },
      ),
    );
  }

  Widget _buildParentCard(ParentListModel parent) {
    // Build chips from parent details
    final chips = <PersonCardChip>[];

    // Phone number
    if (parent.parentPhone.isNotEmpty) {
      chips.add(
        PersonCardChip(icon: Icons.phone_outlined, label: parent.parentPhone),
      );
    }

    // School name
    if (parent.school != null && parent.school!.name.isNotEmpty) {
      chips.add(
        PersonCardChip(icon: Icons.school_outlined, label: parent.school!.name),
      );
    }

    // Address (truncated)
    if (parent.address != null && parent.address!.isNotEmpty) {
      chips.add(
        PersonCardChip(
          icon: Icons.location_on_outlined,
          label: parent.address!.length > 30
              ? '${parent.address!.substring(0, 30)}...'
              : parent.address!,
        ),
      );
    }

    // Build subtitle from mother name
    String? subtitle;
    if (parent.motherName.isNotEmpty && parent.motherName != 'Anonymous') {
      subtitle = parent.motherName;
    }

    return PersonCard(
      title: parent.fatherName,
      subtitle: subtitle,
      chips: chips,
      accentColor: AppColors.student, // Pink color for parents
      // Chat action button
      actionIcon: Icons.chat_bubble_outline_rounded,
      actionTooltip: 'Chat with ${parent.fatherName}',
      onActionTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              otherUserId: parent.id,
              otherUserName: parent.fatherName,
              otherUserAvatar: null,
            ),
          ),
        );
      },
      onTap: () {
        _showParentDetails(parent);
      },
    );
  }

  void _showParentDetails(ParentListModel parent) {
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

            // Father Info
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: AppColors.student,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Father',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color:
                        Theme.of(context).textTheme.bodySmall?.color ??
                        AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              parent.fatherName,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color:
                    Theme.of(context).textTheme.titleLarge?.color ??
                    AppColors.textPrimary,
              ),
            ),

            // Mother Info
            if (parent.motherName.isNotEmpty &&
                parent.motherName != 'Anonymous') ...[
              SizedBox(height: 16.h),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    color: AppColors.student,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Mother',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color:
                          Theme.of(context).textTheme.bodySmall?.color ??
                          AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                parent.motherName,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color:
                      Theme.of(context).textTheme.titleMedium?.color ??
                      AppColors.textPrimary,
                ),
              ),
            ],

            // Phone
            if (parent.parentPhone.isNotEmpty) ...[
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.surfaceDark
                      : AppColors.grey100,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      parent.parentPhone,
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
            ],

            // Address
            if (parent.address != null && parent.address!.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.surfaceDark
                      : AppColors.grey100,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        parent.address!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color:
                              Theme.of(context).textTheme.bodyLarge?.color ??
                              AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 24.h),

            // Action Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      otherUserId: parent.id,
                      otherUserName: parent.fatherName,
                      otherUserAvatar: null,
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
                elevation: 0,
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ParentsProvider provider) {
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
              provider.searchQuery.isNotEmpty
                  ? Icons.search_off_rounded
                  : Icons.family_restroom_outlined,
              size: 56.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            provider.searchQuery.isNotEmpty
                ? 'No Parents Found'
                : 'No Parents Available',
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
            provider.searchQuery.isNotEmpty
                ? 'Try searching with different keywords'
                : 'Parents list is empty',
            style: TextStyle(
              fontSize: 14.sp,
              color:
                  Theme.of(context).textTheme.bodySmall?.color ??
                  AppColors.textSecondary,
            ),
          ),
          if (provider.searchQuery.isNotEmpty) ...[
            SizedBox(height: 24.h),
            OutlinedButton.icon(
              onPressed: () {
                _searchController.clear();
                provider.clearSearch();
              },
              icon: const Icon(Icons.clear_rounded),
              label: const Text('Clear Search'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
