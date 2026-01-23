import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/network/token_storage.dart';
import '../models/user_activity_model.dart';

class ActivityService {
  static const String baseUrl = 'https://sys-chatting.whiteorbit.top';
  static const String source = 'school_sass';

  /// Get user activity status
  /// GET /api/activity/user/:user_id
  Future<UserActivity?> getUserActivity(int userId) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      debugPrint('📊 Fetching activity for user $userId');

      final url = Uri.parse(
        '$baseUrl/api/activity/user/$userId?source=$source',
      );
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'X-Source': source,
          'Accept': 'application/json',
        },
      );

      debugPrint('📥 Activity response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final success = data['success'] as bool? ?? false;

        if (success) {
          debugPrint('✅ User activity loaded: $data');
          return UserActivity.fromJson(data);
        } else {
          debugPrint('⚠️ Failed to get activity: ${data['message']}');
          return null;
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid token');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching user activity: $e');
      return null;
    }
  }

  /// Update current user's activity status
  /// PUT /api/activity/user/:user_id/active
  Future<bool> updateUserActivity(int userId, bool isActive) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      debugPrint('🔄 Updating activity for user $userId: isActive=$isActive');

      final url = Uri.parse(
        '$baseUrl/api/activity/user/$userId/active?source=$source',
      );
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'X-Source': source,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'is_active': isActive}),
      );

      debugPrint('📥 Update activity response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final success = data['success'] as bool? ?? false;
        debugPrint(
          success ? '✅ Activity updated' : '⚠️ Activity update failed',
        );
        return success;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid token');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error updating user activity: $e');
      return false;
    }
  }

  /// Get message history via REST API
  /// GET /api/messages
  Future<Map<String, dynamic>?> getMessages(
    int currentUserId,
    int otherUserId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      debugPrint(
        '📜 Fetching messages via REST: user=$currentUserId, other=$otherUserId, page=$page',
      );

      final uri = Uri.parse('$baseUrl/api/messages').replace(
        queryParameters: {
          'user_id': currentUserId.toString(),
          'other_user_id': otherUserId.toString(),
          'page': page.toString(),
          'limit': limit.toString(),
          'source': source,
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'X-Source': source,
          'Accept': 'application/json',
        },
      );

      debugPrint('📥 REST Messages response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map<String, dynamic>) {
          if (data['success'] == true) {
            debugPrint(
              '✅ REST: Loaded response (Page ${data['current_page']}/${data['total_pages']})',
            );
            return data;
          } else {
            debugPrint('⚠️ REST: API returned success=false');
            return null;
          }
        } else {
          debugPrint('⚠️ Unexpected REST response format');
          return null;
        }
      } else {
        debugPrint('⚠️ REST: Failed to load messages: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ REST Error fetching messages: $e');
      return null;
    }
  }

  /// Mark messages as seen
  /// POST /api/activity/messages/seen
  Future<bool> markMessagesAsSeen(int otherUserId) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      debugPrint('👁️ Marking messages as seen from user $otherUserId');

      final url = Uri.parse(
        '$baseUrl/api/activity/messages/seen?source=$source',
      );
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'X-Source': source,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'other_user_id': otherUserId}),
      );

      debugPrint('📥 Mark seen response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final success = data['success'] as bool? ?? false;
        final count = data['count'] as int? ?? 0;
        debugPrint(
          success ? '✅ Marked $count messages as seen' : '⚠️ Mark seen failed',
        );
        return success;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid token');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error marking messages as seen: $e');
      return false;
    }
  }
}
