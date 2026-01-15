import 'package:flutter/material.dart';

import '../data/models/exam_routine_models.dart';
import '../data/services/exam_routine_service.dart';

/// Provider for exam routines feature
class ExamRoutineProvider extends ChangeNotifier {
  final ExamRoutineService _service;

  ExamRoutineResponse? _cachedData;
  bool _isLoading = false;
  String? _errorMessage;

  ExamRoutineProvider() : _service = ExamRoutineService();

  // Getters
  ExamRoutineResponse? get data => _cachedData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasData => _cachedData != null;
  bool get isEmpty =>
      _cachedData != null && _cachedData!.childrenExamRoutines.isEmpty;

  Future<void> fetchExamRoutines({bool forceRefresh = false}) async {
    if (_cachedData != null && !forceRefresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cachedData = await _service.getExamRoutines();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearCache() {
    _cachedData = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> retry() async {
    await fetchExamRoutines(forceRefresh: true);
  }
}
