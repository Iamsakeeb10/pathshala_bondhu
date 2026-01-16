/// Parent login request model
class ParentLoginRequest {
  final String parentId;
  final String password;

  ParentLoginRequest({
    required this.parentId,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'parent_id': parentId,
      'password': password,
    };
  }
}

/// Parent login response model
class ParentLoginResponse {
  final String token;
  final ParentUser parent;

  ParentLoginResponse({
    required this.token,
    required this.parent,
  });

  factory ParentLoginResponse.fromJson(Map<String, dynamic> json) {
    return ParentLoginResponse(
      token: json['token'] as String,
      parent: ParentUser.fromJson(json['parent'] as Map<String, dynamic>),
    );
  }
}

/// Parent user model
class ParentUser {
  final int id;
  final String parentUniqueId;
  final String fatherName;
  final String? motherName;
  final String? fatherJob;
  final String? motherJob;
  final String parentPhone;
  final String? address;
  final String createdAt;
  final String updatedAt;

  ParentUser({
    required this.id,
    required this.parentUniqueId,
    required this.fatherName,
    this.motherName,
    this.fatherJob,
    this.motherJob,
    required this.parentPhone,
    this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ParentUser.fromJson(Map<String, dynamic> json) {
    return ParentUser(
      id: json['id'] as int,
      parentUniqueId: json['parent_unique_id'] as String,
      fatherName: json['father_name'] as String,
      motherName: json['mother_name'] as String?,
      fatherJob: json['father_job'] as String?,
      motherJob: json['mother_job'] as String?,
      parentPhone: json['parent_phone'] as String,
      address: json['address'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parent_unique_id': parentUniqueId,
      'father_name': fatherName,
      'mother_name': motherName,
      'father_job': fatherJob,
      'mother_job': motherJob,
      'parent_phone': parentPhone,
      'address': address,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

/// Student information model
class StudentInfo {
  final int id;
  final String schoolId;
  final String userId;
  final String parentId;
  final String studentId;
  final String classId;
  final String academicSessionId;
  final String rollNo;
  final String? session;
  final String createdAt;
  final String updatedAt;
  final ClassInfo classInfo;
  final AcademicSession academicSession;
  final StudentUser? user;

  StudentInfo({
    required this.id,
    required this.schoolId,
    required this.userId,
    required this.parentId,
    required this.studentId,
    required this.classId,
    required this.academicSessionId,
    required this.rollNo,
    this.session,
    required this.createdAt,
    required this.updatedAt,
    required this.classInfo,
    required this.academicSession,
    this.user,
  });

  factory StudentInfo.fromJson(Map<String, dynamic> json) {
    return StudentInfo(
      id: json['id'] as int,
      schoolId: json['school_id'] as String,
      userId: json['user_id'] as String,
      parentId: json['parent_id'] as String,
      studentId: json['student_id'] as String,
      classId: json['class_id'] as String,
      academicSessionId: json['academic_session_id'] as String,
      rollNo: json['roll_no'] as String,
      session: json['session'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      classInfo: ClassInfo.fromJson(json['class'] as Map<String, dynamic>),
      academicSession: AcademicSession.fromJson(
        json['academic_session'] as Map<String, dynamic>,
      ),
      user: json['user'] != null
          ? StudentUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}

class StudentUser {
  final int id;
  final String schoolId;
  final String name;
  final String email;
  final String? avatar;

  StudentUser({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.email,
    this.avatar,
  });

  factory StudentUser.fromJson(Map<String, dynamic> json) {
    return StudentUser(
      id: json['id'] as int,
      schoolId: json['school_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
    );
  }
}

/// Class information model
class ClassInfo {
  final int id;
  final String schoolId;
  final String name;
  final String numericValue;
  final String? code;
  final String? description;
  final String? academicYear;
  final String? capacity;
  final String createdAt;
  final String updatedAt;

  ClassInfo({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.numericValue,
    this.code,
    this.description,
    this.academicYear,
    this.capacity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    return ClassInfo(
      id: json['id'] as int,
      schoolId: json['school_id'] as String,
      name: json['name'] as String,
      numericValue: json['numeric_value'] as String,
      code: json['code'] as String?,
      description: json['description'] as String?,
      academicYear: json['academic_year'] as String?,
      capacity: json['capacity'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }
}

/// Academic session model
class AcademicSession {
  final int id;
  final String schoolId;
  final String title;
  final String isCurrent;
  final String createdAt;
  final String updatedAt;

  AcademicSession({
    required this.id,
    required this.schoolId,
    required this.title,
    required this.isCurrent,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AcademicSession.fromJson(Map<String, dynamic> json) {
    return AcademicSession(
      id: json['id'] as int,
      schoolId: json['school_id'] as String,
      title: json['title'] as String,
      isCurrent: json['is_current'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }
}

/// Get students response model
class GetStudentsResponse {
  final List<StudentInfo> students;

  GetStudentsResponse({required this.students});

  factory GetStudentsResponse.fromJson(Map<String, dynamic> json) {
    return GetStudentsResponse(
      students: (json['students'] as List)
          .map((student) => StudentInfo.fromJson(student as Map<String, dynamic>))
          .toList(),
    );
  }
}
