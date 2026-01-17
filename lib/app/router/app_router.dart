import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/token_storage.dart';
import '../../features/attendance/ui/attendance_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/onboarding_screen.dart';
import '../../features/auth/presentation/pages/splash_screen.dart';
import '../../features/books/ui/books_screen.dart';
import '../../features/dashboard/presentation/pages/dashboard_screen.dart';
import '../../features/exams/ui/exam_routine_screen.dart';
import '../../features/fees/ui/fees_screen.dart';
import '../../features/profile/presentation/pages/settings_screen.dart';
import '../../features/routines/ui/class_routine_screen.dart';
import '../../features/teacher_attendance/ui/teacher_attendance_screen.dart';
import '../../features/routines/presentation/screens/teacher_routine_screen.dart';
import '../../features/diary/presentation/screens/teacher_diary_list_screen.dart';
import '../../features/diary/presentation/screens/create_diary_screen.dart';
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
        ],
      ),
    ],

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
