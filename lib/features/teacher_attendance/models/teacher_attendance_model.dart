import 'package:flutter/material.dart';

/// User basic model for marked_by field
class UserBasicModel {
  final int id;
  final String schoolId;
  final String name;
  final String email;
  final String? avatar;
  final String? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserBasicModel({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.email,
    this.avatar,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserBasicModel.fromJson(Map<String, dynamic> json) {
    return UserBasicModel(
      id: json['id'] as int,
      schoolId: json['school_id'].toString(),
      name: json['name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
      emailVerifiedAt: json['email_verified_at'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
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
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Teacher basic model
class TeacherBasicModel {
  final int id;
  final String schoolId;
  final String userId;
  final String department;
  final String? specialization;
  final DateTime hireDate;
  final String? bio;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserBasicModel user;

  TeacherBasicModel({
    required this.id,
    required this.schoolId,
    required this.userId,
    required this.department,
    this.specialization,
    required this.hireDate,
    this.bio,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  String get fullName => user.name;
  String get email => user.email;
  String? get avatar => user.avatar;
  String get displayDepartment =>
      specialization != null && specialization!.isNotEmpty
      ? "$department - $specialization"
      : department;

  factory TeacherBasicModel.fromJson(Map<String, dynamic> json) {
    return TeacherBasicModel(
      id: json['id'] as int,
      schoolId: json['school_id'].toString(),
      userId: json['user_id'].toString(),
      department: json['department'] as String,
      specialization: json['specialization'] as String?,
      hireDate: DateTime.parse(json['hire_date'] as String),
      bio: json['bio'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      user: UserBasicModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'user_id': userId,
      'department': department,
      'specialization': specialization,
      'hire_date': hireDate.toIso8601String(),
      'bio': bio,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user': user.toJson(),
    };
  }
}

/// School basic model
class SchoolBasicModel {
  final int id;
  final String schoolId;
  final bool isActive;
  final String name;
  final String email;
  final String phone;
  final String address;

  SchoolBasicModel({
    required this.id,
    required this.schoolId,
    required this.isActive,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
  });

  factory SchoolBasicModel.fromJson(Map<String, dynamic> json) {
    return SchoolBasicModel(
      id: json['id'] as int,
      schoolId: json['school_id'].toString(),
      isActive: json['is_active'] == true || json['is_active'] == 1,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'is_active': isActive,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
    };
  }
}

/// Academic session model
class AcademicSessionModel {
  final int id;
  final String schoolId;
  final String title;
  final String isCurrent;
  final DateTime createdAt;
  final DateTime updatedAt;

  AcademicSessionModel({
    required this.id,
    required this.schoolId,
    required this.title,
    required this.isCurrent,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AcademicSessionModel.fromJson(Map<String, dynamic> json) {
    return AcademicSessionModel(
      id: json['id'] as int,
      schoolId: json['school_id'].toString(),
      title: json['title'] as String,
      isCurrent: json['is_current'].toString(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'title': title,
      'is_current': isCurrent,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Teacher attendance model
class TeacherAttendanceModel {
  final int id;
  final String schoolId;
  final String academicSessionId;
  final String teacherId;
  final DateTime date;
  final String? checkInTime;
  final String? checkOutTime;
  final String status;
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TeacherBasicModel teacher;
  final UserBasicModel? markedBy;
  final SchoolBasicModel? school;
  final AcademicSessionModel? academicSession;

  TeacherAttendanceModel({
    required this.id,
    required this.schoolId,
    required this.academicSessionId,
    required this.teacherId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
    required this.teacher,
    this.markedBy,
    this.school,
    this.academicSession,
  });

  // Helper methods
  bool get isPresent => status.toLowerCase() == 'present';
  bool get isAbsent => status.toLowerCase() == 'absent';
  bool get isLeave => status.toLowerCase() == 'leave';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get hasCheckOut => checkOutTime != null && checkOutTime!.isNotEmpty;

  Color getStatusColor(bool isDarkMode) {
    if (isPresent) {
      return isDarkMode ? Colors.green.shade400 : Colors.green.shade600;
    } else if (isAbsent) {
      return isDarkMode ? Colors.red.shade400 : Colors.red.shade600;
    } else if (isLeave) {
      return isDarkMode ? Colors.orange.shade400 : Colors.orange.shade600;
    } else {
      return isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    }
  }

  Color getStatusBackgroundColor(bool isDarkMode) {
    if (isPresent) {
      return isDarkMode
          ? Colors.green.shade900.withOpacity(0.2)
          : Colors.green.shade50;
    } else if (isAbsent) {
      return isDarkMode
          ? Colors.red.shade900.withOpacity(0.2)
          : Colors.red.shade50;
    } else if (isLeave) {
      return isDarkMode
          ? Colors.orange.shade900.withOpacity(0.2)
          : Colors.orange.shade50;
    } else {
      return isDarkMode
          ? Colors.grey.shade800.withOpacity(0.3)
          : Colors.grey.shade100;
    }
  }

  String getStatusLabel(String Function(String) translate) {
    if (isPresent) return translate('present');
    if (isAbsent) return translate('absent');
    if (isLeave) return translate('leave');
    return translate('pending');
  }

  factory TeacherAttendanceModel.fromJson(Map<String, dynamic> json) {
    return TeacherAttendanceModel(
      id: json['id'] as int,
      schoolId: json['school_id'].toString(),
      academicSessionId: json['academic_session_id'].toString(),
      teacherId: json['teacher_id'].toString(),
      date: DateTime.parse(json['date'] as String),
      checkInTime: json['check_in_time'] as String?,
      checkOutTime: json['check_out_time'] as String?,
      status: json['status'] as String,
      remarks: json['remarks'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      teacher: TeacherBasicModel.fromJson(
        json['teacher'] as Map<String, dynamic>,
      ),
      markedBy: json['marked_by'] != null
          ? UserBasicModel.fromJson(json['marked_by'] as Map<String, dynamic>)
          : null,
      school: json['school'] != null
          ? SchoolBasicModel.fromJson(json['school'] as Map<String, dynamic>)
          : null,
      academicSession: json['academic_session'] != null
          ? AcademicSessionModel.fromJson(
              json['academic_session'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'academic_session_id': academicSessionId,
      'teacher_id': teacherId,
      'date': date.toIso8601String(),
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'status': status,
      'remarks': remarks,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'teacher': teacher.toJson(),
      'marked_by': markedBy?.toJson(),
      'school': school?.toJson(),
      'academic_session': academicSession?.toJson(),
    };
  }

  /// Create a pending attendance model for teachers without attendance
  static TeacherAttendanceModel createPending({
    required TeacherBasicModel teacher,
    required DateTime date,
  }) {
    return TeacherAttendanceModel(
      id: -1,
      schoolId: teacher.schoolId,
      academicSessionId: '0',
      teacherId: teacher.id.toString(),
      date: date,
      status: 'pending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      teacher: teacher,
    );
  }
}
