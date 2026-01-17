import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/token_storage.dart';
import '../../../features/auth/data/services/auth_service.dart';
import '../../constants/user_role.dart';

/// User model - unified for both parent and teacher
class User {
  final String id;
  final String name;
  final String? email;
  final UserRole role;
  final String? avatarUrl;

  User({
    required this.id,
    required this.name,
    this.email,
    required this.role,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.parent,
      ),
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'avatarUrl': avatarUrl,
    };
  }
}

/// Provider for managing authentication state
class AuthProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  final AuthService _authService;

  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;

  AuthProvider(this._prefs) : _authService = AuthService() {
    _checkAuthStatus();
  }

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  UserRole? get currentUserRole => _currentUser?.role;
  bool get isAuthenticated => _currentUser != null;
  bool get isParent => _currentUser?.role == UserRole.parent;
  bool get isTeacher => _currentUser?.role == UserRole.teacher;

  /// Check authentication status on app launch
  Future<void> _checkAuthStatus() async {
    final hasToken = await TokenStorage.hasToken();

    if (!hasToken) {
      // No token, user is not authenticated
      _currentUser = null;
      notifyListeners();
      return;
    }

    // Token exists, load user info from storage
    final role = await TokenStorage.getUserRole();
    final id = await TokenStorage.getUserId();
    final name = await TokenStorage.getUserName();
    final email = await TokenStorage.getUserEmail();
    final avatar = await TokenStorage.getUserAvatar();

    if (role != null && id != null && name != null) {
      _currentUser = User(
        id: id,
        name: name,
        email: email,
        role: role,
        avatarUrl: avatar,
      );
      notifyListeners();
    } else {
      // Incomplete data, clear everything
      await TokenStorage.clearAll();
      _currentUser = null;
      notifyListeners();
    }
  }

  /// Parent login
  Future<bool> loginAsParent({
    required String parentId,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Call API
      final response = await _authService.parentLogin(
        parentId: parentId,
        password: password,
      );

      // Save token
      await TokenStorage.saveToken(response.token);

      // Save user role
      await TokenStorage.saveUserRole(UserRole.parent);

      // Save user info
      await TokenStorage.saveUserInfo(
        id: response.parent.id.toString(),
        name: response.parent.fatherName,
        email: null, // Parents don't have email in this API
      );

      // Set current user
      _currentUser = User(
        id: response.parent.id.toString(),
        name: response.parent.fatherName,
        email: null,
        role: UserRole.parent,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Teacher login
  Future<bool> loginAsTeacher({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Call API
      final response = await _authService.teacherLogin(
        email: email,
        password: password,
      );

      // Save token
      await TokenStorage.saveToken(response.token);

      // Save user role
      await TokenStorage.saveUserRole(UserRole.teacher);

      // Save user info
      await TokenStorage.saveUserInfo(
        id: response.user.id.toString(),
        name: response.user.name,
        email: response.user.email,
        avatar: response.user.avatar,
      );

      // Set current user
      _currentUser = User(
        id: response.user.id.toString(),
        name: response.user.name,
        email: response.user.email,
        role: UserRole.teacher,
        avatarUrl: response.user.avatar,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Generic login method (for backward compatibility with login screen)
  Future<bool> login(String identifier, String password, UserRole role) async {
    if (role == UserRole.parent) {
      return loginAsParent(parentId: identifier, password: password);
    } else {
      return loginAsTeacher(email: identifier, password: password);
    }
  }

  /// Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await TokenStorage.clearAll();
    _currentUser = null;
    _errorMessage = null;

    _isLoading = false;
    notifyListeners();
  }

  /// Force logout (called by API interceptor on 401/403)
  /// Does NOT set loading state to avoid UI flicker
  Future<void> forceLogout() async {
    await TokenStorage.clearAll();
    _currentUser = null;
    _errorMessage = 'Session expired. Please login again.';
    notifyListeners();
  }

  /// Update current user details (called after profile update)
  Future<void> updateCurrentUser({
    String? name,
    String? email,
    String? avatarUrl,
  }) async {
    if (_currentUser == null) return;

    // Update in storage
    if (name != null) await TokenStorage.saveUserName(name);
    if (email != null) await TokenStorage.saveUserEmail(email);
    if (avatarUrl != null) await TokenStorage.saveUserAvatar(avatarUrl);

    // Update local state
    _currentUser = User(
      id: _currentUser!.id,
      name: name ?? _currentUser!.name,
      email: email ?? _currentUser!.email,
      role: _currentUser!.role,
      avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
    );
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
