/// Question Bank Models for the school management app
/// Supports 8 question types: MCQ, True/False, Short Answer, Essay,
/// Matching, Fill in the Blank, Math Problem, Creative Question

/// Question type enumeration
enum QuestionType {
  mcq,
  trueFalse,
  shortAnswer,
  essay,
  matching,
  fillBlank,
  mathProblem,
  creative;

  String get apiValue {
    switch (this) {
      case QuestionType.mcq:
        return 'mcq';
      case QuestionType.trueFalse:
        return 'true_false';
      case QuestionType.shortAnswer:
        return 'short_answer';
      case QuestionType.essay:
        return 'essay';
      case QuestionType.matching:
        return 'matching';
      case QuestionType.fillBlank:
        return 'fill_blank';
      case QuestionType.mathProblem:
        return 'math_problem';
      case QuestionType.creative:
        return 'creative';
    }
  }

  static QuestionType fromApiValue(String value) {
    switch (value.toLowerCase()) {
      case 'mcq':
        return QuestionType.mcq;
      case 'true_false':
        return QuestionType.trueFalse;
      case 'short_answer':
        return QuestionType.shortAnswer;
      case 'essay':
        return QuestionType.essay;
      case 'matching':
        return QuestionType.matching;
      case 'fill_blank':
        return QuestionType.fillBlank;
      case 'math_problem':
        return QuestionType.mathProblem;
      case 'creative':
        return QuestionType.creative;
      default:
        return QuestionType.mcq;
    }
  }

  String getDisplayName(bool isBangla) {
    if (isBangla) {
      switch (this) {
        case QuestionType.mcq:
          return 'বহুনির্বাচনী';
        case QuestionType.trueFalse:
          return 'সত্য/মিথ্যা';
        case QuestionType.shortAnswer:
          return 'সংক্ষিপ্ত উত্তর';
        case QuestionType.essay:
          return 'রচনা';
        case QuestionType.matching:
          return 'মিলকরণ';
        case QuestionType.fillBlank:
          return 'শূন্যস্থান পূরণ';
        case QuestionType.mathProblem:
          return 'গণিত সমস্যা';
        case QuestionType.creative:
          return 'সৃজনশীল প্রশ্ন';
      }
    } else {
      switch (this) {
        case QuestionType.mcq:
          return 'MCQ';
        case QuestionType.trueFalse:
          return 'True/False';
        case QuestionType.shortAnswer:
          return 'Short Answer';
        case QuestionType.essay:
          return 'Essay';
        case QuestionType.matching:
          return 'Matching';
        case QuestionType.fillBlank:
          return 'Fill in the Blank';
        case QuestionType.mathProblem:
          return 'Math Problem';
        case QuestionType.creative:
          return 'Creative Question';
      }
    }
  }

  String get icon {
    switch (this) {
      case QuestionType.mcq:
        return '📝';
      case QuestionType.trueFalse:
        return '✓✗';
      case QuestionType.shortAnswer:
        return '✍️';
      case QuestionType.essay:
        return '📋';
      case QuestionType.matching:
        return '🔗';
      case QuestionType.fillBlank:
        return '⬜';
      case QuestionType.mathProblem:
        return '🔢';
      case QuestionType.creative:
        return '🎨';
    }
  }
}

/// Option model for MCQ, True/False, Matching, Fill Blank, and Creative questions
class QuestionOption {
  final String? id;
  final String text;
  final bool isCorrect;
  final double? marks; // For creative questions sub-parts

  QuestionOption({
    this.id,
    required this.text,
    this.isCorrect = false,
    this.marks,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    // Try multiple possible field names for option text
    final text = json['text'] as String? ??
        json['option_text'] as String? ??
        json['optionText'] as String? ??
        json['value'] as String? ??
        json['content'] as String? ??
        json['label'] as String? ??
        '';
    
    // Parse isCorrect from multiple possible formats
    bool isCorrect = false;
    if (json['is_correct'] != null) {
      if (json['is_correct'] is bool) {
        isCorrect = json['is_correct'] as bool;
      } else if (json['is_correct'] == 1 || json['is_correct'] == '1') {
        isCorrect = true;
      }
    } else if (json['isCorrect'] != null) {
      if (json['isCorrect'] is bool) {
        isCorrect = json['isCorrect'] as bool;
      } else if (json['isCorrect'] == 1 || json['isCorrect'] == '1') {
        isCorrect = true;
      }
    }
    
    return QuestionOption(
      id: json['id']?.toString(),
      text: text,
      isCorrect: isCorrect,
      marks: json['marks'] != null
          ? double.tryParse(json['marks'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'text': text, 'is_correct': isCorrect};
    if (id != null) map['id'] = id;
    if (marks != null) map['marks'] = marks;
    return map;
  }

  QuestionOption copyWith({
    String? id,
    String? text,
    bool? isCorrect,
    double? marks,
  }) {
    return QuestionOption(
      id: id ?? this.id,
      text: text ?? this.text,
      isCorrect: isCorrect ?? this.isCorrect,
      marks: marks ?? this.marks,
    );
  }
}

/// Main Question model
class Question {
  final int? id;
  final int classId;
  final int subjectId;
  final QuestionType questionType;
  final String questionText;
  final double marks;
  final List<QuestionOption>? options;
  final String? explanation; // For True/False, Essay guidelines
  final String? expectedAnswer; // For Short Answer
  final int? expectedWordCount; // For Essay
  final String? solution; // For Math Problem
  final String? imageUrl; // For Math Problem diagrams
  final String? createdAt;
  final String? updatedAt;
  final QuestionClass? questionClass;
  final QuestionSubject? subject;

  Question({
    this.id,
    required this.classId,
    required this.subjectId,
    required this.questionType,
    required this.questionText,
    required this.marks,
    this.options,
    this.explanation,
    this.expectedAnswer,
    this.expectedWordCount,
    this.solution,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
    this.questionClass,
    this.subject,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
      classId: json['class_id'] is int
          ? json['class_id']
          : int.tryParse(json['class_id'].toString()) ?? 0,
      subjectId: json['subject_id'] is int
          ? json['subject_id']
          : int.tryParse(json['subject_id'].toString()) ?? 0,
      questionType: QuestionType.fromApiValue(
        json['question_type'] as String? ?? 'mcq',
      ),
      questionText: json['question_text'] as String? ?? '',
      marks: json['marks'] != null
          ? double.tryParse(json['marks'].toString()) ?? 1.0
          : 1.0,
      options: json['options'] != null
          ? (json['options'] as List)
                .map((e) => QuestionOption.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      explanation: json['explanation'] as String?,
      expectedAnswer: json['expected_answer'] as String?,
      expectedWordCount: json['expected_word_count'] != null
          ? int.tryParse(json['expected_word_count'].toString())
          : null,
      solution: json['solution'] as String?,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      questionClass: json['class'] != null
          ? QuestionClass.fromJson(json['class'] as Map<String, dynamic>)
          : null,
      subject: json['subject'] != null
          ? QuestionSubject.fromJson(json['subject'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'class_id': classId,
      'subject_id': subjectId,
      'question_type': questionType.apiValue,
      'question_text': questionText,
      'marks': marks,
    };

    if (id != null) map['id'] = id;
    if (options != null && options!.isNotEmpty) {
      map['options'] = options!.map((e) => e.toJson()).toList();
    }
    if (explanation != null) map['explanation'] = explanation;
    if (expectedAnswer != null) map['expected_answer'] = expectedAnswer;
    if (expectedWordCount != null)
      map['expected_word_count'] = expectedWordCount;
    if (solution != null) map['solution'] = solution;
    if (imageUrl != null) map['image_url'] = imageUrl;

    return map;
  }

  Question copyWith({
    int? id,
    int? classId,
    int? subjectId,
    QuestionType? questionType,
    String? questionText,
    double? marks,
    List<QuestionOption>? options,
    String? explanation,
    String? expectedAnswer,
    int? expectedWordCount,
    String? solution,
    String? imageUrl,
    String? createdAt,
    String? updatedAt,
    QuestionClass? questionClass,
    QuestionSubject? subject,
  }) {
    return Question(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      subjectId: subjectId ?? this.subjectId,
      questionType: questionType ?? this.questionType,
      questionText: questionText ?? this.questionText,
      marks: marks ?? this.marks,
      options: options ?? this.options,
      explanation: explanation ?? this.explanation,
      expectedAnswer: expectedAnswer ?? this.expectedAnswer,
      expectedWordCount: expectedWordCount ?? this.expectedWordCount,
      solution: solution ?? this.solution,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      questionClass: questionClass ?? this.questionClass,
      subject: subject ?? this.subject,
    );
  }

  /// Get class name safely
  String get className => questionClass?.name ?? 'Class $classId';

  /// Get subject name safely
  String get subjectName => subject?.name ?? 'Subject $subjectId';

  /// Get truncated question text for preview (60 chars)
  String get previewText {
    if (questionText.length <= 60) return questionText;
    return '${questionText.substring(0, 57)}...';
  }

  /// Check if question has correct answer selected (for MCQ/TF)
  bool get hasCorrectAnswer {
    if (options == null || options!.isEmpty) return true;
    return options!.any((o) => o.isCorrect);
  }
}

/// Class model for questions
class QuestionClass {
  final int id;
  final String name;

  QuestionClass({required this.id, required this.name});

  factory QuestionClass.fromJson(Map<String, dynamic> json) {
    return QuestionClass(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

/// Subject model for questions
class QuestionSubject {
  final int id;
  final String name;
  final String? code;

  QuestionSubject({required this.id, required this.name, this.code});

  factory QuestionSubject.fromJson(Map<String, dynamic> json) {
    return QuestionSubject(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] as String? ?? 'Unknown',
      code: json['code'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (code != null) 'code': code,
  };
}

/// Paginated response for question list
class PaginatedQuestionResponse {
  final int currentPage;
  final List<Question> data;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMore;

  PaginatedQuestionResponse({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    required this.perPage,
    required this.total,
  }) : hasMore = currentPage < lastPage;

  factory PaginatedQuestionResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedQuestionResponse(
      currentPage: json['current_page'] ?? 1,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => Question.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 20,
      total: json['total'] ?? 0,
    );
  }
}
