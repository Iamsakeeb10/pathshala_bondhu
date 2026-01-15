/// Exam routine response model
class ExamRoutineResponse {
  final String parentName;
  final String schoolName;
  final int totalStudents;
  final List<ChildExamRoutine> childrenExamRoutines;

  ExamRoutineResponse({
    required this.parentName,
    required this.schoolName,
    required this.totalStudents,
    required this.childrenExamRoutines,
  });

  factory ExamRoutineResponse.fromJson(Map<String, dynamic> json) {
    return ExamRoutineResponse(
      parentName: json['parent_name'] as String,
      schoolName: json['school_name'] as String,
      totalStudents: json['total_students'] as int,
      childrenExamRoutines: (json['children_exam_routines'] as List)
          .map((item) =>
              ChildExamRoutine.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Child exam routine model
class ChildExamRoutine {
  final String studentName;
  final String studentId;
  final String classInfo;
  final String academicSession;
  final List<ExamEntry> examRoutines;

  ChildExamRoutine({
    required this.studentName,
    required this.studentId,
    required this.classInfo,
    required this.academicSession,
    required this.examRoutines,
  });

  factory ChildExamRoutine.fromJson(Map<String, dynamic> json) {
    return ChildExamRoutine(
      studentName: json['student_name'] as String,
      studentId: json['student_id'] as String,
      classInfo: json['class_info'] as String,
      academicSession: json['academic_session'] as String,
      examRoutines: (json['exam_routines'] as List)
          .map((exam) => ExamEntry.fromJson(exam as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Exam entry model
class ExamEntry {
  final String examName;
  final String subject;
  final String date;
  final String startTime;
  final String endTime;
  final String roomNumber;

  ExamEntry({
    required this.examName,
    required this.subject,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.roomNumber,
  });

  factory ExamEntry.fromJson(Map<String, dynamic> json) {
    return ExamEntry(
      examName: json['exam_name'] as String,
      subject: json['subject'] as String,
      date: json['date'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      roomNumber: json['room_number'] as String,
    );
  }
}
