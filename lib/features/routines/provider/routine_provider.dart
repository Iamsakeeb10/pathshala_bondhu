import 'package:flutter/material.dart';

import '../data/models/routine_models.dart';
import '../data/services/routine_service.dart';

/// Provider for class routines feature
/// Implements in-memory caching
class RoutineProvider extends ChangeNotifier {
  final RoutineService _routineService;

  RoutineResponse? _cachedData;
  bool _isLoading = false;
  String? _errorMessage;

  RoutineProvider() : _routineService = RoutineService();

  // Getters
  RoutineResponse? get data => _cachedData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasData => _cachedData != null;
  bool get isEmpty =>
      _cachedData != null && _cachedData!.childrenRoutines.isEmpty;

  /// Fetch routines
  /// Uses cache if available
  Future<void> fetchRoutines({bool forceRefresh = false}) async {
    // Return cached data if available and not forcing refresh
    if (_cachedData != null && !forceRefresh) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cachedData = await _routineService.getRoutines();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear cache
  void clearCache() {
    _cachedData = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Retry loading
  Future<void> retry() async {
    await fetchRoutines(forceRefresh: true);
  }
}
