import '../../../teachers/data/models/teacher_model.dart';

/// Parent model matching the API response structure
///
/// API: GET /api/v1/parents?search=<query>&page=1&per_page=10
class ParentListModel {
  final int id;
  final int? userId;
  final String parentUniqueId;
  final String fatherName;
  final String motherName;
  final String? fatherJob;
  final String? motherJob;
  final String parentPhone;
  final String? address;
  final SchoolInfo? school;

  ParentListModel({
    required this.id,
    this.userId,
    required this.parentUniqueId,
    required this.fatherName,
    required this.motherName,
    this.fatherJob,
    this.motherJob,
    required this.parentPhone,
    this.address,
    this.school,
  });

  factory ParentListModel.fromJson(Map<String, dynamic> json) {
    // Handle user_id which might be String or int from API
    int? parsedUserId;
    if (json['user_id'] != null) {
      if (json['user_id'] is int) {
        parsedUserId = json['user_id'] as int;
      } else if (json['user_id'] is String) {
        parsedUserId = int.tryParse(json['user_id'] as String);
      }
    }

    return ParentListModel(
      id: json['id'] as int,
      userId: parsedUserId,
      parentUniqueId: json['parent_unique_id'] as String? ?? '',
      fatherName: json['father_name'] as String? ?? 'Unknown',
      motherName: json['mother_name'] as String? ?? '',
      fatherJob: json['father_job'] as String?,
      motherJob: json['mother_job'] as String?,
      parentPhone: json['parent_phone'] as String? ?? '',
      address: json['address'] as String?,
      school: json['school'] != null
          ? SchoolInfo.fromJson(json['school'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Get display name for the parent (primary: father name)
  String get displayName => fatherName;
}

/// Parents list response
class ParentsListResponse {
  final bool success;
  final List<ParentListModel> parents;
  final PaginationInfo pagination;

  ParentsListResponse({
    required this.success,
    required this.parents,
    required this.pagination,
  });

  factory ParentsListResponse.fromJson(Map<String, dynamic> json) {
    return ParentsListResponse(
      success: json['success'] as bool? ?? true,
      parents:
          (json['data'] as List<dynamic>?)
              ?.map((e) => ParentListModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: PaginationInfo.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
