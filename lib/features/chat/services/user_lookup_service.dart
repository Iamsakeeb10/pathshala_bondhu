import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/token_storage.dart';
import '../models/chat_user_model.dart';

/// Service to fetch user information by user ID for chat screens
class UserLookupService {
  static const String baseUrl = 'http://pathshalabondhu.top';
  static const String _cacheKeyPrefix = 'user_cache_';
  // static const Duration _cacheDuration = Duration(days: 7); // Cache validity (kept for future use)

  // Memory cache
  final Map<int, ChatUser> _memoryCache = {};

  // Track ongoing requests to prevent duplicates
  final Map<int, Future<ChatUser?>> _ongoingRequests = {};

  /// Initialize service and load cache
  Future<void> init() async {
    // We can preload frequent users here if needed, or rely on lazy loading
  }

  /// Get user info by ID
  Future<ChatUser?> getUserById(int userId, {bool forceRefresh = false}) async {
    // 1. Check memory cache first
    if (!forceRefresh && _memoryCache.containsKey(userId)) {
      return _memoryCache[userId];
    }

    // 2. Check overlap (deduplication)
    if (_ongoingRequests.containsKey(userId)) {
      return _ongoingRequests[userId];
    }

    // 3. Check persistent cache
    if (!forceRefresh) {
      final cachedUser = await _getFromDisk(userId);
      if (cachedUser != null) {
        _memoryCache[userId] = cachedUser;
        return cachedUser;
      }
    }

    // 4. Fetch from API
    final future = _fetchFromApi(userId);
    _ongoingRequests[userId] = future;

    try {
      final user = await future;
      if (user != null) {
        _memoryCache[userId] = user;
        await _saveToDisk(user);
      }
      return user;
    } finally {
      _ongoingRequests.remove(userId);
    }
  }

  /// Fetch multiple users efficiently
  Future<Map<int, ChatUser>> getUsersByIds(List<int> userIds) async {
    final Map<int, ChatUser> results = {};
    final List<int> idsToFetch = [];

    // 1. Check Caches
    for (final id in userIds) {
      if (_memoryCache.containsKey(id)) {
        results[id] = _memoryCache[id]!;
      } else {
        // Try disk cache
        final cached = await _getFromDisk(id);
        if (cached != null) {
          _memoryCache[id] = cached;
          results[id] = cached;
        } else {
          idsToFetch.add(id);
        }
      }
    }

    if (idsToFetch.isEmpty) return results;

    // 2. Fetch missing (Parallel)
    // Note: If backend supports batch, replace this with batch call
    debugPrint('🔍 Fetching ${idsToFetch.length} missing users from API');

    final futures = idsToFetch.map((id) => getUserById(id, forceRefresh: true));
    final fetchedUsers = await Future.wait(futures);

    for (final user in fetchedUsers) {
      if (user != null) {
        results[user.id] = user;
      }
    }

    return results;
  }

  Future<ChatUser?> _fetchFromApi(int userId) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        debugPrint('❌ No token available for user lookup');
        return null;
      }

      final url = Uri.parse('$baseUrl/api/users/$userId/details');

      debugPrint('🔍 ========== USER LOOKUP API CALL ==========');
      debugPrint('🔍 Request URL: $url');
      debugPrint('🔍 Request Method: GET');
      debugPrint(
        '🔍 Request Headers: {Authorization: Bearer ${token.substring(0, 20)}..., Accept: application/json}',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint('📥 Response Status: ${response.statusCode}');
      debugPrint('📥 Response Headers: ${response.headers}');
      debugPrint('📥 Response Body: ${response.body}');
      debugPrint('🔍 ========== END API CALL ==========');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        debugPrint('📦 Decoded JSON: $data');

        if (data['success'] == true && data['user'] != null) {
          debugPrint('✅ Success field is true');
          final userData = data['user'] as Map<String, dynamic>;
          debugPrint('👤 User Data: $userData');

          final user = ChatUser.fromJson(userData);
          debugPrint(
            '✅ Successfully parsed user: ${user.name} (ID: $userId, Image: ${user.imageUrl})',
          );
          return user;
        } else {
          debugPrint(
            '⚠️ Success is false or user is null: success=${data['success']}, user=${data['user']}',
          );
        }
      } else if (response.statusCode == 404) {
        debugPrint('❌ User $userId not found (404)');
        debugPrint('❌ Response body: ${response.body}');
      } else {
        debugPrint('❌ Unexpected status code: ${response.statusCode}');
        debugPrint('❌ Response body: ${response.body}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching user $userId: $e');
      debugPrint('❌ Stack trace: $stackTrace');
    }
    return null;
  }

  Future<void> _saveToDisk(ChatUser user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_cacheKeyPrefix${user.id}';
      final jsonStr = jsonEncode({
        ...user.toJson(),
        'cached_at': DateTime.now().toIso8601String(),
      });
      await prefs.setString(key, jsonStr);
    } catch (_) {}
  }

  Future<ChatUser?> _getFromDisk(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_cacheKeyPrefix$userId';
      final jsonStr = prefs.getString(key);

      if (jsonStr != null) {
        final data = jsonDecode(jsonStr);
        // Optional: Check cache expiry
        // final cachedAt = DateTime.parse(data['cached_at']);
        // if (DateTime.now().difference(cachedAt) > _cacheDuration) return null;

        return ChatUser.fromJson(data);
      }
    } catch (_) {}
    return null;
  }

  void clearCache() {
    _memoryCache.clear();
    // Clear disk cache if needed
  }
}
