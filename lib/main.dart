import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/providers/language_provider.dart';
import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/providers/auth_provider.dart';
import 'app/theme/providers/theme_provider.dart';
// 🔹 Network connectivity imports
import 'core/services/connectivity_service.dart';
import 'core/widgets/no_internet_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  await ConnectivityService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(prefs)),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
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
