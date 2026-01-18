import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/teacher_model.dart';

/// Service for fetching teachers list from API
class TeachersService {
  final DioClient _dioClient;

  TeachersService() : _dioClient = DioClient();

  /// Fetch teachers list with pagination
  /// 
  /// [page] - Page number (1-indexed)
  /// [perPage] - Items per page (default: 25)
  Future<TeachersListResponse> getTeachers({
    int page = 1,
    int perPage = 25,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.teachers,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      return TeachersListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Failed to fetch teachers: $e');
    }
  }

  String _handleDioException(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      switch (statusCode) {
        case 401:
          return 'Session expired. Please login again.';
        case 403:
          return 'Access denied.';
        case 404:
          return 'Teachers not found.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return 'An error occurred. Please try again.';
      }
    }
    return 'Network error. Please check your connection.';
  }
}
