import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../shared/utils/app_colors.dart';
import '../models/conversation_model.dart';
import '../providers/conversations_provider.dart';
import '../widgets/conversations_shimmer.dart';
import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConversationsProvider>().initialize();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final provider = context.read<ConversationsProvider>();
    if (state == AppLifecycleState.paused) {
      provider.pause();
    } else if (state == AppLifecycleState.resumed) {
      provider.resume();
    }
  }

  List<Conversation> _getFilteredConversations(List<Conversation> conversations) {
    if (_searchQuery.isEmpty) return conversations;

    return conversations.where((c) {
      return c.userName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          Consumer<ConversationsProvider>(
            builder: (context, provider, _) {
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Icon(
                  provider.isConnected ? Icons.cloud_done : Icons.cloud_off,
                  color: provider.isConnected
                      ? AppColors.success
                      : AppColors.grey400,
                  size: 20.sp,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: EdgeInsets.all(12.w),
            color: isDark ? AppColors.surfaceDark : Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                prefixIcon: Icon(Icons.search, color: AppColors.grey400),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: AppColors.grey400),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? AppColors.grey700 : AppColors.grey100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ),

          // Conversations list
          Expanded(
            child: Consumer<ConversationsProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.conversations.isEmpty) {
                  return const ConversationsShimmer();
                }

                if (provider.error != null && provider.conversations.isEmpty) {
                  return _buildErrorState(provider);
                }

                final conversations = _getFilteredConversations(provider.conversations);

                if (conversations.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchConversations(),
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      return _buildConversationItem(
                        conversations[index],
                        provider,
                        isDark,
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

  Widget _buildConversationItem(
    Conversation conversation,
    ConversationsProvider provider,
    bool isDark,
  ) {
    final user = provider.getUserById(conversation.userId);

    return InkWell(
      onTap: () {
        provider.markAsRead(conversation.userId);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              otherUserId: conversation.userId,
              otherUserName: conversation.userName,
              otherUserImage: user?.imageUrl,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                CircleAvatar(
                  radius: 27.r,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  backgroundImage: user?.imageUrl != null
                      ? NetworkImage(user!.imageUrl!)
                      : null,
                  child: user?.imageUrl == null
                      ? Text(
                          conversation.userName.isNotEmpty
                              ? conversation.userName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
                if (conversation.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14.w,
                      height: 14.w,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12.w),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and time
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.userName,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.lastMessageTime != null)
                        Text(
                          _formatTime(conversation.lastMessageTime!),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: conversation.unreadCount > 0
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),

                  // Last message and unread badge
                  Row(
                    children: [
                      if (conversation.lastMessageSentByMe)
                        Padding(
                          padding: EdgeInsets.only(right: 4.w),
                          child: Icon(
                            conversation.lastMessageSeen
                                ? Icons.done_all
                                : Icons.done,
                            size: 14.sp,
                            color: conversation.lastMessageSeen
                                ? Colors.blue
                                : AppColors.grey400,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          conversation.lastMessage ?? 'No messages yet',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: conversation.unreadCount > 0
                                ? (isDark ? Colors.white70 : AppColors.textPrimary)
                                : AppColors.textSecondary,
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (conversation.unreadCount > 0)
                        Container(
                          margin: EdgeInsets.only(left: 8.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            conversation.unreadCount > 99
                                ? '99+'
                                : conversation.unreadCount.toString(),
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 80.sp,
            color: AppColors.grey300,
          ),
          SizedBox(height: 16.h),
          Text(
            _searchQuery.isNotEmpty
                ? 'No conversations found'
                : 'No messages yet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Start a conversation with a teacher or parent',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.grey400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ConversationsProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 60.sp,
            color: AppColors.error,
          ),
          SizedBox(height: 16.h),
          Text(
            'Failed to load conversations',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: () => provider.fetchConversations(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return DateFormat('h:mm a').format(dateTime);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (now.difference(dateTime).inDays < 7) {
      return DateFormat('EEE').format(dateTime);
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }
}
