/// Question Bank Draft Storage Service
/// Handles auto-saving form drafts locally

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/question_model.dart';

/// Keys for draft storage
class _DraftStorageKeys {
  static const String draftQuestion = 'qb_draft_question';
  static const String draftTimestamp = 'qb_draft_timestamp';
  static const String lastClassId = 'qb_last_class_id';
  static const String lastSubjectId = 'qb_last_subject_id';
  static const String recentTypes = 'qb_recent_types';
}

/// Question Bank Draft Storage Service
class QuestionBankDraftService {
  QuestionBankDraftService._();
  static final QuestionBankDraftService _instance =
      QuestionBankDraftService._();
  static QuestionBankDraftService get instance => _instance;

  /// Save draft question
  Future<void> saveDraft(Map<String, dynamic> questionData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _DraftStorageKeys.draftQuestion,
      jsonEncode(questionData),
    );
    await prefs.setString(
      _DraftStorageKeys.draftTimestamp,
      DateTime.now().toIso8601String(),
    );
    print('✅ Draft saved');
  }

  /// Get saved draft
  Future<Map<String, dynamic>?> getDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draftJson = prefs.getString(_DraftStorageKeys.draftQuestion);
    if (draftJson == null) return null;

    try {
      return jsonDecode(draftJson) as Map<String, dynamic>;
    } catch (e) {
      print('❌ Error parsing draft: $e');
      return null;
    }
  }

  /// Get draft timestamp
  Future<DateTime?> getDraftTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final timestampStr = prefs.getString(_DraftStorageKeys.draftTimestamp);
    if (timestampStr == null) return null;
    return DateTime.tryParse(timestampStr);
  }

  /// Check if draft exists
  Future<bool> hasDraft() async {
    final draft = await getDraft();
    return draft != null;
  }

  /// Clear draft
  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_DraftStorageKeys.draftQuestion);
    await prefs.remove(_DraftStorageKeys.draftTimestamp);
    print('✅ Draft cleared');
  }

  /// Save last used class ID
  Future<void> saveLastClassId(int classId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_DraftStorageKeys.lastClassId, classId);
  }

  /// Get last used class ID
  Future<int?> getLastClassId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_DraftStorageKeys.lastClassId);
  }

  /// Save last used subject ID
  Future<void> saveLastSubjectId(int subjectId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_DraftStorageKeys.lastSubjectId, subjectId);
  }

  /// Get last used subject ID
  Future<int?> getLastSubjectId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_DraftStorageKeys.lastSubjectId);
  }

  /// Save recently used question types (max 3)
  Future<void> saveRecentType(QuestionType type) async {
    final prefs = await SharedPreferences.getInstance();
    final recentTypesJson =
        prefs.getStringList(_DraftStorageKeys.recentTypes) ?? [];

    // Remove if already exists
    recentTypesJson.remove(type.apiValue);

    // Add to front
    recentTypesJson.insert(0, type.apiValue);

    // Keep only last 3
    final trimmed = recentTypesJson.take(3).toList();

    await prefs.setStringList(_DraftStorageKeys.recentTypes, trimmed);
  }

  /// Get recently used question types
  Future<List<QuestionType>> getRecentTypes() async {
    final prefs = await SharedPreferences.getInstance();
    final recentTypesJson =
        prefs.getStringList(_DraftStorageKeys.recentTypes) ?? [];

    return recentTypesJson
        .map((value) => QuestionType.fromApiValue(value))
        .toList();
  }

  /// Clear all draft data
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_DraftStorageKeys.draftQuestion);
    await prefs.remove(_DraftStorageKeys.draftTimestamp);
    // Don't clear last class/subject/recent types - they're user preferences
  }
}
