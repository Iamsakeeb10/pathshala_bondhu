/// Filter state model for Question Bank
/// Used to filter questions by class, subject, type, and marks range

import 'question_model.dart';

class QuestionFilterState {
  final List<int> selectedClassIds;
  final List<int> selectedSubjectIds;
  final List<QuestionType> selectedTypes;
  final double minMarks;
  final double maxMarks;
  final String searchQuery;

  const QuestionFilterState({
    this.selectedClassIds = const [],
    this.selectedSubjectIds = const [],
    this.selectedTypes = const [],
    this.minMarks = 0.5,
    this.maxMarks = 20.0,
    this.searchQuery = '',
  });

  /// Check if any filter is active
  bool get hasActiveFilters {
    return selectedClassIds.isNotEmpty ||
        selectedSubjectIds.isNotEmpty ||
        selectedTypes.isNotEmpty ||
        minMarks > 0.5 ||
        maxMarks < 20.0 ||
        searchQuery.isNotEmpty;
  }

  /// Get count of active filters
  int get activeFilterCount {
    int count = 0;
    if (selectedClassIds.isNotEmpty) count++;
    if (selectedSubjectIds.isNotEmpty) count++;
    if (selectedTypes.isNotEmpty) count++;
    if (minMarks > 0.5 || maxMarks < 20.0) count++;
    return count;
  }

  /// Apply filters to a list of questions
  List<Question> applyTo(List<Question> questions) {
    return questions.where((q) {
      // Filter by class
      if (selectedClassIds.isNotEmpty &&
          !selectedClassIds.contains(q.classId)) {
        return false;
      }

      // Filter by subject
      if (selectedSubjectIds.isNotEmpty &&
          !selectedSubjectIds.contains(q.subjectId)) {
        return false;
      }

      // Filter by type
      if (selectedTypes.isNotEmpty && !selectedTypes.contains(q.questionType)) {
        return false;
      }

      // Filter by marks range
      if (q.marks < minMarks || q.marks > maxMarks) {
        return false;
      }

      // Filter by search query
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchesText = q.questionText.toLowerCase().contains(query);
        final matchesClass = q.className.toLowerCase().contains(query);
        final matchesSubject = q.subjectName.toLowerCase().contains(query);
        if (!matchesText && !matchesClass && !matchesSubject) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  QuestionFilterState copyWith({
    List<int>? selectedClassIds,
    List<int>? selectedSubjectIds,
    List<QuestionType>? selectedTypes,
    double? minMarks,
    double? maxMarks,
    String? searchQuery,
  }) {
    return QuestionFilterState(
      selectedClassIds: selectedClassIds ?? this.selectedClassIds,
      selectedSubjectIds: selectedSubjectIds ?? this.selectedSubjectIds,
      selectedTypes: selectedTypes ?? this.selectedTypes,
      minMarks: minMarks ?? this.minMarks,
      maxMarks: maxMarks ?? this.maxMarks,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// Reset all filters
  QuestionFilterState reset() {
    return const QuestionFilterState();
  }

  /// Toggle class selection
  QuestionFilterState toggleClass(int classId) {
    final newList = List<int>.from(selectedClassIds);
    if (newList.contains(classId)) {
      newList.remove(classId);
    } else {
      newList.add(classId);
    }
    return copyWith(selectedClassIds: newList);
  }

  /// Toggle subject selection
  QuestionFilterState toggleSubject(int subjectId) {
    final newList = List<int>.from(selectedSubjectIds);
    if (newList.contains(subjectId)) {
      newList.remove(subjectId);
    } else {
      newList.add(subjectId);
    }
    return copyWith(selectedSubjectIds: newList);
  }

  /// Toggle type selection
  QuestionFilterState toggleType(QuestionType type) {
    final newList = List<QuestionType>.from(selectedTypes);
    if (newList.contains(type)) {
      newList.remove(type);
    } else {
      newList.add(type);
    }
    return copyWith(selectedTypes: newList);
  }
}
