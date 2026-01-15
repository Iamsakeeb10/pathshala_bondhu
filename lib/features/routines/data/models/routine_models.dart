/// Class routine response model
class RoutineResponse {
  final String parentName;
  final String schoolName;
  final int totalStudents;
  final List<ChildRoutine> childrenRoutines;

  RoutineResponse({
    required this.parentName,
    required this.schoolName,
    required this.totalStudents,
    required this.childrenRoutines,
  });

  factory RoutineResponse.fromJson(Map<String, dynamic> json) {
    return RoutineResponse(
      parentName: json['parent_name'] as String,
      schoolName: json['school_name'] as String,
      totalStudents: json['total_students'] as int,
      childrenRoutines: (json['children_routines'] as List)
          .map((item) => ChildRoutine.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Child routine model
class ChildRoutine {
  final String studentName;
  final String studentId;
  final String classInfo;
  final String academicSession;
  final List<RoutineEntry> routines;

  ChildRoutine({
    required this.studentName,
    required this.studentId,
    required this.classInfo,
    required this.academicSession,
    required this.routines,
  });

  factory ChildRoutine.fromJson(Map<String, dynamic> json) {
    return ChildRoutine(
      studentName: json['student_name'] as String,
      studentId: json['student_id'] as String,
      classInfo: json['class_info'] as String,
      academicSession: json['academic_session'] as String,
      routines: (json['routines'] as List)
          .map((routine) => RoutineEntry.fromJson(routine as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Routine entry model
class RoutineEntry {
  final String day;
  final String startTime;
  final String endTime;
  final String subject;
  final String teacherName;
  final String roomNumber;

  RoutineEntry({
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.subject,
    required this.teacherName,
    required this.roomNumber,
  });

  factory RoutineEntry.fromJson(Map<String, dynamic> json) {
    return RoutineEntry(
      day: json['day'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      subject: json['subject'] as String,
      teacherName: json['teacher_name'] as String,
      roomNumber: json['room_number'] as String,
    );
  }
}
