class ParentDiaryResponse {
  final String parentName;
  final String schoolName;
  final int totalStudents;
  final List<ParentChildDiary> childrenDiaries;

  ParentDiaryResponse({
    required this.parentName,
    required this.schoolName,
    required this.totalStudents,
    required this.childrenDiaries,
  });

  factory ParentDiaryResponse.fromJson(Map<String, dynamic> json) {
    return ParentDiaryResponse(
      parentName: json['parent_name'] ?? '',
      schoolName: json['school_name'] ?? '',
      totalStudents: json['total_students'] ?? 0,
      childrenDiaries: (json['children_diaries'] as List?)
              ?.map((e) => ParentChildDiary.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ParentChildDiary {
  final String studentName;
  final String studentId;
  final String classInfo;
  final String academicSession;
  final List<ParentDiaryEntry> diaries;

  ParentChildDiary({
    required this.studentName,
    required this.studentId,
    required this.classInfo,
    required this.academicSession,
    required this.diaries,
  });

  factory ParentChildDiary.fromJson(Map<String, dynamic> json) {
    return ParentChildDiary(
      studentName: json['student_name'] ?? '',
      studentId: json['student_id'] ?? '',
      classInfo: json['class_info'] ?? '',
      academicSession: json['academic_session'] ?? '',
      diaries: (json['diaries'] as List?)
              ?.map((e) => ParentDiaryEntry.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ParentDiaryEntry {
  final int id;
  final String date; // Using String to preserve format, can parse if needed
  final String subject;
  final String title;
  final String description;
  final String teacherName;
  final String? attachmentUrl;
  final String submissionDate;

  ParentDiaryEntry({
    required this.id,
    required this.date,
    required this.subject,
    required this.title,
    required this.description,
    required this.teacherName,
    this.attachmentUrl,
    required this.submissionDate,
  });

  factory ParentDiaryEntry.fromJson(Map<String, dynamic> json) {
    return ParentDiaryEntry(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      date: json['date'] ?? '',
      subject: json['subject'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      teacherName: json['teacher_name'] ?? '',
      attachmentUrl: json['attachment_url'],
      submissionDate: json['submission_date'] ?? '',
    );
  }
}
