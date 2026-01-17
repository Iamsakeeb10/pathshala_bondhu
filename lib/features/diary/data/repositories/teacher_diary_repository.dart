import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../routines/data/models/teacher_routine_model.dart';
import '../../../teacher_attendance/data/models/teacher_attendance_models.dart';
import '../models/teacher_diary_model.dart';

class TeacherDiaryRepository {
  final DioClient _dioClient;

  TeacherDiaryRepository({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  Future<PaginatedDiaryResponse> fetchDiaries({int page = 1}) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.teacherDiaries,
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        return PaginatedDiaryResponse.fromJson(response.data);
      }
      throw Exception('Failed to load diaries');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch diaries');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<TeacherDiary> getDiary(int id) async {
    try {
      final response = await _dioClient.get('${ApiEndpoints.teacherDiaries}/$id');
      if (response.statusCode == 200) {
        // Assuming response structure: { "data": { ...diary_object... } } or just the object
        // Standard REST often returns object directly or wrapped in data
        // Based on list response wrapping in data, detailed response likely wraps in data too.
        // If not, we might need a adjust.
        // Let's assume response.data['data'] if wrapper exists, or response.data if direct.
        // To be safe, let's look at the list response. It clearly uses "data" wrapper for list.
        // Usually single item entry isn't wrapped or is wrapped in "data".
        // I will act defensively.
        final json = response.data['diary'] ?? response.data['data'] ?? response.data;
        return TeacherDiary.fromJson(json);
      }
      throw Exception('Failed to fetch diary details');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch diary');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> createDiary(Map<String, dynamic> diaryData) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.teacherDiaries,
        data: diaryData,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(response.data['message'] ?? 'Failed to create diary');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create diary');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> updateDiary(int id, Map<String, dynamic> diaryData) async {
    try {
      final response = await _dioClient.put(
        '${ApiEndpoints.teacherDiaries}/$id',
        data: diaryData,
      );

      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to update diary');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update diary');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> deleteDiary(int id) async {
    try {
      final response = await _dioClient.delete('${ApiEndpoints.teacherDiaries}/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(response.data['message'] ?? 'Failed to delete diary');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to delete diary');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<List<TeacherClass>> fetchClasses() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.teacherClasses);
      if (response.statusCode == 200 && response.data['classes'] != null) {
        return (response.data['classes'] as List)
            .map((json) => TeacherClass.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch classes: $e');
    }
  }

  Future<List<TeacherAcademicSession>> fetchAcademicSessions() async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.teacherAcademicSessions,
      );
      if (response.statusCode == 200 && response.data['sessions'] != null) {
        return (response.data['sessions'] as List)
            .map((json) => TeacherAcademicSession.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch sessions: $e');
    }
  }

  Future<List<DiarySubject>> fetchSubjects() async {
    try {
      // Since there is no direct /teacher/subjects endpoint, we fetch routines
      // and extract unique subjects from there. This is a workaround.
      final response = await _dioClient.get(ApiEndpoints.teacherRoutines);
      if (response.statusCode == 200 && response.data['routines'] != null) {
        final List<dynamic> routinesJson = response.data['routines'];
        final routines = routinesJson
            .map((json) => TeacherRoutine.fromJson(json))
            .toList();

        final Map<int, DiarySubject> uniqueSubjects = {};
        for (var routine in routines) {
          if (routine.subject != null) {
            // Convert RoutineSubject to DiarySubject
            uniqueSubjects[routine.subject!.id] = DiarySubject(
              id: routine.subject!.id,
              name: routine.subject!.name,
              code: routine.subject!.code,
            );
          }
        }
        return uniqueSubjects.values.toList();
      }
      return [];
    } catch (e) {
      // Fail silently or return empty, users can't select subject
      print('Failed to fetch subjects from routines: $e');
      return [];
    }
  }
}
