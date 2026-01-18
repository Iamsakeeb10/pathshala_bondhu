// lib/features/notifications/screens/notification_screen.dart

import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../shared/utils/app_colors.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../models/notification_model.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_shimmer.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();

  bool _autoMarked = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<NotificationProvider>();

      // Load notifications
      provider.fetchNotifications(refresh: true);

      // Auto-mark after 5 seconds (only once per screen-open)
      Future.delayed(const Duration(seconds: 5), () async {
        if (mounted && !_autoMarked) {
          _autoMarked = true;

          try {
            await provider.markAllAsRead();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('All notifications marked as read'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } catch (_) {
            // ignore errors to keep experience smooth
          }
        }
      });
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationProvider>().loadMore();
    }
  }

  Future<void> _handleRefresh() async {
    await context.read<NotificationProvider>().fetchNotifications(
      refresh: true,
    );
  }

  Future<void> _markAllAsRead() async {
    try {
      await context.read<NotificationProvider>().markAllAsRead();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('All notifications marked as read'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Map<String, List<NotificationModel>> _groupNotificationsByDate(
    List<NotificationModel> notifications,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final Map<String, List<NotificationModel>> grouped = {
      'Today': [],
      'Yesterday': [],
      'This Week': [],
      'Earlier': [],
    };

    for (var notification in notifications) {
      final date = DateTime(
        notification.createdAt.year,
        notification.createdAt.month,
        notification.createdAt.day,
      );

      if (date == today) {
        grouped['Today']!.add(notification);
      } else if (date == yesterday) {
        grouped['Yesterday']!.add(notification);
      } else if (now.difference(notification.createdAt).inDays < 7) {
        grouped['This Week']!.add(notification);
      } else {
        grouped['Earlier']!.add(notification);
      }
    }

    // Remove empty groups
    grouped.removeWhere((key, value) => value.isEmpty);

    return grouped;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/dashboard');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Column(
          children: [
            CustomAppBar(
              title: 'Notifications',
              height: 60.h,
              actions: [
                Consumer<NotificationProvider>(
                  builder: (context, provider, child) {
                    if (provider.notifications.any((n) => !n.isRead)) {
                      return MarkAllReadAction(onTap: _markAllAsRead);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),

            Expanded(
              child: Consumer<NotificationProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.notifications.isEmpty) {
                    return const NotificationShimmer();
                  }

                  if (provider.hasError && provider.notifications.isEmpty) {
                    return Center(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 32.w),
                        padding: EdgeInsets.all(24.w),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.08),
                              offset: Offset(0, 4.h),
                              blurRadius: 20.r,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80.w,
                              height: 80.w,
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.error_outline_rounded,
                                size: 40.sp,
                                color: AppColors.error,
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              'Oops! Something went wrong',
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              provider.errorMessage,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 24.h),
                            ElevatedButton(
                              onPressed: _handleRefresh,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 32.w,
                                  vertical: 14.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.refresh_rounded, size: 20.sp),
                                  SizedBox(width: 8.w),
                                  const Text('Try Again'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (provider.notifications.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120.w,
                            height: 120.w,
                            decoration: BoxDecoration(
                              color: AppColors.grey200.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.notifications_none_rounded,
                              size: 60.sp,
                              color: AppColors.textSecondary.withOpacity(0.5),
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            'No notifications yet',
                            style: TextStyle(
                              fontSize: 20.sp,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "We'll notify you when something arrives",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final groupedNotifications = _groupNotificationsByDate(
                    provider.notifications,
                  );

                  return RefreshIndicator(
                    onRefresh: _handleRefresh,
                    color: AppColors.primary,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.only(
                        left: 16.w,
                        top: 12.h,
                        bottom: 12.h + MediaQuery.of(context).padding.bottom,
                        right: 16.w,
                      ),
                      itemCount:
                          groupedNotifications.length +
                          (provider.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == groupedNotifications.length) {
                          return Padding(
                            padding: EdgeInsets.all(20.h),
                            child: Center(
                              child: SizedBox(
                                width: 30.w,
                                height: 30.w,
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: 3.w,
                                ),
                              ),
                            ),
                          );
                        }

                        final groupKey = groupedNotifications.keys.elementAt(
                          index,
                        );
                        final notifications = groupedNotifications[groupKey]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Group Header
                            Padding(
                              padding: EdgeInsets.only(
                                left: 4.w,
                                top: index == 0 ? 0 : 16.h,
                                bottom: 12.h,
                              ),
                              child: Text(
                                groupKey,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),

                            // Notifications in this group
                            ...notifications.map(
                              (notification) => Padding(
                                padding: EdgeInsets.only(bottom: 8.h),
                                child: _NotificationCard(
                                  notification: notification,
                                  onTap: () {
                                    // Handle tap if needed
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  Future<void> _markAsRead(BuildContext context) async {
    try {
      await context.read<NotificationProvider>().markNotificationAsRead(
        notification.id,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'normal':
        return Icons.notifications_rounded;
      case 'urgent':
        return Icons.priority_high_rounded;
      case 'reminder':
        return Icons.access_time_rounded;
      case 'fee_payment':
        return Icons.payment_rounded;
      case 'attendance':
        return Icons.calendar_today_rounded;
      case 'result':
        return Icons.assignment_rounded;
      case 'announcement':
        return Icons.campaign_rounded;
      case 'general':
        return Icons.info_rounded;
      case 'admin_notification':
        return Icons.admin_panel_settings_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  Color _getColorByType(String type) {
    switch (type.toLowerCase()) {
      case 'reminder':
        return AppColors.primary;
      case 'fee_payment':
        return AppColors.error;
      case 'attendance':
        return AppColors.success;
      case 'result':
        return AppColors.info;
      case 'announcement':
        return AppColors.warning;
      case 'urgent':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }

  String _getCategoryName() {
    try {
      if (notification.data != null &&
          notification.data!['category_name'] != null) {
        return notification.data!['category_name'];
      }
    } catch (e) {
      // Fallback if data is not available
    }
    return notification.type.isNotEmpty ? notification.type : 'General';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorByType(notification.type);
    final categoryName = _getCategoryName();

    return Container(
      decoration: BoxDecoration(
        color: notification.isRead
            ? AppColors.surfaceLight
            : color.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: notification.isRead
              ? AppColors.grey200.withOpacity(0.6)
              : color.withOpacity(0.15),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: notification.isRead
                ? AppColors.grey200.withOpacity(0.3)
                : color.withOpacity(0.05),
            offset: Offset(0, 2.h),
            blurRadius: 8.r,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Container with Category
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.15),
                        color.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    _getCategoryIcon(categoryName),
                    color: color,
                    size: 24.sp,
                  ),
                ),

                SizedBox(width: 12.w),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Timestamp Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    notification.title,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: notification.isRead
                                          ? FontWeight.w600
                                          : FontWeight.bold,
                                      color: AppColors.textPrimary,
                                      letterSpacing: -0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (!notification.isRead) ...[
                                  SizedBox(width: 6.w),
                                  Container(
                                    width: 8.w,
                                    height: 8.w,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),

                          Text(
                            timeago.format(notification.createdAt),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textSecondary.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 6.h),

                      ExpandableText(
                        notification.message,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                          height: 1.4,
                          letterSpacing: -0.1,
                        ),
                        maxLines: 2,
                        expandText: 'Read more',
                        collapseText: 'Show less',
                        linkColor: AppColors.primary,
                        linkStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                        expandOnTextTap: true,
                        collapseOnTextTap: true,
                        animation: true,
                      ),

                      SizedBox(height: 8.h),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Category Tag
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              categoryName,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: color,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),

                          // Mark as Read Button
                          if (!notification.isRead)
                            InkWell(
                              onTap: () => _markAsRead(context),
                              borderRadius: BorderRadius.circular(8.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: color.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_rounded,
                                      size: 14.sp,
                                      color: color,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'Mark as read',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: color,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
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
          ),
        ),
      ),
    );
  }
}
