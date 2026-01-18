import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../shared/utils/app_colors.dart';
import '../models/chat_message_model.dart';
import '../providers/chat_background_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/conversations_provider.dart'; // Added
import '../widgets/chat_shimmer.dart';
import '../widgets/connection_status_bar.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input_field.dart';
import '../widgets/typing_indicator.dart';
import 'chat_background_selection_screen.dart';

class ChatScreen extends StatefulWidget {
  final int otherUserId;
  final String otherUserName;
  final String? otherUserImage;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserImage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().initialize(
        otherUserId: widget.otherUserId,
        otherUserName: widget.otherUserName,
        otherUserImage: widget.otherUserImage,
      );
    });

    // Setup scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    context.read<ChatProvider>().cleanup();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      context.read<ChatProvider>().loadMoreMessages();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: _buildAppBar(isDark),
      body: Consumer2<ChatProvider, ChatBackgroundProvider>(
        builder: (context, chatProvider, bgProvider, _) {
          return Container(
            decoration: bgProvider.getBackgroundDecoration(),
            child: Stack(
              children: [
                // Pattern overlay
                if (bgProvider.getPatternEmoji() != null)
                  _buildPatternOverlay(bgProvider.getPatternEmoji()!),

                // Main content
                Column(
                  children: [
                    // Connection status
                    ConnectionStatusBar(
                      isConnected: chatProvider.isConnected,
                      errorMessage: chatProvider.error,
                      onRetry: () => chatProvider.reconnect(),
                    ),

                    // Messages
                    Expanded(
                      child:
                          chatProvider.isLoading &&
                              chatProvider.messages.isEmpty
                          ? const ChatShimmer()
                          : _buildMessagesList(chatProvider),
                    ),

                    // Typing indicator
                    TypingIndicator(
                      isTyping: chatProvider.isOtherUserTyping,
                      userName: widget.otherUserName.split(' ').first,
                    ),

                    // Input field
                    MessageInputField(
                      enabled: chatProvider.isConnected,
                      onSendMessage: (text) {
                        chatProvider.sendMessage(text);
                        _scrollToBottom();
                        
                        // Update Conversations List Realtime (Optimistic)
                        context.read<ConversationsProvider>().updateLastMessage(
                          otherUserId: widget.otherUserId,
                          message: text,
                          time: DateTime.now(),
                          sentByMe: true,
                        );
                      },
                      onTyping: (isTyping) {
                        chatProvider.sendTyping(isTyping);
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textPrimary,
      elevation: 0.5,
      titleSpacing: 0,
      title: Consumer<ChatProvider>(
        builder: (context, provider, _) {
          return Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 18.r,
                backgroundColor: Colors.white.withOpacity(0.3),
                backgroundImage: widget.otherUserImage != null
                    ? NetworkImage(widget.otherUserImage!)
                    : null,
                child: widget.otherUserImage == null
                    ? Text(
                        widget.otherUserName.isNotEmpty
                            ? widget.otherUserName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 10.w),

              // Name and status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.otherUserName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      provider.isOtherUserOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: provider.isOtherUserOnline
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        // Background customization
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ChatBackgroundSelectionScreen(),
              ),
            );
          },
          icon: const Icon(Icons.wallpaper_outlined),
          tooltip: 'Change background',
        ),
      ],
    );
  }

  Widget _buildPatternOverlay(String emoji) {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.08,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            mainAxisSpacing: 20.w,
            crossAxisSpacing: 20.w,
          ),
          itemBuilder: (context, index) {
            return Center(
              child: Text(emoji, style: TextStyle(fontSize: 24.sp)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessagesList(ChatProvider provider) {
    final messages = provider.messages;

    if (messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
      itemCount: messages.length + (provider.hasMoreMessages ? 1 : 0),
      itemBuilder: (context, index) {
        // Loading indicator at top
        if (index == messages.length) {
          return Container(
            padding: EdgeInsets.all(16.h),
            alignment: Alignment.center,
            child: SizedBox(
              width: 24.w,
              height: 24.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          );
        }

        // Messages in reverse order
        final reversedIndex = messages.length - 1 - index;
        final message = messages[reversedIndex];
        final isMe = _isMyMessage(message, provider);

        // Grouping logic
        final isFirstInGroup =
            reversedIndex == 0 ||
            _isMyMessage(messages[reversedIndex - 1], provider) != isMe ||
            _isNewTimeGroup(messages[reversedIndex - 1], message);

        final isLastInGroup =
            reversedIndex == messages.length - 1 ||
            _isMyMessage(messages[reversedIndex + 1], provider) != isMe ||
            _isNewTimeGroup(message, messages[reversedIndex + 1]);

        return Column(
          children: [
            // Date separator
            if (isFirstInGroup &&
                _shouldShowDateSeparator(messages, reversedIndex))
              _buildDateSeparator(message.createdAt),

            MessageBubble(
              message: message,
              isMe: isMe,
              isFirstInGroup: isFirstInGroup,
              isLastInGroup: isLastInGroup,
              showTimestamp: isLastInGroup,
            ),
          ],
        );
      },
    );
  }

  bool _isMyMessage(ChatMessage message, ChatProvider provider) {
    // We check if the message was sent by the current user
    return message.fromUserId != widget.otherUserId;
  }

  bool _isNewTimeGroup(ChatMessage prev, ChatMessage curr) {
    return curr.createdAt.difference(prev.createdAt).inMinutes > 5;
  }

  bool _shouldShowDateSeparator(List<ChatMessage> messages, int index) {
    if (index == 0) return true;

    final prevMessage = messages[index - 1];
    final currMessage = messages[index];

    final prevDate = DateTime(
      prevMessage.createdAt.year,
      prevMessage.createdAt.month,
      prevMessage.createdAt.day,
    );
    final currDate = DateTime(
      currMessage.createdAt.year,
      currMessage.createdAt.month,
      currMessage.createdAt.day,
    );

    return prevDate != currDate;
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    String text;
    if (messageDate == today) {
      text = 'Today';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      text = 'Yesterday';
    } else {
      text = '${date.day}/${date.month}/${date.year}';
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 12.h),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
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
            size: 60.sp,
            color: AppColors.grey300,
          ),
          SizedBox(height: 12.h),
          Text(
            'No messages yet',
            style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 4.h),
          Text(
            'Send a message to start chatting',
            style: TextStyle(fontSize: 13.sp, color: AppColors.grey400),
          ),
        ],
      ),
    );
  }
}
