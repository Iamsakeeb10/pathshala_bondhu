import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/providers/auth_provider.dart';
import '../../../../core/services/app_update_service.dart';
import '../../../../shared/utils/app_colors.dart';
import '../../../chat/providers/chat_provider.dart';
import '../../../chat/providers/conversations_provider.dart';

/// Professional splash screen with animations
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkAuthAndOnboarding();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();
  }

  Future<void> _checkAuthAndOnboarding() async {
    // Wait for animation to play
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    try {
      final AppUpdateService updateService = AppUpdateService();
      final updateData = await updateService.checkForUpdate();

      if (mounted &&
          updateData != null &&
          updateData['update_available'] == true) {
        if (updateData['force_update'] == true) {
          updateService.showUpdateDialog(
            context: context,
            updateInfo: updateData,
            isForceUpdate: true,
          );
          return;
        } else {
          updateService.showUpdateDialog(
            context: context,
            updateInfo: updateData,
            isForceUpdate: false,
          );
        }
      }
    } catch (e) {
      // Error checking for update, continue with normal flow
    }

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool(_hasSeenOnboardingKey) ?? false;
    final authProvider = context.read<AuthProvider>();

    if (authProvider.isAuthenticated) {
      // === APP UPDATE / FRESH START CHECK ===
      if (mounted) {
        try {
          final wasUpdated = await AppUpdateService()
              .checkIfAppRecentlyUpdated();
          if (wasUpdated) {
            debugPrint(
              '📢 App update detected in Splash! Triggering Chat Soft Reset...',
            );

            // Access providers safely
            // We use read() because we are in a function, not build
            context.read<ChatProvider>().softReset();
            context.read<ConversationsProvider>().softReset();
          }
        } catch (e) {
          debugPrint('⚠️ Error during update check/reset: $e');
        }
      }
      // ======================================

      if (mounted) {
        // User is logged in - go directly to dashboard
        context.go(AppRouter.dashboard);
      }
    } else if (hasSeenOnboarding) {
      if (mounted) {
        // User has seen onboarding - go to login
        context.go(AppRouter.login);
      }
    } else {
      if (mounted) {
        // First time user - show onboarding
        context.go(AppRouter.onboarding);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF283447), // Professional dark blue-gray
                    const Color(0xFF1F2937), // backgroundDark
                    const Color(0xFF111827), // darker shade
                  ]
                : [
                    AppColors.primary,
                    AppColors.primaryDark,
                    AppColors.primary.withBlue(180),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Animated Logo
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: 140.w,
                  height: 140.w,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF283447) : Colors.white,
                    borderRadius: BorderRadius.circular(30.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.5 : 0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/logo_tiny.png',
                      width: 120.sp,
                      height: 120.sp,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // App Name
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(opacity: _fadeAnimation.value, child: child);
                },
                child: Column(
                  children: [
                    Text(
                      'পাঠশালা বন্ধু',
                      style: TextStyle(
                        fontSize: 36.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                        shadows: isDark
                            ? [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  offset: Offset(0, 2.h),
                                  blurRadius: 8.r,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Pathshala Bondhu',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 2,
                        shadows: isDark
                            ? [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: Offset(0, 1.h),
                                  blurRadius: 4.r,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(isDark ? 0.15 : 0.2),
                        borderRadius: BorderRadius.circular(20.r),
                        border: isDark
                            ? Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              )
                            : null,
                      ),
                      child: Text(
                        'Your School Companion',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Loading indicator
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(opacity: _fadeAnimation.value, child: child);
                },
                child: Column(
                  children: [
                    SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(isDark ? 0.9 : 0.8),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white.withOpacity(isDark ? 0.85 : 0.7),
                        shadows: isDark
                            ? [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: Offset(0, 1.h),
                                  blurRadius: 2.r,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 48.h),
            ],
          ),
        ),
      ),
    );
  }
}
