import 'package:flutter/foundation.dart';

import '../../../core/network/token_storage.dart';
import '../models/chat_user_model.dart';
import '../models/conversation_model.dart';
import '../services/activity_service.dart';
import '../services/chat_service.dart';
import '../services/conversations_service.dart';
import '../services/user_lookup_service.dart';

class ConversationsProvider extends ChangeNotifier {
  final ConversationsService _service = ConversationsService();
  final UserLookupService _userLookupService = UserLookupService();
  final ActivityService _activityService = ActivityService();

  // Socket for real-time updates
  ChatService? _chatService;
  int? _currentUserId;
  bool _isSocketConnected = false;

  // Track locally read conversations (persists across API refreshes)
  final Set<int> _locallyReadConversations = {};

  List<Conversation> _conversations = [];
  bool _isLoading = false;
  String? _error;

  List<Conversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasConversations => _conversations.isNotEmpty;
  bool get isSocketConnected => _isSocketConnected;

  /// Get total unread count across all conversations
  int get totalUnreadCount {
    return _conversations.fold<int>(0, (sum, conv) => sum + conv.unreadCount);
  }

  /// Initialize socket for real-time updates
  Future<void> initializeSocket(int currentUserId) async {
    if (_chatService != null &&
        _isSocketConnected &&
        _currentUserId == currentUserId) {
      debugPrint('⚠️ Socket already connected for conversations');
      return;
    }

    _currentUserId = currentUserId;

    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        debugPrint('❌ No token for conversations socket');
        return;
      }

      // Dispose old socket if exists
      _chatService?.dispose();

      _chatService = ChatService(token: token, userId: currentUserId);

      // Set up callbacks for real-time updates
      _chatService!.onConnectionStatusChanged = (bool connected) {
        _isSocketConnected = connected;
        debugPrint('📡 Conversations socket connected: $connected');
        notifyListeners();
      };

      _chatService!.onUserActive = (Map<String, dynamic> data) {
        _handleUserActiveRealtime(data);
      };

      _chatService!.onMessagesSeen = (Map<String, dynamic> data) {
        _handleMessagesSeenRealtime(data);
      };

      _chatService!.onMessageReceived = (Map<String, dynamic> data) {
        _handleNewMessageRealtime(data);
      };

      _chatService!.connect();
      debugPrint('🔌 Conversations socket connecting...');
    } catch (e) {
      debugPrint('❌ Error initializing conversations socket: $e');
    }
  }

  /// Pause socket (disconnect but keep user ID for resuming later)
  /// Call this when entering chat screen to avoid socket conflicts
  void pauseSocket() {
    debugPrint('⏸️ Pausing conversations socket');
    _chatService?.disconnect();
    _isSocketConnected = false;
  }

  /// Resume socket connection after pausing
  /// Call this when leaving chat screen
  Future<void> resumeSocket() async {
    if (_currentUserId != null) {
      debugPrint('▶️ Resuming conversations socket');
      await initializeSocket(_currentUserId!);
    }
  }

  /// Soft reset for app updates
  Future<void> softReset() async {
    debugPrint('🔄 executing ConversationsProvider softReset()');

    // Disconnect socket
    _chatService?.dispose();
    _chatService = null;
    _isSocketConnected = false;

    // Clear lists
    _conversations = [];
    _locallyReadConversations.clear();

    // Reset state
    _isLoading = false;
    _error = null;
    // We do NOT clear _currentUserId here because we want to be able to reconnect
    // easily if fetchConversations is called shortly after.

    notifyListeners();
  }

  /// Check connection and reconnect if needed (e.g. on app resume)
  Future<void> checkConnection() async {
    if (_currentUserId != null && !_isSocketConnected) {
      debugPrint('🔄 Checking conversations socket connection...');
      await initializeSocket(_currentUserId!);
    }
  }

  /// Handle real-time user activity updates
  void _handleUserActiveRealtime(Map<String, dynamic> data) {
    try {
      final userId = int.tryParse(data['user_id'].toString());
      final isActive = data['is_active'] as bool? ?? false;

      if (userId == null) return;

      final index = _conversations.indexWhere((c) => c.userId == userId);
      if (index != -1) {
        DateTime? lastSeen;
        if (data['last_seen'] != null) {
          lastSeen = DateTime.parse(data['last_seen'] as String);
        } else if (!isActive) {
          lastSeen = DateTime.now();
        }

        _conversations[index] = _conversations[index].copyWith(
          isOnline: isActive,
          lastSeen: lastSeen,
        );
        debugPrint('🟢 RT: User $userId isOnline=$isActive');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error handling user_active RT: $e');
    }
  }

  /// Handle real-time messages seen updates
  void _handleMessagesSeenRealtime(Map<String, dynamic> data) {
    try {
      final userId = int.tryParse(
        data['user_id'].toString(),
      ); // The user who SAW the messages

      if (userId == null) return;

      // If the user who saw messages is in our conversations, update lastMessageSeen
      final index = _conversations.indexWhere((c) => c.userId == userId);
      if (index != -1) {
        // Only update if last message was sent by us
        if (_conversations[index].lastMessageSentByMe) {
          _conversations[index] = _conversations[index].copyWith(
            lastMessageSeen: true,
          );
          debugPrint('👁️ RT: User $userId saw our message');
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('❌ Error handling messages_seen RT: $e');
    }
  }

  /// Handle real-time new message received
  void _handleNewMessageRealtime(Map<String, dynamic> data) {
    try {
      final fromUserId = int.tryParse(data['from_user_id'].toString());
      final toUserId = int.tryParse(data['to_user_id'].toString());
      final message = data['message'] as String?;

      debugPrint(
        '📨 RT Message: from=$fromUserId, to=$toUserId, currentUser=$_currentUserId',
      );

      if (fromUserId == null || message == null) return;

      // Determine the other user ID (the one we're chatting with)
      final otherUserId = fromUserId == _currentUserId ? toUserId : fromUserId;
      if (otherUserId == null) return;

      debugPrint('👤 Conversation will be with userId=$otherUserId');

      // START REFINE: Better handling of messages
      final isSentByMe = fromUserId == _currentUserId;

      // Update local state
      updateLastMessage(
        otherUserId,
        message,
        DateTime.now(),
        isSentByMe: isSentByMe,
        isSeen: false,
      );

      // If it's a new conversation (not in list), fetch it
      final index = _conversations.indexWhere((c) => c.userId == otherUserId);
      if (index == -1) {
        debugPrint('🆕 RT: New conversation with $otherUserId detected');
        _fetchAndAddNewConversation(otherUserId);
      }
    } catch (e) {
      debugPrint('❌ Error handling new message RT: $e');
    }
  }

  /// Manually update the last message of a conversation (e.g. when sending from ChatScreen)
  void updateLastMessage(
    int otherUserId,
    String message,
    DateTime time, {
    bool isSentByMe = true,
    bool isSeen = false,
    String? otherUserName,
    String? otherUserImage,
  }) {
    final index = _conversations.indexWhere((c) => c.userId == otherUserId);
    if (index != -1) {
      // If receiving a new message from them, remove from locally read set
      if (!isSentByMe) {
        _locallyReadConversations.remove(otherUserId);
      }

      int newUnreadCount = _conversations[index].unreadCount;
      if (!isSentByMe) {
        newUnreadCount += 1;
      }

      _conversations[index] = _conversations[index].copyWith(
        lastMessage: message,
        lastMessageTime: time,
        lastMessageSentByMe: isSentByMe,
        lastMessageSeen: isSeen,
        unreadCount: newUnreadCount,
      );

      // Re-sort conversations
      _conversations.sort((a, b) {
        if (a.lastMessageTime == null) return 1;
        if (b.lastMessageTime == null) return -1;
        return b.lastMessageTime!.compareTo(a.lastMessageTime!);
      });

      debugPrint('💬 Updated last message for user $otherUserId');
      notifyListeners();
    } else {
      // Create new conversation optimistically if user details are provided
      if (otherUserName != null) {
        debugPrint('🆕 Creating new optimistic conversation for $otherUserId');
        final newConversation = Conversation(
          userId: otherUserId,
          userName: otherUserName,
          userImage: otherUserImage,
          lastMessage: message,
          lastMessageTime: time,
          unreadCount: 0, // Sent by me, so 0 unread
          lastMessageSentByMe: isSentByMe,
          lastMessageSeen: isSeen,
          isOnline: false, // Don't know yet
        );

        _conversations.insert(0, newConversation);
        notifyListeners();
      }
    }
  }

  /* 
   * original _handleNewMessageRealtime logic was partly duplicated. 
   * I replaced the body with a call to updateLastMessage and the fetch logic.
   * Below is keeping the rest of the file intact.
   */

  /// Fetch a specific conversation and add it to the list
  Future<void> _fetchAndAddNewConversation(int otherUserId) async {
    if (_currentUserId == null) return;

    _locallyReadConversations.remove(otherUserId);

    try {
      final newConversation = await _service.getConversationWithUser(
        _currentUserId!,
        otherUserId,
      );

      if (newConversation != null) {
        // Check again to avoid race conditions
        final index = _conversations.indexWhere((c) => c.userId == otherUserId);
        if (index == -1) {
          // Fetch user details immediately (in parallel if possible, or just await)
          ChatUser? user;
          try {
            // Try to get from cache first or fetch
            final usersMap = await _userLookupService.getUsersByIds([
              otherUserId,
            ]);
            user = usersMap[otherUserId];
          } catch (e) {
            debugPrint(
              '⚠️ Error fetching user details for new conversation: $e',
            );
          }

          if (user != null) {
            final updatedConversation = newConversation.copyWith(
              userName: user.name,
              userImage: user.imageUrl,
            );
            _conversations.insert(0, updatedConversation);
          } else {
            _conversations.insert(0, newConversation);
          }

          // Remove from locally read if it exists (fresh start)
          // _locallyReadConversations.remove(otherUserId);

          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('❌ Error adding new conversation: $e');
    }
  }

  /// Fetch conversations for a user
  Future<void> fetchConversations(
    int userId, {
    bool forceRefresh = false,
  }) async {
    // Smart Caching:
    // If we have data and it's not a forced refresh, don't show loading spinner.
    // Just fetch in background.
    if (forceRefresh || _conversations.isEmpty) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      debugPrint(
        '🔄 Fetching conversations for user $userId (Background: ${!_isLoading})',
      );
      final fetchedConversations = await _service.getConversations(userId);
      _conversations = fetchedConversations;
      debugPrint('✅ Loaded ${_conversations.length} conversations');

      // PRE-FETCH: Load user details from cache immediately (Synchronous-like speed)
      // This is crucial to prevent "User ID" flash (FOUC)
      await _fetchUserDetails();

      _isLoading = false;
      notifyListeners(); // First UI paint: Names should be visible now

      // Apply locally read status
      _applyLocallyReadStatus();

      // Background: Fetch activity status for each user
      _fetchActivityStatus();

      // Background: Initialize socket for real-time updates
      initializeSocket(userId);

      _error = null;
    } catch (e) {
      debugPrint('❌ Error loading conversations: $e');
      if (_conversations.isEmpty) {
        _error = e.toString();
        _conversations = [];
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Fetch user details (names and images) for all conversations
  Future<void> _fetchUserDetails() async {
    if (_conversations.isEmpty) return;

    // Get unique user IDs
    final userIds = _conversations.map((c) => c.userId).toSet().toList();
    debugPrint('🔍 Fetching details for ${userIds.length} users: $userIds');

    // Debug: Show each conversation's user ID
    for (var conv in _conversations) {
      debugPrint(
        '  📋 Conversation userId: ${conv.userId}, current userName: ${conv.userName}',
      );
    }

    // Fetch all users
    final users = await _userLookupService.getUsersByIds(userIds);

    debugPrint('🟨 Users fetched: $users');

    // Debug: Show what was fetched for each user ID
    for (var userId in userIds) {
      final user = users[userId];
      if (user != null) {
        debugPrint('  ✅ User $userId: ${user.name} (avatar: ${user.imageUrl})');
      } else {
        debugPrint('  ❌ User $userId: NOT FOUND');
      }
    }

    // Update conversations with user details
    _conversations = _conversations.map((conversation) {
      final user = users[conversation.userId];
      if (user != null) {
        // debugPrint('🟨 User Name ----- ${user.name}');
        return conversation.copyWith(
          userName: user.name,
          userImage: user.imageUrl,
        );
      } else {
        // User not found (404) or deleted
        // Update name to "Unknown User" so that shimmer stops (UI checks for "User X")
        return conversation.copyWith(
          userName: 'Unknown User',
          userImage: null, // Ensure no image
        );
      }
    }).toList();

    debugPrint('✅ Updated ${users.length} user details');
  }

  /// Fetch activity status for all users
  Future<void> _fetchActivityStatus() async {
    if (_conversations.isEmpty) return;

    debugPrint(
      '🟢 Fetching activity status for ${_conversations.length} users',
    );

    // Fetch activity for each user (in parallel)
    final futures = _conversations.map((c) async {
      try {
        final activity = await _activityService.getUserActivity(c.userId);
        if (activity != null) {
          return c.copyWith(
            isOnline: activity.isActive,
            lastSeen: activity.lastSeen,
          );
        }
      } catch (e) {
        debugPrint('⚠️ Error fetching activity for user ${c.userId}: $e');
      }
      return c;
    });

    _conversations = await Future.wait(futures);
    debugPrint('✅ Activity status updated');
  }

  /// Apply locally tracked read status to prevent old unread counts
  void _applyLocallyReadStatus() {
    for (int i = 0; i < _conversations.length; i++) {
      if (_locallyReadConversations.contains(_conversations[i].userId)) {
        _conversations[i] = _conversations[i].copyWith(unreadCount: 0);
      }
    }
  }

  /// Refresh conversations
  Future<void> refresh(int userId) async {
    return fetchConversations(userId, forceRefresh: true);
  }

  /// Clear conversations and disconnect socket
  void clear() {
    _chatService?.dispose();
    _chatService = null;
    _isSocketConnected = false;
    _conversations = [];
    _locallyReadConversations.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Update user online status
  void updateUserOnlineStatus(int userId, bool isOnline, {DateTime? lastSeen}) {
    final index = _conversations.indexWhere((c) => c.userId == userId);
    if (index != -1) {
      _conversations[index] = _conversations[index].copyWith(
        isOnline: isOnline,
        lastSeen: lastSeen ?? (isOnline ? null : DateTime.now()),
      );
      notifyListeners();
    }
  }

  /// Mark conversation as read (reset unread count and notify server)
  void markConversationAsRead(int userId) {
    debugPrint('📖 markConversationAsRead called for userId: $userId');
    final index = _conversations.indexWhere((c) => c.userId == userId);

    if (index == -1) {
      debugPrint('⚠️ Conversation not found for userId: $userId');
      return;
    }

    final currentUnread = _conversations[index].unreadCount;
    debugPrint('📖 Current unread count for $userId: $currentUnread');

    // Always call server to mark messages as seen (even if local count is 0)
    // This ensures server-side state is updated
    if (_chatService != null && _isSocketConnected) {
      _chatService!.markSeen(userId);
      debugPrint('📖 Called markSeen via socket for $userId');
    } else {
      // Fallback: Use REST API when socket is not connected
      _markAsSeenViaApi(userId);
      debugPrint('📖 Called markSeen via REST API for $userId');
    }

    // Update local state if there are unread messages
    if (currentUnread > 0) {
      _conversations[index] = _conversations[index].copyWith(unreadCount: 0);
      _locallyReadConversations.add(userId);
      debugPrint('📖 Updated local unread count to 0 for $userId');
      notifyListeners();
    } else {
      // Still add to locally read set to prevent future API overwrites
      _locallyReadConversations.add(userId);
    }
  }

  /// Mark messages as seen via REST API (fallback when socket is unavailable)
  Future<void> _markAsSeenViaApi(int userId) async {
    try {
      debugPrint('🌐 Calling markMessagesAsSeen API for userId: $userId');
      final success = await _activityService.markMessagesAsSeen(userId);
      debugPrint('🌐 markMessagesAsSeen API result: $success');
    } catch (e) {
      debugPrint('❌ Error marking messages as seen via API: $e');
    }
  }

  /// Update conversation with user name (can be called after fetching user details)
  void updateConversationUserName(int userId, String userName) {
    final index = _conversations.indexWhere((c) => c.userId == userId);
    if (index != -1) {
      _conversations[index] = _conversations[index].copyWith(
        userName: userName,
      );
      notifyListeners();
    }
  }

  /// Update conversation with user image
  void updateConversationUserImage(int userId, String? userImage) {
    final index = _conversations.indexWhere((c) => c.userId == userId);
    if (index != -1) {
      _conversations[index] = _conversations[index].copyWith(
        userImage: userImage,
      );
      notifyListeners();
    }
  }

  /// Get user info for a specific conversation (for passing to chat screen)
  Conversation? getConversation(int userId) {
    final index = _conversations.indexWhere((c) => c.userId == userId);
    return index != -1 ? _conversations[index] : null;
  }

  @override
  void dispose() {
    _chatService?.dispose();
    super.dispose();
  }
}
