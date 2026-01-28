/// Question Bank List Provider
/// Manages question list state, pagination, filtering, and CRUD operations

import 'package:flutter/material.dart';

import '../../data/models/filter_state_model.dart';
import '../../data/models/question_model.dart';
import '../../data/services/question_bank_api_service.dart';

class QuestionBankListProvider extends ChangeNotifier {
  final QuestionBankApiService _apiService;

  // Question list state
  List<Question> _questions = [];
  List<Question> _filteredQuestions = [];
  bool _isLoading = false;
  bool _isMoreLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;

  // Filter state
  QuestionFilterState _filterState = const QuestionFilterState();

  // Classes and subjects for filtering
  List<QuestionClass> _classes = [];
  List<QuestionSubject> _subjects = [];
  bool _isMetadataLoading = false;

  // Undo support
  Question? _lastDeletedQuestion;
  int? _lastDeletedIndex;

  QuestionBankListProvider({QuestionBankApiService? apiService})
    : _apiService = apiService ?? QuestionBankApiService();

  // Getters
  List<Question> get questions => _filteredQuestions;
  List<Question> get allQuestions => _questions;
  bool get isLoading => _isLoading;
  bool get isMoreLoading => _isMoreLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _currentPage < _lastPage;
  int get total => _total;
  int get currentPage => _currentPage;
  QuestionFilterState get filterState => _filterState;
  List<QuestionClass> get classes => _classes;
  List<QuestionSubject> get subjects => _subjects;
  bool get isMetadataLoading => _isMetadataLoading;
  bool get isEmpty => _questions.isEmpty && !_isLoading;
  bool get hasActiveFilters => _filterState.hasActiveFilters;

  /// Fetch questions with pagination
  Future<void> fetchQuestions({bool refresh = false}) async {
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
      final response = await _apiService.fetchQuestions(page: _currentPage);

      if (refresh) {
        _questions = response.data;
      } else {
        _questions.addAll(response.data);
      }

      _currentPage = response.currentPage;
      _lastPage = response.lastPage;
      _total = response.total;

      _applyFilters();
      _isLoading = false;
      _isMoreLoading = false;
      notifyListeners();
    } on SessionExpiredException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      _isMoreLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      _isMoreLoading = false;
      notifyListeners();
    }
  }

  /// Fetch classes and subjects for filtering
  Future<void> fetchMetadata() async {
    if (_classes.isNotEmpty && _subjects.isNotEmpty) return;

    _isMetadataLoading = true;
    notifyListeners();

    try {
      _classes = await _apiService.fetchClasses();
      _subjects = await _apiService.fetchSubjects();
    } catch (e) {
      print('Error fetching metadata: $e');
    }

    _isMetadataLoading = false;
    notifyListeners();
  }

  /// Get single question
  Future<Question?> getQuestion(int id) async {
    try {
      return await _apiService.getQuestion(id);
    } on SessionExpiredException {
      rethrow;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  /// Create new question
  Future<Question?> createQuestion(Question question) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await _apiService.createQuestion(question);

      // Add to list
      _questions.insert(0, created);
      _total++;
      _applyFilters();

      _isLoading = false;
      notifyListeners();
      return created;
    } on SessionExpiredException {
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Update existing question
  Future<Question?> updateQuestion(int id, Question question) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _apiService.updateQuestion(id, question);

      // Update in list
      final index = _questions.indexWhere((q) => q.id == id);
      if (index != -1) {
        _questions[index] = updated;
        _applyFilters();
      }

      _isLoading = false;
      notifyListeners();
      return updated;
    } on SessionExpiredException {
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Delete question (with optimistic UI)
  Future<bool> deleteQuestion(int id) async {
    // Store for undo
    final index = _questions.indexWhere((q) => q.id == id);
    if (index == -1) return false;

    _lastDeletedQuestion = _questions[index];
    _lastDeletedIndex = index;

    // Optimistic removal
    _questions.removeAt(index);
    _total--;
    _applyFilters();
    notifyListeners();

    try {
      await _apiService.deleteQuestion(id);
      return true;
    } on SessionExpiredException {
      // Revert on error
      _undoDeleteInternal();
      rethrow;
    } catch (e) {
      // Revert on error
      _undoDeleteInternal();
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Undo last delete
  Future<bool> undoDelete() async {
    if (_lastDeletedQuestion == null) return false;

    try {
      // Re-create on server
      final restored = await _apiService.createQuestion(_lastDeletedQuestion!);

      // Add back to list at original position
      if (_lastDeletedIndex != null &&
          _lastDeletedIndex! <= _questions.length) {
        _questions.insert(_lastDeletedIndex!, restored);
      } else {
        _questions.insert(0, restored);
      }

      _total++;
      _applyFilters();

      _lastDeletedQuestion = null;
      _lastDeletedIndex = null;

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to restore question';
      notifyListeners();
      return false;
    }
  }

  /// Internal undo (for reverting optimistic UI)
  void _undoDeleteInternal() {
    if (_lastDeletedQuestion != null && _lastDeletedIndex != null) {
      _questions.insert(_lastDeletedIndex!, _lastDeletedQuestion!);
      _total++;
      _applyFilters();
      _lastDeletedQuestion = null;
      _lastDeletedIndex = null;
    }
  }

  /// Clear undo state (call after undo window expires)
  void clearUndoState() {
    _lastDeletedQuestion = null;
    _lastDeletedIndex = null;
  }

  /// Update filter state
  void updateFilters(QuestionFilterState newState) {
    _filterState = newState;
    _applyFilters();
    notifyListeners();
  }

  /// Update search query with debounce
  void updateSearchQuery(String query) {
    _filterState = _filterState.copyWith(searchQuery: query);
    _applyFilters();
    notifyListeners();
  }

  /// Reset all filters
  void resetFilters() {
    _filterState = const QuestionFilterState();
    _applyFilters();
    notifyListeners();
  }

  /// Apply current filters to questions
  void _applyFilters() {
    _filteredQuestions = _filterState.applyTo(_questions);
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get question type counts for filter display
  Map<QuestionType, int> getTypeCounts() {
    final counts = <QuestionType, int>{};
    for (final type in QuestionType.values) {
      counts[type] = _questions.where((q) => q.questionType == type).length;
    }
    return counts;
  }

  /// Get class name by ID
  String getClassName(int classId) {
    return _classes
        .firstWhere(
          (c) => c.id == classId,
          orElse: () => QuestionClass(id: classId, name: 'Class $classId'),
        )
        .name;
  }

  /// Get subject name by ID
  String getSubjectName(int subjectId) {
    return _subjects
        .firstWhere(
          (s) => s.id == subjectId,
          orElse: () =>
              QuestionSubject(id: subjectId, name: 'Subject $subjectId'),
        )
        .name;
  }
}
