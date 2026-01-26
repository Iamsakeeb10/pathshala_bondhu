import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../models/attendance_summary_model.dart';
import '../models/teacher_attendance_model.dart';

/// Service for teacher attendance API calls
class TeacherAttendanceService {
  final DioClient _dioClient;
  static const String _baseUrl = '/teacher-attendance';

  TeacherAttendanceService() : _dioClient = DioClient();

  /// Get attendance summary for a specific date
  ///
  /// Returns summary with total teachers, marked, pending, present, absent, leave counts
  /// and attendance percentage
  Future<AttendanceSummaryModel> getSummary(String date) async {
    try {
      final response = await _dioClient.get(
        '$_baseUrl/summary',
        queryParameters: {'date': date},
      );

      return AttendanceSummaryModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Unexpected error fetching summary: $e');
    }
  }

  /// Get attendance list by date
  ///
  /// Returns list of all attendance records for the given date with teacher details
  Future<List<TeacherAttendanceModel>> getAttendanceByDate(String date) async {
    try {
      final response = await _dioClient.get(
        '$_baseUrl/by-date',
        queryParameters: {'date': date},
      );

      final data = response.data as Map<String, dynamic>;
      final attendancesList = data['attendances'] as List;

      return attendancesList
          .map(
            (json) =>
                TeacherAttendanceModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Unexpected error fetching attendance list: $e');
    }
  }

  /// Mark or update teacher attendance
  ///
  /// [teacherId] - ID of the teacher
  /// [date] - Date in YYYY-MM-DD format
  /// [status] - present, absent, or leave
  /// [checkInTime] - Time in HH:mm format (required if status is present)
  /// [checkOutTime] - Time in HH:mm format (optional)
  /// [remarks] - Optional notes/comments
  Future<TeacherAttendanceModel> markAttendance({
    required int teacherId,
    required String date,
    required String status,
    String? checkInTime,
    String? checkOutTime,
    String? remarks,
  }) async {
    try {
      final payload = <String, dynamic>{
        'teacher_id': teacherId,
        'date': date,
        'status': status,
      };

      // Only include time fields if status is present
      if (status.toLowerCase() == 'present') {
        if (checkInTime != null && checkInTime.isNotEmpty) {
          payload['check_in_time'] = checkInTime;
        }
        if (checkOutTime != null && checkOutTime.isNotEmpty) {
          payload['check_out_time'] = checkOutTime;
        }
      }

      // Include remarks if provided
      if (remarks != null && remarks.trim().isNotEmpty) {
        payload['remarks'] = remarks.trim();
      }

      final response = await _dioClient.post('$_baseUrl/mark', data: payload);

      final data = response.data as Map<String, dynamic>;
      return TeacherAttendanceModel.fromJson(
        data['attendance'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Unexpected error marking attendance: $e');
    }
  }

  /// Handle Dio exceptions and return user-friendly error messages
  String _handleError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;

      switch (statusCode) {
        case 400:
          return data['message'] ?? 'Invalid request. Please check your input.';
        case 401:
          return 'Unauthorized. Please login again.';
        case 403:
          return 'Access denied. You do not have permission.';
        case 404:
          return 'Service not found. Please contact support.';
        case 409:
          return data['message'] ??
              'Attendance already marked for this teacher.';
        case 422:
          // Extract validation errors
          if (data is Map && data.containsKey('errors')) {
            final errors = data['errors'];
            if (errors is Map && errors.isNotEmpty) {
              final firstError = errors.values.first;
              if (firstError is List && firstError.isNotEmpty) {
                return firstError[0].toString();
              }
            }
          }
          return data['message'] ??
              'Validation error. Please check your input.';
        case 500:
          return 'Server error. Please try again later.';
        case 503:
          return 'Service unavailable. Please try again later.';
        default:
          return data['message'] ?? 'Something went wrong. Please try again.';
      }
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return 'Server is taking too long to respond. Please try again.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'No internet connection. Please check your network.';
    } else {
      return 'Network error. Please check your connection.';
    }
  }
}
