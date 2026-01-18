import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/router/app_router.dart';
import '../../app/theme/providers/auth_provider.dart';
import '../../features/attendance/provider/attendance_provider.dart';
import '../../features/books/provider/books_provider.dart';
import '../../features/diary/provider/parent_diary_provider.dart';
import '../../features/diary/provider/teacher_diary_provider.dart';
import '../../features/exams/provider/exam_routine_provider.dart';
import '../../features/fees/provider/fees_provider.dart';
import '../../features/notifications/providers/notification_provider.dart';
import '../../features/parents/provider/parents_provider.dart';
import '../../features/routines/provider/routine_provider.dart';
import '../../features/routines/provider/teacher_routine_provider.dart';
import '../../features/students/provider/student_provider.dart';
import '../../features/teacher_attendance/provider/teacher_attendance_provider.dart';
import '../../features/teachers/provider/teachers_provider.dart';
import '../network/token_storage.dart';
import '../network/user_storage.dart';

/// Centralized logout service for handling complete user session cleanup.
/// 
/// This service ensures all local data is cleared and all providers are reset
/// to their initial state when a user logs out. It also handles navigation
/// to the login screen with back-prevention.
class LogoutService {
  LogoutService._();

  /// Performs a complete logout with all data cleanup.
  /// 
  /// Clears:
  /// - Auth token and user data from storage
  /// - All provider states
  /// - Notification cache
  /// 
  /// Then navigates to login screen preventing back navigation.
  static Future<void> logout(BuildContext context) async {
    try {
      // 1. Clear all persistent storage
      await TokenStorage.clearAll();
      await UserStorage.clearUserData();

      // 2. Reset all feature providers
      if (context.mounted) {
        _resetAllProviders(context);
      }

      // 3. Reset auth provider state
      if (context.mounted) {
        await context.read<AuthProvider>().logout();
      }

      // 4. Navigate to login with stack replacement (prevents back navigation)
      if (context.mounted) {
        // Use go() instead of push() to replace the entire navigation stack
        GoRouter.of(context).go(AppRouter.login);
      }

      debugPrint('✅ Logout completed successfully');
    } catch (e) {
      debugPrint('❌ Error during logout: $e');
      // Even if something fails, try to navigate to login
      if (context.mounted) {
        GoRouter.of(context).go(AppRouter.login);
      }
    }
  }

  /// Resets all feature providers to their initial state.
  /// 
  /// This prevents data leakage between different users.
  static void _resetAllProviders(BuildContext context) {
    try {
      // Student data (parent-specific)
      context.read<StudentProvider>().clearAll();

      // Notification data
      context.read<NotificationProvider>().reset();

      // Books data - uses clearCache()
      context.read<BooksProvider>().clearCache();

      // Routine data - uses clearCache()
      context.read<RoutineProvider>().clearCache();

      // Exam routine data - uses clearCache()
      context.read<ExamRoutineProvider>().clearCache();

      // Attendance data
      context.read<AttendanceProvider>().reset();

      // Fees data
      context.read<FeesProvider>().reset();

      // Teacher attendance data
      context.read<TeacherAttendanceProvider>().reset();

      // Teacher routine data
      context.read<TeacherRoutineProvider>().reset();

      // Diary data
      context.read<TeacherDiaryProvider>().reset();
      context.read<ParentDiaryProvider>().reset();

      // Teachers & Parents listing data
      context.read<TeachersProvider>().reset();
      context.read<ParentsProvider>().reset();

      debugPrint('✅ All providers reset successfully');
    } catch (e) {
      debugPrint('⚠️ Error resetting some providers: $e');
      // Continue even if some providers fail to reset
    }
  }
}
