import 'package:flutter/material.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/token_storage.dart';
import '../../auth/data/models/parent_models.dart';
import '../../auth/data/services/auth_service.dart';

/// Provider for managing student selection (Parent flow only)
/// Student selection is in-memory only and resets on logout/app restart
class StudentProvider extends ChangeNotifier {
  final AuthService _authService;

  List<StudentInfo> _students = [];
  StudentInfo? _selectedStudent;
  bool _isLoading = false;
  String? _errorMessage;

  StudentProvider() : _authService = AuthService();

  // Getters
  List<StudentInfo> get students => _students;
  StudentInfo? get selectedStudent => _selectedStudent;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMultipleStudents => _students.length > 1;
  bool get hasSingleStudent => _students.length == 1;
  bool get hasNoStudents => _students.isEmpty;

  /// Fetch students list from API
  /// Call this after parent login
  Future<void> fetchStudents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.getParentStudents();
      _students = response.students;

      // Auto-select if only one student
      if (_students.length == 1) {
        _selectedStudent = _students.first;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Select a student
  void selectStudent(StudentInfo student) {
    _selectedStudent = student;
    notifyListeners();
  }

  /// Clear selection (used when switching categories or logging out)
  void clearSelection() {
    _selectedStudent = null;
    notifyListeners();
  }

  /// Clear all data (call on logout)
  void clearAll() {
    _students = [];
    _selectedStudent = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Get display name for student (name + class + roll)
  String getStudentDisplayName(StudentInfo student) {
    return '${student.classInfo.name} (Roll: ${student.rollNo})';
  }
}
