import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/attendance_summary_model.dart';
import '../models/teacher_attendance_model.dart';
import '../services/teacher_attendance_service.dart';

/// Provider for managing teacher attendance state
/// Handles attendance listing, filtering, marking, and updates
class TeacherAttendanceListProvider extends ChangeNotifier {
  final TeacherAttendanceService _service;

  // State
  DateTime _selectedDate = DateTime.now();
  AttendanceSummaryModel? _summary;
  List<TeacherAttendanceModel> _attendances = [];
  List<TeacherBasicModel> _allTeachers = [];

  // Filters
  String _selectedStatus = 'all'; // all, present, absent, leave, pending
  String? _selectedDepartment;
  String _searchQuery = '';

  // Loading states
  bool _isLoadingSummary = false;
  bool _isLoadingList = false;
  bool _isMarkingAttendance = false;

  // Error states
  String? _errorMessage;

  TeacherAttendanceListProvider() : _service = TeacherAttendanceService();

  // Getters
  DateTime get selectedDate => _selectedDate;
  AttendanceSummaryModel? get summary => _summary;
  List<TeacherAttendanceModel> get attendances => _attendances;
  List<TeacherAttendanceModel> get filteredAttendances => _applyFilters();
  String get selectedStatus => _selectedStatus;
  String? get selectedDepartment => _selectedDepartment;
  String get searchQuery => _searchQuery;

  bool get isLoadingSummary => _isLoadingSummary;
  bool get isLoadingList => _isLoadingList;
  bool get isMarkingAttendance => _isMarkingAttendance;
  bool get isLoading => _isLoadingSummary || _isLoadingList;
  String? get errorMessage => _errorMessage;

  bool get isToday => DateUtils.isSameDay(_selectedDate, DateTime.now());
  bool get isPastDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    return selected.isBefore(today);
  }

  bool get isFutureDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    return selected.isAfter(today);
  }

  bool get canMarkAttendance => isToday; // Only allow marking for today
  bool get hasPendingTeachers =>
      _summary != null && _summary!.pendingAttendance > 0;

  List<String> get availableDepartments {
    final departments = <String>{};
    for (final attendance in _attendances) {
      departments.add(attendance.teacher.department);
    }
    return departments.toList()..sort();
  }

  /// Load all attendance data (summary + list)
  Future<void> loadAttendanceData() async {
    await Future.wait([_fetchSummary(), _fetchAttendanceList()]);
  }

  /// Fetch attendance summary
  Future<void> _fetchSummary() async {
    _isLoadingSummary = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dateStr = _formatDate(_selectedDate);
      _summary = await _service.getSummary(dateStr);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _summary = null;
    } finally {
      _isLoadingSummary = false;
      notifyListeners();
    }
  }

  /// Fetch attendance list
  Future<void> _fetchAttendanceList() async {
    _isLoadingList = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dateStr = _formatDate(_selectedDate);
      _attendances = await _service.getAttendanceByDate(dateStr);

      // Extract unique teachers for pending calculation
      _allTeachers = _attendances.map((a) => a.teacher).toList();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _attendances = [];
      _allTeachers = [];
    } finally {
      _isLoadingList = false;
      notifyListeners();
    }
  }

  /// Change selected date
  Future<void> changeDate(DateTime newDate) async {
    if (isSameDate(newDate, _selectedDate)) return;

    // Prevent future dates
    if (newDate.isAfter(DateTime.now())) {
      _errorMessage = 'Cannot view future attendance';
      notifyListeners();
      return;
    }

    _selectedDate = newDate;
    _resetFilters();
    await loadAttendanceData();
  }

  /// Go to previous day
  Future<void> previousDay() async {
    final previousDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day - 1,
    );
    await changeDate(previousDate);
  }

  /// Go to next day
  Future<void> nextDay() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day + 1,
    );

    if (nextDate.isAfter(today)) {
      _errorMessage = 'Cannot view future attendance';
      notifyListeners();
      return;
    }

    await changeDate(nextDate);
  }

  /// Mark or update attendance
  Future<bool> markAttendance({
    required int teacherId,
    required String status,
    String? checkInTime,
    String? checkOutTime,
    String? remarks,
  }) async {
    _isMarkingAttendance = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.markAttendance(
        teacherId: teacherId,
        date: _formatDate(_selectedDate),
        status: status,
        checkInTime: status.toLowerCase() == 'present' ? checkInTime : null,
        checkOutTime: status.toLowerCase() == 'present' ? checkOutTime : null,
        remarks: remarks,
      );

      // Update local state
      _updateLocalAttendance(result);

      // Refresh summary
      await _fetchSummary();

      _isMarkingAttendance = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isMarkingAttendance = false;
      notifyListeners();
      return false;
    }
  }

  /// Update local attendance list after successful API call
  void _updateLocalAttendance(TeacherAttendanceModel newAttendance) {
    final index = _attendances.indexWhere(
      (a) => a.teacherId == newAttendance.teacherId,
    );

    if (index >= 0) {
      // Update existing
      _attendances[index] = newAttendance;
    } else {
      // Add new
      _attendances.add(newAttendance);
    }
  }

  /// Set status filter
  void setStatusFilter(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  /// Set department filter
  void setDepartmentFilter(String? department) {
    _selectedDepartment = department;
    notifyListeners();
  }

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Reset all filters
  void resetFilters() {
    _selectedStatus = 'all';
    _selectedDepartment = null;
    _searchQuery = '';
    notifyListeners();
  }

  /// Apply filters to attendance list
  List<TeacherAttendanceModel> _applyFilters() {
    var filtered = List<TeacherAttendanceModel>.from(_attendances);

    // Handle pending status separately
    if (_selectedStatus == 'pending') {
      // Show teachers who don't have attendance marked
      if (_summary != null && _summary!.pendingAttendance > 0) {
        // For now, return empty list for pending
        // In a real app, you'd fetch the list of all teachers
        // and filter out those who have attendance
        return [];
      }
      return [];
    }

    // Status filter (present, absent, leave)
    if (_selectedStatus != 'all') {
      filtered = filtered
          .where((a) => a.status.toLowerCase() == _selectedStatus)
          .toList();
    }

    // Department filter
    if (_selectedDepartment != null && _selectedDepartment!.isNotEmpty) {
      filtered = filtered
          .where((a) => a.teacher.department == _selectedDepartment)
          .toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((a) {
        final name = a.teacher.fullName.toLowerCase();
        final email = a.teacher.email.toLowerCase();
        final dept = a.teacher.department.toLowerCase();
        return name.contains(query) ||
            email.contains(query) ||
            dept.contains(query);
      }).toList();
    }

    return filtered;
  }

  /// Reset filters helper
  void _resetFilters() {
    _selectedStatus = 'all';
    _selectedDepartment = null;
    _searchQuery = '';
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh data (pull-to-refresh)
  Future<void> refresh() async {
    await loadAttendanceData();
  }

  /// Format date to API format (YYYY-MM-DD)
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Check if two dates are the same
  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Get display date string
  String getDisplayDate() {
    final now = DateTime.now();
    if (isSameDate(_selectedDate, now)) {
      return 'Today';
    } else if (isSameDate(
      _selectedDate,
      now.subtract(const Duration(days: 1)),
    )) {
      return 'Yesterday';
    } else {
      return DateFormat('dd MMM yyyy').format(_selectedDate);
    }
  }

  /// Get Bangla display date string
  String getBanglaDisplayDate() {
    final now = DateTime.now();
    if (isSameDate(_selectedDate, now)) {
      return 'আজ';
    } else if (isSameDate(
      _selectedDate,
      now.subtract(const Duration(days: 1)),
    )) {
      return 'গতকাল';
    } else {
      return DateFormat('dd MMM yyyy').format(_selectedDate);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
