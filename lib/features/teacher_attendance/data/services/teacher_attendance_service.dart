import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/teacher_attendance_models.dart';

class TeacherAttendanceService {
  final DioClient _dioClient;

  TeacherAttendanceService() : _dioClient = DioClient();

  /// Get list of academic sessions
  Future<List<TeacherAcademicSession>> getAcademicSessions() async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.teacherAcademicSessions,
      );
      final data = response.data;
      if (data['sessions'] != null) {
        return (data['sessions'] as List)
            .map((e) => TeacherAcademicSession.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load academic sessions: $e');
    }
  }

  /// Get list of classes
  Future<List<TeacherClass>> getClasses() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.teacherClasses);
      final data = response.data;
      if (data['classes'] != null) {
        return (data['classes'] as List)
            .map((e) => TeacherClass.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load classes: $e');
    }
  }

  /// Get students for a specific class and session
  Future<List<TeacherStudent>> getStudents({
    required int classId,
    required int academicSessionId,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.teacherStudents,
        queryParameters: {
          'class_id': classId,
          'academic_session_id': academicSessionId,
        },
      );
      final data = response.data;
      if (data['students'] != null) {
        return (data['students'] as List)
            .map((e) => TeacherStudent.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load students: $e');
    }
  }

  /// Submit attendance
  Future<void> submitAttendance(AttendanceSubmissionPayload payload) async {
    try {
      await _dioClient.post(
        ApiEndpoints.teacherAttendance,
        data: payload.toJson(),
      );
    } catch (e) {
      throw Exception('Failed to submit attendance: $e');
    }
  }

  /// Get attendance history/params
  Future<List<AttendanceHistoryRecord>> getAttendanceHistory({
    required int classId,
    required int academicSessionId,
    required String date,
  }) async {
    try {
      // Using GET with queryParameters as standard approach
      final response = await _dioClient.get(
        ApiEndpoints.teacherAttendance,
        queryParameters: {
          'class_id': classId,
          'academic_session_id': academicSessionId,
          'date': date,
        },
      );
      final data = response.data;
      if (data['attendances'] != null) {
        return (data['attendances'] as List)
            .map((e) => AttendanceHistoryRecord.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load attendance history: $e');
    }
  }
}
