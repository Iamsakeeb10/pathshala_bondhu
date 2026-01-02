import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User roles in the system
enum UserRole { admin, teacher, student, parent }

/// User model
class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
        orElse: () => UserRole.student,
      ),
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'avatarUrl': avatarUrl,
    };
  }
}

/// Provider for managing authentication state
/// Handles login, logout, and user session persistence
class AuthProvider extends ChangeNotifier {
  static const String _authKey = 'is_authenticated';
  static const String _userKey = 'user_data';
  final SharedPreferences _prefs;

  bool _isAuthenticated = false;
  User? _currentUser;
  bool _isLoading = false;

  AuthProvider(this._prefs) {
    _loadAuthState();
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _isAuthenticated;

  /// Get current user
  User? get currentUser => _currentUser;

  /// Get current user role
  UserRole? get currentUserRole => _currentUser?.role;

  /// Check if loading
  bool get isLoading => _isLoading;

  /// Load authentication state from storage
  Future<void> _loadAuthState() async {
    _isAuthenticated = _prefs.getBool(_authKey) ?? false;

    // Load user data if authenticated
    if (_isAuthenticated) {
      final userJson = _prefs.getString(_userKey);
      if (userJson != null) {
        // In production, parse JSON properly
        // For now, create a dummy user
        _currentUser = User(
          id: '1',
          name: 'John Doe',
          email: 'john@example.com',
          role: UserRole.admin,
        );
      }
    }

    notifyListeners();
  }

  /// Login user
  /// In production, this would make an API call
  Future<bool> login(String email, String password, UserRole role) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Mock successful login
    _isAuthenticated = true;
    _currentUser = User(
      id: '1',
      name: _getNameByRole(role),
      email: email,
      role: role,
      avatarUrl: null,
    );

    await _prefs.setBool(_authKey, true);
    await _prefs.setString(_userKey, ''); // Store user JSON in production

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Register new user
  /// In production, this would make an API call
  Future<bool> register(
    String name,
    String email,
    String password,
    UserRole role,
  ) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Mock successful registration
    _isAuthenticated = true;
    _currentUser = User(id: '1', name: name, email: email, role: role);

    await _prefs.setBool(_authKey, true);
    await _prefs.setString(_userKey, ''); // Store user JSON in production

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Logout user
  Future<void> logout() async {
    _isAuthenticated = false;
    _currentUser = null;

    await _prefs.setBool(_authKey, false);
    await _prefs.remove(_userKey);

    notifyListeners();
  }

  /// Check if user has specific role
  bool hasRole(UserRole role) {
    return _currentUser?.role == role;
  }

  /// Check if user is admin
  bool get isAdmin => hasRole(UserRole.admin);

  /// Check if user is teacher
  bool get isTeacher => hasRole(UserRole.teacher);

  /// Check if user is student
  bool get isStudent => hasRole(UserRole.student);

  /// Check if user is parent
  bool get isParent => hasRole(UserRole.parent);

  /// Helper method to get name by role
  String _getNameByRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Admin User';
      case UserRole.teacher:
        return 'Teacher User';
      case UserRole.student:
        return 'Student User';
      case UserRole.parent:
        return 'Parent User';
    }
  }
}
