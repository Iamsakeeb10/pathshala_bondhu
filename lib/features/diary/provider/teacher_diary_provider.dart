import 'package:flutter/material.dart';
import '../data/models/teacher_diary_model.dart';
import '../../teacher_attendance/data/models/teacher_attendance_models.dart';
import '../data/repositories/teacher_diary_repository.dart';

class TeacherDiaryProvider extends ChangeNotifier {
  final TeacherDiaryRepository _repository;

  List<TeacherDiary> _diaries = [];
  List<TeacherClass> _classes = [];
  List<TeacherAcademicSession> _sessions = [];
  List<DiarySubject> _subjects = [];
  
  bool _isLoading = false;
  String? _errorMessage;

  TeacherDiaryProvider({TeacherDiaryRepository? repository})
      : _repository = repository ?? TeacherDiaryRepository();

  List<TeacherDiary> get diaries => _diaries;
  List<TeacherClass> get classes => _classes;
  List<TeacherAcademicSession> get sessions => _sessions;
  List<DiarySubject> get subjects => _subjects;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDiaries() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _diaries = await _repository.fetchDiaries();
      // Sort by creation date descending
      _diaries.sort((a, b) => (b.diaryDate ?? '').compareTo(a.diaryDate ?? ''));
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createDiary(Map<String, dynamic> diaryData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.createDiary(diaryData);
      // Refresh list after creation
      await fetchDiaries();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      // Re-throw to let UI handle success/error navigation/toast
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
