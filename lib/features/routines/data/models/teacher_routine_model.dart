class TeacherRoutine {
  final int id;
  final String? schoolId;
  final String? classId;
  final String? academicSessionId;
  final String? subjectId;
  final String? teacherId;
  final String day;
  final String startTime;
  final String endTime;
  final String? roomNumber;
  final RoutineClass? routineClass;
  final RoutineSubject? subject;
  final RoutineSession? session;

  TeacherRoutine({
    required this.id,
    this.schoolId,
    this.classId,
    this.academicSessionId,
    this.subjectId,
    this.teacherId,
    required this.day,
    required this.startTime,
    required this.endTime,
    this.roomNumber,
    this.routineClass,
    this.subject,
    this.session,
  });

  factory TeacherRoutine.fromJson(Map<String, dynamic> json) {
    return TeacherRoutine(
      id: json['id'],
      schoolId: json['school_id']?.toString(),
      classId: json['class_id']?.toString(),
      academicSessionId: json['academic_sessions']?.toString(),
      subjectId: json['subject_id']?.toString(),
      teacherId: json['teacher_id']?.toString(),
      day: json['day'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      roomNumber: json['room_number'],
      routineClass: json['class'] != null ? RoutineClass.fromJson(json['class']) : null,
      subject: json['subject'] != null ? RoutineSubject.fromJson(json['subject']) : null,
      session: json['academic_session'] != null ? RoutineSession.fromJson(json['academic_session']) : null,
    );
  }
}

class RoutineClass {
  final int id;
  final String name;
  final String? numericValue;

  RoutineClass({required this.id, required this.name, this.numericValue});

  factory RoutineClass.fromJson(Map<String, dynamic> json) {
    return RoutineClass(
      id: json['id'],
      name: json['name'] ?? '',
      numericValue: json['numeric_value'],
    );
  }
}

class RoutineSubject {
  final int id;
  final String name;
  final String? code;

  RoutineSubject({required this.id, required this.name, this.code});

  factory RoutineSubject.fromJson(Map<String, dynamic> json) {
    return RoutineSubject(
      id: json['id'],
      name: json['name'] ?? '',
      code: json['code'],
    );
  }
}

class RoutineSession {
  final int id;
  final String title;
  final String isCurrent;

  RoutineSession({required this.id, required this.title, required this.isCurrent});

  factory RoutineSession.fromJson(Map<String, dynamic> json) {
    return RoutineSession(
      id: json['id'],
      title: json['title'] ?? '',
      isCurrent: json['is_current']?.toString() ?? '0',
    );
  }
}
