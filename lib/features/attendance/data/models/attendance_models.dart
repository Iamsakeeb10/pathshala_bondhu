/// Attendance response model
class AttendanceResponse {
  final String parentName;
  final String schoolName;
  final int totalStudents;
  final String monthName;
  final int year;
  final List<ChildAttendance> childrenAttendance;

  AttendanceResponse({
    required this.parentName,
    required this.schoolName,
    required this.totalStudents,
    required this.monthName,
    required this.year,
    required this.childrenAttendance,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      parentName: json['parent_name'] as String,
      schoolName: json['school_name'] as String,
      totalStudents: json['total_students'] as int,
      monthName: json['month_name'] as String,
      year: json['year'] as int,
      childrenAttendance: (json['children_attendance'] as List)
          .map((item) => ChildAttendance.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ChildAttendance {
  final String studentName;
  final String studentId;
  final String classInfo;
  final AttendanceSummary summary;
  final List<AttendanceLog> attendanceLog;

  ChildAttendance({
    required this.studentName,
    required this.studentId,
    required this.classInfo,
    required this.summary,
    required this.attendanceLog,
  });

  factory ChildAttendance.fromJson(Map<String, dynamic> json) {
    return ChildAttendance(
      studentName: json['student_name'] as String,
      studentId: json['student_id'] as String,
      classInfo: json['class_info'] as String,
      summary: AttendanceSummary.fromJson(json['summary'] as Map<String, dynamic>),
      attendanceLog: (json['attendance_log'] as List)
          .map((log) => AttendanceLog.fromJson(log as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AttendanceSummary {
  final int totalRecords;
  final int present;
  final int absent;
  final int late;
  final String attendanceRate;

  AttendanceSummary({
    required this.totalRecords,
    required this.present,
    required this.absent,
    required this.late,
    required this.attendanceRate,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      totalRecords: json['total_records'] as int,
      present: json['present'] as int,
      absent: json['absent'] as int,
      late: json['late'] as int,
      attendanceRate: json['attendance_rate'] as String,
    );
  }
}

class AttendanceLog {
  final String date;
  final String status;
  final String remarks;

  AttendanceLog({
    required this.date,
    required this.status,
    required this.remarks,
  });

  factory AttendanceLog.fromJson(Map<String, dynamic> json) {
    return AttendanceLog(
      date: json['date'] as String,
      status: json['status'] as String,
      remarks: json['remarks'] as String,
    );
  }
}
