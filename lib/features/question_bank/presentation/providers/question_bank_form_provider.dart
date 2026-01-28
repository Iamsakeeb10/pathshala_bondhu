/// Question Bank Form Provider
/// Manages form state for creating/editing questions

import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/models/question_model.dart';
import '../../data/services/question_bank_draft_service.dart';

/// Form step enum
enum FormStep { selectType, basicInfo, typeSpecific, preview }

class QuestionBankFormProvider extends ChangeNotifier {
  final QuestionBankDraftService _draftService;

  // Form state
  FormStep _currentStep = FormStep.selectType;
  QuestionType? _selectedType;
  QuestionClass? _selectedClass;
  QuestionSubject? _selectedSubject;
  double _marks = 1.0;
  String _questionText = '';
  List<QuestionOption> _options = [];
  String _explanation = '';
  String _correctAnswer = '';
  int? _wordLimit;
  List<String> _solutionSteps = [];
  List<String> _blankAnswers = [];
  List<Map<String, String>> _matchingPairs = [];
  String _stimulus = '';
  List<Map<String, dynamic>> _subQuestions = [];

  // Edit mode
  Question? _editingQuestion;
  bool get isEditMode => _editingQuestion != null;

  // Validation
  bool _isValid = false;
  Map<String, String> _validationErrors = {};

  // Auto-save
  Timer? _autoSaveTimer;
  bool _isDraft = false;
  DateTime? _draftTimestamp;

  // Loading state
  bool _isLoading = false;

  QuestionBankFormProvider({QuestionBankDraftService? draftService})
    : _draftService = draftService ?? QuestionBankDraftService.instance {
    _initializeDefaults();
  }

  // Getters
  FormStep get currentStep => _currentStep;
  QuestionType? get selectedType => _selectedType;
  QuestionClass? get selectedClass => _selectedClass;
  QuestionSubject? get selectedSubject => _selectedSubject;
  double get marks => _marks;
  String get questionText => _questionText;
  List<QuestionOption> get options => _options;
  String get explanation => _explanation;
  String get correctAnswer => _correctAnswer;
  int? get wordLimit => _wordLimit;
  List<String> get solutionSteps => _solutionSteps;
  List<String> get blankAnswers => _blankAnswers;
  List<Map<String, String>> get matchingPairs => _matchingPairs;
  String get stimulus => _stimulus;
  List<Map<String, dynamic>> get subQuestions => _subQuestions;
  bool get isValid => _isValid;
  Map<String, String> get validationErrors => _validationErrors;
  bool get isDraft => _isDraft;
  DateTime? get draftTimestamp => _draftTimestamp;
  bool get isLoading => _isLoading;
  Question? get editingQuestion => _editingQuestion;

  /// Initialize with defaults from storage
  Future<void> _initializeDefaults() async {
    // Initialize matching pairs with 2 empty pairs
    _matchingPairs = [
      {'left': '', 'right': ''},
      {'left': '', 'right': ''},
    ];
    // Initialize sub-questions with 1 empty sub-question
    _subQuestions = [];
  }

  /// Set question type and move to next step
  void setQuestionType(QuestionType type) {
    _selectedType = type;
    _initializeOptionsForType(type);
    _draftService.saveRecentType(type);
    _currentStep = FormStep.basicInfo;
    _validate();
    notifyListeners();
    _scheduleDraftSave();
  }

  /// Set selected class
  void setSelectedClass(QuestionClass? qClass) {
    _selectedClass = qClass;
    _validate();
    notifyListeners();
    _scheduleDraftSave();
  }

  /// Set selected subject
  void setSelectedSubject(QuestionSubject? subject) {
    _selectedSubject = subject;
    _validate();
    notifyListeners();
    _scheduleDraftSave();
  }

  /// Set marks
  void setMarks(double marks) {
    _marks = marks;
    _validate();
    notifyListeners();
    _scheduleDraftSave();
  }

  /// Set question text
  void setQuestionText(String text) {
    _questionText = text;
    _validate();
    notifyListeners();
    _scheduleDraftSave();
  }

  /// Set explanation
  void setExplanation(String explanation) {
    _explanation = explanation;
    notifyListeners();
    _scheduleDraftSave();
  }

  /// Set correct answer text (for True/False, Short Answer, Math, etc.)
  void setCorrectAnswerText(String answer) {
    _correctAnswer = answer;
    _validate();
    notifyListeners();
    _scheduleDraftSave();
  }

  /// Set word limit (for Essay and Short Answer)
  void setWordLimit(int? limit) {
    _wordLimit = limit;
    notifyListeners();
    _scheduleDraftSave();
  }

  /// Set stimulus (for Creative Questions)
  void setStimulus(String stimulus) {
    _stimulus = stimulus;
    notifyListeners();
    _scheduleDraftSave();
  }

  /// Initialize default options based on question type
  void _initializeOptionsForType(QuestionType type) {
    switch (type) {
      case QuestionType.mcq:
        _options = [
          QuestionOption(text: '', isCorrect: false),
          QuestionOption(text: '', isCorrect: false),
          QuestionOption(text: '', isCorrect: false),
          QuestionOption(text: '', isCorrect: false),
        ];
        break;
      case QuestionType.trueFalse:
        // For T/F we use _correctAnswer instead of options
        _options = [];
        _correctAnswer = '';
        break;
      case QuestionType.matching:
        _matchingPairs = [
          {'left': '', 'right': ''},
          {'left': '', 'right': ''},
        ];
        break;
      case QuestionType.fillBlank:
        _blankAnswers = [];
        break;
      case QuestionType.mathProblem:
        _solutionSteps = [];
        _correctAnswer = '';
        break;
      case QuestionType.creative:
        _stimulus = '';
        _subQuestions = [];
        break;
      default:
        _options = [];
    }
  }

  // ========== MCQ Options Methods ==========

  /// Initialize MCQ options with exactly 4 empty options (Bangladeshi standard)
  void initializeMCQOptions() {
    if (_selectedType == QuestionType.mcq && _options.length != 4) {
      _options = List.generate(
        4,
        (index) => QuestionOption(text: '', isCorrect: false),
      );
      notifyListeners();
    }
  }

  /// Update options (for MCQ)
  void updateOptions(List<QuestionOption> options) {
    _options = options;
    _validate();
    notifyListeners();
    _scheduleDraftSave();
  }

  /// Add new option (Not used for MCQ - always exactly 4 options)
  void addOption() {
    // MCQ always has exactly 4 options - no adding allowed
    if (_selectedType == QuestionType.mcq) return;

    _options.add(QuestionOption(text: '', isCorrect: false));
    _validate();
    notifyListeners();
  }

  /// Remove option at index (Not used for MCQ - always exactly 4 options)
  void removeOption(int index) {
    // MCQ always has exactly 4 options - no removing allowed
    if (_selectedType == QuestionType.mcq) return;
    if (_options.length <= 2) return;
    _options.removeAt(index);
    _validate();
    notifyListeners();
  }

  /// Update single option
  void updateOption(int index, QuestionOption option) {
    if (index < 0 || index >= _options.length) return;
    _options[index] = option;
    _validate();
    notifyListeners();
    _scheduleDraftSave();
  }

  /// Set correct answer for MCQ (marks the correct option)
  void setCorrectAnswer(int index) {
    if (_selectedType == QuestionType.mcq) {
      _options = _options.asMap().entries.map((entry) {
        return entry.value.copyWith(isCorrect: entry.key == index);
      }).toList();
    }
    _validate();
    notifyListeners();
    _scheduleDraftSave();
  }

  /// Reorder options
  void reorderOptions(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final option = _options.removeAt(oldIndex);
    _options.insert(newIndex, option);
    notifyListeners();
    _scheduleDraftSave();
  }

  // ========== Matching Pairs Methods ==========

  /// Add matching pair
  void addMatchingPair() {
    if (_matchingPairs.length >= 10) return;
    _matchingPairs.add({'left': '', 'right': ''});
    _validate();
    notifyListeners();
  }

  /// Remove matching pair
  void removeMatchingPair(int index) {
    if (_matchingPairs.length <= 2) return;
    _matchingPairs.removeAt(index);
    _validate();
    notifyListeners();
  }

  /// Update matching pair
  void updateMatchingPair(int index, {String? left, String? right}) {
    if (index < 0 || index >= _matchingPairs.length) return;
    if (left != null) _matchingPairs[index]['left'] = left;
    if (right != null) _matchingPairs[index]['right'] = right;
    _validate();
    notifyListeners();
    _scheduleDraftSave();
  }

  // ========== Fill in the Blanks Methods ==========

  /// Update blank answer at index
  void updateBlankAnswer(int index, String answer) {
    while (_blankAnswers.length <= index) {
      _blankAnswers.add('');
    }
    _blankAnswers[index] = answer;
    _validate();
    notifyListeners();
    _scheduleDraftSave();
  }

  // ========== Math Problem Methods ==========

  /// Add solution step
  void addSolutionStep() {
    _solutionSteps.add('');
    notifyListeners();
  }

  /// Remove solution step
  void removeSolutionStep(int index) {
    if (index >= 0 && index < _solutionSteps.length) {
      _solutionSteps.removeAt(index);
      notifyListeners();
    }
  }

  /// Update solution step
  void updateSolutionStep(int index, String step) {
    if (index >= 0 && index < _solutionSteps.length) {
      _solutionSteps[index] = step;
      notifyListeners();
      _scheduleDraftSave();
    }
  }

  /// Reorder solution steps
  void reorderSolutionSteps(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final step = _solutionSteps.removeAt(oldIndex);
    _solutionSteps.insert(newIndex, step);
    notifyListeners();
    _scheduleDraftSave();
  }

  // ========== Creative Question Methods ==========

  /// Add sub-question
  void addSubQuestion() {
    if (_subQuestions.length >= 6) return;
    _subQuestions.add({'text': '', 'marks': 2, 'level': 'knowledge'});
    _validate();
    notifyListeners();
  }

  /// Remove sub-question
  void removeSubQuestion(int index) {
    if (_subQuestions.length <= 1) return;
    _subQuestions.removeAt(index);
    _validate();
    notifyListeners();
  }

  /// Update sub-question
  void updateSubQuestion(int index, {String? text, int? marks, String? level}) {
    if (index < 0 || index >= _subQuestions.length) return;
    if (text != null) _subQuestions[index]['text'] = text;
    if (marks != null) _subQuestions[index]['marks'] = marks;
    if (level != null) _subQuestions[index]['level'] = level;
    _validate();
    notifyListeners();
    _scheduleDraftSave();
  }

  // ========== Basic Info Methods ==========

  /// Update basic info (legacy method for compatibility)
  void updateBasicInfo({
    int? classId,
    int? subjectId,
    double? marks,
    String? questionText,
  }) {
    if (marks != null) _marks = marks;
    if (questionText != null) _questionText = questionText;

    _validate();
    notifyListeners();
    _scheduleDraftSave();
  }

  /// Navigate to specific step
  void goToStep(FormStep step) {
    // Validate before moving forward
    if (step.index > _currentStep.index) {
      _validate();
      if (!_canProceedFromCurrentStep()) return;
    }
    _currentStep = step;
    notifyListeners();
  }

  /// Go to next step
  void nextStep() {
    _validate();
    if (!_canProceedFromCurrentStep()) return;

    final nextIndex = _currentStep.index + 1;
    if (nextIndex < FormStep.values.length) {
      _currentStep = FormStep.values[nextIndex];
      notifyListeners();
    }
  }

  /// Go to previous step
  void previousStep() {
    final prevIndex = _currentStep.index - 1;
    if (prevIndex >= 0) {
      _currentStep = FormStep.values[prevIndex];
      notifyListeners();
    }
  }

  /// Check if can proceed from current step
  bool _canProceedFromCurrentStep() {
    switch (_currentStep) {
      case FormStep.selectType:
        return _selectedType != null;
      case FormStep.basicInfo:
        return _selectedClass != null &&
            _selectedSubject != null &&
            _questionText.isNotEmpty &&
            _marks >= 0.5;
      case FormStep.typeSpecific:
        return _validateTypeSpecific();
      case FormStep.preview:
        return true;
    }
  }

  /// Validate type-specific fields
  bool _validateTypeSpecific() {
    if (_selectedType == null) return false;

    switch (_selectedType!) {
      case QuestionType.mcq:
        // Exactly 4 options, all filled, exactly 1 correct (Bangladeshi standard)
        if (_options.length != 4) return false;
        final allFilled = _options.every((o) => o.text.trim().isNotEmpty);
        final correctCount = _options.where((o) => o.isCorrect).length;
        return allFilled && correctCount == 1;

      case QuestionType.trueFalse:
        // Must have selected true or false
        return _correctAnswer == 'true' || _correctAnswer == 'false';

      case QuestionType.matching:
        // At least 2 pairs with both left and right filled
        final validPairs = _matchingPairs
            .where(
              (p) =>
                  (p['left']?.isNotEmpty ?? false) &&
                  (p['right']?.isNotEmpty ?? false),
            )
            .length;
        return validPairs >= 2;

      case QuestionType.fillBlank:
        final hasBlank = _questionText.contains(
          RegExp(r'_{3,}|\[blank\]|\[শূন্যস্থান\]'),
        );
        return hasBlank;

      case QuestionType.creative:
        // At least 1 sub-question with text
        return _subQuestions.any(
          (sq) => (sq['text'] as String?)?.isNotEmpty == true,
        );

      case QuestionType.essay:
        // Word limit should be set
        return _wordLimit != null && _wordLimit! > 0;

      case QuestionType.mathProblem:
        // Should have a correct answer
        return _correctAnswer.isNotEmpty;

      default:
        return true;
    }
  }

  /// Full validation
  void _validate() {
    _validationErrors.clear();

    // Type validation
    if (_selectedType == null && _currentStep != FormStep.selectType) {
      _validationErrors['type'] = 'Please select a question type';
    }

    // Basic info validation
    if (_currentStep.index >= FormStep.basicInfo.index) {
      if (_selectedClass == null) {
        _validationErrors['class'] = 'Please select a class';
      }
      if (_selectedSubject == null) {
        _validationErrors['subject'] = 'Please select a subject';
      }
      if (_questionText.isEmpty) {
        _validationErrors['questionText'] = 'Please enter the question text';
      }
      if (_marks < 0.5) {
        _validationErrors['marks'] = 'Minimum marks is 0.5';
      }
    }

    // Type-specific validation
    if (_currentStep.index >= FormStep.typeSpecific.index &&
        _selectedType != null) {
      _validateTypeSpecificFields();
    }

    _isValid = _validationErrors.isEmpty && _canProceedFromCurrentStep();
  }

  void _validateTypeSpecificFields() {
    switch (_selectedType!) {
      case QuestionType.mcq:
        if (_options.length != 4) {
          _validationErrors['options'] =
              'MCQ must have exactly 4 options (A, B, C, D)';
          return;
        }
        final emptyOptions = _options.where((o) => o.text.trim().isEmpty);
        if (emptyOptions.isNotEmpty) {
          _validationErrors['options'] = 'All MCQ options are required';
        }
        final correctCount = _options.where((o) => o.isCorrect).length;
        if (correctCount != 1) {
          _validationErrors['correct'] = 'Please select one correct answer';
        }
        break;

      case QuestionType.trueFalse:
        if (_correctAnswer != 'true' && _correctAnswer != 'false') {
          _validationErrors['correct'] = 'Select True or False';
        }
        break;

      case QuestionType.matching:
        final validPairs = _matchingPairs
            .where(
              (p) =>
                  (p['left']?.isNotEmpty ?? false) &&
                  (p['right']?.isNotEmpty ?? false),
            )
            .length;
        if (validPairs < 2) {
          _validationErrors['matching'] =
              'Add at least 2 complete matching pairs';
        }
        break;

      case QuestionType.fillBlank:
        final hasBlank = _questionText.contains(
          RegExp(r'_{3,}|\[blank\]|\[শূন্যস্থান\]'),
        );
        if (!hasBlank) {
          _validationErrors['blanks'] =
              'Add blanks using ___ or [blank] in the question';
        }
        break;

      case QuestionType.creative:
        if (_subQuestions.isEmpty ||
            !_subQuestions.any(
              (sq) => (sq['text'] as String?)?.isNotEmpty == true,
            )) {
          _validationErrors['subQuestions'] = 'Add at least one sub-question';
        }
        break;

      case QuestionType.essay:
        if (_wordLimit == null || _wordLimit! <= 0) {
          _validationErrors['wordLimit'] = 'Select a word limit';
        }
        break;

      case QuestionType.mathProblem:
        if (_correctAnswer.isEmpty) {
          _validationErrors['answer'] = 'Enter the final answer';
        }
        break;

      default:
        break;
    }
  }

  /// Build question from form state
  Question buildQuestion() {
    // For True/False questions, build options array with correct is_correct flag
    List<QuestionOption>? options;
    if (_selectedType == QuestionType.mcq) {
      options = _options;
    } else if (_selectedType == QuestionType.trueFalse) {
      // Build True/False options with correct answer marked
      final isTrue = _correctAnswer.toLowerCase().trim() == 'true';
      
      // If editing, try to preserve existing option IDs
      if (_editingQuestion?.options != null && 
          _editingQuestion!.options!.length >= 2) {
        final existingOptions = _editingQuestion!.options!;
        options = [
          QuestionOption(
            id: existingOptions[0].id,
            text: 'True',
            isCorrect: isTrue,
          ),
          QuestionOption(
            id: existingOptions.length > 1 ? existingOptions[1].id : null,
            text: 'False',
            isCorrect: !isTrue,
          ),
        ];
        print('🔍 [BuildQuestion Debug] True/False options built (preserving IDs):');
        print('🔍 [BuildQuestion Debug]   True: id=${options[0].id}, isCorrect=$isTrue');
        print('🔍 [BuildQuestion Debug]   False: id=${options[1].id}, isCorrect=${!isTrue}');
      } else {
        options = [
          QuestionOption(text: 'True', isCorrect: isTrue),
          QuestionOption(text: 'False', isCorrect: !isTrue),
        ];
        print('🔍 [BuildQuestion Debug] True/False options built (new):');
        print('🔍 [BuildQuestion Debug]   True: isCorrect=$isTrue');
        print('🔍 [BuildQuestion Debug]   False: isCorrect=${!isTrue}');
      }
    }
    
    return Question(
      id: _editingQuestion?.id,
      classId: _selectedClass?.id ?? 0,
      subjectId: _selectedSubject?.id ?? 0,
      questionType: _selectedType!,
      questionText: _questionText,
      marks: _marks,
      options: options,
      expectedAnswer: _correctAnswer.isNotEmpty ? _correctAnswer : null,
      explanation: _explanation.isNotEmpty ? _explanation : null,
      expectedWordCount: _wordLimit,
      questionClass: _selectedClass,
      subject: _selectedSubject,
      createdAt: _editingQuestion?.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  /// Load question for editing
  void loadQuestion(Question question) {
    _editingQuestion = question;
    _selectedType = question.questionType;
    _selectedClass = question.questionClass;
    _selectedSubject = question.subject;
    _marks = question.marks;
    _questionText = question.questionText;
    
    // For True/False questions, get answer from options array (where is_correct = true)
    if (question.questionType == QuestionType.trueFalse) {
      // For True/False, we don't store options in _options, we use _correctAnswer
      // But we need to extract the answer from the options array if available
      _options = [];
      print('🔍 [LoadQuestion Debug] Loading True/False question');
      print('🔍 [LoadQuestion Debug] Expected Answer: ${question.expectedAnswer}');
      print('🔍 [LoadQuestion Debug] Options count: ${question.options?.length ?? 0}');
      
      // Find the option with isCorrect = true
      String answerText = '';
      if (question.options != null && question.options!.isNotEmpty) {
        print('🔍 [LoadQuestion Debug] Checking ${question.options!.length} options...');
        for (var i = 0; i < question.options!.length; i++) {
          final option = question.options![i];
          print('🔍 [LoadQuestion Debug] Option $i: text="${option.text}", isCorrect=${option.isCorrect}');
        }
        
        try {
          final correctOption = question.options!.firstWhere(
            (option) => option.isCorrect,
          );
          print('🔍 [LoadQuestion Debug] Found correct option: text="${correctOption.text}", isCorrect=${correctOption.isCorrect}');
          answerText = correctOption.text.toLowerCase();
          print('🔍 [LoadQuestion Debug] Extracted answer: "$answerText"');
        } catch (e) {
          print('🔍 [LoadQuestion Debug] ⚠️ No correct option found in array!');
          print('🔍 [LoadQuestion Debug] Error: $e');
          print('🔍 [LoadQuestion Debug] All options checked:');
          for (var i = 0; i < question.options!.length; i++) {
            final opt = question.options![i];
            print('🔍 [LoadQuestion Debug]   Option $i: text="${opt.text}", isCorrect=${opt.isCorrect}');
          }
          
          // Try to infer from option text if one matches "true" or "false"
          // This handles cases where is_correct flag wasn't set properly
          // We'll check both options and try to find which one matches the expected answer
          // or use the option order as a hint
          bool foundInferredAnswer = false;
          
          // First, try to match with expectedAnswer if available
          if (question.expectedAnswer != null && question.expectedAnswer!.isNotEmpty) {
            final expectedLower = question.expectedAnswer!.toLowerCase().trim();
            for (var option in question.options!) {
              final normalizedText = option.text.toLowerCase().trim();
              if (normalizedText == expectedLower) {
                answerText = normalizedText;
                foundInferredAnswer = true;
                print('🔍 [LoadQuestion Debug] ⚠️ Inferred answer from expectedAnswer match: "$answerText"');
                break;
              }
            }
          }
          
          // If still not found, use the first option that matches "true" or "false"
          if (!foundInferredAnswer) {
            for (var option in question.options!) {
              final normalizedText = option.text.toLowerCase().trim();
              if (normalizedText == 'true' || normalizedText == 'false') {
                answerText = normalizedText;
                foundInferredAnswer = true;
                print('🔍 [LoadQuestion Debug] ⚠️ Inferred answer from option text (first match): "$answerText"');
                print('🔍 [LoadQuestion Debug] ⚠️ WARNING: This may not be the correct answer!');
                break;
              }
            }
          }
          
          if (!foundInferredAnswer) {
            print('🔍 [LoadQuestion Debug] Falling back to expectedAnswer: ${question.expectedAnswer}');
            // No correct option found, fallback to expectedAnswer
            answerText = (question.expectedAnswer ?? '').toLowerCase();
          }
        }
      } else {
        print('🔍 [LoadQuestion Debug] No options array, using expectedAnswer: ${question.expectedAnswer}');
        // No options, use expectedAnswer
        answerText = (question.expectedAnswer ?? '').toLowerCase();
      }
      
      print('🔍 [LoadQuestion Debug] Final answerText: "$answerText"');
      _correctAnswer = answerText;
      print('🔍 [LoadQuestion Debug] Set _correctAnswer to: "$_correctAnswer"');
    } else {
      // For other question types, use expectedAnswer directly
      _correctAnswer = question.expectedAnswer ?? '';
    }
    
    _explanation = question.explanation ?? '';
    _wordLimit = question.expectedWordCount;
    _currentStep = FormStep.basicInfo;
    _validate();
    notifyListeners();
  }

  /// Duplicate a question (for creating new from existing)
  void duplicateQuestion(Question question) {
    _selectedType = question.questionType;
    _selectedClass = question.questionClass;
    _selectedSubject = question.subject;
    _marks = question.marks;
    _questionText = question.questionText;
    _options =
        question.options
            ?.map((o) => QuestionOption(text: o.text, isCorrect: o.isCorrect))
            .toList() ??
        [];
    
    // For True/False questions, get answer from options array (where is_correct = true)
    if (question.questionType == QuestionType.trueFalse) {
      // Find the option with isCorrect = true
      String answerText = '';
      if (question.options != null && question.options!.isNotEmpty) {
        try {
          final correctOption = question.options!.firstWhere(
            (option) => option.isCorrect,
          );
          answerText = correctOption.text.toLowerCase();
        } catch (e) {
          // No correct option found, fallback to expectedAnswer
          answerText = (question.expectedAnswer ?? '').toLowerCase();
        }
      } else {
        // No options, use expectedAnswer
        answerText = (question.expectedAnswer ?? '').toLowerCase();
      }
      
      _correctAnswer = answerText;
    } else {
      // For other question types, use expectedAnswer directly
      _correctAnswer = question.expectedAnswer ?? '';
    }
    
    _explanation = question.explanation ?? '';
    _wordLimit = question.expectedWordCount;
    _currentStep = FormStep.basicInfo;
    _validate();
    notifyListeners();
  }

  /// Save draft
  Future<void> saveDraft() async {
    _isDraft = true;
    _draftTimestamp = DateTime.now();

    await _draftService.saveDraft({
      'type': _selectedType?.apiValue,
      'class_id': _selectedClass?.id,
      'subject_id': _selectedSubject?.id,
      'marks': _marks,
      'question_text': _questionText,
      'options': _options.map((o) => o.toJson()).toList(),
      'explanation': _explanation,
      'correct_answer': _correctAnswer,
      'word_limit': _wordLimit,
      'solution_steps': _solutionSteps,
      'blank_answers': _blankAnswers,
      'matching_pairs': _matchingPairs,
      'stimulus': _stimulus,
      'sub_questions': _subQuestions,
    });

    notifyListeners();
  }

  /// Load draft
  Future<bool> loadDraft() async {
    final draft = await _draftService.getDraft();
    if (draft == null) return false;

    _selectedType = draft['type'] != null
        ? QuestionType.fromApiValue(draft['type'])
        : null;
    _marks = (draft['marks'] as num?)?.toDouble() ?? 1.0;
    _questionText = draft['question_text'] ?? '';
    _options =
        (draft['options'] as List<dynamic>?)
            ?.map((o) => QuestionOption.fromJson(o as Map<String, dynamic>))
            .toList() ??
        [];
    _explanation = draft['explanation'] ?? '';
    _correctAnswer = draft['correct_answer'] ?? '';
    _wordLimit = draft['word_limit'];
    _solutionSteps = List<String>.from(draft['solution_steps'] ?? []);
    _blankAnswers = List<String>.from(draft['blank_answers'] ?? []);
    _matchingPairs =
        (draft['matching_pairs'] as List<dynamic>?)
            ?.map((p) => Map<String, String>.from(p as Map))
            .toList() ??
        [];
    _stimulus = draft['stimulus'] ?? '';
    _subQuestions =
        (draft['sub_questions'] as List<dynamic>?)
            ?.map((sq) => Map<String, dynamic>.from(sq as Map))
            .toList() ??
        [];

    _draftTimestamp = await _draftService.getDraftTimestamp();
    _isDraft = true;

    if (_selectedType != null) {
      _currentStep = FormStep.basicInfo;
    }

    _validate();
    notifyListeners();
    return true;
  }

  /// Clear draft
  Future<void> clearDraft() async {
    await _draftService.clearDraft();
    _isDraft = false;
    _draftTimestamp = null;
    notifyListeners();
  }

  /// Schedule auto-save (30 seconds debounce)
  void _scheduleDraftSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 30), () {
      if (_questionText.isNotEmpty || _selectedType != null) {
        saveDraft();
      }
    });
  }

  /// Reset form
  void reset() {
    _autoSaveTimer?.cancel();
    _currentStep = FormStep.selectType;
    _selectedType = null;
    _selectedClass = null;
    _selectedSubject = null;
    _marks = 1.0;
    _questionText = '';
    _options = [];
    _explanation = '';
    _correctAnswer = '';
    _wordLimit = null;
    _solutionSteps = [];
    _blankAnswers = [];
    _matchingPairs = [
      {'left': '', 'right': ''},
      {'left': '', 'right': ''},
    ];
    _stimulus = '';
    _subQuestions = [];
    _editingQuestion = null;
    _isValid = false;
    _validationErrors.clear();
    _isDraft = false;
    _draftTimestamp = null;

    notifyListeners();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }
}
