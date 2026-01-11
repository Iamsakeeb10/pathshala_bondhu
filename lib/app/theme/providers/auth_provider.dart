import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/user_role.dart';

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
  static const String _authKey = 'is_authenticated';
  static const String _userKey = 'user_data';

  final SharedPreferences _prefs;

  bool _isAuthenticated = false;
  bool _isLoading = false;
  User? _currentUser;

  AuthProvider(this._prefs) {
    _loadAuthState();
  }

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;
  UserRole? get currentUserRole => _currentUser?.role;

  /// Load authentication state from local storage
  Future<void> _loadAuthState() async {
    _isAuthenticated = _prefs.getBool(_authKey) ?? false;

    if (_isAuthenticated) {
      final userJson = _prefs.getString(_userKey);
      if (userJson != null) {
        // TODO: Parse JSON properly when API is added
        _currentUser = User(
          id: '1',
          name: 'Parent User',
          email: 'parent@example.com',
          role: UserRole.parent,
        );
      }
    }

    notifyListeners();
  }

  /// Login user (mock)
  Future<bool> login(String identifier, String password, UserRole role) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _isAuthenticated = true;
    _currentUser = User(
      id: '1',
      name: _getNameByRole(role),
      email: identifier,
      role: role,
    );

    await _prefs.setBool(_authKey, true);
    await _prefs.setString(_userKey, ''); // store JSON later

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Logout user
  Future<void> logout() async {
    _isAuthenticated = false;
    _currentUser = null;

    await _prefs.remove(_authKey);
    await _prefs.remove(_userKey);

    notifyListeners();
  }

  /// Role helpers
  bool get isParent => _currentUser?.role == UserRole.parent;
  bool get isTeacher => _currentUser?.role == UserRole.teacher;

  String _getNameByRole(UserRole role) {
    switch (role) {
      case UserRole.parent:
        return 'Parent User';
      case UserRole.teacher:
        return 'Teacher User';
    }
  }
}
