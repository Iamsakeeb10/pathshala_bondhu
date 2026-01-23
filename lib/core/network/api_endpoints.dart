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

  /// Update parent profile
  /// PUT with Bearer token
  /// Body: { "father_name": "...", ... }
  static const String parentProfileUpdate = '/parent/profile';

  /// Get teacher profile
  /// GET with Bearer token
  static const String teacherMe = '/teacher/me';

  /// Update teacher profile
  /// PUT with Bearer token
  /// Body: { "name": "...", ... }
  static const String teacherProfileUpdate = '/teacher/profile';

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

  /// Get student results for all children
  /// GET with Bearer token
  /// No query params needed - returns all children's results
  static const String studentResults = '/student/result';

  // ========== Teacher Attendance Endpoints ==========

  /// Get academic sessions for teacher
  /// GET
  static const String teacherAcademicSessions = '/teacher/academic-sessions';

  /// Get classes for teacher
  /// GET
  static const String teacherClasses = '/teacher/classes';

  /// Get students for a class and session
  /// POST: { "class_id": "1", "academic_session_id": "1" }
  static const String teacherStudents = '/teacher/students';

  /// Submit attendance OR Get History (POST)
  static const String teacherAttendance = '/teacher/attendance';

  /// Get routines for teacher
  /// GET
  static const String teacherRoutines = '/teacher/routines';

  /// Get diaries (GET) or Create diary (POST)
  /// GET/POST
  static const String teacherDiaries = '/teacher/diaries';

  /// Get student diaries with date filter
  /// GET (with body): { "date": "YYYY-MM-DD" }
  static const String studentDiaries = '/student/diaries';

  // ========== Notification Endpoints ==========

  /// Get all notifications (paginated)
  /// GET with Bearer token
  /// Query params: per_page, type
  static const String notifications = '/notifications';

  /// Get unread notifications only
  /// GET with Bearer token
  static const String notificationsUnread = '/notifications/unread';

  /// Get unread count (for badge)
  /// GET with Bearer token
  static const String notificationsUnreadCount = '/notifications/unread/count';

  /// Mark single notification as read
  /// POST with Bearer token
  /// Path param: {id}
  static const String markNotificationRead = '/notifications/{id}/mark-read';

  /// Mark all notifications as read
  /// POST with Bearer token
  static const String markAllNotificationsRead = '/notifications/mark-all-read';

  /// Delete notification
  /// DELETE with Bearer token
  /// Path param: {id}
  static const String deleteNotification = '/notifications/{id}';

  // ========== Teachers & Parents Endpoints ==========

  /// Get teachers list (paginated)
  /// GET with Bearer token
  /// Query params: page, per_page
  static const String teachers = '/teachers';

  /// Get parents list (paginated, with optional search)
  /// GET with Bearer token
  /// Query params: page, per_page, search
  static const String parents = '/parents';
}
