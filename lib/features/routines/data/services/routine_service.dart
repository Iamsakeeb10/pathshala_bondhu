import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/routine_models.dart';

/// Class Routine API service
class RoutineService {
  final DioClient _dioClient;

  RoutineService() : _dioClient = DioClient();

  /// Get class routines for all students
  /// Requires authentication token
  Future<RoutineResponse> getRoutines() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.routines);

      return RoutineResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error fetching routines: $e');
    }
  }

  /// Handle Dio exceptions
  String _handleDioException(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;

      switch (statusCode) {
        case 400:
          return 'Invalid request. Please try again.';
        case 404:
          return 'Routines not found.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return 'Failed to load routines.';
      }
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'No internet connection. Please check your network.';
    } else {
      return 'Network error. Please check your connection.';
    }
  }
}
