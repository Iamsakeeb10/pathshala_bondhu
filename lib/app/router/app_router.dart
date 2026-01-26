import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/token_storage.dart';
import '../../features/attendance/ui/attendance_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/onboarding_screen.dart';
import '../../features/auth/presentation/pages/splash_screen.dart';
import '../../features/books/ui/books_screen.dart';
import '../../features/chat/screens/chat_background_selection_screen.dart';
import '../../features/chat/screens/conversations_screen.dart';
import '../../features/dashboard/presentation/pages/dashboard_screen.dart';
import '../../features/diary/data/models/teacher_diary_model.dart';
import '../../features/diary/presentation/screens/create_diary_screen.dart';
import '../../features/diary/presentation/screens/parent_diary_screen.dart';
import '../../features/diary/presentation/screens/teacher_diary_details_screen.dart';
import '../../features/diary/presentation/screens/teacher_diary_list_screen.dart';
import '../../features/exams/ui/exam_routine_screen.dart';
import '../../features/fees/ui/fees_screen.dart';
import '../../features/notifications/screens/notification_screen.dart';
import '../../features/profile/presentation/pages/change_password_screen.dart';
import '../../features/profile/presentation/pages/contact_us_screen.dart';
import '../../features/profile/presentation/pages/edit_profile_screen.dart';
import '../../features/profile/presentation/pages/notification_settings_screen.dart';
import '../../features/profile/presentation/pages/privacy_policy_screen.dart';
import '../../features/profile/presentation/pages/profile_details_screen.dart';
import '../../features/profile/presentation/pages/settings_screen.dart';
import '../../features/profile/presentation/pages/terms_conditions_screen.dart';
import '../../features/results/ui/result_screen.dart';
import '../../features/routines/presentation/screens/teacher_routine_screen.dart';
import '../../features/routines/ui/class_routine_screen.dart';
// Import new teacher attendance management screens
import '../../features/teacher_attendance/models/teacher_attendance_model.dart';
import '../../features/teacher_attendance/screens/mark_attendance_screen.dart';
import '../../features/teacher_attendance/screens/teacher_attendance_list_screen.dart';
import '../../features/teacher_attendance/ui/teacher_attendance_screen.dart';
import 'root_navigator_key.dart';

/// Centralized routing configuration using GoRouter
/// Handles all navigation throughout the app
class AppRouter {
  // Route names as constants for type-safe navigation
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String settings = '/settings';

  // Private constructor
  AppRouter._();

  /// GoRouter configuration
  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    debugLogDiagnostics: true,
    initialLocation: splash,
    routes: [
      // Splash Screen
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding Screen
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Login Screen
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Dashboard Screen
      GoRoute(
        path: dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),

      // Settings Screen
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'contact-us',
            name: 'contact-us',
            builder: (context, state) => const ContactUsScreen(),
          ),
          GoRoute(
            path: 'privacy-policy',
            name: 'privacy-policy',
            builder: (context, state) => const PrivacyPolicyScreen(),
          ),
          GoRoute(
            path: 'terms-conditions',
            name: 'terms-conditions',
            builder: (context, state) => const TermsConditionsScreen(),
          ),
        ],
      ),

      // Notification Settings Screen
      GoRoute(
        path: '/notification-settings',
        name: 'notification-settings',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),

      // Profile Detail Routes (Nested under Dashboard -> Profile)
      // Since ProfileScreen is handled inside DashboardScreen tab 4, we don't need a top level route for /profile unless we want deep linking.
      // But we need routes for sub-pages pushed from ProfileScreen.
      GoRoute(
        path: '/profile/details',
        name: 'profile-details',
        builder: (context, state) => const ProfileDetailsScreen(),
        routes: [
          GoRoute(
            path: 'edit',
            name: 'edit-profile',
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: 'change-password',
            name: 'change-password',
            builder: (context, state) => const ChangePasswordScreen(),
          ),
        ],
      ),

      // Books Screen
      GoRoute(
        path: '/books',
        name: 'books',
        builder: (context, state) => const BooksScreen(),
      ),

      // Class Routine Screen
      GoRoute(
        path: '/routines',
        name: 'routines',
        builder: (context, state) => const ClassRoutineScreen(),
      ),

      // Exam Routine Screen
      GoRoute(
        path: '/exam-routines',
        name: 'exam-routines',
        builder: (context, state) => const ExamRoutineScreen(),
      ),

      // Attendance Screen
      GoRoute(
        path: '/attendance',
        name: 'attendance',
        builder: (context, state) => const AttendanceScreen(),
      ),

      // Fees Screen
      GoRoute(
        path: '/fees',
        name: 'fees',
        builder: (context, state) => const FeesScreen(),
      ),

      // Results Screen
      GoRoute(
        path: '/results',
        name: 'results',
        builder: (context, state) => const ResultScreen(),
      ),

      // Teacher Attendance Screen
      GoRoute(
        path: '/teacher-attendance',
        name: 'teacher-attendance',
        builder: (context, state) {
          final classId = int.parse(state.uri.queryParameters['classId']!);
          final sessionId = int.parse(state.uri.queryParameters['sessionId']!);
          final className = state.uri.queryParameters['className']!;
          final sessionName = state.uri.queryParameters['sessionName']!;

          return TeacherAttendanceScreen(
            classId: classId,
            sessionId: sessionId,
            className: className,
            sessionName: sessionName,
          );
        },
      ),

      // Teacher Routines
      GoRoute(
        path: '/teacher/routines',
        name: 'teacher-routines',
        builder: (context, state) => const TeacherRoutineScreen(),
      ),

      // Teacher Diaries
      GoRoute(
        path: '/teacher/diaries',
        name: 'teacher-diaries',
        builder: (context, state) => const TeacherDiaryListScreen(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'create-diary',
            builder: (context, state) => const CreateDiaryScreen(),
          ),
          GoRoute(
            path: ':id',
            name: 'teacher-diary-details',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return TeacherDiaryDetailsScreen(diaryId: id);
            },
          ),
          GoRoute(
            path: 'edit/:id',
            name: 'edit-diary',
            builder: (context, state) {
              // We can pass the diary object via extra if available, or just fetch by ID in screen (not implemented in create screen yet, but we'll rely on extra or refetch if we update create screen to support fetch)
              // For now, CreateDiaryScreen expects `diary` object or nothing.
              // If we only have ID, we might need a wrapper or update CreateDiaryScreen to fetch by ID.
              // But usually we go List -> Details -> Edit, so we have the object.
              // Or List -> Edit directly.
              final diary = state.extra as TeacherDiary?;
              return CreateDiaryScreen(diary: diary);
            },
          ),
        ],
      ),

      GoRoute(
        path: '/parent/diaries',
        name: 'parent-diaries',
        builder: (context, state) {
          final studentId = state.uri.queryParameters['studentId']!;
          return ParentDiaryScreen(studentId: studentId);
        },
      ),

      // Notifications Screen
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationScreen(),
      ),

      // Chat Conversations Screen
      GoRoute(
        path: '/conversations',
        name: 'conversations',
        builder: (context, state) => const ConversationsScreen(),
      ),

      // Chat Background Selection Screen
      GoRoute(
        path: '/chat-background',
        name: 'chat-background',
        builder: (context, state) => const ChatBackgroundSelectionScreen(),
      ),

      // Teacher Attendance Management Routes
      GoRoute(
        path: '/teacher-attendance-management',
        name: 'teacher-attendance-management',
        builder: (context, state) => const TeacherAttendanceListScreen(),
      ),

      GoRoute(
        path: '/teacher-attendance/mark',
        name: 'mark-teacher-attendance',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final attendance = extra?['attendance'] as TeacherAttendanceModel?;
          final date = extra?['date'] as DateTime? ?? DateTime.now();

          return MarkAttendanceScreen(attendance: attendance, date: date);
        },
      ),
    ],

    // Parent Diaries

    // Redirect logic for authentication
    redirect: (context, state) async {
      final hasToken = await TokenStorage.hasToken();
      final isGoingToLogin = state.matchedLocation == login;
      final isGoingToSplash = state.matchedLocation == splash;
      final isGoingToOnboarding = state.matchedLocation == onboarding;

      // Allow splash and onboarding without auth check
      if (isGoingToSplash || isGoingToOnboarding) {
        return null;
      }

      // If no token and not going to login, redirect to login
      if (!hasToken && !isGoingToLogin) {
        return login;
      }

      // If has token and going to login, redirect to dashboard
      if (hasToken && isGoingToLogin) {
        return dashboard;
      }

      // No redirect needed
      return null;
    },

    // Error page
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(splash),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
