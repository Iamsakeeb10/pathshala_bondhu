import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/constants/user_role.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/providers/auth_provider.dart';
import '../../../../shared/localization/app_localizations.dart';
import '../../../../shared/utils/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/modern_alert.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _parentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  UserRole _selectedRole = UserRole.parent;
  bool _isPasswordVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _parentIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _switchRole(UserRole role) {
    if (_selectedRole == role) return;
    setState(() {
      _selectedRole = role;
      _formKey.currentState?.reset();
      _parentIdController.clear();
      _emailController.clear();
      _passwordController.clear();
    });
    _animationController.reset();
    _animationController.forward();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    // Clear any previous errors
    authProvider.clearError();

    final success = await authProvider.login(
      _selectedRole == UserRole.parent
          ? _parentIdController.text
          : _emailController.text,
      _passwordController.text,
      _selectedRole,
    );

    if (!mounted) return;

    if (success) {
      context.go(AppRouter.dashboard);
    } else {
      // Show error message
      if (authProvider.errorMessage != null) {
        ModernAlert.show(
          context: context,
          type: AlertType.error,
          title: 'লগইন ব্যর্থ',
          message: authProvider.errorMessage!,
          confirmText: 'ঠিক আছে',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SizedBox.expand(
        child: Container(
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
                      AppColors.primary.withOpacity(0.1),
                      AppColors.backgroundLight,
                      AppColors.primaryLight.withOpacity(0.05),
                    ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 20.h),
                    _buildHeader(localizations, isDark),
                    SizedBox(height: 40.h),
                    _buildRoleSelector(localizations, isDark),
                    SizedBox(height: 32.h),
                    _buildLoginForm(localizations),
                    SizedBox(height: 24.h),
                    _buildLoginButton(authProvider, localizations),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations localizations, bool isDark) {
    return Column(
      children: [
        Container(
          height: 80.h,
          width: 80.w,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.surfaceLight.withOpacity(isDark ? 0.4 : 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              'assets/images/logo_tiny.png',
              width: 70.sp,
              height: 70.sp,
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          localizations.translate('welcome_back'),
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: isDark
                ? Colors.white
                : (Theme.of(context).textTheme.titleLarge?.color ??
                      AppColors.textPrimary),
            shadows: isDark
                ? [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: Offset(0, 2.h),
                      blurRadius: 8.r,
                    ),
                  ]
                : null,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          localizations.translate('sign_in_to_continue'),
          style: TextStyle(
            fontSize: 16.sp,
            color: isDark
                ? Colors.white.withOpacity(0.85)
                : (Theme.of(context).textTheme.bodyMedium?.color ??
                      AppColors.textSecondary),
            shadows: isDark
                ? [
                    Shadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: Offset(0, 1.h),
                      blurRadius: 4.r,
                    ),
                  ]
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelector(AppLocalizations localizations, bool isDark) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.grey100,
        borderRadius: BorderRadius.circular(12.r),
        border: isDark
            ? Border.all(color: AppColors.borderDark, width: 1.2)
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildRoleOption(
              role: UserRole.parent,
              label: localizations.translate('parents'),
              icon: Icons.family_restroom_rounded,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: _buildRoleOption(
              role: UserRole.teacher,
              label: localizations.translate('teachers'),
              icon: Icons.person_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption({
    required UserRole role,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => _switchRole(role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(isDark ? 0.4 : 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20.sp,
                color: isSelected
                    ? Colors.white
                    : (isDark
                          ? AppColors.textDarkSecondary
                          : AppColors.textSecondary),
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                            ? AppColors.textDarkSecondary
                            : AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(AppLocalizations localizations) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          if (_selectedRole == UserRole.parent)
            _buildParentFields(localizations)
          else
            _buildTeacherFields(localizations),
          SizedBox(height: 16.h),
          _buildPasswordField(localizations),
        ],
      ),
    );
  }

  Widget _buildParentFields(AppLocalizations localizations) {
    return CustomTextField(
      controller: _parentIdController,
      label: localizations.translate('parent_id'),
      hint: localizations.translate('enter_parent_id'),
      prefixIcon: Icon(Icons.badge_outlined, size: 22.sp),
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Parent ID is required';
        }
        if (value.length < 3) {
          return 'Parent ID must be at least 3 characters';
        }
        return null;
      },
    );
  }

  Widget _buildTeacherFields(AppLocalizations localizations) {
    return CustomTextField(
      controller: _emailController,
      label: localizations.translate('email'),
      hint: localizations.translate('enter_email'),
      prefixIcon: Icon(Icons.email_outlined, size: 22.sp),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email is required';
        }
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(AppLocalizations localizations) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return CustomTextField(
          controller: _passwordController,
          label: localizations.translate('password'),
          hint: localizations.translate('enter_password'),
          prefixIcon: Icon(Icons.lock_outline, size: 22.sp),
          obscureText: !_isPasswordVisible,
          maxLength: 10,
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 22.sp,
              color: isDark
                  ? AppColors.textDarkSecondary
                  : AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password is required';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            if (value.length > 10) {
              return 'Password must not exceed 10 characters';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildLoginButton(
    AuthProvider authProvider,
    AppLocalizations localizations,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: CustomButton(
        text: localizations.translate('sign_in'),
        onPressed: _handleLogin,
        isLoading: authProvider.isLoading,
        backgroundColor: Colors.transparent,
        textColor: Colors.white,
      ),
    );
  }
}
