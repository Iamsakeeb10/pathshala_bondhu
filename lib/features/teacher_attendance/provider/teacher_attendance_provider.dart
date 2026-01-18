import 'package:flutter/material.dart';
import '../data/models/teacher_attendance_models.dart';
import '../data/services/teacher_attendance_service.dart';

class TeacherAttendanceProvider extends ChangeNotifier {
  final TeacherAttendanceService _service;

  // State
  bool _isLoading = false;
  String? _errorMessage;
  
  // Selection Data
  List<TeacherClass> _classes = [];
  List<TeacherAcademicSession> _sessions = [];
  
  // Current Selection
  TeacherClass? _selectedClass;
  TeacherAcademicSession? _selectedSession;
  
  // Mark Attendance State
  List<TeacherStudent> _students = [];
  Map<int, String> _attendanceMap = {}; // studentId (int ID) -> status ('present'/'absent')
  bool _isSubmitting = false;

  // History State
  List<AttendanceHistoryRecord> _historyRecords = [];
  DateTime _selectedHistoryDate = DateTime.now();
  bool _isLoadingHistory = false;

  TeacherAttendanceProvider() : _service = TeacherAttendanceService();

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TeacherClass> get classes => _classes;
  List<TeacherAcademicSession> get sessions => _sessions;
  TeacherClass? get selectedClass => _selectedClass;
  TeacherAcademicSession? get selectedSession => _selectedSession;
  
  List<TeacherStudent> get students => _students;
  Map<int, String> get attendanceMap => _attendanceMap;
  bool get isSubmitting => _isSubmitting;
  
  List<AttendanceHistoryRecord> get historyRecords => _historyRecords;
  DateTime get selectedHistoryDate => _selectedHistoryDate;
  bool get isLoadingHistory => _isLoadingHistory;

  /// Fetch initial data (classes and sessions)
  Future<void> fetchInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getClasses(),
        _service.getAcademicSessions(),
      ]);

      _classes = results[0] as List<TeacherClass>;
      _sessions = results[1] as List<TeacherAcademicSession>;
      
      // Auto-select current session if available
      try {
        _selectedSession = _sessions.firstWhere((s) => s.isCurrent == '1');
      } catch (_) {
        if (_sessions.isNotEmpty) _selectedSession = _sessions.first;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectClass(TeacherClass cls) {
    _selectedClass = cls;
    notifyListeners();
  }

  void selectSession(TeacherAcademicSession session) {
    _selectedSession = session;
    notifyListeners();
  }

  /// Initialize attendance screen data
  Future<void> initializeAttendanceScreen(int classId, int sessionId) async {
    // We already have the IDs passed from navigation, but we might want to ensure
    // we have the full objects or just fetch the students directly.
    // For this implementation, we'll fetch students using the IDs.
    
    _isLoading = true;
    _errorMessage = null;
    _attendanceMap.clear();
    notifyListeners();

    try {
      _students = await _service.getStudents(
        classId: classId,
        academicSessionId: sessionId,
      );

      // Default all to present initially? Or leave empty?
      // Requirement: Active Academic Session must be selected by default (handled in selection)
      // Requirement: Select All -> Present/Absent buttons
      // Let's initialize as empty or present? Usually safe to leave unselected or default present.
      // Let's default to present for better UX, or let user check select all.
      // Based on UI req "Select All -> Present", implies they initiate action.
      // But keeping map valid is good.
      
      for (var student in _students) {
        _attendanceMap[student.id] = 'present';
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mark single student
  void markStudent(int studentId, String status) {
    _attendanceMap[studentId] = status;
    notifyListeners();
  }

  /// Mark all students
  void markAll(String status) {
    for (var student in _students) {
      _attendanceMap[student.id] = status;
    }
    notifyListeners();
  }

  /// Submit attendance
  Future<bool> submitAttendance(String date) async {
    if (_selectedClass == null || _selectedSession == null) return false;

    _isSubmitting = true;
    notifyListeners();

    try {
      final entries = _attendanceMap.entries.map((e) {
        return AttendanceSubmissionEntry(
          studentId: e.key,
          status: e.value,
        );
      }).toList();

      final payload = AttendanceSubmissionPayload(
        classId: _selectedClass!.id,
        academicSessionId: _selectedSession!.id,
        date: date,
        attendances: entries,
      );

      await _service.submitAttendance(payload);
      
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  /// Fetch history
  Future<void> fetchHistory(DateTime date) async {
    if (_selectedClass == null || _selectedSession == null) return;

    _selectedHistoryDate = date;
    _isLoadingHistory = true;
    notifyListeners();

    try {
      final dateStr = date.toIso8601String().split('T')[0];
      _historyRecords = await _service.getAttendanceHistory(
        classId: _selectedClass!.id,
        academicSessionId: _selectedSession!.id,
        date: dateStr,
      );
      
      _isLoadingHistory = false;
      notifyListeners();
    } catch (e) {
      // Don't set main error message for history tab failures, maybe distinct error?
      // For now just log or allow UI to show error based on empty + loading state
      print("History fetch error: $e");
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  /// Reset provider state (call on logout)
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _classes = [];
    _sessions = [];
    _selectedClass = null;
    _selectedSession = null;
    _students = [];
    _attendanceMap = {};
    _isSubmitting = false;
    _historyRecords = [];
    _selectedHistoryDate = DateTime.now();
    _isLoadingHistory = false;
    notifyListeners();
  }
}
