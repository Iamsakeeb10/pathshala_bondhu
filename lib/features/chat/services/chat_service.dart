import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  // Configuration
  static const String baseUrl = 'https://chat.whiteorbit.top';
  static const String source = 'school_sass';

  // Socket instance
  IO.Socket? _socket;

  // Store authentication data
  final String? _token;
  final int? _userId;

  // Callbacks
  Function(bool)? onConnectionStatusChanged;
  Function(String)? onError;
  Function(Map<String, dynamic>)? onMessageReceived;
  Function(List<Map<String, dynamic>>)? onMessageHistoryReceived;
  Function(Map<String, dynamic>)? onMessagesSeen;
  Function(Map<String, dynamic>)? onUserTyping;
  Function(Map<String, dynamic>)? onUserActive;
  Function(Map<String, dynamic>)? onMarkSeenSuccess;

  // State
  bool get isConnected => _socket?.connected ?? false;

  // Constructor
  ChatService({String? token, int? userId}) : _token = token, _userId = userId;

  /// Connect to the Socket.IO server
  void connect() {
    if (_token == null || _userId == null) {
      debugPrint('❌ Cannot connect: token or userId not provided');
      onError?.call('Token or user ID missing');
      return;
    }

    try {
      debugPrint('🔌 Connecting to chat service...');
      debugPrint('📍 URL: $baseUrl');
      debugPrint('🎫 Token: ${_token.substring(0, min(20, _token.length))}...');
      debugPrint('👤 User ID: $_userId');

      // Disconnect existing connection if any
      disconnect();

      // Initial status
      onConnectionStatusChanged?.call(false);

      // Create socket with authentication
      _socket = IO.io(
        baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableAutoConnect()
            .enableForceNew()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setAuth({
              'token': _token,
              'source': source,
            })
            .build(),
      );

      _setupListeners();

      _socket!.connect();

      debugPrint('✅ Socket initialized and connecting...');
    } catch (e) {
      debugPrint('❌ Connection error: $e');
      onError?.call('Failed to connect: $e');
      onConnectionStatusChanged?.call(false);
    }
  }

  /// Setup event listeners
  void _setupListeners() {
    if (_socket == null) return;

    _socket!.onConnect((_) {
      debugPrint('✅ Connected to chat service');
      onConnectionStatusChanged?.call(true);
    });

    _socket!.onConnectError((data) {
      debugPrint('❌ Connection error: $data');
      final errorMsg = data is Map
          ? (data['message'] ?? data.toString())
          : data.toString();
      onError?.call('Connection error: $errorMsg');
      onConnectionStatusChanged?.call(false);
    });

    _socket!.onDisconnect((_) {
      debugPrint('🔌 Disconnected from chat service');
      onConnectionStatusChanged?.call(false);
    });

    _socket!.on('reconnect_attempt', (attempt) {
      debugPrint('🔄 Reconnection attempt: $attempt');
    });

    _socket!.on('reconnect', (attempt) {
      debugPrint('✅ Reconnected after $attempt attempts');
      onConnectionStatusChanged?.call(true);
    });

    _socket!.on('reconnect_failed', (_) {
      debugPrint('❌ Reconnection failed');
      onError?.call('Failed to reconnect to server');
      onConnectionStatusChanged?.call(false);
    });

    _socket!.on('receive_message', (data) {
      try {
        debugPrint('📨 Received message: $data');
        if (data is Map<String, dynamic>) {
          onMessageReceived?.call(data);
        } else {
          debugPrint('⚠️ Unexpected message format: $data');
        }
      } catch (e) {
        debugPrint('❌ Error processing message: $e');
        onError?.call('Failed to process message: $e');
      }
    });

    _socket!.on('message_history', (data) {
      try {
        debugPrint('📚 Received message history: $data');
        if (data is Map<String, dynamic>) {
          final success = data['success'] as bool? ?? false;
          if (success) {
            final messages = data['messages'] as List?;
            if (messages != null) {
              final messageList = messages
                  .map((m) => Map<String, dynamic>.from(m as Map))
                  .toList();
              onMessageHistoryReceived?.call(messageList);
              debugPrint('✅ Loaded ${messageList.length} historical messages');
            }
          } else {
            debugPrint('⚠️ Message history request failed');
          }
        }
      } catch (e) {
        debugPrint('❌ Error processing message history: $e');
      }
    });

    _socket!.on('error', (data) {
      debugPrint('❌ Server error: $data');
      final errorMessage = data is Map
          ? (data['message'] ?? data.toString())
          : data.toString();
      onError?.call(errorMessage);
    });

    _socket!.on('messages_seen', (data) {
      try {
        debugPrint('👁️ Messages seen event: $data');
        if (data is Map<String, dynamic>) {
          onMessagesSeen?.call(data);
        }
      } catch (e) {
        debugPrint('❌ Error processing messages_seen: $e');
      }
    });

    _socket!.on('user_typing', (data) {
      try {
        debugPrint('⌨️ User typing event: $data');
        if (data is Map<String, dynamic>) {
          onUserTyping?.call(data);
        }
      } catch (e) {
        debugPrint('❌ Error processing user_typing: $e');
      }
    });

    _socket!.on('user_active', (data) {
      try {
        debugPrint('🟢 User active event: $data');
        if (data is Map<String, dynamic>) {
          onUserActive?.call(data);
        }
      } catch (e) {
        debugPrint('❌ Error processing user_active: $e');
      }
    });

    _socket!.on('mark_seen_success', (data) {
      try {
        debugPrint('✅ Mark seen success: $data');
        if (data is Map<String, dynamic>) {
          onMarkSeenSuccess?.call(data);
        }
      } catch (e) {
        debugPrint('❌ Error processing mark_seen_success: $e');
      }
    });
  }

  /// Send a message to another user
  void sendMessage(int toUserId, String message) {
    if (_socket == null || !isConnected) {
      debugPrint('❌ Cannot send message: not connected');
      onError?.call('Not connected to server');
      return;
    }

    if (message.trim().isEmpty) {
      debugPrint('❌ Cannot send empty message');
      onError?.call('Message cannot be empty');
      return;
    }

    try {
      debugPrint('📤 Sending message to user $toUserId: $message');
      _socket!.emit('send_message', {
        'to_user_id': toUserId,
        'message': message.trim(),
      });
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      onError?.call('Failed to send message: $e');
      rethrow;
    }
  }

  /// Request message history with another user
  void getMessageHistory(int otherUserId, {int limit = 20, int? page, int? beforeId}) {
    if (_socket == null || !isConnected) {
      debugPrint('❌ Cannot get message history: not connected');
      onError?.call('Not connected to server');
      return;
    }

    try {
      debugPrint(
        '📚 Requesting message history with user $otherUserId (limit: $limit, page: $page)',
      );
      final data = {'other_user_id': otherUserId, 'limit': limit};

      if (page != null) {
        data['page'] = page;
      }

      _socket!.emit('get_message_history', data);
    } catch (e) {
      debugPrint('❌ Error requesting message history: $e');
      onError?.call('Failed to request message history: $e');
    }
  }

  /// Mark messages from another user as seen
  void markSeen(int otherUserId) {
    if (_socket == null || !isConnected) {
      debugPrint('❌ Cannot mark seen: not connected');
      onError?.call('Not connected to server');
      return;
    }

    try {
      debugPrint('👁️ Marking messages from user $otherUserId as seen');
      _socket!.emit('mark_seen', {'other_user_id': otherUserId});
    } catch (e) {
      debugPrint('❌ Error marking seen: $e');
      onError?.call('Failed to mark seen: $e');
    }
  }

  /// Send typing indicator to another user
  void sendTyping(int toUserId, bool isTyping) {
    if (_socket == null || !isConnected) {
      debugPrint('❌ Cannot send typing: not connected');
      return;
    }

    try {
      debugPrint('⌨️ Sending typing=$isTyping to user $toUserId');
      _socket!.emit('typing', {'to_user_id': toUserId, 'is_typing': isTyping});
    } catch (e) {
      debugPrint('❌ Error sending typing: $e');
    }
  }

  /// Disconnect from the server
  void disconnect() {
    if (_socket != null) {
      debugPrint('🔌 Disconnecting from chat service...');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
  }

  /// Clean up resources
  void dispose() {
    disconnect();
    onConnectionStatusChanged = null;
    onError = null;
    onMessageReceived = null;
    onMessageHistoryReceived = null;
    onMessagesSeen = null;
    onUserTyping = null;
    onUserActive = null;
    onMarkSeenSuccess = null;
  }
}

// Helper to get minimum of two integers
int min(int a, int b) => a < b ? a : b;
