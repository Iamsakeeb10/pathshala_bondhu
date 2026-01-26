/// Question Type Icons and Colors
/// Provides consistent visual representation for each question type

import 'package:flutter/material.dart';

import '../data/models/question_model.dart';

/// Get icon data for question type
IconData getQuestionTypeIcon(QuestionType type) {
  switch (type) {
    case QuestionType.mcq:
      return Icons.radio_button_checked;
    case QuestionType.trueFalse:
      return Icons.check_circle_outline;
    case QuestionType.shortAnswer:
      return Icons.short_text;
    case QuestionType.essay:
      return Icons.article_outlined;
    case QuestionType.matching:
      return Icons.compare_arrows;
    case QuestionType.fillBlank:
      return Icons.space_bar;
    case QuestionType.mathProblem:
      return Icons.calculate_outlined;
    case QuestionType.creative:
      return Icons.lightbulb_outline;
  }
}

/// Get color for question type (light theme)
Color getQuestionTypeColor(QuestionType type) {
  switch (type) {
    case QuestionType.mcq:
      return const Color(0xFF2196F3); // Blue
    case QuestionType.trueFalse:
      return const Color(0xFF4CAF50); // Green
    case QuestionType.shortAnswer:
      return const Color(0xFFFF9800); // Orange
    case QuestionType.essay:
      return const Color(0xFF9C27B0); // Purple
    case QuestionType.matching:
      return const Color(0xFF00BCD4); // Teal
    case QuestionType.fillBlank:
      return const Color(0xFFFFC107); // Amber
    case QuestionType.mathProblem:
      return const Color(0xFF3F51B5); // Indigo
    case QuestionType.creative:
      return const Color(0xFFE91E63); // Pink
  }
}

/// Get light background color for question type
Color getQuestionTypeBackgroundColor(QuestionType type) {
  return getQuestionTypeColor(type).withOpacity(0.1);
}

/// Get emoji for question type
String getQuestionTypeEmoji(QuestionType type) {
  switch (type) {
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

/// Question type card widget data
class QuestionTypeCardData {
  final QuestionType type;
  final IconData icon;
  final Color color;
  final String emoji;

  QuestionTypeCardData(this.type)
    : icon = getQuestionTypeIcon(type),
      color = getQuestionTypeColor(type),
      emoji = getQuestionTypeEmoji(type);

  Color get backgroundColor => color.withOpacity(0.1);
  Color get borderColor => color.withOpacity(0.3);
}

/// Get all question type card data
List<QuestionTypeCardData> getAllQuestionTypeCards() {
  return QuestionType.values.map((type) => QuestionTypeCardData(type)).toList();
}

/// Static class for question type icons (convenience wrapper)
class QuestionTypeIcons {
  QuestionTypeIcons._();

  static IconData getIcon(QuestionType type) => getQuestionTypeIcon(type);
  static Color getColor(QuestionType type) => getQuestionTypeColor(type);
  static Color getBackgroundColor(QuestionType type) =>
      getQuestionTypeBackgroundColor(type);
  static String getEmoji(QuestionType type) => getQuestionTypeEmoji(type);
}
