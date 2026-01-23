import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/result_models.dart';

class ResultService {
  final DioClient _dioClient;

  ResultService() : _dioClient = DioClient();

  /// Get student results for all children (similar to fees)
  Future<ResultResponse> getResults() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.studentResults);

      return ResultResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error fetching results: $e');
    }
  }

  String _handleDioException(DioException e) {
    if (e.response != null) {
      switch (e.response!.statusCode) {
        case 400:
          return 'Invalid request.';
        case 404:
          return 'Results not found.';
        case 500:
          return 'Server error.';
        default:
          return 'Failed to load results.';
      }
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'No internet connection.';
    } else {
      return 'Network error.';
    }
  }
}
