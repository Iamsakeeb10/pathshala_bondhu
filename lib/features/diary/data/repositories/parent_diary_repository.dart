import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/parent_diary_model.dart';

class ParentDiaryRepository {
  final DioClient _dioClient;

  ParentDiaryRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  Future<ParentDiaryResponse> fetchDiaries({DateTime? date}) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date ?? DateTime.now());

      // The user specified a GET request with a JSON body for filtering.
      // While unusual for GET, Dio supports it.
      final response = await _dioClient.get(
        ApiEndpoints.studentDiaries,
        data: {'date': dateStr},
      );

      if (response.statusCode == 200) {
        return ParentDiaryResponse.fromJson(response.data);
      }
      throw Exception('Failed to load diaries');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch diaries');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
