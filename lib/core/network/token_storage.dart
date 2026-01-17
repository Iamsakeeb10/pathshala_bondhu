import 'package:shared_preferences/shared_preferences.dart';

import '../../app/constants/user_role.dart';

/// Helper class for token and user session management
/// Uses SharedPreferences for persistent storage
class TokenStorage {
  // Private constructor to prevent instantiation
  TokenStorage._();

  // Storage keys
  static const String _tokenKey = 'auth_token';
  static const String _userRoleKey = 'user_role';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userAvatarKey = 'user_avatar';

  /// Save authentication token
  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      print('✅ Token saved successfully');
    } catch (e) {
      print('❌ Error saving token: $e');
    }
  }

  /// Get authentication token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('❌ Error getting token: $e');
      return null;
    }
  }

  /// Check if token exists
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear authentication token
  static Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      print('✅ Token cleared successfully');
    } catch (e) {
      print('❌ Error clearing token: $e');
    }
  }

  /// Save user role
  static Future<void> saveUserRole(UserRole role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userRoleKey, role.name);
      print('✅ User role saved: ${role.name}');
    } catch (e) {
      print('❌ Error saving user role: $e');
    }
  }

  /// Get user role
  static Future<UserRole?> getUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final roleString = prefs.getString(_userRoleKey);
      
      if (roleString == null) return null;
      
      return UserRole.values.firstWhere(
        (role) => role.name == roleString,
      );
    } catch (e) {
      print('❌ Error getting user role: $e');
      return null;
    }
  }

  /// Save user basic info
  static Future<void> saveUserInfo({
    required String id,
    required String name,
    String? email,
    String? avatar,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, id);
      await prefs.setString(_userNameKey, name);
      if (email != null) {
        await prefs.setString(_userEmailKey, email);
      }
      if (avatar != null) {
        await prefs.setString(_userAvatarKey, avatar);
      }
      print('✅ User info saved');
    } catch (e) {
      print('❌ Error saving user info: $e');
    }
  }

  /// Save user name
  static Future<void> saveUserName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userNameKey, name);
    } catch (e) {
      print('❌ Error saving user name: $e');
    }
  }

  /// Save user email
  static Future<void> saveUserEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userEmailKey, email);
    } catch (e) {
      print('❌ Error saving user email: $e');
    }
  }

  /// Save user avatar
  static Future<void> saveUserAvatar(String avatar) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userAvatarKey, avatar);
    } catch (e) {
      print('❌ Error saving user avatar: $e');
    }
  }

  /// Get user ID
  static Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userIdKey);
    } catch (e) {
      print('❌ Error getting user ID: $e');
      return null;
    }
  }

  /// Get user name
  static Future<String?> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userNameKey);
    } catch (e) {
      print('❌ Error getting user name: $e');
      return null;
    }
  }

  /// Get user email
  static Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userEmailKey);
    } catch (e) {
      print('❌ Error getting user email: $e');
      return null;
    }
  }

  /// Get user avatar
  static Future<String?> getUserAvatar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userAvatarKey);
    } catch (e) {
      print('❌ Error getting user avatar: $e');
      return null;
    }
  }

  /// Clear all stored data (use on logout)
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userRoleKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_userEmailKey);
      await prefs.remove(_userAvatarKey);
      print('✅ All user data cleared');
    } catch (e) {
      print('❌ Error clearing all data: $e');
    }
  }
}
