import 'package:flutter/material.dart';

import '../data/models/attendance_models.dart';
import '../data/services/attendance_service.dart';

/// Attendance provider - NO caching (always refetch)
class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _service;

  AttendanceResponse? _data;
  bool _isLoading = false;
  String? _errorMessage;

  // Current filters
  String _selectedMonth = 'January';
  int _selectedYear = DateTime.now().year;

  AttendanceProvider() : _service = AttendanceService();

  // Getters
  AttendanceResponse? get data => _data;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasData => _data != null;
  bool get isEmpty => _data != null && _data!.childrenAttendance.isEmpty;
  String get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;

  static const List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// Fetch attendance - always refetch (no caching)
  Future<void> fetchAttendance() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _data = await _service.getAttendance(
        monthName: _selectedMonth,
        year: _selectedYear,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update month filter
  void setMonth(String month) {
    if (_selectedMonth != month) {
      _selectedMonth = month;
      fetchAttendance();
    }
  }

  /// Update year filter
  void setYear(int year) {
    if (_selectedYear != year) {
      _selectedYear = year;
      fetchAttendance();
    }
  }

  Future<void> retry() async {
    await fetchAttendance();
  }
}
