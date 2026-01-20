import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/localization/app_localizations.dart';
import '../../../../shared/utils/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';

/// Modern onboarding screen - shown only on first app launch
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';

  Future<void> _completeOnboarding() async {
    // Mark onboarding as seen
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, true);

    if (!mounted) return;
    context.go(AppRouter.login);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary.withOpacity(0.1), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              children: [
                const Spacer(),

                // Logo and illustration
                Container(
                  width: 180.w,
                  height: 180.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.7),
                        AppColors.primaryDark.withOpacity(0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(40.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/logo_tiny.png',
                      width: 150.sp,
                      height: 150.sp,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                SizedBox(height: 48.h),

                // Welcome text
                Text(
                  localizations.translate('welcome_to_pathshala_bondhu'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30.sp, // slightly larger for emphasis
                    fontWeight:
                        FontWeight.w800, // bolder weight for modern look
                    color: const Color.fromARGB(
                      255,
                      201,
                      113,
                      65,
                    ), // new color: dark variant of primary
                    height: 1.3, // tighter line height
                    letterSpacing: 0.5, // subtle spacing for readability
                  ),
                ),

                SizedBox(height: 12.h),

                Text(
                  localizations.translate('your_school_companion'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),

                SizedBox(height: 24.h),

                Text(
                  localizations.translate('welcome_description'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: 16.h),

                // Feature highlights
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12.w,
                  runSpacing: 12.h,
                  children: [
                    _buildFeatureChip(
                      Icons.book,
                      localizations.translate('books'),
                    ),
                    _buildFeatureChip(
                      Icons.schedule,
                      localizations.translate('class_routine'),
                    ),
                    _buildFeatureChip(
                      Icons.check_circle,
                      localizations.translate('attendance'),
                    ),
                    _buildFeatureChip(
                      Icons.payment,
                      localizations.translate('fees'),
                    ),
                  ],
                ),

                const Spacer(),

                // Get Started button
                CustomButton(
                  text: localizations.translate('get_started'),
                  onPressed: _completeOnboarding,
                ),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18.sp, color: AppColors.primary),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
