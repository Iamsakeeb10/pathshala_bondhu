import 'package:flutter/material.dart';

import '../data/models/teacher_model.dart';
import '../data/services/teachers_service.dart';

/// Provider for teachers list feature with pagination support
class TeachersProvider extends ChangeNotifier {
  final TeachersService _service;

  List<TeacherListModel> _teachers = [];
  PaginationInfo? _pagination;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  TeachersProvider() : _service = TeachersService();

  // Getters
  List<TeacherListModel> get teachers => _teachers;
  PaginationInfo? get pagination => _pagination;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasData => _teachers.isNotEmpty;
  bool get isEmpty => !_isLoading && _teachers.isEmpty && _errorMessage == null;
  bool get hasMore => _pagination?.hasMore ?? false;

  /// Fetch teachers list
  /// 
  /// [refresh] - If true, fetches from page 1 and clears existing data
  Future<void> fetchTeachers({bool refresh = false}) async {
    if (_isLoading || _isLoadingMore) return;

    final page = refresh ? 1 : (_pagination?.currentPage ?? 0) + 1;

    if (refresh) {
      _isLoading = true;
      _errorMessage = null;
      _teachers.clear();
    } else {
      // Check if we have more pages before loading more
      if (_pagination != null && !_pagination!.hasMore) return;
      _isLoadingMore = true;
    }
    notifyListeners();

    try {
      final response = await _service.getTeachers(page: page, perPage: 25);

      if (refresh) {
        _teachers = response.teachers;
      } else {
        _teachers.addAll(response.teachers);
      }

      _pagination = response.pagination;
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Load more teachers (pagination)
  Future<void> loadMore() async {
    if (!hasMore || _isLoadingMore) return;
    await fetchTeachers(refresh: false);
  }

  /// Retry after error
  Future<void> retry() async {
    await fetchTeachers(refresh: true);
  }

  /// Reset provider state (call on logout)
  void reset() {
    _teachers = [];
    _pagination = null;
    _isLoading = false;
    _isLoadingMore = false;
    _errorMessage = null;
    notifyListeners();
  }
}
