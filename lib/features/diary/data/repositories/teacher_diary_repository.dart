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

  Future<List<TeacherDiary>> fetchDiaries() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.teacherDiaries);

      if (response.statusCode == 200) {
        final data = response.data;
        // Assuming the list key is 'diaries' or the root is a list/page.
        // Based on routine response { "routines": [...] }, assume { "diaries": [...] }
        // If not, we might need to adjust.
        if (data['diaries'] != null) {
          final List<dynamic> diariesJson = data['diaries'];
          return diariesJson
              .map((json) => TeacherDiary.fromJson(json))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch diaries');
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
