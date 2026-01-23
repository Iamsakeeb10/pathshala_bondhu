// ============================================
// FIXED ChatProvider (chat_provider.dart)
// ============================================
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/token_storage.dart';
import '../models/chat_message_model.dart';
import '../models/user_activity_model.dart';
import '../services/activity_service.dart';
import '../services/chat_service.dart';
import '../services/user_lookup_service.dart';

enum ChatConnectionStatus {
  initializing,
  disconnected,
  connecting,
  connected,
  error,
}

class ChatProvider extends ChangeNotifier with WidgetsBindingObserver {
  ChatService? _chatService;
  final bool _disposed = false;

  // State
  final List<ChatMessage> _messages = [];

  // Fix: Queue for offline messages
  final List<String> _pendingMessages = [];

  ChatConnectionStatus _connectionStatus = ChatConnectionStatus.initializing;
  String? _errorMessage;
  int? _currentUserId;
  int? _otherUserId;

  // Prevent duplicate initialization
  bool _isInitializing = false;
  bool _isInitialized = false;

  ChatProvider() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _chatService?.dispose();
    _chatService = null;
    _activityPollingTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('📱 App resumed in ChatProvider - checking connection...');
      checkConnection();
    }
  }

  // NEW: Better loading state management
  bool _isLoadingMessages = false;
  bool _hasRequestedHistory = false;
  bool _hasMoreMessages = true; // Pagination control

  // Activity tracking
  UserActivity? _otherUserActivity;
  bool _isOtherUserTyping = false;
  final ActivityService _activityService = ActivityService();

  // Periodic activity polling timer
  Timer? _activityPollingTimer;

  // Retry counter for message history (kept for future use)
  int _historyRetryCount = 0;
  // static const int _maxHistoryRetries = 3;

  // Pagination
  int _currentPage = 1;

  // Getters
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  ChatConnectionStatus get connectionStatus => _connectionStatus;
  String? get errorMessage => _errorMessage;
  bool get isConnected => _connectionStatus == ChatConnectionStatus.connected;
  bool get isConnecting => _connectionStatus == ChatConnectionStatus.connecting;

  // NEW: More accurate loading state
  bool get isLoadingMessages => _isLoadingMessages;

  // Activity getters
  UserActivity? get otherUserActivity => _otherUserActivity;
  bool get isOtherUserTyping => _isOtherUserTyping;
  bool get hasMoreMessages => _hasMoreMessages;

  // NEW: Dynamic user details
  String? _otherUserName;
  String? get otherUserName => _otherUserName;

  String? _otherUserImage;
  String? get otherUserImage => _otherUserImage;

  /// Soft reset for app updates
  /// Disconnects and releases memory state but preserves the instance
  Future<void> softReset() async {
    debugPrint('🔄 executing ChatProvider softReset()');
    disconnect();

    // Clear state
    _messages.clear();
    _pendingMessages.clear();
    _isInitialized = false;
    _isInitializing = false;
    _hasRequestedHistory = false;
    _historyRetryCount = 0;
    _currentUserId = null;
    _otherUserId = null;

    _connectionStatus = ChatConnectionStatus.initializing;
    notifyListeners();
  }

  /// Reconnect to chat service (e.g. on app resume)
  Future<void> reconnect() async {
    debugPrint('🔄 Force Reconnecting chat...');
    if (_currentUserId != null && _otherUserId != null) {
      // Disconnect current instance to force fresh connection
      disconnect();

      await initializeChat(
        currentUserId: _currentUserId!,
        otherUserId: _otherUserId!,
      );
    }
  }

  /// Check and restore connection if needed
  Future<void> checkConnection() async {
    if (_currentUserId != null && _otherUserId != null) {
      debugPrint('🔍 Checking connection status...');

      final token = await TokenStorage.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('❌ Check connection failed: No token');
        return;
      }

      if (_chatService == null || !isConnected) {
        debugPrint('⚠️ Connection lost or null, reconnecting...');
        await reconnect();
      } else {
        debugPrint('✅ Connection valid, refreshing activity/history...');
        _fetchOtherUserActivity();
        // Maybe fetch new messages just in case socket missed something
        _fetchChatUserDetails();
      }
    }
  }

  /// Initialize chat connection
  Future<void> initializeChat({
    required int currentUserId,
    required int otherUserId,
  }) async {
    // Prevent duplicate initialization for the SAME conversation
    if (_isInitializing) {
      debugPrint('⚠️ Already initializing chat, skipping...');
      return;
    }

    // Check if we're initializing the same conversation that's already initialized
    if (_isInitialized &&
        _currentUserId == currentUserId &&
        _otherUserId == otherUserId &&
        isConnected) {
      debugPrint(
        '⚠️ Chat already initialized and connected for this conversation',
      );
      return;
    }

    // Clear messages from memory first, then try to load from persistent cache
    if (_currentUserId != currentUserId || _otherUserId != otherUserId) {
      debugPrint('🧹 Clearing in-memory messages for new conversation');
      _messages.clear();
      _hasRequestedHistory = false;
      _historyRetryCount = 0;
      _currentPage = 1; // Reset page
    }

    _isInitializing = true;
    _currentUserId = currentUserId;
    _otherUserId = otherUserId;

    // LOAD CACHE IMMEDIATELY
    await _loadCachedMessages(otherUserId);

    // After loading cache, check if we have messages to determine loading state
    if (_messages.isNotEmpty) {
      _isLoadingMessages = false;
      notifyListeners();
    } else {
      _isLoadingMessages = true;
    notifyListeners();
    }

    try {
      _connectionStatus = ChatConnectionStatus.connecting;
      _errorMessage = null;
      // notifyListeners(); // Already notified above

      debugPrint(
        '🔄 Initializing chat for user $currentUserId with $otherUserId',
      );

      // Removed old in-memory cache check since we now use persistent cache loaded above

      // Get authentication token
      final token = await TokenStorage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      // Dispose old service if exists
      if (_chatService != null) {
        debugPrint('🧹 Disposing old chat service');
        _chatService!.dispose();
        _chatService = null;
      }

      // Create new ChatService instance
      final chatService = ChatService(token: token, userId: currentUserId);

      // Setup callbacks
      chatService.onConnectionStatusChanged = (bool connected) {
        if (connected) {
          _handleConnected();
        } else {
          _handleDisconnected();
        }
      };

      chatService.onError = (String error) {
        _handleError(error);
      };

      chatService.onMessageReceived = (Map<String, dynamic> messageData) {
        try {
          final message = ChatMessage.fromJson(messageData);
          _handleMessageReceived(message);
        } catch (e) {
          debugPrint('❌ Error parsing received message: $e');
        }
      };

      chatService.onMessageHistoryReceived =
          (List<Map<String, dynamic>> historyData) {
            _handleMessageHistory(historyData);
          };

      chatService.onMessagesSeen = (Map<String, dynamic> data) {
        _handleMessagesSeen(data);
      };

      chatService.onUserTyping = (Map<String, dynamic> data) {
        _handleUserTyping(data);
      };

      chatService.onUserActive = (Map<String, dynamic> data) {
        _handleUserActive(data);
      };

      chatService.onMarkSeenSuccess = (Map<String, dynamic> data) {
        debugPrint('✅ Mark seen confirmed: $data');
      };

      _chatService = chatService;

      // Connect to socket
      debugPrint('🔌 Calling connect() on chat service...');
      _chatService!.connect();

      _isInitialized = true;
      debugPrint('✅ Chat initialization complete, waiting for connection...');
    } catch (e) {
      debugPrint('❌ Failed to initialize chat: $e');
      _connectionStatus = ChatConnectionStatus.error;
      _errorMessage = e.toString();
      _isInitialized = false;
      _isLoadingMessages = false; // Stop loading on error
      notifyListeners();
    } finally {
      _isInitializing = false;
    }
  }

  /// Handle successful connection
  void _handleConnected() {
    debugPrint('✅ Chat connected');
    _connectionStatus = ChatConnectionStatus.connected;
    _errorMessage = null;
    notifyListeners();

    // Request message history when connected (only once)
    if (_otherUserId != null && !_hasRequestedHistory) {
      debugPrint('📚 Requesting message history with user $_otherUserId');
      _hasRequestedHistory = true;
      _requestMessageHistoryWithRetry();

      // Fetch other user's activity status
      _fetchOtherUserActivity();

      // NEW: Fetch user details for dynamic AppBar
      _fetchChatUserDetails();

      // Start periodic activity polling (every 30 seconds)
      _startActivityPolling();

      // Update own activity to active
      if (_currentUserId != null) {
        _activityService.updateUserActivity(_currentUserId!, true);
      }

      // Fix: Process pending offline messages
      _processPendingMessages();
    }
  }

  /// Send any messages queued while offline
  void _processPendingMessages() {
    if (_pendingMessages.isEmpty) return;

    debugPrint('📤 Sending ${_pendingMessages.length} pending messages');
    final pending = List<String>.from(_pendingMessages);
    _pendingMessages.clear();

    for (final msg in pending) {
      // We use the raw service method to avoid re-adding optimistic UI
      if (_otherUserId != null) {
        _chatService?.sendMessage(_otherUserId!, msg);
      }
    }
  }

  /// Request message history (Initial Load via REST)
  Future<void> _requestMessageHistoryWithRetry() async {
    if (_otherUserId == null) return;

    _currentPage = 1;
    // Don't set _isLoadingMessages = true here if it's already set by initializeChat
    // But usually good to ensure UI shows loading
    if (_messages.isEmpty) {
      _isLoadingMessages = true;
      notifyListeners();
    }

    try {
      debugPrint('📜 Fetching initial history via REST for user $_otherUserId');

      final responseMap = await _activityService.getMessages(
        _currentUserId!,
        _otherUserId!,
        page: 1,
        limit: 20,
      );

      if (responseMap != null && responseMap['success'] == true) {
        final List<dynamic> messagesList = responseMap['messages'] ?? [];
        final totalPages = responseMap['total_pages'] as int? ?? 1;
        final hasNext = responseMap['has_next'] as bool? ?? false;

        final List<Map<String, dynamic>> typedHistory = messagesList
            .map((e) => e as Map<String, dynamic>)
            .toList();

        _handleMessageHistory(typedHistory);

        // Update pagination flags
        _hasMoreMessages = hasNext && _currentPage < totalPages;
      } else {
        debugPrint('⚠️ Initial history fetch failed or returned false success');
        _isLoadingMessages = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error fetching initial history: $e');
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  /// Start periodic polling for user activity
  void _startActivityPolling() {
    _stopActivityPolling(); // Cancel any existing timer

    _activityPollingTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _fetchOtherUserActivity(),
    );
    debugPrint('⏰ Started activity polling (every 30s)');
  }

  /// Stop activity polling timer
  void _stopActivityPolling() {
    _activityPollingTimer?.cancel();
    _activityPollingTimer = null;
  }

  /// Handle disconnection
  void _handleDisconnected() {
    debugPrint('🔌 Chat disconnected');
    _connectionStatus = ChatConnectionStatus.disconnected;
          notifyListeners();
        }

  /// Handle received message
  void _handleMessageReceived(ChatMessage message) {
    debugPrint(
      '📨 Message received from ${message.fromUserId}: ${message.message}',
    );

    if ((message.fromUserId == _currentUserId &&
            message.toUserId == _otherUserId) ||
        (message.fromUserId == _otherUserId &&
            message.toUserId == _currentUserId)) {
      // Fix: Better deduplication strategy
      int indexToUpdate = -1;

      // 1. Try to find message by Server ID (if both have ID)
      if (message.id != null && message.id! > 0) {
        indexToUpdate = _messages.indexWhere((m) {
          return m.id == message.id;
        });
      }

      // 2. If not found, try to find Optimistic Message (Self sent, no server ID, matching content)
      if (indexToUpdate == -1 && message.fromUserId == _currentUserId) {
        indexToUpdate = _messages.indexWhere((m) {
          // Check if it looks like an optimistic message (ID is timestamp-like or null)
          // And content matches
          final isOptimistic = (m.id == null || m.id! > 1000000000000);
          // Relaxed time window: 60 seconds (network can be slow)
          final isRecent =
              m.createdAt.difference(message.createdAt).abs().inSeconds < 60;

          return isOptimistic &&
          m.message == message.message &&
              m.fromUserId == _currentUserId &&
              isRecent;
        });
      }

      if (indexToUpdate != -1) {
        // Found existing/optimistic message -> UPDATE it
        debugPrint(
          '🔄 Merging/Updating message index $indexToUpdate with Server ID ${message.id}',
        );
        _messages[indexToUpdate] = message; // Replace with clean server version
        _sortMessages();
          notifyListeners();
          
        // Update persistent cache
        if (_otherUserId != null) {
          _cacheMessages(_otherUserId!);
        }
      } else {
        // New Message -> ADD it
        _messages.add(message);
        _sortMessages();

        // Update persistent cache
        if (_otherUserId != null) {
          _cacheMessages(_otherUserId!);
        }

        debugPrint('✅ Message added. Total messages: ${_messages.length}');
        notifyListeners();
      }
    } else {
      debugPrint(
        '⚠️ Message not for this conversation (from: ${message.fromUserId}, to: ${message.toUserId})',
      );
    }
  }

  /// Handle message history from server
  void _handleMessageHistory(List<Map<String, dynamic>> historyData) {
    try {
      debugPrint('📚 Processing ${historyData.length} historical messages');

      if (historyData.isEmpty) {
        debugPrint('📚 No messages in history batch');
      }

      for (final messageData in historyData) {
        try {
          final message = ChatMessage.fromJson(messageData);

          // Only add if relevant to this conversation and not duplicate
          if ((message.fromUserId == _currentUserId &&
                  message.toUserId == _otherUserId) ||
              (message.fromUserId == _otherUserId &&
                  message.toUserId == _currentUserId)) {
            // Check for duplicates by server ID
            final isDuplicate = _messages.any((m) {
              if (message.id != null && m.id != null) {
                return m.id == message.id;
              }
              return false;
            });

            if (!isDuplicate) {
              _messages.add(message);
            }
          }
        } catch (e) {
          debugPrint('⚠️ Error parsing historical message: $e');
        }
      }

      _sortMessages();
      _isLoadingMessages = false; // Stop loading after receiving history
      debugPrint(
        '✅ Message history loaded. Total messages: ${_messages.length}',
      );

      // Update persistent cache
      if (_otherUserId != null) {
        _cacheMessages(_otherUserId!);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error handling message history: $e');
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  /// Load more messages (Pagination) - Uses REST API
  Future<void> loadMoreMessages() async {
    if (_isLoadingMessages ||
        _otherUserId == null ||
        _messages.isEmpty ||
        !_hasMoreMessages)
      return;

    _isLoadingMessages = true;
    notifyListeners();

    final nextPage = _currentPage + 1;
    debugPrint('📜 Loading page $nextPage for user $_otherUserId via REST');

    try {
      final responseMap = await _activityService.getMessages(
        _currentUserId!,
        _otherUserId!,
        page: nextPage,
        limit: 20,
      );

      if (responseMap != null && responseMap['success'] == true) {
        final List<dynamic> messagesList = responseMap['messages'] ?? [];
        final totalPages = responseMap['total_pages'] as int? ?? 1;
        final hasNext = responseMap['has_next'] as bool? ?? false;

        if (messagesList.isNotEmpty) {
          final List<Map<String, dynamic>> typedHistory = messagesList
              .map((e) => e as Map<String, dynamic>)
              .toList();

          _handleMessageHistory(typedHistory);

          _currentPage = nextPage;
          _hasMoreMessages = hasNext && _currentPage < totalPages;
        } else {
          _hasMoreMessages = false;
        }
      } else {
        // Failed or no more data
        debugPrint('📜 No more messages returned from REST or error');
        _isLoadingMessages = false;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading more messages via REST: $e');
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  /// Handle errors
  void _handleError(String error) {
    debugPrint('❌ Chat error: $error');
    _errorMessage = error;
    _connectionStatus = ChatConnectionStatus.error;
    _isLoadingMessages = false; // Stop loading on error
    notifyListeners();
  }

  /// Handle messages seen event
  void _handleMessagesSeen(Map<String, dynamic> data) {
    try {
      // Parse event payload:
      // user_id = who SAW the messages
      // other_user_id = who SENT the messages (current user)
      final userId = data['user_id'] as int?; // The person who saw our messages
      final count = data['count'] as int? ?? 0;

      debugPrint(
        '📩 Messages seen event received: user_id=$userId (who saw), count=$count',
      );

      if (userId != null) {
        debugPrint('👁️ User $userId saw $count of our messages');

        // Update isSeen for ALL messages we sent TO that user
        // This ensures real-time updates work correctly
        bool updated = false;
        final updatedMessages = <ChatMessage>[];

        for (final message in _messages) {
          // Check if this is a message WE sent TO the user who just viewed
          if (message.fromUserId == _currentUserId &&
              message.toUserId == userId) {
            // Mark as seen
            updatedMessages.add(message.copyWith(isSeen: true));
            updated = true;
            debugPrint(
              '✓ Marked message ${message.id} (to user $userId) as seen',
            );
          } else {
            updatedMessages.add(message);
          }
        }

        if (updated) {
          _messages.clear();
          _messages.addAll(updatedMessages);
          debugPrint(
            '✅ Updated ${_messages.length} messages, triggering UI refresh',
          );

          // Update persistent cache (silently)
          if (_otherUserId != null) {
            _cacheMessages(_otherUserId!).ignore();
          }

          notifyListeners();
        } else {
          debugPrint('⚠️ No messages found to mark as seen for user $userId');
        }
      }
    } catch (e) {
      debugPrint('❌ Error handling messages_seen: $e');
    }
  }

  /// Handle user typing event
  void _handleUserTyping(Map<String, dynamic> data) {
    try {
      final fromUserId = data['from_user_id'] as int?;
      final isTyping = data['is_typing'] as bool? ?? false;

      if (fromUserId == _otherUserId) {
        debugPrint(
          '⌨️ User $fromUserId is ${isTyping ? "typing" : "not typing"}',
        );
        _isOtherUserTyping = isTyping;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error handling user_typing: $e');
    }
  }

  /// Handle user active event
  void _handleUserActive(Map<String, dynamic> data) {
    try {
      final userId = data['user_id'] as int?;

      if (userId == _otherUserId && userId != null) {
        final isActive = data['is_active'] as bool? ?? false;

        // Parse last_seen, keeping old value if not provided
        DateTime? lastSeen;
        if (data['last_seen'] != null) {
          lastSeen = DateTime.parse(data['last_seen'] as String);
        } else if (!isActive && _otherUserActivity != null) {
          // If user went inactive but no last_seen provided, use current time
          lastSeen = _otherUserActivity?.lastSeen ?? DateTime.now();
        }

        _otherUserActivity = UserActivity(
          userId: userId,
          isActive: isActive,
          lastSeen: lastSeen,
          typingToUserId: data['typing_to_user_id'] as int?,
        );

        debugPrint(
          '🟢 User $userId activity updated: isActive=$isActive, lastSeen=$lastSeen',
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error handling user_active: $e');
    }
  }

  /// Fetch other user's activity status
  Future<void> _fetchOtherUserActivity() async {
    if (_otherUserId == null) return;

    try {
      final activity = await _activityService.getUserActivity(_otherUserId!);
      if (activity != null) {
        _otherUserActivity = activity;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error fetching user activity: $e');
    }
  }

  /// Send a message
  Future<void> sendMessage(String messageText) async {
    if (_chatService == null) {
      debugPrint('❌ Cannot send message: chat service not initialized');
      _errorMessage = 'Chat service not initialized';
      notifyListeners();
      return;
    }

    if (_otherUserId == null || _currentUserId == null) {
      debugPrint('❌ Cannot send message: user IDs not set');
      return;
    }

    if (messageText.trim().isEmpty) {
      debugPrint('❌ Cannot send empty message');
      return;
    }

    if (!isConnected) {
      _errorMessage = 'Not connected to chat service';
      notifyListeners();
      return;
    }

    // Create optimistic message
    final optimisticMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch, // Temp ID
      fromUserId: _currentUserId!,
      toUserId: _otherUserId!,
      source: ChatService.source,
      message: messageText.trim(),
      createdAt: DateTime.now().toUtc(),
      isSent: false, // Mark as not fully sent yet (could add a status enum)
    );

    // 1. Always add to UI immediately (Optimistic)
    _messages.add(optimisticMessage);
    _sortMessages();
    notifyListeners();

    // Update persistent cache
    if (_otherUserId != null) {
      _cacheMessages(_otherUserId!).ignore();
    }

    // 2. Check connection
    if (!isConnected) {
      debugPrint('🔌 Offline: Queueing message for later');
      _pendingMessages.add(messageText.trim());
      // Keep optimistic message in list
      return;
    }

    try {
      // Send to server
      _chatService!.sendMessage(_otherUserId!, messageText.trim());
      debugPrint('✅ Message sent to socket: $messageText');
    } catch (e) {
      debugPrint('❌ Failed to send message: $e');
      _errorMessage = 'Failed to send message: $e';

      // If immediate fail, maybe queue it too?
      // For now, let's behave standardly and perhaps roll back or mark error
      // But user requested "queueing if socket disconnected".
      // If socket throws, it's likely disconnected.
      debugPrint('🔌 Error sending, adding to queue');
      _pendingMessages.add(messageText.trim());

      notifyListeners();
    }
  }

  // NEW: Fetch user details
  Future<void> _fetchChatUserDetails() async {
    if (_otherUserId == null) return;
    try {
      // We can reuse UserLookupService which is already in ConversationsProvider,
      // but ChatProvider doesn't have it imported or instantiated.
      // Let's rely on importing it at the top and instantiating it.
      // Note: In a cleaner architecture we might inject this.
      // For now, lazy load or create new instance.

      // Import alias check: need UserLookupService
      final userLookup =
          UserLookupService(); // Assuming it's imported or available
      final user = await userLookup.getUserById(_otherUserId!);

      if (user != null) {
        _otherUserName = user.name;
        _otherUserImage = user.imageUrl;
        notifyListeners();
        debugPrint('👤 Updated chat user details: ${user.name}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching chat user details: $e');
    }
  }

  /// Sort messages by creation time (Newest -> Oldest for reverse list)
  void _sortMessages() {
    _messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Mark messages as seen
  Future<void> markMessagesAsSeen() async {
    if (_otherUserId == null) return;

    try {
      // Mark via Socket.IO
      _chatService?.markSeen(_otherUserId!);

      // Also mark via REST API for persistence
      await _activityService.markMessagesAsSeen(_otherUserId!);
    } catch (e) {
      debugPrint('❌ Error marking messages as seen: $e');
    }
  }

  // Debounce helper for typing indicator
  Future<void>? _typingDebounce;
  bool _isCurrentlyTyping = false;

  /// Send typing indicator with debouncing
  void sendTyping(bool isTyping) {
    if (_otherUserId == null || !isConnected) return;

    // Cancel previous debounce
    _typingDebounce?.ignore();

    if (isTyping) {
      // Start typing immediately
      if (!_isCurrentlyTyping) {
        _isCurrentlyTyping = true;
        _chatService?.sendTyping(_otherUserId!, true);
      }

      // Stop typing after 2 seconds of inactivity
      _typingDebounce = Future.delayed(const Duration(seconds: 2), () {
        if (_isCurrentlyTyping) {
          _isCurrentlyTyping = false;
          _chatService?.sendTyping(_otherUserId!, false);
        }
      });
      } else {
      // Stop typing immediately
      if (_isCurrentlyTyping) {
        _isCurrentlyTyping = false;
        _chatService?.sendTyping(_otherUserId!, false);
      }
    }
  }

  /// Retry connection
  Future<void> retryConnection() async {
    if (_currentUserId != null && _otherUserId != null) {
      _isInitialized = false; // Allow reinitialization
      _hasRequestedHistory = false; // Allow history request again
      await initializeChat(
        currentUserId: _currentUserId!,
        otherUserId: _otherUserId!,
      );
    }
  }

  void disconnect() {
    if (_disposed) return;

    debugPrint('🔌 Disconnecting chat provider...');

    // Stop activity polling
    _stopActivityPolling();

    // Update own activity to inactive
    if (_currentUserId != null) {
      _activityService.updateUserActivity(_currentUserId!, false);
    }

    if (_chatService != null) {
      _chatService!.onConnectionStatusChanged = null;
      _chatService!.onError = null;
      _chatService!.onMessageReceived = null;
      _chatService!.onMessageHistoryReceived = null;
      _chatService!.onMessagesSeen = null;
      _chatService!.onUserTyping = null;
      _chatService!.onUserActive = null;
      _chatService!.onMarkSeenSuccess = null;

      _chatService!.disconnect();
      _chatService!.dispose();
      _chatService = null;
    }

    _connectionStatus = ChatConnectionStatus.disconnected;
    _isInitialized = false;
    _isLoadingMessages = false;
    _hasRequestedHistory = false;
    _isOtherUserTyping = false;
    _otherUserActivity = null;
  }

  /// Clear all messages (useful when switching conversations)
  void clearMessages() {
    _messages.clear();
    _isLoadingMessages = false;
    _hasRequestedHistory = false;
    notifyListeners();
  }

  // ==========================================
  // PERSISTENT CACHING IMPLEMENTATION
  // ==========================================

  /// Generate a unique cache key for the conversation
  String _getCacheKey(int otherUserId) {
    final myId = _currentUserId ?? 0; // Should ideally be set
    // Key format: chat_messages_MIN_MAX (to be unique per pair)
    final minId = myId < otherUserId ? myId : otherUserId;
    final maxId = myId > otherUserId ? myId : otherUserId;
    return 'chat_messages_${minId}_$maxId';
  }

  /// Load messages from SharedPreferences
  Future<void> _loadCachedMessages(int otherUserId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getCacheKey(otherUserId);
      final jsonString = prefs.getString(key);

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(jsonString);
        final cachedMessages = decodedList
            .map((m) => ChatMessage.fromJson(m))
            .toList();

        if (cachedMessages.isNotEmpty) {
          _messages.clear();
          _messages.addAll(cachedMessages);
          _sortMessages();
          debugPrint(
            '💾 Loaded ${cachedMessages.length} messages from persistent cache',
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading cached messages: $e');
    }
  }

  /// Save messages to SharedPreferences
  Future<void> _cacheMessages(int otherUserId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getCacheKey(otherUserId);

      // Cache only the latest 50 messages to save space
      const maxCacheSize = 20;
      final messagesToCache = _messages.take(maxCacheSize).toList();

      final jsonList = messagesToCache.map((m) => m.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      await prefs.setString(key, jsonString);
      // debugPrint('💾 Cached ${messagesToCache.length} messages');
    } catch (e) {
      debugPrint('❌ Error caching messages: $e');
    }
  }
}
