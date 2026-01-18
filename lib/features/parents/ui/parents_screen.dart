import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../shared/utils/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/person_card.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../data/models/parent_model.dart';
import '../provider/parents_provider.dart';
import '../../chat/screens/chat_screen.dart';

/// Screen displaying list of parents with search functionality
///
/// Only visible to Teacher role
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
      backgroundColor: AppColors.backgroundLight,

      body: Column(
        children: [
          CustomAppBar(title: 'Parents', showBackButton: false),

          // Search bar
          _buildSearchBar(),

          // Parents list
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
                  return EmptyState(
                    icon: Icons.family_restroom_outlined,
                    message: provider.searchQuery.isNotEmpty
                        ? 'No parents found for your search'
                        : 'No parents found',
                    subMessage: provider.searchQuery.isNotEmpty
                        ? 'Try a different search term'
                        : 'Parents list is empty.',
                    onAction: provider.searchQuery.isNotEmpty
                        ? () {
                            _searchController.clear();
                            provider.clearSearch();
                          }
                        : null,
                    actionLabel: provider.searchQuery.isNotEmpty
                        ? 'Clear Search'
                        : null,
                  );
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

  /// Search bar with clear button and search icon
  Widget _buildSearchBar() {
    return Consumer<ParentsProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              provider.searchParents(value);
            },
            decoration: InputDecoration(
              hintText: 'Search parent by name or phone',
              hintStyle: TextStyle(color: AppColors.grey400, fontSize: 14.sp),
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
                  : Icon(Icons.search, color: AppColors.grey400, size: 22.sp),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        provider.clearSearch();
                      },
                      icon: Icon(
                        Icons.close,
                        color: AppColors.grey500,
                        size: 20.sp,
                      ),
                    )
                  : null,
              filled: true,
              fillColor: AppColors.grey100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
          ),
        );
      },
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
              child: const Center(child: CircularProgressIndicator()),
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
          label: parent.address!.length > 25
              ? '${parent.address!.substring(0, 25)}...'
              : parent.address!,
        ),
      );
    }

    // Build subtitle from mother name
    String? subtitle;
    if (parent.motherName.isNotEmpty && parent.motherName != 'Anonymous') {
      subtitle = 'Mother: ${parent.motherName}';
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
              // Parent model doesn't have an avatar URL in the list model currently,
              // passing null or we could try to look it up if available later.
              otherUserImage: null, 
            ),
          ),
        );
      },
      onTap: () {
        // For now, just show a snackbar - can add detail screen later
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${parent.fatherName}'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );
  }
}
