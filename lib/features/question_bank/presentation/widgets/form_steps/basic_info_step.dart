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
  final _customMarksController = TextEditingController();
  final _customMarksFocusNode = FocusNode();

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
      _customMarksController.text = formProvider.marks.toString();
    });

    // Listen to focus changes to rebuild UI
    _questionTextFocusNode.addListener(() => setState(() {}));
    _customMarksFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _questionTextController.dispose();
    _questionTextFocusNode.dispose();
    _customMarksController.dispose();
    _customMarksFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final listProvider = context.watch<QuestionBankListProvider>();
    final formProvider = context.watch<QuestionBankFormProvider>();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Class dropdown
              _buildLabel(_t('qb_class'), true, Icons.school_outlined),
              SizedBox(height: 8.h),
              _buildClassDropdown(listProvider, formProvider, isDark),
              SizedBox(height: 16.h),

              // Subject dropdown
              _buildLabel(_t('qb_subject'), true, Icons.book_outlined),
              SizedBox(height: 8.h),
              _buildSubjectDropdown(listProvider, formProvider, isDark),
              SizedBox(height: 16.h),

              // Marks input
              _buildLabel(_t('qb_marks'), true, Icons.grade_outlined),
              SizedBox(height: 8.h),
              _buildMarksInput(formProvider, isDark),
              SizedBox(height: 16.h),

              // Question text
              _buildLabel(_t('qb_question_text'), true, Icons.edit_outlined),
              SizedBox(height: 8.h),
              // Question text input
              _buildQuestionTextInput(formProvider, isDark),

              // Validation errors
              if (formProvider.validationErrors.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 16.h),
                  child: _buildValidationErrors(formProvider),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label, bool required, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: isDark ? AppColors.textDarkSecondary : AppColors.textSecondary,
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        if (required)
          Text(
            ' *',
            style: TextStyle(fontSize: 13.sp, color: AppColors.error),
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
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: formProvider.validationErrors['class'] != null
              ? AppColors.error
              : (isDark
                    ? AppColors.borderDark.withOpacity(0.3)
                    : AppColors.grey300.withOpacity(0.5)),
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<int>(
        value: formProvider.selectedClass?.id,
        isExpanded: true,
        style: TextStyle(
          fontSize: 13.sp,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: _t('qb_class_hint'),
          hintStyle: TextStyle(
            fontSize: 13.sp,
            color: isDark
                ? AppColors.textDarkSecondary
                : AppColors.textSecondary,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14.w,
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
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: formProvider.validationErrors['subject'] != null
              ? AppColors.error
              : (isDark
                    ? AppColors.borderDark.withOpacity(0.3)
                    : AppColors.grey300.withOpacity(0.5)),
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<int>(
        value: formProvider.selectedSubject?.id,
        isExpanded: true,
        style: TextStyle(
          fontSize: 13.sp,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: _t('qb_subject_hint'),
          hintStyle: TextStyle(
            fontSize: 13.sp,
            color: isDark
                ? AppColors.textDarkSecondary
                : AppColors.textSecondary,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14.w,
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
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected
                      ? null
                      : (isDark ? AppColors.surfaceDark : Colors.white),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : (isDark
                              ? AppColors.borderDark.withOpacity(0.3)
                              : AppColors.grey300.withOpacity(0.5)),
                    width: 1,
                  ),
                ),
                child: Text(
                  '$marks',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white : AppColors.textPrimary),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 10.h),

        // Custom marks input
        Row(
          children: [
            Text(
              'Custom:',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textDarkSecondary
                    : AppColors.textSecondary,
              ),
            ),
            SizedBox(width: 10.w),
            SizedBox(
              width: 70.w,
              child: TextFormField(
                controller: _customMarksController,
                focusNode: _customMarksFocusNode,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: isDark ? AppColors.surfaceDark : Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 10.h,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.borderDark.withOpacity(0.3)
                          : AppColors.grey300.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
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
            padding: EdgeInsets.only(top: 6.h),
            child: Text(
              formProvider.validationErrors['marks']!,
              style: TextStyle(fontSize: 11.sp, color: AppColors.error),
            ),
          ),
      ],
    );
  }

  Widget _buildQuestionTextInput(
    QuestionBankFormProvider formProvider,
    bool isDark,
  ) {
    final hasError = formProvider.validationErrors['questionText'] != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _questionTextController,
          focusNode: _questionTextFocusNode,
          minLines: 4,
          maxLines: 8,
          maxLength: 2000,
          style: TextStyle(
            fontSize: 13.sp,
            color: isDark ? Colors.white : AppColors.textPrimary,
            height: 1.4,
          ),
          decoration: InputDecoration(
            hintText: _t('qb_question_text_hint'),
            hintStyle: TextStyle(
              fontSize: 13.sp,
              color: isDark
                  ? AppColors.textDarkSecondary
                  : AppColors.textSecondary,
            ),
            filled: true,
            fillColor: isDark ? AppColors.surfaceDark : Colors.white,
            contentPadding: EdgeInsets.all(14.w),
            counterStyle: TextStyle(
              fontSize: 11.sp,
              color: isDark
                  ? AppColors.textDarkSecondary
                  : AppColors.textSecondary,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.error
                    : (isDark
                          ? AppColors.borderDark.withOpacity(0.3)
                          : AppColors.grey300.withOpacity(0.5)),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
          ),
          onChanged: (value) {
            formProvider.updateBasicInfo(questionText: value);
          },
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Text(
              formProvider.validationErrors['questionText']!,
              style: TextStyle(fontSize: 11.sp, color: AppColors.error),
            ),
          ),
      ],
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
