/// Question Bank API Service
/// Handles all API calls for Question Bank feature

import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/question_model.dart';
import 'question_bank_auth_service.dart';

/// API endpoints for Question Bank
class QBApiEndpoints {
  static const String auth = '/teacher/auth';
  static const String questions = '/questions';
  static const String classes = '/teacher/classes';
  // Note: Subjects endpoint not available in API
}

/// Question Bank API Service
class QuestionBankApiService {
  final DioClient _dioClient;
  final QuestionBankAuthService _authService;

  QuestionBankApiService({
    DioClient? dioClient,
    QuestionBankAuthService? authService,
  }) : _dioClient = dioClient ?? DioClient(),
       _authService = authService ?? QuestionBankAuthService.instance;

  /// Get authorization headers with Question Bank token
  Future<Options> _getAuthOptions() async {
    final token = await _authService.getToken();
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
  }

  /// Authenticate teacher for Question Bank access
  /// Returns token on success, throws on failure
  Future<String> authenticate(String email, String password) async {
    try {
      // Use baseUrlWithoutV1 since teacher/auth doesn't have v1 prefix
      final response = await _dioClient.post(
        '${ApiEndpoints.baseUrlWithoutV1}${QBApiEndpoints.auth}',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final token = response.data['token'] as String;
        await _authService.saveToken(token, email: email);
        return token;
      }

      throw Exception(response.data['message'] ?? 'Authentication failed');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid email or password');
      }
      throw Exception(
        e.response?.data['message'] ??
            'Authentication failed. Please try again.',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Validate session and refresh if needed
  /// Returns true if session is valid, false if re-authentication needed
  Future<bool> validateSession() async {
    return await _authService.isSessionValid();
  }

  /// Fetch questions with pagination
  Future<PaginatedQuestionResponse> fetchQuestions({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      // Check session validity
      if (!await validateSession()) {
        throw SessionExpiredException('Session expired, please login again');
      }

      final options = await _getAuthOptions();
      final response = await _dioClient.get(
        QBApiEndpoints.questions,
        queryParameters: {'page': page, 'per_page': perPage},
        options: options,
      );

      if (response.statusCode == 200) {
        // Refresh session on successful API call
        await _authService.refreshSession();
        return PaginatedQuestionResponse.fromJson(response.data);
      }

      throw Exception('Failed to load questions');
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Get single question by ID
  Future<Question> getQuestion(int id) async {
    try {
      if (!await validateSession()) {
        throw SessionExpiredException('Session expired, please login again');
      }

      final options = await _getAuthOptions();
      final response = await _dioClient.get(
        '${QBApiEndpoints.questions}/$id',
        options: options,
      );

      if (response.statusCode == 200) {
        await _authService.refreshSession();
        final json =
            response.data['question'] ?? response.data['data'] ?? response.data;
        return Question.fromJson(json);
      }

      throw Exception('Failed to load question');
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Create new question
  Future<Question> createQuestion(Question question) async {
    try {
      if (!await validateSession()) {
        throw SessionExpiredException('Session expired, please login again');
      }

      final options = await _getAuthOptions();
      final response = await _dioClient.post(
        QBApiEndpoints.questions,
        data: question.toJson(),
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _authService.refreshSession();
        final json =
            response.data['question'] ?? response.data['data'] ?? response.data;
        return Question.fromJson(json);
      }

      throw Exception(response.data['message'] ?? 'Failed to create question');
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Update existing question
  Future<Question> updateQuestion(int id, Question question) async {
    try {
      if (!await validateSession()) {
        throw SessionExpiredException('Session expired, please login again');
      }

      final options = await _getAuthOptions();
      final response = await _dioClient.put(
        '${QBApiEndpoints.questions}/$id',
        data: question.toJson(),
        options: options,
      );

      if (response.statusCode == 200) {
        await _authService.refreshSession();
        final json =
            response.data['question'] ?? response.data['data'] ?? response.data;
        return Question.fromJson(json);
      }

      throw Exception(response.data['message'] ?? 'Failed to update question');
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Delete question
  Future<void> deleteQuestion(int id) async {
    try {
      if (!await validateSession()) {
        throw SessionExpiredException('Session expired, please login again');
      }

      final options = await _getAuthOptions();
      final response = await _dioClient.delete(
        '${QBApiEndpoints.questions}/$id',
        options: options,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          response.data['message'] ?? 'Failed to delete question',
        );
      }

      await _authService.refreshSession();
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Fetch available classes
  Future<List<QuestionClass>> fetchClasses() async {
    try {
      if (!await validateSession()) {
        throw SessionExpiredException('Session expired, please login again');
      }

      final options = await _getAuthOptions();
      final response = await _dioClient.get(
        QBApiEndpoints.classes,
        options: options,
      );

      if (response.statusCode == 200) {
        final List<dynamic> classesJson =
            response.data['classes'] ?? response.data['data'] ?? [];
        return classesJson
            .map((json) => QuestionClass.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      _handleDioError(e);
      return [];
    }
  }

  /// Handle Dio errors
  void _handleDioError(DioException e) {
    if (e.response?.statusCode == 401) {
      // Clear session on 401
      _authService.clearSession();
      throw SessionExpiredException('Session expired, please login again');
    }

    if (e.response?.statusCode == 404) {
      throw NotFoundException('Question not found');
    }

    if (e.response?.statusCode == 403) {
      throw ForbiddenException(
        'You don\'t have permission to perform this action',
      );
    }

    throw Exception(
      e.response?.data['message'] ?? 'An error occurred. Please try again.',
    );
  }

  /// Logout from Question Bank
  Future<void> logout() async {
    await _authService.clearSession();
  }
}

/// Custom exceptions for Question Bank
class SessionExpiredException implements Exception {
  final String message;
  SessionExpiredException(this.message);
  @override
  String toString() => message;
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
  @override
  String toString() => message;
}

class ForbiddenException implements Exception {
  final String message;
  ForbiddenException(this.message);
  @override
  String toString() => message;
}
