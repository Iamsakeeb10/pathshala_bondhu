import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/providers/language_provider.dart';
import 'app/router/app_router.dart';
import 'app/router/root_navigator_key.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/providers/auth_provider.dart';
import 'app/theme/providers/theme_provider.dart';
// 🔹 Network connectivity imports
import 'core/services/connectivity_service.dart';
import 'core/services/notification_service.dart';
import 'core/widgets/no_internet_overlay.dart';
// 🔹 Feature providers
import 'features/attendance/provider/attendance_provider.dart';
import 'features/books/provider/books_provider.dart';
import 'features/diary/provider/parent_diary_provider.dart';
import 'features/diary/provider/teacher_diary_provider.dart';
import 'features/exams/provider/exam_routine_provider.dart';
import 'features/fees/provider/fees_provider.dart';
import 'features/notifications/providers/notification_provider.dart';
import 'features/parents/provider/parents_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/routines/provider/routine_provider.dart';
import 'features/routines/provider/teacher_routine_provider.dart';
import 'features/students/provider/student_provider.dart';
import 'features/teacher_attendance/provider/teacher_attendance_provider.dart';
import 'features/teachers/provider/teachers_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();

  await ConnectivityService().init();

  // Initialize NotificationService
  await NotificationService.init(
    onNotificationTap: (payload) async {
      print('🔔 [Notification Tap Detected]');
      print('📦 Payload: ${payload.toJson()}');
      print('➡️ Route: ${payload.route}');

      // Determine target route
      String targetRoute = payload.route?.startsWith('/') == true
          ? payload.route!
          : '/${payload.route ?? 'notifications'}';

      // Use addPostFrameCallback to ensure router is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = rootNavigatorKey.currentContext;
        if (context != null && context.mounted) {
          GoRouter.of(context).push(targetRoute);
        }
      });

      // Refresh notification count
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = rootNavigatorKey.currentContext;
        if (context != null) {
          context.read<NotificationProvider>().fetchUnreadCount();
        }
      });
    },
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(prefs)),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => BooksProvider()),
        ChangeNotifierProvider(create: (_) => RoutineProvider()),
        ChangeNotifierProvider(create: (_) => ExamRoutineProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => FeesProvider()),
        ChangeNotifierProvider(create: (_) => TeacherAttendanceProvider()),
        ChangeNotifierProvider(create: (_) => TeacherRoutineProvider()),
        ChangeNotifierProvider(create: (_) => TeacherDiaryProvider()),
        ChangeNotifierProvider(create: (_) => ParentDiaryProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        // Teachers & Parents listing providers
        ChangeNotifierProvider(create: (_) => TeachersProvider()),
        ChangeNotifierProvider(create: (_) => ParentsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final themeProvider = context.watch<ThemeProvider>();
        final languageProvider = context.watch<LanguageProvider>();

        return MaterialApp.router(
          title: 'Pathshala Bondhu',
          debugShowCheckedModeBanner: false,

          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,

          locale: languageProvider.currentLocale,
          routerConfig: AppRouter.router,

          // ✅ GLOBAL no-internet overlay
          builder: (context, routerChild) {
            return NoInternetOverlay(
              child: routerChild ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
