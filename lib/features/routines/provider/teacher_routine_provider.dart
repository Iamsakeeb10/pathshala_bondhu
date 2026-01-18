import 'package:flutter/material.dart';
import '../data/models/teacher_routine_model.dart';
import '../data/repositories/teacher_routine_repository.dart';

class TeacherRoutineProvider extends ChangeNotifier {
  final TeacherRoutineRepository _repository;

  List<TeacherRoutine> _routines = [];
  bool _isLoading = false;
  String? _errorMessage;

  TeacherRoutineProvider({TeacherRoutineRepository? repository})
      : _repository = repository ?? TeacherRoutineRepository();

  List<TeacherRoutine> get routines => _routines;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchRoutines() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _routines = await _repository.fetchRoutines();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get routines filtered by day
  List<TeacherRoutine> getRoutinesForDay(String day) {
    return _routines.where((routine) => routine.day.toLowerCase() == day.toLowerCase()).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  /// Reset provider state (call on logout)
  void reset() {
    _routines = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
