/// Result response model (similar to FeesResponse)
class ResultResponse {
  final String parentName;
  final String schoolName;
  final int totalStudents;
  final List<ChildResult> childrenResults;

  ResultResponse({
    required this.parentName,
    required this.schoolName,
    required this.totalStudents,
    required this.childrenResults,
  });

  factory ResultResponse.fromJson(Map<String, dynamic> json) {
    return ResultResponse(
      parentName: json['parent_name'] as String? ?? '',
      schoolName: json['school_name'] as String? ?? '',
      totalStudents: json['total_students'] as int? ?? 0,
      childrenResults:
          (json['children_results'] as List?)
              ?.map(
                (item) => ChildResult.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

/// Individual child result model
class ChildResult {
  final String studentName;
  final String studentId;
  final String classInfo;
  final String academicSession;
  final List<ExamResult> exams;

  ChildResult({
    required this.studentName,
    required this.studentId,
    required this.classInfo,
    required this.academicSession,
    required this.exams,
  });

  factory ChildResult.fromJson(Map<String, dynamic> json) {
    return ChildResult(
      studentName: json['student_name'] as String? ?? '',
      studentId: json['student_id'] as String? ?? '',
      classInfo: json['class_info'] as String? ?? '',
      academicSession: json['academic_session'] as String? ?? '',
      exams:
          (json['exams'] as List?)
              ?.map((item) => ExamResult.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Individual exam result model
class ExamResult {
  final String examName;
  final int totalMarks;
  final double averageGpa;
  final String status;
  final List<SubjectResult> subjects;

  ExamResult({
    required this.examName,
    required this.totalMarks,
    required this.averageGpa,
    required this.status,
    required this.subjects,
  });

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      examName: json['exam_name'] as String? ?? '',
      totalMarks: json['total_marks'] as int? ?? 0,
      averageGpa: (json['average_gpa'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? '',
      subjects:
          (json['subjects'] as List?)
              ?.map(
                (item) => SubjectResult.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

/// Subject-wise result model
class SubjectResult {
  final String subject;
  final String marks;
  final String grade;
  final String gpa;

  SubjectResult({
    required this.subject,
    required this.marks,
    required this.grade,
    required this.gpa,
  });

  factory SubjectResult.fromJson(Map<String, dynamic> json) {
    return SubjectResult(
      subject: json['subject'] as String? ?? '',
      marks: json['marks'] as String? ?? '0',
      grade: json['grade'] as String? ?? '',
      gpa: json['gpa'] as String? ?? '0',
    );
  }

  double get marksValue => double.tryParse(marks) ?? 0.0;
  double get gpaValue => double.tryParse(gpa) ?? 0.0;
}
