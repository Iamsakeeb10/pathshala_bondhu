import 'package:flutter/material.dart';

import '../../teacher_attendance/data/models/teacher_attendance_models.dart';
import '../data/models/teacher_diary_model.dart';
import '../data/repositories/teacher_diary_repository.dart';

class TeacherDiaryProvider extends ChangeNotifier {
  final TeacherDiaryRepository _repository;

  List<TeacherDiary> _diaries = [];
  List<TeacherClass> _classes = [];
  List<TeacherAcademicSession> _sessions = [];
  List<DiarySubject> _subjects = [];

  bool _isLoading = false;
  bool _isMoreLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _lastPage = 1;

  TeacherDiaryProvider({TeacherDiaryRepository? repository})
    : _repository = repository ?? TeacherDiaryRepository();

  List<TeacherDiary> get diaries => _diaries;
  List<TeacherClass> get classes => _classes;
  List<TeacherAcademicSession> get sessions => _sessions;
  List<DiarySubject> get subjects => _subjects;

  bool get isLoading => _isLoading;
  bool get isMoreLoading => _isMoreLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _currentPage < _lastPage;

  Future<void> fetchDiaries({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    } else {
      if (_currentPage >= _lastPage || _isLoading || _isMoreLoading) return;
      _isMoreLoading = true;
      notifyListeners();
      _currentPage++;
    }

    try {
      final response = await _repository.fetchDiaries(page: _currentPage);

      if (refresh) {
        _diaries = response.data;
      } else {
        _diaries.addAll(response.data);
      }

      _currentPage = response.currentPage;
      _lastPage = response.lastPage;
      _isLoading = false;
      _isMoreLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      _isMoreLoading = false;
      notifyListeners();
    }
  }

  Future<TeacherDiary?> getDiary(int id) async {
    try {
      return await _repository.getDiary(id);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  Future<void> createDiary(Map<String, dynamic> diaryData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.createDiary(diaryData);
      // Refresh list after creation
      await fetchDiaries(refresh: true);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateDiary(int id, Map<String, dynamic> diaryData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateDiary(id, diaryData);
      await fetchDiaries(refresh: true);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteDiary(int id) async {
    // We might not want to show full screen loading for delete, but for safety let's do it or handle in UI
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteDiary(id);
      // Remove from local list
      _diaries.removeWhere((d) => d.id == id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchMetadata() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.fetchClasses(),
        _repository.fetchAcademicSessions(),
        _repository.fetchSubjects(),
      ]);

      _classes = results[0] as List<TeacherClass>;
      _sessions = results[1] as List<TeacherAcademicSession>;
      _subjects = results[2] as List<DiarySubject>;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }
}
