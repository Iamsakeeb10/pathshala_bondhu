// ============================================================================
// 3. lib/core/network/user_storage.dart
// ============================================================================
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'token_storage.dart';

class UserStorage {
  static const String _userKey = 'user_data';

  /// Save user data
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(userData);
      await prefs.setString(_userKey, userJson);
      print('✅ User data saved successfully');
    } catch (e) {
      print('❌ Error saving user data: $e');
    }
  }

  /// Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson == null) return null;

      return jsonDecode(userJson) as Map<String, dynamic>;
    } catch (e) {
      print('❌ Error getting user data: $e');
      return null;
    }
  }

  /// Clear user data
  static Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      print('✅ User data cleared successfully');
    } catch (e) {
      print('❌ Error clearing user data: $e');
    }
  }

  /// Clear all stored data (token + user data)
  static Future<void> clearAll() async {
    await TokenStorage.clearToken();
    await clearUserData();
    print('✅ All user session data cleared');
  }
}
