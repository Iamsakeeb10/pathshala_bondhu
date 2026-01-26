/// Attendance summary model for statistics
class AttendanceSummaryModel {
  final String date;
  final int totalTeachers;
  final int markedAttendance;
  final int pendingAttendance;
  final int present;
  final int absent;
  final int leave;
  final double attendancePercentage;

  AttendanceSummaryModel({
    required this.date,
    required this.totalTeachers,
    required this.markedAttendance,
    required this.pendingAttendance,
    required this.present,
    required this.absent,
    required this.leave,
    required this.attendancePercentage,
  });

  // Helper methods
  bool get hasNoTeachers => totalTeachers == 0;
  bool get allMarked => pendingAttendance == 0;
  String getPercentageDisplay() =>
      "${attendancePercentage.toStringAsFixed(1)}%";

  factory AttendanceSummaryModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSummaryModel(
      date: json['date'] as String,
      totalTeachers: json['total_teachers'] as int,
      markedAttendance: json['marked_attendance'] as int,
      pendingAttendance: json['pending_attendance'] as int,
      present: json['present'] as int,
      absent: json['absent'] as int,
      leave: json['leave'] as int,
      attendancePercentage: (json['attendance_percentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'total_teachers': totalTeachers,
      'marked_attendance': markedAttendance,
      'pending_attendance': pendingAttendance,
      'present': present,
      'absent': absent,
      'leave': leave,
      'attendance_percentage': attendancePercentage,
    };
  }
}
