import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/attendance_models.dart';

/// Attendance API service
class AttendanceService {
  final DioClient _dioClient;

  AttendanceService() : _dioClient = DioClient();

  /// Get attendance with filters
  Future<AttendanceResponse> getAttendance({
    required String monthName,
    required int year,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.studentAttendance,
        queryParameters: {
          'month_name': monthName,
          'year': year,
        },
      );

      return AttendanceResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error fetching attendance: $e');
    }
  }

  String _handleDioException(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      switch (statusCode) {
        case 400:
          return 'Invalid request. Please try again.';
        case 404:
          return 'Attendance records not found.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return 'Failed to load attendance.';
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
