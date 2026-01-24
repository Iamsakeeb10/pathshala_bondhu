import 'package:flutter/material.dart';

import '../../auth/data/models/parent_models.dart';
import '../../auth/data/models/teacher_models.dart';
import '../../auth/data/services/auth_service.dart';

enum ProfileType { parent, teacher }

class ProfileProvider extends ChangeNotifier {
  final AuthService _authService;

  ParentUser? _parentProfile;
  TeacherUserWithDetails? _teacherProfile;

  bool _isLoading = false;
  String? _errorMessage;

  ProfileProvider() : _authService = AuthService();

  ParentUser? get parentProfile => _parentProfile;
  TeacherUserWithDetails? get teacherProfile => _teacherProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch profile based on role
  Future<void> fetchProfile(ProfileType type) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (type == ProfileType.parent) {
        _parentProfile = await _authService.getParentProfile();
        _teacherProfile = null; // Clear other role data
      } else {
        _teacherProfile = await _authService.getTeacherProfile();
        _parentProfile = null;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update parent profile
  Future<bool> updateParentProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.updateParentProfile(data);
      // Refresh data
      await fetchProfile(ProfileType.parent);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update teacher profile
  Future<bool> updateTeacherProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.updateTeacherProfile(data);
      // Refresh data
      await fetchProfile(ProfileType.teacher);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear all profile data (called on logout)
  void clear() {
    _parentProfile = null;
    _teacherProfile = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
