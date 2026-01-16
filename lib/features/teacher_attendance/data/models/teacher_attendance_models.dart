class TeacherAcademicSession {
  final int id;
  final String title;
  final String isCurrent;

  TeacherAcademicSession({
    required this.id,
    required this.title,
    required this.isCurrent,
  });

  factory TeacherAcademicSession.fromJson(Map<String, dynamic> json) {
    return TeacherAcademicSession(
      id: json['id'] as int,
      title: json['title'] as String,
      isCurrent: json['is_current'].toString(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeacherAcademicSession &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class TeacherClass {
  final int id;
  final String name;
  final String numericValue;

  TeacherClass({
    required this.id,
    required this.name,
    required this.numericValue,
  });

  factory TeacherClass.fromJson(Map<String, dynamic> json) {
    return TeacherClass(
      id: json['id'] as int,
      name: json['name'] as String,
      numericValue: json['numeric_value'].toString(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeacherClass &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class TeacherStudent {
  final int id;
  final String studentId; // e.g. "83740280"
  final String rollNo;
  final UserInfo user;

  TeacherStudent({
    required this.id,
    required this.studentId,
    required this.rollNo,
    required this.user,
  });

  factory TeacherStudent.fromJson(Map<String, dynamic> json) {
    return TeacherStudent(
      id: json['id'] as int,
      studentId: json['student_id'].toString(),
      rollNo: json['roll_no'].toString(),
      user: UserInfo.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class UserInfo {
  final int id;
  final String name;
  final String? avatar;
  final String? email;

  UserInfo({
    required this.id,
    required this.name,
    this.avatar,
    this.email,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      email: json['email'] as String?,
    );
  }
}

class AttendanceSubmissionEntry {
  final int studentId;
  final String status; // 'present' or 'absent'
  final String? remarks;

  AttendanceSubmissionEntry({
    required this.studentId,
    required this.status,
    this.remarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'status': status,
      'remarks': remarks,
    };
  }
}

class AttendanceSubmissionPayload {
  final int classId;
  final int academicSessionId;
  final String date;
  final List<AttendanceSubmissionEntry> attendances;

  AttendanceSubmissionPayload({
    required this.classId,
    required this.academicSessionId,
    required this.date,
    required this.attendances,
  });

  Map<String, dynamic> toJson() {
    return {
      'class_id': classId,
      'academic_session_id': academicSessionId,
      'date': date,
      'attendances': attendances.map((e) => e.toJson()).toList(),
    };
  }
}

class AttendanceHistoryRecord {
  final int id;
  final String status; // 'present' or 'absent'
  final String? remarks;
  final String date;
  final TeacherStudent student; // Nested student object
  final UserInfo? markedBy; // Nested user object

  AttendanceHistoryRecord({
    required this.id,
    required this.status,
    this.remarks,
    required this.date,
    required this.student,
    this.markedBy,
  });

  factory AttendanceHistoryRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryRecord(
      id: json['id'] as int,
      status: json['status'] as String,
      remarks: json['remarks'] as String?,
      date: json['date'] as String,
      student: TeacherStudent.fromJson(json['student'] as Map<String, dynamic>),
      markedBy: json['marked_by'] is Map<String, dynamic>
          ? UserInfo.fromJson(json['marked_by'] as Map<String, dynamic>)
          : null, // marked_by can be int ID in some responses or object? Spec says object in history list.
    );
  }
}

