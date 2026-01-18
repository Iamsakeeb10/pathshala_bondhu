/// Teacher login request model
class TeacherLoginRequest {
  final String email;
  final String password;
  final String? deviceId;

  TeacherLoginRequest({
    required this.email,
    required this.password,
    this.deviceId,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'email': email,
      'password': password,
    };
    // Only include device_id if available
    if (deviceId != null && deviceId!.isNotEmpty) {
      json['device_id'] = deviceId;
    }
    return json;
  }
}

/// Teacher login response model
class TeacherLoginResponse {
  final String token;
  final TeacherUserWithDetails user;

  TeacherLoginResponse({required this.token, required this.user});

  factory TeacherLoginResponse.fromJson(Map<String, dynamic> json) {
    return TeacherLoginResponse(
      token: json['token'] as String,
      user: TeacherUserWithDetails.fromJson(
        json['user'] as Map<String, dynamic>,
      ),
    );
  }
}

/// Teacher user with teacher details
class TeacherUserWithDetails {
  final int id;
  final String schoolId;
  final String name;
  final String email;
  final String? avatar;
  final String? emailVerifiedAt;
  final String? passwordDisplay;
  final String createdAt;
  final String updatedAt;
  final TeacherDetails? teacher;

  TeacherUserWithDetails({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.email,
    this.avatar,
    this.emailVerifiedAt,
    this.passwordDisplay,
    required this.createdAt,
    required this.updatedAt,
    this.teacher,
  });

  factory TeacherUserWithDetails.fromJson(Map<String, dynamic> json) {
    return TeacherUserWithDetails(
      id: json['id'] as int,
      schoolId: json['school_id'].toString(),
      name: json['name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
      emailVerifiedAt: json['email_verified_at'] as String?,
      passwordDisplay: json['password_display'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      teacher: json['teacher'] != null
          ? TeacherDetails.fromJson(json['teacher'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'name': name,
      'email': email,
      'avatar': avatar,
      'email_verified_at': emailVerifiedAt,
      'password_display': passwordDisplay,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'teacher': teacher?.toJson(),
    };
  }
}

/// Teacher details model
class TeacherDetails {
  final int id;
  final String schoolId;
  final String userId;
  final String department;
  final String specialization;
  final String hireDate;
  final String? bio;
  final String createdAt;
  final String updatedAt;

  TeacherDetails({
    required this.id,
    required this.schoolId,
    required this.userId,
    required this.department,
    required this.specialization,
    required this.hireDate,
    this.bio,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TeacherDetails.fromJson(Map<String, dynamic> json) {
    return TeacherDetails(
      id: json['id'] as int,
      schoolId: json['school_id'].toString(),
      userId: json['user_id'].toString(),
      department: json['department'] as String,
      specialization: json['specialization'] as String,
      hireDate: json['hire_date'] as String,
      bio: json['bio'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'user_id': userId,
      'department': department,
      'specialization': specialization,
      'hire_date': hireDate,
      'bio': bio,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
