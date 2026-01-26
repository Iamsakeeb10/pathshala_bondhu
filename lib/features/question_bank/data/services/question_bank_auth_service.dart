/// Question Bank Authentication Service
/// Handles secure token storage and session management with 30-minute validity

import 'package:shared_preferences/shared_preferences.dart';

/// Keys for Question Bank authentication storage
class _QBStorageKeys {
  static const String token = 'qb_auth_token';
  static const String timestamp = 'qb_auth_timestamp';
  static const String email = 'qb_auth_email';
}

/// Question Bank Authentication Service
/// Uses SharedPreferences for token storage (flutter_secure_storage can be added later)
/// Session validity: 30 minutes from last authentication
class QuestionBankAuthService {
  // Private constructor for singleton
  QuestionBankAuthService._();
  static final QuestionBankAuthService _instance = QuestionBankAuthService._();
  static QuestionBankAuthService get instance => _instance;

  /// Session validity duration
  static const Duration sessionValidity = Duration(minutes: 30);

  /// Save authentication token with timestamp
  Future<void> saveToken(String token, {String? email}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_QBStorageKeys.token, token);
    await prefs.setString(
      _QBStorageKeys.timestamp,
      DateTime.now().toIso8601String(),
    );
    if (email != null) {
      await prefs.setString(_QBStorageKeys.email, email);
    }
    print('✅ Question Bank token saved successfully');
  }

  /// Get stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_QBStorageKeys.token);
  }

  /// Get authentication timestamp
  Future<DateTime?> getAuthTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final timestampStr = prefs.getString(_QBStorageKeys.timestamp);
    if (timestampStr == null) return null;
    return DateTime.tryParse(timestampStr);
  }

  /// Get stored email
  Future<String?> getStoredEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_QBStorageKeys.email);
  }

  /// Check if session is still valid (within 30 minutes)
  Future<bool> isSessionValid() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    final timestamp = await getAuthTimestamp();
    if (timestamp == null) {
      return false;
    }

    final now = DateTime.now();
    final difference = now.difference(timestamp);
    final isValid = difference < sessionValidity;

    if (!isValid) {
      print(
        '⚠️ Question Bank session expired (${difference.inMinutes} minutes)',
      );
    }

    return isValid;
  }

  /// Get remaining session time
  Future<Duration?> getRemainingSessionTime() async {
    final timestamp = await getAuthTimestamp();
    if (timestamp == null) return null;

    final now = DateTime.now();
    final expiryTime = timestamp.add(sessionValidity);
    final remaining = expiryTime.difference(now);

    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Refresh session timestamp (extends session without re-authentication)
  Future<void> refreshSession() async {
    final token = await getToken();
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _QBStorageKeys.timestamp,
        DateTime.now().toIso8601String(),
      );
      print('✅ Question Bank session refreshed');
    }
  }

  /// Clear all Question Bank authentication data
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_QBStorageKeys.token);
    await prefs.remove(_QBStorageKeys.timestamp);
    await prefs.remove(_QBStorageKeys.email);
    print('✅ Question Bank session cleared');
  }

  /// Check if user has ever authenticated
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
