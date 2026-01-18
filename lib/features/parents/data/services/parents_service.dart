import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/parent_model.dart';

/// Service for fetching parents list from API
class ParentsService {
  final DioClient _dioClient;

  ParentsService() : _dioClient = DioClient();

  /// Fetch parents list with pagination and optional search
  /// 
  /// [page] - Page number (1-indexed)
  /// [perPage] - Items per page (default: 10)
  /// [search] - Optional search query (searches by name or phone)
  Future<ParentsListResponse> getParents({
    int page = 1,
    int perPage = 10,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };

      // Add search param if not empty
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await _dioClient.get(
        ApiEndpoints.parents,
        queryParameters: queryParams,
      );

      return ParentsListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Failed to fetch parents: $e');
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
          return 'Parents not found.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return 'An error occurred. Please try again.';
      }
    }
    return 'Network error. Please check your connection.';
  }
}
