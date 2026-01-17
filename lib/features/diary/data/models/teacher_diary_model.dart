import '../../../teacher_attendance/data/models/teacher_attendance_models.dart';

class PaginatedDiaryResponse {
  final int currentPage;
  final List<TeacherDiary> data;
  final String firstPageUrl;
  final int? from;
  final int lastPage;
  final String lastPageUrl;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int? to;
  final int total;

  PaginatedDiaryResponse({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    this.from,
    required this.lastPage,
    required this.lastPageUrl,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    this.to,
    required this.total,
  });

  factory PaginatedDiaryResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedDiaryResponse(
      currentPage: json['current_page'] ?? 1,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => TeacherDiary.fromJson(e))
              .toList() ??
          [],
      firstPageUrl: json['first_page_url'] ?? '',
      from: json['from'],
      lastPage: json['last_page'] ?? 1,
      lastPageUrl: json['last_page_url'] ?? '',
      nextPageUrl: json['next_page_url'],
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 20,
      prevPageUrl: json['prev_page_url'],
      to: json['to'],
      total: json['total'] ?? 0,
    );
  }
}

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
  final String? attachment;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final TeacherClass? diaryClass;
  final DiarySubject? subject;
  final TeacherAcademicSession? academicSession;

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
    this.attachment,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.diaryClass,
    this.subject,
    this.academicSession,
  });

  factory TeacherDiary.fromJson(Map<String, dynamic> json) {
    return TeacherDiary(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      classId: json['class_id'] != null
          ? int.tryParse(json['class_id'].toString())
          : null,
      academicSessionId: json['academic_session_id'] != null
          ? int.tryParse(json['academic_session_id'].toString())
          : null,
      subjectId: json['subject_id'] != null
          ? int.tryParse(json['subject_id'].toString())
          : null,
      teacherId: json['teacher_id'] != null
          ? int.tryParse(json['teacher_id'].toString())
          : null,
      diaryDate: json['diary_date'],
      submissionDate: json['submission_date'],
      title: json['title'] ?? '',
      description: json['description'],
      attachment: json['attachment'],
      status: json['status'] ?? 'draft',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      diaryClass: json['class'] != null
          ? TeacherClass.fromJson(json['class'])
          : null,
      subject: json['subject'] != null
          ? DiarySubject.fromJson(json['subject'])
          : null,
      academicSession: json['academic_session'] != null
          ? TeacherAcademicSession.fromJson(json['academic_session'])
          : null,
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
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      code: json['code'],
    );
  }
}

