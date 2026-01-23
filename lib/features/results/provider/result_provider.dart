import 'package:flutter/material.dart';

import '../data/models/result_models.dart';
import '../data/services/result_service.dart';

class ResultProvider with ChangeNotifier {
  final ResultService _resultService = ResultService();

  ResultResponse? _resultResponse;
  bool _isLoading = false;
  String? _error;

  ResultResponse? get resultResponse => _resultResponse;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasResults =>
      _resultResponse != null && _resultResponse!.childrenResults.isNotEmpty;

  /// Fetch results for all children
  Future<void> fetchResults() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _resultResponse = await _resultService.getResults();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _resultResponse = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear results
  void clearResults() {
    _resultResponse = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
