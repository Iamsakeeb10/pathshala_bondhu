import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/teacher_routine_model.dart';

class TeacherRoutineRepository {
  final DioClient _dioClient;

  TeacherRoutineRepository({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  Future<List<TeacherRoutine>> fetchRoutines() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.teacherRoutines);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['routines'] != null) {
          final List<dynamic> routinesJson = data['routines'];
          return routinesJson
              .map((json) => TeacherRoutine.fromJson(json))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch routines');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
