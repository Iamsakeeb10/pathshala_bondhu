/// Fees response model
class FeesResponse {
  final String parentName;
  final String schoolName;
  final int totalStudents;
  final int academicYear;
  final List<ChildFees> childrenFees;

  FeesResponse({
    required this.parentName,
    required this.schoolName,
    required this.totalStudents,
    required this.academicYear,
    required this.childrenFees,
  });

  factory FeesResponse.fromJson(Map<String, dynamic> json) {
    return FeesResponse(
      parentName: json['parent_name'] as String,
      schoolName: json['school_name'] as String,
      totalStudents: json['total_students'] as int,
      academicYear: json['academic_year'] as int,
      childrenFees: (json['children_fees'] as List)
          .map((item) => ChildFees.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ChildFees {
  final String studentName;
  final String studentId;
  final String classInfo;
  final int totalPaidYear;
  final List<MonthlyFee> monthlyBreakdown;

  ChildFees({
    required this.studentName,
    required this.studentId,
    required this.classInfo,
    required this.totalPaidYear,
    required this.monthlyBreakdown,
  });

  factory ChildFees.fromJson(Map<String, dynamic> json) {
    return ChildFees(
      studentName: json['student_name'] as String,
      studentId: json['student_id'] as String,
      classInfo: json['class_info'] as String,
      totalPaidYear: json['total_paid_year'] as int,
      monthlyBreakdown: (json['monthly_breakdown'] as List)
          .map((item) => MonthlyFee.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MonthlyFee {
  final String monthName;
  final int paidAmount;
  final String status;

  MonthlyFee({
    required this.monthName,
    required this.paidAmount,
    required this.status,
  });

  factory MonthlyFee.fromJson(Map<String, dynamic> json) {
    return MonthlyFee(
      monthName: json['month_name'] as String,
      paidAmount: json['paid_amount'] as int,
      status: json['status'] as String,
    );
  }

  bool get isPaid => status.toLowerCase().contains('paid') && !status.toLowerCase().contains('unpaid');
}
