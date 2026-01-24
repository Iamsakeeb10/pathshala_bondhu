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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableHeight = constraints.maxHeight;
                final isSmallScreen = availableHeight < 600;

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: availableHeight),
                    child: Column(
                      children: [
                        SizedBox(height: isSmallScreen ? 16.h : 32.h),

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

                        SizedBox(height: isSmallScreen ? 32.h : 48.h),

                        // Welcome text
                        Text(
                          localizations.translate(
                            'welcome_to_pathshala_bondhu',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30.sp, // slightly larger for emphasis
                            fontWeight: FontWeight
                                .w800, // bolder weight for modern look
                            color: AppColors
                                .textPrimary, // Better contrast for primary text
                            height: 1.3, // tighter line height
                            letterSpacing:
                                0.5, // subtle spacing for readability
                          ),
                        ),

                        SizedBox(height: 12.h),

                        Text(
                          localizations.translate('your_school_companion'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors
                                .primaryDark, // Better UX with primary dark
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? 16.h : 24.h),

                        Text(
                          localizations.translate('welcome_description'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.sp,
                            height: 1.6,
                            color: AppColors
                                .textSecondary, // Good contrast for secondary text
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? 12.h : 16.h),

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

                        SizedBox(height: isSmallScreen ? 24.h : 48.h),

                        // Get Started button with glowing animation
                        _GlowingButton(
                          child: CustomButton(
                            borderRadius: BorderRadius.circular(25.r),
                            text: localizations.translate('get_started'),
                            onPressed: _completeOnboarding,
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? 16.h : 24.h),
                      ],
                    ),
                  ),
                );
              },
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
              color: AppColors.primaryDark, // Better UX with consistent color
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget that wraps a button with an infinite horizontal glowing animation effect
class _GlowingButton extends StatefulWidget {
  final Widget child;

  const _GlowingButton({required this.child});

  @override
  State<_GlowingButton> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<_GlowingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(
        milliseconds: 2500,
      ), // Slightly slower for better visibility
      vsync: this,
    )..repeat();

    _animation =
        Tween<double>(
          begin: -1.0,
          end: 2.0, // Extend range for better coverage
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeInOut, // Smoother curve
          ),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonWidth = constraints.maxWidth;
        return Stack(
          children: [
            // The actual button
            widget.child,

            // Shimmer effect overlay - positioned on top
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25.r),
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_animation.value * buttonWidth, 0),
                      child: Container(
                        width: buttonWidth * 0.1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.white.withOpacity(0.0),
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.6),
                              Colors.white.withOpacity(0.8),
                              Colors.white.withOpacity(0.6),
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.0),
                            ],
                            stops: const [0.0, 0.2, 0.4, 0.5, 0.6, 0.8, 1.0],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
