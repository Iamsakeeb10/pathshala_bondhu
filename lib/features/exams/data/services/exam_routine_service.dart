import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/exam_routine_models.dart';

/// Exam Routine API service
class ExamRoutineService {
  final DioClient _dioClient;

  ExamRoutineService() : _dioClient = DioClient();

  /// Get exam routines for all students
  Future<ExamRoutineResponse> getExamRoutines() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.examRoutines);

      return ExamRoutineResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error fetching exam routines: $e');
    }
  }

  String _handleDioException(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      switch (statusCode) {
        case 400:
          return 'Invalid request. Please try again.';
        case 404:
          return 'Exam routines not found.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return 'Failed to load exam routines.';
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
