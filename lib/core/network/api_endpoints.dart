/// API endpoint constants for PathShala Bondhu
class ApiEndpoints {
  // Private constructor to prevent instantiation
  ApiEndpoints._();

  // Base URL
  static const String baseUrl = 'http://pathshalabondhu.top/api/v1';

  // ========== Authentication Endpoints ==========
  
  /// Teacher login endpoint
  /// POST: { "email": "string", "password": "string" }
  static const String teacherLogin = '/teacher/login';

  /// Parent login endpoint
  /// POST: { "parent_id": "string", "password": "string" }
  static const String parentLogin = '/parent/login';

  /// Get parent profile
  /// GET with Bearer token
  static const String parentMe = '/parent/me';

  // ========== Parent Endpoints ==========
  
  /// Get parent's students list
  /// GET with Bearer token
  static const String parentStudents = '/parent/students';

  // ========== Category Endpoints ==========
  
  /// Get book list for all students
  /// GET with Bearer token
  static const String bookList = '/booklist';

  /// Get class routines for all students
  /// GET with Bearer token
  static const String routines = '/routines';

  /// Get exam routines for all students
  /// GET with Bearer token
  static const String examRoutines = '/exam-routines';

  /// Get student attendance with filters
  /// GET with Bearer token
  /// Query params: month_name, year
  static const String studentAttendance = '/student/attendance';

  /// Get student fees with filters
  /// POST with Bearer token
  /// Body: { "year": "string" }
  static const String studentFees = '/student/fees/monthly';
}
