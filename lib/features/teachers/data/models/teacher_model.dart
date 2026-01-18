/// Teacher model matching the API response structure
/// 
/// API: GET /api/v1/teachers?page=1&per_page=25
class TeacherListModel {
  final int id;
  final String name;
  final String? email;
  final String? avatar;
  final TeacherDetails? teacher;
  final SchoolInfo? school;

  TeacherListModel({
    required this.id,
    required this.name,
    this.email,
    this.avatar,
    this.teacher,
    this.school,
  });

  factory TeacherListModel.fromJson(Map<String, dynamic> json) {
    return TeacherListModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String?,
      avatar: json['avatar'] as String?,
      teacher: json['teacher'] != null
          ? TeacherDetails.fromJson(json['teacher'] as Map<String, dynamic>)
          : null,
      school: json['school'] != null
          ? SchoolInfo.fromJson(json['school'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Teacher details (nested object in response)
class TeacherDetails {
  final int id;
  final String? department;
  final String? specialization;
  final String? bio;

  TeacherDetails({
    required this.id,
    this.department,
    this.specialization,
    this.bio,
  });

  factory TeacherDetails.fromJson(Map<String, dynamic> json) {
    return TeacherDetails(
      id: json['id'] as int,
      department: json['department'] as String?,
      specialization: json['specialization'] as String?,
      bio: json['bio'] as String?,
    );
  }
}

/// School info (shared between teachers and parents)
class SchoolInfo {
  final int id;
  final String? schoolId;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? logo;

  SchoolInfo({
    required this.id,
    this.schoolId,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.logo,
  });

  factory SchoolInfo.fromJson(Map<String, dynamic> json) {
    return SchoolInfo(
      id: json['id'] as int,
      schoolId: json['school_id'] as String?,
      name: json['name'] as String? ?? 'Unknown School',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      logo: json['logo'] as String?,
    );
  }
}

/// Pagination info from API response
class PaginationInfo {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final int? from;
  final int? to;
  final String? nextPageUrl;
  final String? prevPageUrl;

  PaginationInfo({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    this.from,
    this.to,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      total: json['total'] as int? ?? 0,
      perPage: json['per_page'] as int? ?? 25,
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      from: json['from'] as int?,
      to: json['to'] as int?,
      nextPageUrl: json['next_page_url'] as String?,
      prevPageUrl: json['prev_page_url'] as String?,
    );
  }

  bool get hasMore => currentPage < lastPage;
}

/// Teachers list response
class TeachersListResponse {
  final bool success;
  final List<TeacherListModel> teachers;
  final PaginationInfo pagination;

  TeachersListResponse({
    required this.success,
    required this.teachers,
    required this.pagination,
  });

  factory TeachersListResponse.fromJson(Map<String, dynamic> json) {
    return TeachersListResponse(
      success: json['success'] as bool? ?? true,
      teachers: (json['data'] as List<dynamic>?)
              ?.map((e) => TeacherListModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: PaginationInfo.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
