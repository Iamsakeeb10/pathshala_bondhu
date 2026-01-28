/// Question Bank Authentication Modal
/// Shows login form for Question Bank access

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../shared/utils/app_colors.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../presentation/providers/question_bank_auth_provider.dart';
import '../../utils/question_bank_translations.dart';
import '../../utils/validators.dart';

class QuestionBankAuthModal extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback? onCancel;

  const QuestionBankAuthModal({
    super.key,
    required this.onSuccess,
    this.onCancel,
  });

  /// Show auth modal as bottom sheet
  static Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => QuestionBankAuthModal(
        onSuccess: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
    return result ?? false;
  }

  @override
  State<QuestionBankAuthModal> createState() => _QuestionBankAuthModalState();
}

class _QuestionBankAuthModalState extends State<QuestionBankAuthModal> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _isSubmitting = false;

  bool get _isBangla {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'bn';
  }

  String _t(String key) => QuestionBankTranslations.t(key, _isBangla);

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final authProvider = context.read<QuestionBankAuthProvider>();
    if (authProvider.email != null) {
      _emailController.text = authProvider.email!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final authProvider = context.read<QuestionBankAuthProvider>();
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      widget.onSuccess();
    } else {
      _showError(authProvider.errorMessage ?? _t('qb_auth_error'));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(top: 100.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24.w,
            right: 24.w,
            top: 24.h,
            bottom: bottomPadding + 24.h,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.grey600 : AppColors.grey300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Icon
                Container(
                  width: 72.w,
                  height: 72.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    size: 36.sp,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 20.h),

                // Title
                Text(
                  _t('qb_auth_title'),
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),

                // Subtitle
                Text(
                  _t('qb_auth_subtitle'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark
                        ? AppColors.textDarkSecondary
                        : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),

                // Email field
                _EmailField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  passwordFocusNode: _passwordFocusNode,
                  isBangla: _isBangla,
                ),
                SizedBox(height: 16.h),

                // Password field
                _PasswordField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscurePassword: _obscurePassword,
                  onToggleVisibility: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  onSubmitted: _handleLogin,
                  isBangla: _isBangla,
                ),
                SizedBox(height: 24.h),

                // Login button
                GradientButton(
                  text: _t('qb_auth_login'),
                  onPressed: _isSubmitting ? null : _handleLogin,
                  isLoading: _isSubmitting,
                  startColor: AppColors.primary,
                  height: 52.h,
                  borderRadius: BorderRadius.circular(12.r),
                  enableShadow: false,
                ),
                SizedBox(height: 12.h),

                // Cancel button
                if (widget.onCancel != null)
                  TextButton(
                    onPressed: widget.onCancel,
                    child: Text(
                      _t('qb_cancel'),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark
                            ? AppColors.textDarkSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper widget for email field
class _EmailField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode passwordFocusNode;
  final bool isBangla;

  const _EmailField({
    required this.controller,
    required this.focusNode,
    required this.passwordFocusNode,
    required this.isBangla,
  });

  String _t(String key) => QuestionBankTranslations.t(key, isBangla);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      autofillHints: const [AutofillHints.email],
      validator: QuestionBankValidators.validateEmail,
      onFieldSubmitted: (_) => passwordFocusNode.requestFocus(),
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: _t('qb_auth_email'),
        hintText: _t('qb_auth_email_hint'),
        prefixIcon: const Icon(Icons.email_outlined),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }
}

// Helper widget for password field
class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool obscurePassword;
  final VoidCallback onToggleVisibility;
  final VoidCallback onSubmitted;
  final bool isBangla;

  const _PasswordField({
    required this.controller,
    required this.focusNode,
    required this.obscurePassword,
    required this.onToggleVisibility,
    required this.onSubmitted,
    required this.isBangla,
  });

  String _t(String key) => QuestionBankTranslations.t(key, isBangla);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscurePassword,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      validator: QuestionBankValidators.validatePassword,
      onFieldSubmitted: (_) => onSubmitted(),
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: _t('qb_auth_password'),
        hintText: _t('qb_auth_password_hint'),
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: onToggleVisibility,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }
}
