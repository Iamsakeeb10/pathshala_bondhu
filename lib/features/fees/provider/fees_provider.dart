import 'package:flutter/material.dart';

import '../data/models/fees_models.dart';
import '../data/services/fees_service.dart';

/// Fees provider - NO caching
class FeesProvider extends ChangeNotifier {
  final FeesService _service;

  FeesResponse? _data;
  bool _isLoading = false;
  String? _errorMessage;
  int _selectedYear = DateTime.now().year;

  FeesProvider() : _service = FeesService();

  FeesResponse? get data => _data;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasData => _data != null;
  bool get isEmpty => _data != null && _data!.childrenFees.isEmpty;
  int get selectedYear => _selectedYear;

  Future<void> fetchFees() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _data = await _service.getFees(year: _selectedYear.toString());
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  void setYear(int year) {
    if (_selectedYear != year) {
      _selectedYear = year;
      fetchFees();
    }
  }

  Future<void> retry() async {
    await fetchFees();
  }
}
