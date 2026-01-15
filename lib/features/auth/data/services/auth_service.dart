import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/parent_models.dart';
import '../models/teacher_models.dart';

/// Authentication service for API calls
/// Handles parent and teacher login, profile fetching
class AuthService {
  final DioClient _dioClient;

  AuthService() : _dioClient = DioClient();

  /// Parent login
  /// Returns ParentLoginResponse with token and parent info
  Future<ParentLoginResponse> parentLogin({
    required String parentId,
    required String password,
  }) async {
    try {
      final request = ParentLoginRequest(
        parentId: parentId,
        password: password,
      );

      final response = await _dioClient.post(
        ApiEndpoints.parentLogin,
        data: request.toJson(),
      );

      return ParentLoginResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error during parent login: $e');
    }
  }

  /// Teacher login
  /// Returns TeacherLoginResponse with token and teacher info
  Future<TeacherLoginResponse> teacherLogin({
    required String email,
    required String password,
  }) async {
    try {
      final request = TeacherLoginRequest(
        email: email,
        password: password,
      );

      final response = await _dioClient.post(
        ApiEndpoints.teacherLogin,
        data: request.toJson(),
      );

      return TeacherLoginResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error during teacher login: $e');
    }
  }

  /// Get parent profile
  /// Requires authentication token (handled by interceptor)
  Future<ParentUser> getParentProfile() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.parentMe);

      final data = response.data as Map<String, dynamic>;
      return ParentUser.fromJson(data['parent'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error fetching parent profile: $e');
    }
  }

  /// Get parent's students list
  /// Requires authentication token (handled by interceptor)
  Future<GetStudentsResponse> getParentStudents() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.parentStudents);

      return GetStudentsResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error fetching students: $e');
    }
  }

  /// Handle Dio exceptions and return user-friendly error messages
  String _handleDioException(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;

      switch (statusCode) {
        case 400:
          return 'Invalid request. Please check your input.';
        case 401:
          return 'Invalid credentials. Please try again.';
        case 403:
          return 'Access denied. You do not have permission.';
        case 404:
          return 'Service not found. Please contact support.';
        case 422:
          // Extract validation errors if available
          if (data is Map && data.containsKey('message')) {
            return data['message'] as String;
          }
          return 'Validation error. Please check your input.';
        case 500:
          return 'Server error. Please try again later.';
        case 503:
          return 'Service unavailable. Please try again later.';
        default:
          return 'An error occurred. Please try again.';
      }
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet.';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return 'Server is taking too long to respond.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'No internet connection. Please check your network.';
    } else {
      return 'Network error. Please check your connection.';
    }
  }
}
