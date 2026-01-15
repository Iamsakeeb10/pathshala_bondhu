/// Book list response model
class BookListResponse {
  final String parentName;
  final String schoolName;
  final int totalStudents;
  final List<ChildBookList> childrenBookLists;

  BookListResponse({
    required this.parentName,
    required this.schoolName,
    required this.totalStudents,
    required this.childrenBookLists,
  });

  factory BookListResponse.fromJson(Map<String, dynamic> json) {
    return BookListResponse(
      parentName: json['parent_name'] as String,
      schoolName: json['school_name'] as String,
      totalStudents: json['total_students'] as int,
      childrenBookLists: (json['children_book_lists'] as List)
          .map((item) => ChildBookList.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Child book list model
class ChildBookList {
  final String studentName;
  final String studentId;
  final String classInfo;
  final String academicSession;
  final List<BookInfo> books;

  ChildBookList({
    required this.studentName,
    required this.studentId,
    required this.classInfo,
    required this.academicSession,
    required this.books,
  });

  factory ChildBookList.fromJson(Map<String, dynamic> json) {
    return ChildBookList(
      studentName: json['student_name'] as String,
      studentId: json['student_id'] as String,
      classInfo: json['class_info'] as String,
      academicSession: json['academic_session'] as String,
      books: (json['books'] as List)
          .map((book) => BookInfo.fromJson(book as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Book information model
class BookInfo {
  final String subject;
  final String bookName;
  final String author;
  final String publisher;
  final String edition;
  final String isMandatory;

  BookInfo({
    required this.subject,
    required this.bookName,
    required this.author,
    required this.publisher,
    required this.edition,
    required this.isMandatory,
  });

  factory BookInfo.fromJson(Map<String, dynamic> json) {
    return BookInfo(
      subject: json['subject'] as String,
      bookName: json['book_name'] as String,
      author: json['author'] as String,
      publisher: json['publisher'] as String,
      edition: json['edition'] as String,
      isMandatory: json['is_mandatory'] as String,
    );
  }

  bool get mandatory => isMandatory.toLowerCase() == 'yes';
}
