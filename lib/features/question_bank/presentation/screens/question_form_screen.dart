/// Question Form Screen
/// Multi-step wizard for creating/editing questions

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../shared/utils/app_colors.dart';
import '../../../../shared/widgets/custom_appbar.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../data/models/question_model.dart';
import '../../data/services/question_bank_api_service.dart';
import '../../presentation/providers/question_bank_form_provider.dart';
import '../../presentation/providers/question_bank_list_provider.dart';
import '../../utils/question_bank_translations.dart';
import '../widgets/form_steps/basic_info_step.dart';
import '../widgets/form_steps/question_preview_step.dart';
import '../widgets/form_steps/question_type_selector.dart';
import '../widgets/form_steps/type_specific_step.dart';
import 'question_bank_auth_modal.dart';

class QuestionFormScreen extends StatefulWidget {
  final String? questionId; // If provided, edit mode (as String from route)
  final Question? existingQuestion; // Optional pre-loaded question for edit
  final Question? duplicateFrom; // Optional question to duplicate

  const QuestionFormScreen({
    super.key,
    this.questionId,
    this.existingQuestion,
    this.duplicateFrom,
  });

  @override
  State<QuestionFormScreen> createState() => _QuestionFormScreenState();
}

class _QuestionFormScreenState extends State<QuestionFormScreen> {
  bool _isSubmitting = false;

  bool get _isBangla {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'bn';
  }

  String _t(String key) => QuestionBankTranslations.t(key, _isBangla);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    final formProvider = context.read<QuestionBankFormProvider>();
    formProvider.reset();

    // Load metadata
    final listProvider = context.read<QuestionBankListProvider>();
    await listProvider.fetchMetadata();

    // If duplicating, load the question to duplicate
    if (widget.duplicateFrom != null) {
      formProvider.duplicateQuestion(widget.duplicateFrom!);
    }
    // If editing, load question
    else if (widget.questionId != null) {
      if (widget.existingQuestion != null) {
        formProvider.loadQuestion(widget.existingQuestion!);
      } else {
        await _loadQuestion();
      }
    } else {
      // Check for draft
      await _checkForDraft();
    }
  }

  Future<void> _loadQuestion() async {
    final listProvider = context.read<QuestionBankListProvider>();
    final formProvider = context.read<QuestionBankFormProvider>();

    try {
      final questionId = int.tryParse(widget.questionId ?? '');
      if (questionId == null) return;

      final question = await listProvider.getQuestion(questionId);
      if (question != null) {
        formProvider.loadQuestion(question);
      }
    } on SessionExpiredException {
      _handleSessionExpiry();
    }
  }

  Future<void> _checkForDraft() async {
    final formProvider = context.read<QuestionBankFormProvider>();
    final hasDraft = await formProvider.loadDraft();

    if (hasDraft && mounted) {
      _showDraftRestoreDialog();
    }
  }

  void _showDraftRestoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_t('qb_draft_found')),
        content: Text(_t('qb_draft_restore')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<QuestionBankFormProvider>()
                ..reset()
                ..clearDraft();
            },
            child: Text(_t('qb_discard')),
          ),
          GradientButton(
            text: _t('qb_restore'),
            onPressed: () => Navigator.of(context).pop(),
            startColor: AppColors.primary,
            height: 40.h,
            width: 100.w,
          ),
        ],
      ),
    );
  }

  void _handleSessionExpiry() async {
    final success = await QuestionBankAuthModal.show(context);
    if (!success && mounted) {
      context.pop();
    }
  }

  Future<void> _handleSubmit() async {
    final formProvider = context.read<QuestionBankFormProvider>();
    final listProvider = context.read<QuestionBankListProvider>();

    if (!formProvider.isValid) return;

    setState(() => _isSubmitting = true);

    try {
      final question = formProvider.buildQuestion();

      Question? result;
      if (widget.questionId != null) {
        final id = int.tryParse(widget.questionId!);
        if (id != null) {
          result = await listProvider.updateQuestion(id, question);
        }
      } else {
        result = await listProvider.createQuestion(question);
      }

      if (!mounted) return;

      if (result != null) {
        // Clear draft on success
        await formProvider.clearDraft();

        _showSuccessDialog(result);
      } else {
        _showError(listProvider.errorMessage ?? _t('qb_error'));
      }
    } on SessionExpiredException {
      _handleSessionExpiry();
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSuccessDialog(Question question) {
    final isEdit = widget.questionId != null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 40.sp,
                color: AppColors.success,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              isEdit ? _t('qb_updated') : _t('qb_created'),
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back from form
              context.push('/question-bank/detail/${question.id}');
            },
            child: Text(_t('qb_view_question')),
          ),
          if (!isEdit)
            GradientButton(
              text: _t('qb_create_another'),
              onPressed: () {
                Navigator.of(context).pop();
                this.context.read<QuestionBankFormProvider>().reset();
              },
              startColor: AppColors.primary,
              height: 40.h,
              width: 140.w,
            )
          else
            GradientButton(
              text: 'Done',
              onPressed: () {
                Navigator.of(context).pop();
                this.context.pop();
              },
              startColor: AppColors.primary,
              height: 40.h,
              width: 100.w,
            ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final formProvider = context.read<QuestionBankFormProvider>();

    // If form has data, ask to save draft
    if (formProvider.questionText.isNotEmpty ||
        formProvider.selectedType != null) {
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(_t('qb_discard_title')),
          content: Text(_t('qb_discard_confirm')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('discard'),
              child: Text(_t('qb_discard')),
            ),
            GradientButton(
              text: _t('qb_save'),
              onPressed: () async {
                await formProvider.saveDraft();
                if (context.mounted) {
                  Navigator.of(context).pop('save');
                }
              },
              startColor: AppColors.primary,
              height: 40.h,
              width: 100.w,
            ),
          ],
        ),
      );

      return result != null;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.questionId != null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        body: Consumer<QuestionBankFormProvider>(
          builder: (context, formProvider, child) {
            return Column(
              children: [
                _buildCustomAppBar(isDark, isEdit),
                // Step indicator
                _buildStepIndicator(formProvider, isDark),
                // Form content
                Expanded(child: _buildStepContent(formProvider)),
                // Navigation buttons
                _buildNavigationButtons(formProvider, isDark),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(bool isDark, bool isEdit) {
    return CustomAppBar(
      title: isEdit ? _t('qb_edit_question') : _t('qb_create'),
      onBackPressed: () async {
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          context.pop();
        }
      },
    );
  }

  Widget _buildStepIndicator(QuestionBankFormProvider provider, bool isDark) {
    final steps = [
      _t('qb_step_type'),
      _t('qb_step_basic'),
      _t('qb_step_details'),
      _t('qb_step_preview'),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index == provider.currentStep.index;
          final isCompleted = index < provider.currentStep.index;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Step circle
                      Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          gradient: isActive || isCompleted
                              ? LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryDark,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isActive || isCompleted
                              ? null
                              : (isDark
                                    ? AppColors.grey800
                                    : AppColors.grey200),
                          shape: BoxShape.circle,
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: isCompleted
                              ? Icon(
                                  Icons.check_rounded,
                                  size: 16.sp,
                                  color: Colors.white,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isActive
                                        ? Colors.white
                                        : (isDark
                                              ? AppColors.textDarkSecondary
                                              : AppColors.textSecondary),
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      // Step label
                      Text(
                        steps[index],
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isActive
                              ? AppColors.primary
                              : (isDark
                                    ? AppColors.textDarkSecondary
                                    : AppColors.textSecondary),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Connector line
                if (index < steps.length - 1)
                  Container(
                    width: 16.w,
                    height: 2.h,
                    margin: EdgeInsets.only(bottom: 22.h),
                    decoration: BoxDecoration(
                      gradient: isCompleted
                          ? LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primaryDark,
                              ],
                            )
                          : null,
                      color: isCompleted
                          ? null
                          : (isDark ? AppColors.grey800 : AppColors.grey200),
                      borderRadius: BorderRadius.circular(1.r),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent(QuestionBankFormProvider provider) {
    switch (provider.currentStep) {
      case FormStep.selectType:
        return const QuestionTypeSelector();
      case FormStep.basicInfo:
        return const BasicInfoStep();
      case FormStep.typeSpecific:
        return const TypeSpecificStep();
      case FormStep.preview:
        return const QuestionPreviewStep();
    }
  }

  Widget _buildNavigationButtons(
    QuestionBankFormProvider provider,
    bool isDark,
  ) {
    final isFirstStep = provider.currentStep == FormStep.selectType;
    final isLastStep = provider.currentStep == FormStep.preview;

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Previous button
            if (!isFirstStep)
              Expanded(
                child: Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: provider.previousStep,
                      borderRadius: BorderRadius.circular(12.r),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_back_rounded,
                              size: 18.sp,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              _t('qb_previous'),
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            if (!isFirstStep) SizedBox(width: 12.w),

            // Next/Submit button
            Expanded(
              flex: isFirstStep ? 1 : 1,
              child: GradientButton(
                text: isLastStep ? _t('qb_save') : _t('qb_next'),
                icon: isLastStep
                    ? Icons.check_circle_rounded
                    : Icons.arrow_forward_rounded,
                onPressed: _isSubmitting
                    ? null
                    : (isLastStep ? _handleSubmit : provider.nextStep),
                isLoading: _isSubmitting,
                startColor: AppColors.primary,
                endColor: AppColors.primaryDark,
                height: 48.h,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
