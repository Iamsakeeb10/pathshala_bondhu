import 'package:flutter/material.dart';

import '../data/models/attendance_models.dart';
import '../data/services/attendance_service.dart';

/// Attendance provider - NO caching (always refetch)
class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _service;

  AttendanceResponse? _data;
  bool _isLoading = false;
  String? _errorMessage;

  // Current filters - using numeric month (1-12)
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  AttendanceProvider() : _service = AttendanceService();

  // Getters
  AttendanceResponse? get data => _data;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasData => _data != null;
  bool get isEmpty => _data != null && _data!.childrenAttendance.isEmpty;
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;

  // Get month name for display
  String get selectedMonthName => months[_selectedMonth - 1];

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
    // Clear old data first to prevent showing stale data
    _data = null;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('Fetching attendance for month: $_selectedMonth, year: $_selectedYear');
      _data = await _service.getAttendance(
        month: _selectedMonth,
        year: _selectedYear,
      );
      debugPrint('Attendance fetched: ${_data?.childrenAttendance.length} students');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching attendance: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update month filter (1-12)
  void setMonth(int month) {
    if (_selectedMonth != month) {
      _selectedMonth = month;
      // Clear data immediately and fetch new
      _data = null;
      notifyListeners();
      fetchAttendance();
    }
  }

  /// Update year filter
  void setYear(int year) {
    if (_selectedYear != year) {
      _selectedYear = year;
      // Clear data immediately and fetch new
      _data = null;
      notifyListeners();
      fetchAttendance();
    }
  }

  Future<void> retry() async {
    await fetchAttendance();
  }
}
