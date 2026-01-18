import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/token_storage.dart';
import '../models/chat_message_model.dart';
import '../models/user_activity_model.dart';
import '../services/activity_service.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  // Services
  ChatService? _chatService;
  final ActivityService _activityService = ActivityService();

  // Auth data
  int? _currentUserId;
  String? _token;

  // Other user info
  int? _otherUserId;
  String? _otherUserName;
  String? _otherUserImage;

  // Messages
  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  // Connection state
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error state
  String? _error;
  String? get error => _error;

  // User activity
  UserActivity? _otherUserActivity;
  UserActivity? get otherUserActivity => _otherUserActivity;
  bool get isOtherUserOnline => _otherUserActivity?.isActive ?? false;

  // Typing state
  bool _isOtherUserTyping = false;
  bool get isOtherUserTyping => _isOtherUserTyping;

  // Pagination
  bool _hasMoreMessages = true;
  bool get hasMoreMessages => _hasMoreMessages;
  int _currentPage = 1;
  bool _isPaginating = false;
  int? _oldestMessageId;

  // Offline queue
  final List<ChatMessage> _offlineQueue = [];

  // Cache
  static const String _messageCachePrefix = 'chat_messages_';
  static const int _maxCachedMessages = 50;

  /// Initialize the chat with another user
  Future<void> initialize({
    required int otherUserId,
    required String otherUserName,
    String? otherUserImage,
  }) async {
    debugPrint('💬 Initializing chat with user $otherUserId ($otherUserName)');

    _otherUserId = otherUserId;
    _otherUserName = otherUserName;
    _otherUserImage = otherUserImage;
    _messages = [];
    _error = null;
    _isLoading = true;
    _hasMoreMessages = true;
    _currentPage = 1;
    _oldestMessageId = null;
    notifyListeners();

    try {
      // Get auth data
      _token = await TokenStorage.getToken();
      final userIdStr = await TokenStorage.getUserId();
      _currentUserId = userIdStr != null ? int.tryParse(userIdStr) : null;

      if (_token == null || _currentUserId == null) {
        _error = 'Authentication required';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Load cached messages first for instant display
      await _loadCachedMessages(otherUserId);

      // Create chat service
      _chatService = ChatService(token: _token, userId: _currentUserId);
      _setupCallbacks();
      _chatService!.connect();

      _isLoading = false;
      notifyListeners();

      // Fetch user activity in background
      _fetchUserActivity(otherUserId);
    } catch (e) {
      debugPrint('❌ Error initializing chat: $e');
      _error = 'Failed to initialize chat: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setupCallbacks() {
    if (_chatService == null) return;

    _chatService!.onConnectionStatusChanged = (connected) {
      debugPrint('🔌 Connection status: $connected');
      _isConnected = connected;
      notifyListeners();

      if (connected && _otherUserId != null) {
        // Request message history when connected
        debugPrint('📚 Requesting message history for user $_otherUserId');
        _chatService!.getMessageHistory(_otherUserId!, limit: 30);

        // Mark messages as seen
        _chatService!.markSeen(_otherUserId!);

        // Flush offline queue
        _flushOfflineQueue();
      }
    };

    _chatService!.onError = (error) {
      debugPrint('❌ Chat error: $error');
      _error = error;
      notifyListeners();

      // Clear error after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (_error == error) {
          _error = null;
          notifyListeners();
        }
      });
    };

    _chatService!.onMessageReceived = (data) {
      debugPrint('📨 New message received: $data');
      final message = ChatMessage.fromJson(data);

      // Check if this message is for current conversation
      if ((message.fromUserId == _otherUserId && message.toUserId == _currentUserId) ||
          (message.fromUserId == _currentUserId && message.toUserId == _otherUserId)) {
        
        // Check if we have an optimistic (pending) message that matches this one
        // We match by: id is null, isSent is false, message content matches
        final pendingIndex = _messages.indexWhere((m) => 
          m.id == null && 
          !m.isSent && 
          m.message == message.message &&
          m.toUserId == message.toUserId
        );

        if (pendingIndex != -1) {
          // Update the pending message with the real one from server
          _messages[pendingIndex] = message;
          _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          notifyListeners();
          
          // Cache messages
          _cacheMessages(_otherUserId!).ignore();
        } 
        // If not a pending match, check ID to avoid duplicates
        else if (!_messages.any((m) => m.id == message.id)) {
          _messages.add(message);
          _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          notifyListeners();

          // Cache messages
          _cacheMessages(_otherUserId!).ignore();
        }

        // Mark as seen if from other user
        if (message.fromUserId == _otherUserId) {
          _chatService!.markSeen(_otherUserId!);
        }
      }
    };

    _chatService!.onMessageHistoryReceived = (messages) {
      debugPrint('📚 Received ${messages.length} history messages');

      final newMessages = messages.map((m) => ChatMessage.fromJson(m)).toList();

      if (_isPaginating) {
        // Paginating: merge and dedupe
        final existingIds = _messages.map((m) => m.id).toSet();
        final uniqueNew = newMessages.where((m) => !existingIds.contains(m.id)).toList();

        if (uniqueNew.isEmpty || newMessages.length < 30) {
          _hasMoreMessages = false;
        } 
        
        if (uniqueNew.isNotEmpty) {
          _messages.insertAll(0, uniqueNew);
        }
        _isPaginating = false;
      } else {
        // Initial load: replace
        _messages = newMessages;
        if (_messages.length < 30) {
          _hasMoreMessages = false;
        }
      }

      _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      if (_messages.isNotEmpty) {
        _oldestMessageId = _messages.first.id;
      }

      if (_otherUserId != null) {
        _cacheMessages(_otherUserId!).ignore();
      }

      notifyListeners();
    };

    _chatService!.onMessagesSeen = (data) {
      debugPrint('👁️ Messages seen: $data');
      final seenByUserId = data['seen_by_user_id'] as int?;
      final otherUserId = data['other_user_id'] as int?;

      if (seenByUserId == _otherUserId || otherUserId == _otherUserId) {
        // Mark my messages to this user as seen
        bool updated = false;
        for (int i = 0; i < _messages.length; i++) {
          final msg = _messages[i];
          if (msg.fromUserId == _currentUserId && msg.toUserId == _otherUserId && !msg.isSeen) {
            _messages[i] = msg.copyWith(isSeen: true);
            updated = true;
          }
        }
        if (updated) {
          notifyListeners();
          if (_otherUserId != null) {
            _cacheMessages(_otherUserId!).ignore();
          }
        }
      }
    };

    _chatService!.onUserTyping = (data) {
      final typingUserId = data['user_id'] as int?;
      final isTyping = data['is_typing'] as bool? ?? false;

      if (typingUserId == _otherUserId) {
        _isOtherUserTyping = isTyping;
        notifyListeners();
      }
    };

    _chatService!.onUserActive = (data) {
      final userId = data['user_id'] as int?;
      if (userId == _otherUserId) {
        _otherUserActivity = UserActivity.fromJson(data);
        notifyListeners();
      }
    };
  }

  /// Send a message
  void sendMessage(String text) {
    if (text.trim().isEmpty || _otherUserId == null || _currentUserId == null) {
      return;
    }

    final message = ChatMessage(
      fromUserId: _currentUserId!,
      toUserId: _otherUserId!,
      source: ChatService.source,
      message: text.trim(),
      createdAt: DateTime.now(),
      isSent: false,
    );

    // Add to local list immediately (optimistic update)
    _messages.add(message);
    notifyListeners();

    if (_isConnected && _chatService != null) {
      _chatService!.sendMessage(_otherUserId!, text.trim());
    } else {
      // Add to offline queue
      _offlineQueue.add(message);
      debugPrint('📥 Added to offline queue (${_offlineQueue.length} pending)');
    }
  }

  /// Send typing indicator
  void sendTyping(bool isTyping) {
    if (_chatService != null && _otherUserId != null && _isConnected) {
      _chatService!.sendTyping(_otherUserId!, isTyping);
    }
  }

  /// Load more messages (pagination)
  Future<void> loadMoreMessages() async {
    if (_isPaginating || !_hasMoreMessages || _otherUserId == null) return;

    _isPaginating = true;
    _currentPage++;
    notifyListeners();

    try {
      // Try Socket.IO first
      if (_isConnected && _chatService != null) {
        _chatService!.getMessageHistory(
          _otherUserId!,
          limit: 30,
          page: _currentPage,
          beforeId: _oldestMessageId,
        );

        // Wait for response (handled in callback)
        await Future.delayed(const Duration(seconds: 3));
        if (_isPaginating) {
          // Socket didn't respond, try REST
          await _loadViaRest();
        }
      } else {
        await _loadViaRest();
      }
    } catch (e) {
      debugPrint('❌ Error loading more messages: $e');
      _isPaginating = false;
      notifyListeners();
    }
  }

  Future<void> _loadViaRest() async {
    if (_currentUserId == null || _otherUserId == null) return;

    final result = await _activityService.getMessages(
      _currentUserId!,
      _otherUserId!,
      page: _currentPage,
      limit: 30,
    );

    if (result != null) {
      final messageList = result['messages'] as List<dynamic>?;
      if (messageList != null && messageList.isNotEmpty) {
        final newMessages = messageList.map((m) => ChatMessage.fromJson(m as Map<String, dynamic>)).toList();

        final existingIds = _messages.map((m) => m.id).toSet();
        final uniqueNew = newMessages.where((m) => !existingIds.contains(m.id)).toList();

        if (uniqueNew.isEmpty) {
          _hasMoreMessages = false;
        } else {
          _messages.insertAll(0, uniqueNew);
          _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          if (_messages.isNotEmpty) {
            _oldestMessageId = _messages.first.id;
          }
        }

        final totalPages = result['total_pages'] as int? ?? 1;
        if (_currentPage >= totalPages) {
          _hasMoreMessages = false;
        }
      } else {
        _hasMoreMessages = false;
      }
    } else {
      // If request failed (null result), stop pagination preventing infinite loader
      _hasMoreMessages = false;
    }

    _isPaginating = false;
    notifyListeners();
  }

  Future<void> _fetchUserActivity(int userId) async {
    final activity = await _activityService.getUserActivity(userId);
    if (activity != null) {
      _otherUserActivity = activity;
      notifyListeners();
    }
  }

  void _flushOfflineQueue() {
    if (_offlineQueue.isEmpty) return;

    debugPrint('📤 Flushing ${_offlineQueue.length} offline messages');

    for (final msg in _offlineQueue) {
      _chatService?.sendMessage(msg.toUserId, msg.message);
    }

    _offlineQueue.clear();
  }

  // Caching methods
  Future<void> _loadCachedMessages(int otherUserId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_messageCachePrefix${_currentUserId}_$otherUserId';
      final jsonStr = prefs.getString(key);

      if (jsonStr != null) {
        final list = jsonDecode(jsonStr) as List;
        _messages = list.map((m) => ChatMessage.fromJson(m)).toList();
        _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        debugPrint('📦 Loaded ${_messages.length} cached messages');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('⚠️ Error loading cached messages: $e');
    }
  }

  Future<void> _cacheMessages(int otherUserId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_messageCachePrefix${_currentUserId}_$otherUserId';

      // Cache only recent messages
      final toCache = _messages.length > _maxCachedMessages
          ? _messages.sublist(_messages.length - _maxCachedMessages)
          : _messages;

      final jsonStr = jsonEncode(toCache.map((m) => m.toJson()).toList());
      await prefs.setString(key, jsonStr);
    } catch (e) {
      debugPrint('⚠️ Error caching messages: $e');
    }
  }

  /// Clean up when leaving chat
  void cleanup() {
    debugPrint('🧹 Cleaning up chat provider');

    // Cache final messages
    if (_otherUserId != null) {
      _cacheMessages(_otherUserId!);
    }

    _chatService?.dispose();
    _chatService = null;

    _isConnected = false;
    _isOtherUserTyping = false;
    _error = null;
    notifyListeners();
  }

  /// Reconnect to the chat
  void reconnect() {
    if (_chatService != null && _token != null && _currentUserId != null) {
      debugPrint('🔄 Reconnecting to chat...');
      _chatService!.connect();
    }
  }

  @override
  void dispose() {
    cleanup();
    super.dispose();
  }
}
