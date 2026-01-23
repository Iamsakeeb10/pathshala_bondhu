import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/providers/language_provider.dart';
import 'app/router/app_router.dart';
import 'app/router/root_navigator_key.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/providers/auth_provider.dart';
import 'app/theme/providers/theme_provider.dart';
// 🔹 Network connectivity imports
import 'core/network/token_storage.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/notification_service.dart';
import 'core/widgets/no_internet_overlay.dart';
// 🔹 Feature providers
import 'features/attendance/provider/attendance_provider.dart';
import 'features/books/provider/books_provider.dart';
import 'features/chat/providers/chat_background_provider.dart';
// 🔹 Chat feature providers
import 'features/chat/providers/chat_provider.dart';
import 'features/chat/providers/conversations_provider.dart';
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
import 'shared/localization/app_localizations.dart';

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

          // ✅ Sync conversations for new_message notifications
          final notifType = payload.data?['type'] as String?;
          if (notifType == 'new_message') {
            try {
              final conversationsProvider = context.read<ConversationsProvider>();
              TokenStorage.getUserId().then((userIdStr) {
                final userId = userIdStr != null ? int.tryParse(userIdStr) : null;
                if (userId != null) {
                  print('💬 Syncing conversations for new message (Notification Tap)...');
                  conversationsProvider.fetchConversations(userId);
                }
              });
            } catch (e) {
              print('⚠️ Error syncing conversations on notification tap: $e');
            }
          }
        }
      });
    },
  );

  // Initialize theme and language providers with saved preferences
  final themeProvider = ThemeProvider();
  final languageProvider = LanguageProvider();

  // Load saved preferences
  await themeProvider.initialize();
  await languageProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: AuthProvider(prefs)),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: languageProvider),
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
        // 🔹 Chat feature providers
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ConversationsProvider()),
        ChangeNotifierProvider(create: (_) => ChatBackgroundProvider()),
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

          theme: AppTheme.lightTheme.copyWith(
            textTheme: GoogleFonts.nunitoSansTextTheme(
              AppTheme.lightTheme.textTheme,
            ),
          ),
          darkTheme: AppTheme.darkTheme.copyWith(
            textTheme: GoogleFonts.nunitoSansTextTheme(
              AppTheme.darkTheme.textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
            ),
          ),
          themeMode: themeProvider.themeMode,

          locale: languageProvider.currentLocale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,

          routerConfig: AppRouter.router,

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
