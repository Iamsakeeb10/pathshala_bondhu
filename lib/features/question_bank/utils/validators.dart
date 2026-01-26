/// Question Bank Validators
/// Form validation utilities

class QuestionBankValidators {
  QuestionBankValidators._();

  /// Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName is required'
          : 'This field is required';
    }
    return null;
  }

  /// Validate marks
  static String? validateMarks(double? value) {
    if (value == null) {
      return 'Marks is required';
    }

    if (value < 0.5) {
      return 'Minimum marks is 0.5';
    }

    if (value > 100) {
      return 'Maximum marks is 100';
    }

    return null;
  }

  /// Validate question text
  static String? validateQuestionText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Question text is required';
    }

    if (value.length < 5) {
      return 'Question must be at least 5 characters';
    }

    if (value.length > 2000) {
      return 'Question must be less than 2000 characters';
    }

    return null;
  }

  /// Validate option text
  static String? validateOptionText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Option text is required';
    }

    if (value.length > 500) {
      return 'Option must be less than 500 characters';
    }

    return null;
  }

  /// Validate MCQ options
  static String? validateMCQOptions(List<Map<String, dynamic>> options) {
    if (options.length < 2) {
      return 'At least 2 options are required';
    }

    if (options.length > 6) {
      return 'Maximum 6 options allowed';
    }

    // Check for empty options
    final validOptions = options
        .where(
          (o) => o['text'] != null && (o['text'] as String).trim().isNotEmpty,
        )
        .toList();

    if (validOptions.length < 2) {
      return 'At least 2 options must have text';
    }

    // Check for correct answer
    final correctCount = options.where((o) => o['is_correct'] == true).length;
    if (correctCount == 0) {
      return 'Select the correct answer';
    }

    if (correctCount > 1) {
      return 'Only one correct answer allowed';
    }

    return null;
  }

  /// Validate True/False options
  static String? validateTrueFalseOptions(List<Map<String, dynamic>> options) {
    final correctCount = options.where((o) => o['is_correct'] == true).length;
    if (correctCount != 1) {
      return 'Select the correct answer (True or False)';
    }
    return null;
  }

  /// Validate matching pairs
  static String? validateMatchingPairs(List<Map<String, dynamic>> pairs) {
    if (pairs.length < 2) {
      return 'At least 2 matching pairs are required';
    }

    // Check for empty pairs
    final validPairs = pairs
        .where(
          (p) =>
              p['left'] != null &&
              (p['left'] as String).trim().isNotEmpty &&
              p['right'] != null &&
              (p['right'] as String).trim().isNotEmpty,
        )
        .toList();

    if (validPairs.length < 2) {
      return 'At least 2 complete pairs are required';
    }

    return null;
  }

  /// Validate fill in the blank question
  static String? validateFillBlankQuestion(String questionText) {
    // Check for blank markers
    final hasNumberedBlanks = RegExp(r'\[\d+\]').hasMatch(questionText);
    final hasUnderscoreBlanks = questionText.contains('___');

    if (!hasNumberedBlanks && !hasUnderscoreBlanks) {
      return 'Add blanks using [1], [2] or ___';
    }

    return null;
  }

  /// Validate creative question sub-parts
  static String? validateCreativeSubParts(List<Map<String, dynamic>> subParts) {
    if (subParts.isEmpty) {
      return 'At least one sub-question is required';
    }

    // Check for empty sub-parts
    final validParts = subParts
        .where(
          (p) => p['text'] != null && (p['text'] as String).trim().isNotEmpty,
        )
        .toList();

    if (validParts.isEmpty) {
      return 'At least one sub-question must have text';
    }

    return null;
  }

  /// Validate dropdown selection
  static String? validateDropdownSelection(dynamic value, {String? fieldName}) {
    if (value == null) {
      return fieldName != null
          ? 'Please select a $fieldName'
          : 'Please select an option';
    }
    return null;
  }
}
