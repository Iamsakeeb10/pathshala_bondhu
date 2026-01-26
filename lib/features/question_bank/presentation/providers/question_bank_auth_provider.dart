/// Question Bank Authentication Provider
/// Manages authentication state for Question Bank feature

import 'package:flutter/material.dart';

import '../../data/services/question_bank_api_service.dart';
import '../../data/services/question_bank_auth_service.dart';

/// Authentication state for Question Bank
enum QBAuthStatus { initial, checking, authenticated, unauthenticated, error }

class QuestionBankAuthProvider extends ChangeNotifier {
  final QuestionBankAuthService _authService;
  final QuestionBankApiService _apiService;

  QBAuthStatus _status = QBAuthStatus.initial;
  String? _errorMessage;
  String? _email;
  bool _isLoading = false;
  DateTime? _authTimestamp;

  QuestionBankAuthProvider({
    QuestionBankAuthService? authService,
    QuestionBankApiService? apiService,
  }) : _authService = authService ?? QuestionBankAuthService.instance,
       _apiService = apiService ?? QuestionBankApiService();

  // Getters
  QBAuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get email => _email;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == QBAuthStatus.authenticated;
  DateTime? get authTimestamp => _authTimestamp;

  /// Check if session is valid on provider initialization
  Future<void> checkSession() async {
    _status = QBAuthStatus.checking;
    _isLoading = true;
    notifyListeners();

    try {
      final isValid = await _authService.isSessionValid();

      if (isValid) {
        _email = await _authService.getStoredEmail();
        _authTimestamp = await _authService.getAuthTimestamp();
        _status = QBAuthStatus.authenticated;
      } else {
        _status = QBAuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = QBAuthStatus.unauthenticated;
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Login to Question Bank
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.authenticate(email, password);
      _email = email;
      _authTimestamp = DateTime.now();
      _status = QBAuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = QBAuthStatus.error;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout from Question Bank
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _apiService.logout();

    _status = QBAuthStatus.unauthenticated;
    _email = null;
    _authTimestamp = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Handle session expiry (called when API returns 401)
  void handleSessionExpiry() {
    _status = QBAuthStatus.unauthenticated;
    _authTimestamp = null;
    _errorMessage = 'Session expired, please login again';
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    if (_status == QBAuthStatus.error) {
      _status = QBAuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  /// Get remaining session time formatted
  Future<String> getRemainingTimeFormatted() async {
    final remaining = await _authService.getRemainingSessionTime();
    if (remaining == null) return '';

    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;

    if (minutes <= 0 && seconds <= 0) return 'Expired';
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
