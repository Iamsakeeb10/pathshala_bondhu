// ============================================
// UPDATED ChatScreen (chat_screen.dart)
// ============================================
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/network/token_storage.dart';
import '../../../shared/utils/app_colors.dart';
import '../providers/chat_background_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/conversations_provider.dart';
import '../widgets/chat_shimmer.dart';
import '../widgets/connection_status_bar.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input_field.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  final int otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final int? requestId;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    this.requestId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;
  late ChatProvider _chatProvider;
  ConversationsProvider? _conversationsProvider;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add observer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('📱 App resumed - ensuring chat connection...');
      // Use the robust checkConnection which handles reconnection if needed
      _chatProvider.checkConnection();
    }
  }

  Future<void> _initializeChat() async {
    if (_isInitialized) {
      debugPrint('⚠️ Chat already initialized');
      return;
    }

    if (!mounted) return;

    _isInitialized = true;

    try {
      _chatProvider = Provider.of<ChatProvider>(context, listen: false);
      _conversationsProvider = Provider.of<ConversationsProvider>(
        context,
        listen: false,
      );

      // Get current user ID from TokenStorage (returns String?, parse to int)
      final userIdStr = await TokenStorage.getUserId();
      _currentUserId = userIdStr != null ? int.tryParse(userIdStr) : null;

      if (_currentUserId == null) {
        if (mounted) _showError('User not authenticated');
        _isInitialized = false;
        return;
      }

      debugPrint(
        '🎬 Initializing chat for user $_currentUserId with ${widget.otherUserId}',
      );

      // Pause conversations socket to avoid conflicts
      _conversationsProvider?.pauseSocket();

      await _chatProvider.initializeChat(
        currentUserId: _currentUserId!,
        otherUserId: widget.otherUserId,
      );

      if (mounted) {
        _conversationsProvider?.markConversationAsRead(widget.otherUserId);
      }
    } catch (e) {
      if (mounted) {
        debugPrint('❌ Error initializing chat: $e');
        _showError('Failed to initialize chat');
      }
      _isInitialized = false;
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    debugPrint('🗑️ ChatScreen disposing');
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();

    if (_isInitialized) {
      _chatProvider.disconnect();

      // Resume conversations socket after leaving chat
      _conversationsProvider?.resumeSocket();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: Column(
        children: [
          buildChatAppBar(context),
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                if (chatProvider.isConnected &&
                    chatProvider.messages.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    chatProvider.markMessagesAsSeen();
                  });
                }

                return Column(
                  children: [
                    // Connection status bar
                    ConnectionStatusBar(
                      isConnected: chatProvider.isConnected,
                      errorMessage: chatProvider.errorMessage,
                      onRetry: chatProvider.retryConnection,
                    ),

                    // Messages list with custom background
                    Expanded(
                      child: Stack(
                        children: [
                          Consumer<ChatBackgroundProvider>(
                            builder: (context, bgProvider, _) {
                              return bgProvider.buildBackground(
                                child: Builder(
                                  builder: (context) {
                                    if (chatProvider.isLoadingMessages &&
                                        chatProvider.messages.isEmpty) {
                                      return const ChatShimmer();
                                    }

                                    if (chatProvider.messages.isEmpty) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(32.r),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    AppColors.primary
                                                        .withOpacity(0.1),
                                                    AppColors.primaryDark
                                                        .withOpacity(0.05),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons
                                                    .chat_bubble_outline_rounded,
                                                size: 64.sp,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            SizedBox(height: 24.h),
                                            Text(
                                              'No messages yet',
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    color: isDark
                                                        ? AppColors.textDark
                                                        : AppColors.textPrimary,
                                                  ),
                                            ),
                                            SizedBox(height: 8.h),
                                            Text(
                                              'Start the conversation with ${widget.otherUserName}!',
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    color: isDark
                                                        ? AppColors
                                                              .textDarkSecondary
                                                        : AppColors
                                                              .textSecondary,
                                                  ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    // Pagination Listener
                                    _scrollController.addListener(() {
                                      if (_scrollController.position.pixels >=
                                          _scrollController
                                                  .position
                                                  .maxScrollExtent -
                                              200) {
                                        chatProvider.loadMoreMessages();
                                      }
                                    });

                                    return ListView.builder(
                                      controller: _scrollController,
                                      reverse: true, // Start from bottom
                                      padding: EdgeInsets.only(
                                        top: 8.h,
                                        bottom: 60.h,
                                      ), // Extra bottom padding for typing indicator
                                      itemCount:
                                          chatProvider.messages.length +
                                          (chatProvider.isLoadingMessages
                                              ? 1
                                              : 0),
                                      itemBuilder: (context, index) {
                                        if (index ==
                                            chatProvider.messages.length) {
                                          return const Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child:
                                                  CircularProgressIndicator.adaptive(),
                                            ),
                                          );
                                        }

                                        final message =
                                            chatProvider.messages[index];
                                        final isMine =
                                            _currentUserId != null &&
                                            message.fromUserId ==
                                                _currentUserId;

                                        bool isLastInGroup = false;
                                        if (index == 0) {
                                          isLastInGroup = true;
                                        } else {
                                          final nextMessage =
                                              chatProvider.messages[index -
                                                  1]; // visually below
                                          if (nextMessage.fromUserId !=
                                              message.fromUserId) {
                                            isLastInGroup = true;
                                          }
                                        }

                                        return MessageBubble(
                                          message: message,
                                          isMe: isMine,
                                          isLastInGroup: isLastInGroup,
                                        );
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                          ),

                          // Typing indicator overlay
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Consumer<ChatProvider>(
                              builder: (context, chatProvider, _) {
                                return TypingIndicator(
                                  userName:
                                      chatProvider.otherUserName ??
                                      widget.otherUserName,
                                  isTyping: chatProvider.isOtherUserTyping,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Message input
                    // Fix: Input always enabled, provider handles queuing
                    MessageInputField(
                      onSendMessage: (message) {
                        final chatProvider = Provider.of<ChatProvider>(
                          context,
                          listen: false,
                        );
                        chatProvider.sendMessage(message);

                        // Update Conversations List Realtime (Optimistic)
                        Provider.of<ConversationsProvider>(
                          context,
                          listen: false,
                        ).updateLastMessage(
                          widget.otherUserId,
                          message,
                          DateTime.now(),
                          otherUserName:
                              chatProvider.otherUserName ??
                              widget.otherUserName,
                          otherUserImage:
                              chatProvider.otherUserImage ??
                              widget.otherUserAvatar,
                        );
                      },
                      onTyping: (isTyping) {
                        Provider.of<ChatProvider>(
                          context,
                          listen: false,
                        ).sendTyping(isTyping);
                      },
                      enabled: true, // Always allow typing
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Custom Facebook-style AppBar for Chat Screen
  Widget buildChatAppBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
            AppColors.primaryDark.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main AppBar Content
            Container(
              height: 56.h,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                children: [
                  // Back Button
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                    padding: EdgeInsets.all(8.w),
                  ),

                  SizedBox(width: 12.w),

                  // User Avatar
                  Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: Consumer<ChatProvider>(
                      builder: (context, chatProvider, _) {
                        final avatarUrl =
                            chatProvider.otherUserImage ??
                            widget.otherUserAvatar;
                        return CircleAvatar(
                          radius: 20.r,
                          backgroundImage: avatarUrl != null
                              ? NetworkImage(avatarUrl)
                              : null,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: avatarUrl == null
                              ? Text(
                                  (chatProvider.otherUserName ??
                                          widget.otherUserName)
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        );
                      },
                    ),
                  ),

                  SizedBox(width: 8.w),

                  // User Name and Status
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer<ChatProvider>(
                          builder: (context, chatProvider, _) {
                            return Text(
                              chatProvider.otherUserName ??
                                  widget.otherUserName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                        SizedBox(height: 2.h),
                        // Activity Status using UserActivityStatus widget
                        Consumer<ChatProvider>(
                          builder: (context, chatProvider, _) {
                            if (chatProvider.otherUserActivity == null) {
                              return const SizedBox.shrink();
                            }

                            return Transform.translate(
                              offset: Offset(-10.w, 0),
                              child: UserActivityStatus(
                                isActive:
                                    chatProvider.otherUserActivity!.isActive,
                                lastSeen:
                                    chatProvider.otherUserActivity!.lastSeen,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Wallpaper Button
                  IconButton(
                    onPressed: () => context.push('/chat-background'),
                    icon: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.wallpaper_outlined,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                    padding: EdgeInsets.all(4.w),
                  ),

                  SizedBox(width: 4.w),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// UPDATED User Activity Status Widget
// ============================================

class UserActivityStatus extends StatelessWidget {
  final bool isActive;
  final DateTime? lastSeen;

  const UserActivityStatus({
    super.key,
    required this.isActive,
    required this.lastSeen,
  });

  String _formatLastSeen() {
    if (lastSeen == null) return 'Offline';

    final now = DateTime.now();
    final difference = now.difference(lastSeen!);

    if (difference.inMinutes < 1) {
      return 'Active just now';
    } else if (difference.inMinutes < 60) {
      return 'Active ${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return 'Active ${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Active yesterday';
    } else if (difference.inDays < 7) {
      return 'Active ${difference.inDays}d ago';
    } else {
      return 'Offline';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Status indicator dot
        Container(
          width: 6.w,
          height: 6.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFF31A24C) : Colors.white60,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF31A24C).withOpacity(0.4),
                      blurRadius: 4.r,
                      spreadRadius: 1.r,
                    ),
                  ]
                : null,
          ),
        ),
        SizedBox(width: 5.w),
        // Status text
        Text(
          isActive ? 'Active now' : _formatLastSeen(),
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white.withOpacity(0.85),
            fontWeight: FontWeight.w400,
            letterSpacing: 0.1,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

// ============================================
// UPDATED Message Seen Indicator - Eye Icon Only
// ============================================
class MessageSeenIndicator extends StatefulWidget {
  final bool isSeen;
  final bool isLoading;

  const MessageSeenIndicator({
    super.key,
    required this.isSeen,
    this.isLoading = false,
  });

  @override
  State<MessageSeenIndicator> createState() => _MessageSeenIndicatorState();
}

class _MessageSeenIndicatorState extends State<MessageSeenIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    if (widget.isSeen) {
      _scaleController.forward();
    }
  }

  @override
  void didUpdateWidget(MessageSeenIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSeen && !oldWidget.isSeen) {
      _scaleController.forward();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 12.w, bottom: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isLoading)
            SizedBox(
              width: 14.sp,
              height: 14.sp,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation(
                  AppColors.textSecondary.withOpacity(0.5),
                ),
              ),
            )
          else if (widget.isSeen)
            ScaleTransition(
              scale: CurvedAnimation(
                parent: _scaleController,
                curve: Curves.easeOutBack,
              ),
              child: Icon(
                Icons.visibility_rounded,
                size: 16.sp,
                color: const Color(0xFF0084FF),
              ),
            )
          else
            Icon(
              Icons.check_rounded,
              size: 16.sp,
              color: AppColors.textSecondary.withOpacity(0.4),
            ),
        ],
      ),
    );
  }
}
