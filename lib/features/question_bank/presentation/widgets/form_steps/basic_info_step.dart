/// Basic Info Step
/// Second step in the form wizard - class, subject, marks, question text

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/utils/app_colors.dart';
import '../../../presentation/providers/question_bank_form_provider.dart';
import '../../../presentation/providers/question_bank_list_provider.dart';
import '../../../utils/question_bank_translations.dart';

class BasicInfoStep extends StatefulWidget {
  const BasicInfoStep({super.key});

  @override
  State<BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends State<BasicInfoStep> {
  final _questionTextController = TextEditingController();
  final _questionTextFocusNode = FocusNode();

  bool get _isBangla {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'bn';
  }

  String _t(String key) => QuestionBankTranslations.t(key, _isBangla);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final formProvider = context.read<QuestionBankFormProvider>();
      _questionTextController.text = formProvider.questionText;
    });
  }

  @override
  void dispose() {
    _questionTextController.dispose();
    _questionTextFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final listProvider = context.watch<QuestionBankListProvider>();
    final formProvider = context.watch<QuestionBankFormProvider>();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class dropdown
          _buildLabel(_t('qb_class'), true),
          SizedBox(height: 8.h),
          _buildClassDropdown(listProvider, formProvider, isDark),
          SizedBox(height: 20.h),

          // Subject dropdown
          _buildLabel(_t('qb_subject'), true),
          SizedBox(height: 8.h),
          _buildSubjectDropdown(listProvider, formProvider, isDark),
          SizedBox(height: 20.h),

          // Marks input
          _buildLabel(_t('qb_marks'), true),
          SizedBox(height: 8.h),
          _buildMarksInput(formProvider, isDark),
          SizedBox(height: 20.h),

          // Question text
          _buildLabel(_t('qb_question_text'), true),
          SizedBox(height: 8.h),
          _buildQuestionTextInput(formProvider, isDark),

          // Validation errors
          if (formProvider.validationErrors.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: _buildValidationErrors(formProvider),
            ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label, bool required) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        if (required)
          Text(
            ' *',
            style: TextStyle(fontSize: 14.sp, color: AppColors.error),
          ),
      ],
    );
  }

  Widget _buildClassDropdown(
    QuestionBankListProvider listProvider,
    QuestionBankFormProvider formProvider,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: formProvider.validationErrors['class'] != null
              ? AppColors.error
              : (isDark ? AppColors.borderDark : AppColors.border),
        ),
      ),
      child: DropdownButtonFormField<int>(
        value: formProvider.selectedClass?.id,
        isExpanded: true,
        decoration: InputDecoration(
          hintText: _t('qb_class_hint'),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
        items: listProvider.classes.map((c) {
          return DropdownMenuItem<int>(value: c.id, child: Text(c.name));
        }).toList(),
        onChanged: (value) {
          final selectedClass = listProvider.classes.firstWhere(
            (c) => c.id == value,
          );
          formProvider.setSelectedClass(selectedClass);
        },
      ),
    );
  }

  Widget _buildSubjectDropdown(
    QuestionBankListProvider listProvider,
    QuestionBankFormProvider formProvider,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: formProvider.validationErrors['subject'] != null
              ? AppColors.error
              : (isDark ? AppColors.borderDark : AppColors.border),
        ),
      ),
      child: DropdownButtonFormField<int>(
        value: formProvider.selectedSubject?.id,
        isExpanded: true,
        decoration: InputDecoration(
          hintText: _t('qb_subject_hint'),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
        items: listProvider.subjects.map((s) {
          return DropdownMenuItem<int>(value: s.id, child: Text(s.name));
        }).toList(),
        onChanged: (value) {
          final selectedSubject = listProvider.subjects.firstWhere(
            (s) => s.id == value,
          );
          formProvider.setSelectedSubject(selectedSubject);
        },
      ),
    );
  }

  Widget _buildMarksInput(QuestionBankFormProvider formProvider, bool isDark) {
    final quickMarks = [1.0, 2.0, 5.0, 10.0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick select chips
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: quickMarks.map((marks) {
            final isSelected = formProvider.marks == marks;
            return GestureDetector(
              onTap: () => formProvider.updateBasicInfo(marks: marks),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.surfaceDark : Colors.white),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.borderDark : AppColors.border),
                  ),
                ),
                child: Text(
                  '$marks',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.textPrimary
                        : (isDark ? Colors.white : AppColors.textPrimary),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 12.h),

        // Custom marks input
        Row(
          children: [
            Text(
              'Custom:',
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark
                    ? AppColors.textDarkSecondary
                    : AppColors.textSecondary,
              ),
            ),
            SizedBox(width: 12.w),
            SizedBox(
              width: 80.w,
              child: TextFormField(
                initialValue: formProvider.marks.toString(),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                onChanged: (value) {
                  final marks = double.tryParse(value);
                  if (marks != null && marks >= 0.5) {
                    formProvider.updateBasicInfo(marks: marks);
                  }
                },
              ),
            ),
          ],
        ),
        if (formProvider.validationErrors['marks'] != null)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              formProvider.validationErrors['marks']!,
              style: TextStyle(fontSize: 12.sp, color: AppColors.error),
            ),
          ),
      ],
    );
  }

  Widget _buildQuestionTextInput(
    QuestionBankFormProvider formProvider,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: formProvider.validationErrors['questionText'] != null
              ? AppColors.error
              : (isDark ? AppColors.borderDark : AppColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextFormField(
            controller: _questionTextController,
            focusNode: _questionTextFocusNode,
            minLines: 4,
            maxLines: 8,
            maxLength: 2000,
            decoration: InputDecoration(
              hintText: _t('qb_question_text_hint'),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16.w),
              counterText: '',
            ),
            onChanged: (value) {
              formProvider.updateBasicInfo(questionText: value);
            },
          ),
          Padding(
            padding: EdgeInsets.only(right: 12.w, bottom: 8.h),
            child: Text(
              '${_questionTextController.text.length}/2000',
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark
                    ? AppColors.textDarkSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationErrors(QuestionBankFormProvider formProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, size: 18.sp, color: AppColors.error),
              SizedBox(width: 8.w),
              Text(
                'Please fix the following:',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ...formProvider.validationErrors.entries.map(
            (e) => Padding(
              padding: EdgeInsets.only(left: 26.w, top: 4.h),
              child: Text(
                '• ${e.value}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark
                      ? AppColors.textDarkSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
