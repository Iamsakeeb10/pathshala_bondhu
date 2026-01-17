import 'package:flutter/material.dart';
import '../data/repositories/parent_diary_repository.dart';
import '../data/models/parent_diary_model.dart';

class ParentDiaryProvider extends ChangeNotifier {
  final ParentDiaryRepository _repository;

  ParentDiaryResponse? _diaryResponse;
  bool _isLoading = false;
  String? _errorMessage;
  DateTime _selectedDate = DateTime.now();
  String? _selectedStudentId;

  ParentDiaryProvider({ParentDiaryRepository? repository})
      : _repository = repository ?? ParentDiaryRepository();

  ParentDiaryResponse? get diaryResponse => _diaryResponse;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime get selectedDate => _selectedDate;
  String? get selectedStudentId => _selectedStudentId;

  // Get diaries for the specifically selected student
  List<ParentDiaryEntry> get currentStudentDiaries {
    if (_diaryResponse == null || _selectedStudentId == null) return [];
    
    final studentData = _diaryResponse!.childrenDiaries.firstWhere(
      (child) => child.studentId == _selectedStudentId,
      orElse: () => ParentChildDiary(
        studentName: '',
        studentId: '',
        classInfo: '',
        academicSession: '',
        diaries: [],
      ),
    );
    
    return studentData.diaries;
  }
  
  // Get student info
  ParentChildDiary? get currentStudentInfo {
    if (_diaryResponse == null || _selectedStudentId == null) return null;
     try {
       return _diaryResponse!.childrenDiaries.firstWhere(
        (child) => child.studentId == _selectedStudentId,
      );
     } catch (_) {
       return null;
     }
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    fetchDiaries();
  }
  
  void setSelectedStudent(String studentId) {
    _selectedStudentId = studentId;
    notifyListeners();
  }

  Future<void> fetchDiaries() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _diaryResponse = await _repository.fetchDiaries(date: _selectedDate);
      
      // If student ID is not set yet (first load), and we have children, pick the first one?
      // Actually, navigation should set the student ID beforehand or we pick one.
      // But typically, the screen is opened for a specific student.
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }
}
