import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/fees_models.dart';

class FeesService {
  final DioClient _dioClient;

  FeesService() : _dioClient = DioClient();

  /// Get fees - using GET with query parameter
  Future<FeesResponse> getFees({required String year}) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.studentFees,
        queryParameters: {'year': year},
      );

      return FeesResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error fetching fees: $e');
    }
  }

  String _handleDioException(DioException e) {
    if (e.response != null) {
      switch (e.response!.statusCode) {
        case 400:
          return 'Invalid request.';
        case 404:
          return 'Fees not found.';
        case 500:
          return 'Server error.';
        default:
          return 'Failed to load fees.';
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
