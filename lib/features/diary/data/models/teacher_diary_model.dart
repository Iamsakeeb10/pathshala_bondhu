class TeacherDiary {
  final int id;
  final int? classId;
  final int? academicSessionId;
  final int? subjectId;
  final int? teacherId;
  final String? diaryDate;
  final String? submissionDate;
  final String title;
  final String? description;
  final String status;
  final DiaryClass? diaryClass;
  final DiarySubject? subject;

  TeacherDiary({
    required this.id,
    this.classId,
    this.academicSessionId,
    this.subjectId,
    this.teacherId,
    this.diaryDate,
    this.submissionDate,
    required this.title,
    this.description,
    required this.status,
    this.diaryClass,
    this.subject,
  });

  factory TeacherDiary.fromJson(Map<String, dynamic> json) {
    return TeacherDiary(
      id: json['id'],
      classId: json['class_id'],
      academicSessionId: json['academic_session_id'],
      subjectId: json['subject_id'],
      teacherId: json['teacher_id'],
      diaryDate: json['diary_date'],
      submissionDate: json['submission_date'],
      title: json['title'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'draft',
      diaryClass: json['class'] != null ? DiaryClass.fromJson(json['class']) : null,
      subject: json['subject'] != null ? DiarySubject.fromJson(json['subject']) : null,
    );
  }
}

class DiaryClass {
  final int id;
  final String name;

  DiaryClass({required this.id, required this.name});

  factory DiaryClass.fromJson(Map<String, dynamic> json) {
    return DiaryClass(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }
}

class DiarySubject {
  final int id;
  final String name;
  final String? code;

  DiarySubject({required this.id, required this.name, this.code});

  factory DiarySubject.fromJson(Map<String, dynamic> json) {
    return DiarySubject(
      id: json['id'],
      name: json['name'] ?? '',
      code: json['code'],
    );
  }
}
