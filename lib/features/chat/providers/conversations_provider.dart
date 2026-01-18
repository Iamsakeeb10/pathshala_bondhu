import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/network/token_storage.dart';
import '../models/chat_user_model.dart';
import '../models/conversation_model.dart';
import '../services/chat_service.dart';
import '../services/conversations_service.dart';
import '../services/user_lookup_service.dart';

class ConversationsProvider extends ChangeNotifier {
  // Services
  final ConversationsService _conversationsService = ConversationsService();
  final UserLookupService _userLookupService = UserLookupService();
  ChatService? _chatService;

  // Auth
  int? _currentUserId;
  String? _token;

  // Conversations
  List<Conversation> _conversations = [];
  List<Conversation> get conversations => _conversations;

  // User lookup cache
  final Map<int, ChatUser> _userCache = {};
  Map<int, ChatUser> get userCache => _userCache;

  // Connection state
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error state
  String? _error;
  String? get error => _error;

  // Unread count
  int get totalUnreadCount => _conversations.fold(0, (sum, c) => sum + c.unreadCount);

  /// Initialize the provider
  Future<void> initialize() async {
    debugPrint('📚 Initializing conversations provider');

    _isLoading = true;
    notifyListeners();

    try {
      _token = await TokenStorage.getToken();
      final userIdStr = await TokenStorage.getUserId();
      _currentUserId = userIdStr != null ? int.tryParse(userIdStr) : null;

      if (_token == null || _currentUserId == null) {
        _error = 'Authentication required';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Initialize user lookup service
      await _userLookupService.init();

      // Initialize socket for real-time updates
      _initializeSocket();

      // Fetch conversations
      await fetchConversations();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error initializing conversations: $e');
      _error = 'Failed to initialize: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void _initializeSocket() {
    if (_token == null || _currentUserId == null) return;

    _chatService = ChatService(token: _token, userId: _currentUserId);

    _chatService!.onConnectionStatusChanged = (connected) {
      _isConnected = connected;
      notifyListeners();
    };

    _chatService!.onMessageReceived = (data) {
      _handleNewMessage(data);
    };

    _chatService!.onUserActive = (data) {
      final userId = data['user_id'] as int?;
      final isActive = data['is_active'] as bool? ?? false;

      if (userId != null) {
        final index = _conversations.indexWhere((c) => c.userId == userId);
        if (index != -1) {
          _conversations[index] = _conversations[index].copyWith(isOnline: isActive);
          notifyListeners();
        }
      }
    };

    _chatService!.onMessagesSeen = (data) {
      final otherUserId = data['other_user_id'] as int?;
      if (otherUserId != null) {
        final index = _conversations.indexWhere((c) => c.userId == otherUserId);
        if (index != -1 && _conversations[index].lastMessageSentByMe) {
          _conversations[index] = _conversations[index].copyWith(lastMessageSeen: true);
          notifyListeners();
        }
      }
    };

    _chatService!.connect();
  }

  void _handleNewMessage(Map<String, dynamic> data) {
    if (_currentUserId == null) return;

    final fromUserId = data['from_user_id'] as int;
    final toUserId = data['to_user_id'] as int;
    final message = data['message'] as String?;
    final createdAt = data['created_at'] != null
        ? DateTime.parse(data['created_at'] as String)
        : DateTime.now();

    final otherUserId = fromUserId == _currentUserId ? toUserId : fromUserId;
    final sentByMe = fromUserId == _currentUserId;

    // Find existing conversation
    final index = _conversations.indexWhere((c) => c.userId == otherUserId);

    if (index != -1) {
      // Update existing
      final existing = _conversations[index];
      _conversations[index] = existing.copyWith(
        lastMessage: message,
        lastMessageTime: createdAt,
        lastMessageSentByMe: sentByMe,
        lastMessageSeen: false,
        unreadCount: sentByMe ? existing.unreadCount : existing.unreadCount + 1,
      );

      // Move to top
      final updated = _conversations.removeAt(index);
      _conversations.insert(0, updated);
    } else {
      // Create new conversation
      _createNewConversation(otherUserId, message, createdAt, sentByMe);
    }

    notifyListeners();
  }

  Future<void> _createNewConversation(
    int otherUserId,
    String? message,
    DateTime createdAt,
    bool sentByMe,
  ) async {
    // Fetch user info
    final user = await _userLookupService.getUserById(otherUserId);

    final newConversation = Conversation(
      userId: otherUserId,
      userName: user?.name ?? 'User $otherUserId',
      userImage: user?.imageUrl,
      lastMessage: message,
      lastMessageTime: createdAt,
      unreadCount: sentByMe ? 0 : 1,
      isOnline: false,
      lastMessageSentByMe: sentByMe,
      lastMessageSeen: false,
    );

    _conversations.insert(0, newConversation);
    if (user != null) {
      _userCache[otherUserId] = user;
    }
    notifyListeners();
  }

  /// Fetch all conversations
  Future<void> fetchConversations() async {
    if (_currentUserId == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      _conversations = await _conversationsService.getConversations(_currentUserId!);

      // Fetch user details for all conversations (non-blocking)
      _fetchConversationUsers();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error fetching conversations: $e');
      _error = 'Failed to load conversations: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchConversationUsers() async {
    final userIds = _conversations.map((c) => c.userId).toList();
    if (userIds.isEmpty) return;

    final users = await _userLookupService.getUsersByIds(userIds);
    _userCache.addAll(users);

    // Update conversations with user info
    for (int i = 0; i < _conversations.length; i++) {
      final conv = _conversations[i];
      final user = users[conv.userId];
      if (user != null) {
        _conversations[i] = conv.copyWith(
          userName: user.name,
          userImage: user.imageUrl,
        );
      }
    }

    notifyListeners();
  }

  /// Update last message for a conversation
  void updateLastMessage({
    required int otherUserId,
    required String message,
    required DateTime time,
    required bool sentByMe,
  }) {
    final index = _conversations.indexWhere((c) => c.userId == otherUserId);
    if (index != -1) {
      final existing = _conversations[index];
      _conversations[index] = existing.copyWith(
        lastMessage: message,
        lastMessageTime: time,
        lastMessageSentByMe: sentByMe,
        lastMessageSeen: false,
      );

      // Move to top
      final updated = _conversations.removeAt(index);
      _conversations.insert(0, updated);
      notifyListeners();
    }
  }

  /// Mark conversation as read
  void markAsRead(int otherUserId) {
    final index = _conversations.indexWhere((c) => c.userId == otherUserId);
    if (index != -1 && _conversations[index].unreadCount > 0) {
      _conversations[index] = _conversations[index].copyWith(unreadCount: 0);
      notifyListeners();
    }
  }

  /// Pause socket connection (for background)
  void pause() {
    _chatService?.disconnect();
    _isConnected = false;
    notifyListeners();
  }

  /// Resume socket connection
  void resume() {
    if (_chatService != null && _token != null) {
      _chatService!.connect();
    }
  }

  /// Get user info by ID
  ChatUser? getUserById(int userId) {
    return _userCache[userId];
  }

  /// Clean up resources
  void cleanup() {
    _chatService?.dispose();
    _chatService = null;
    _isConnected = false;
  }

  @override
  void dispose() {
    cleanup();
    super.dispose();
  }
}
