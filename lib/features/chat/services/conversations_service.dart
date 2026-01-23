import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/network/token_storage.dart';
import '../models/conversation_model.dart';

class ConversationsService {
  static const String baseUrl = 'https://sys-chatting.whiteorbit.top';
  static const String source = 'school_sass';

  /// Fetch all messages for a user and group them into conversations
  Future<List<Conversation>> getConversations(int userId) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      debugPrint('📚 Fetching conversations for user $userId');

      final url = Uri.parse(
        '$baseUrl/api/messages/user/$userId?limit=500&source=$source',
      );
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final success = data['success'] as bool? ?? false;

        if (success) {
          final messages = data['messages'] as List<dynamic>? ?? [];
          debugPrint('✅ Received ${messages.length} messages');

          // Group messages by conversation partner
          final Map<int, List<Map<String, dynamic>>> conversationMap = {};

          for (final msg in messages) {
            final message = msg as Map<String, dynamic>;
            final fromUserId = message['from_user_id'] as int;
            final toUserId = message['to_user_id'] as int;

            // Determine the other user (conversation partner)
            final otherUserId = fromUserId == userId ? toUserId : fromUserId;

            // Group messages by conversation partner
            if (!conversationMap.containsKey(otherUserId)) {
              conversationMap[otherUserId] = [];
            }
            conversationMap[otherUserId]!.add(message);
          }

          debugPrint('💬 Found ${conversationMap.length} conversations');

          // Convert to Conversation objects
          final conversations = conversationMap.entries.map((entry) {
            final messages = entry.value;

            // Sort messages by date (oldest first)
            messages.sort((a, b) {
              final aDate = DateTime.parse(a['created_at'] as String);
              final bDate = DateTime.parse(b['created_at'] as String);
              return aDate.compareTo(bDate);
            });

            return Conversation.fromMessages(
              currentUserId: userId,
              messages: messages,
            );
          }).toList();

          // Sort conversations by latest message time (newest first)
          conversations.sort((a, b) {
            if (a.lastMessageTime == null && b.lastMessageTime == null) {
              return 0;
            }
            if (a.lastMessageTime == null) return 1;
            if (b.lastMessageTime == null) return -1;
            return b.lastMessageTime!.compareTo(a.lastMessageTime!);
          });

          return conversations;
        } else {
          throw Exception('Failed to fetch conversations: ${data['message']}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching conversations: $e');
      rethrow;
    }
  }

  /// Fetch conversation with a specific user
  Future<Conversation?> getConversationWithUser(
    int currentUserId,
    int otherUserId,
  ) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      debugPrint(
        '📚 Fetching conversation with user $otherUserId for $currentUserId',
      );

      final url = Uri.parse(
        '$baseUrl/api/messages/history?other_user_id=$otherUserId&limit=50&source=$source',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final success = data['success'] as bool? ?? false;

        if (success) {
          final messages = data['messages'] as List<dynamic>? ?? [];
          debugPrint(
            '✅ Received ${messages.length} messages for new conversation',
          );

          if (messages.isEmpty) return null;

          final messageList = messages
              .map((m) => m as Map<String, dynamic>)
              .toList();

          // Sort messages by date (oldest first)
          messageList.sort((a, b) {
            final aDate = DateTime.parse(a['created_at'] as String);
            final bDate = DateTime.parse(b['created_at'] as String);
            return aDate.compareTo(bDate);
          });

          return Conversation.fromMessages(
            currentUserId: currentUserId,
            messages: messageList,
          );
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching single conversation: $e');
      return null;
    }
  }
}
