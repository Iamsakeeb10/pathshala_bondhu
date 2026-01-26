/// Question Preview Step
/// Final preview of the question before submission

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/utils/app_colors.dart';
import '../../../data/models/question_model.dart';
import '../../../utils/question_type_icons.dart';
import '../../providers/question_bank_form_provider.dart';

class QuestionPreviewStep extends StatefulWidget {
  const QuestionPreviewStep({super.key});

  @override
  State<QuestionPreviewStep> createState() => _QuestionPreviewStepState();
}

class _QuestionPreviewStepState extends State<QuestionPreviewStep> {
  bool _showAnswers = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBangla = Localizations.localeOf(context).languageCode == 'bn';
    final formProvider = context.watch<QuestionBankFormProvider>();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.preview_outlined,
                size: 24.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  isBangla ? 'প্রশ্ন পূর্বরূপ' : 'Question Preview',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
              // Show/Hide answers toggle
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showAnswers = !_showAnswers;
                  });
                },
                icon: Icon(
                  _showAnswers ? Icons.visibility_off : Icons.visibility,
                  size: 18.sp,
                ),
                label: Text(
                  _showAnswers
                      ? (isBangla ? 'উত্তর লুকান' : 'Hide Answers')
                      : (isBangla ? 'উত্তর দেখান' : 'Show Answers'),
                  style: TextStyle(fontSize: 12.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Question type badge
          if (formProvider.selectedType != null) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: QuestionTypeIcons.getColor(
                  formProvider.selectedType!,
                ).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    QuestionTypeIcons.getIcon(formProvider.selectedType!),
                    size: 16.sp,
                    color: QuestionTypeIcons.getColor(
                      formProvider.selectedType!,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    formProvider.selectedType!.getDisplayName(isBangla),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: QuestionTypeIcons.getColor(
                        formProvider.selectedType!,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
          ],

          // Metadata row
          _buildMetadataRow(formProvider, isDark, isBangla),
          SizedBox(height: 16.h),

          // Question card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question text
                Text(
                  formProvider.questionText.isEmpty
                      ? (isBangla ? 'প্রশ্ন লেখা হয়নি' : 'No question text')
                      : formProvider.questionText,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 16.h),

                // Type-specific content
                _buildTypeSpecificContent(formProvider, isDark, isBangla),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Explanation section (if available)
          if (formProvider.explanation.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 18.sp,
                        color: AppColors.info,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        isBangla
                            ? 'ব্যাখ্যা/নির্দেশনা'
                            : 'Explanation/Guidelines',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    formProvider.explanation,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Validation summary
          if (formProvider.validationErrors.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Container(
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
                      Icon(
                        Icons.warning_amber,
                        size: 18.sp,
                        color: AppColors.error,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        isBangla ? 'অসম্পূর্ণ তথ্য' : 'Incomplete Information',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  ...formProvider.validationErrors.values.map(
                    (error) => Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: TextStyle(color: AppColors.error)),
                          Expanded(
                            child: Text(
                              error,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetadataRow(
    QuestionBankFormProvider formProvider,
    bool isDark,
    bool isBangla,
  ) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        if (formProvider.selectedClass != null)
          _MetadataChip(
            icon: Icons.school_outlined,
            label: formProvider.selectedClass!.name,
            isDark: isDark,
          ),
        if (formProvider.selectedSubject != null)
          _MetadataChip(
            icon: Icons.book_outlined,
            label: formProvider.selectedSubject!.name,
            isDark: isDark,
          ),
        if (formProvider.marks > 0)
          _MetadataChip(
            icon: Icons.stars_outlined,
            label: '${formProvider.marks} ${isBangla ? 'নম্বর' : 'marks'}',
            isDark: isDark,
          ),
      ],
    );
  }

  Widget _buildTypeSpecificContent(
    QuestionBankFormProvider formProvider,
    bool isDark,
    bool isBangla,
  ) {
    if (formProvider.selectedType == null) {
      return const SizedBox.shrink();
    }

    switch (formProvider.selectedType!) {
      case QuestionType.mcq:
        return _buildMCQPreview(formProvider, isDark, isBangla);
      case QuestionType.trueFalse:
        return _buildTrueFalsePreview(formProvider, isDark, isBangla);
      case QuestionType.shortAnswer:
        return _buildShortAnswerPreview(formProvider, isDark, isBangla);
      case QuestionType.essay:
        return _buildEssayPreview(formProvider, isDark, isBangla);
      case QuestionType.matching:
        return _buildMatchingPreview(formProvider, isDark, isBangla);
      case QuestionType.fillBlank:
        return _buildFillBlankPreview(formProvider, isDark, isBangla);
      case QuestionType.mathProblem:
        return _buildMathPreview(formProvider, isDark, isBangla);
      case QuestionType.creative:
        return _buildCreativePreview(formProvider, isDark, isBangla);
    }
  }

  Widget _buildMCQPreview(
    QuestionBankFormProvider formProvider,
    bool isDark,
    bool isBangla,
  ) {
    return Column(
      children: formProvider.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final label = String.fromCharCode(65 + index);
        final isCorrect = option.isCorrect;

        return Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: _showAnswers && isCorrect
                ? AppColors.success.withOpacity(0.1)
                : (isDark ? AppColors.grey800 : AppColors.grey100),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: _showAnswers && isCorrect
                  ? AppColors.success
                  : (isDark ? AppColors.borderDark : AppColors.border),
              width: _showAnswers && isCorrect ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: _showAnswers && isCorrect
                      ? AppColors.success
                      : AppColors.grey300,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: _showAnswers && isCorrect
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  option.text.isEmpty
                      ? (isBangla ? 'অপশন $label' : 'Option $label')
                      : option.text,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
              if (_showAnswers && isCorrect)
                Icon(Icons.check_circle, size: 20.sp, color: AppColors.success),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrueFalsePreview(
    QuestionBankFormProvider formProvider,
    bool isDark,
    bool isBangla,
  ) {
    final isTrue = formProvider.correctAnswer == 'true';
    final isFalse = formProvider.correctAnswer == 'false';

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              color: _showAnswers && isTrue
                  ? AppColors.success.withOpacity(0.15)
                  : (isDark ? AppColors.grey800 : AppColors.grey100),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: _showAnswers && isTrue
                    ? AppColors.success
                    : (isDark ? AppColors.borderDark : AppColors.border),
                width: _showAnswers && isTrue ? 2 : 1,
              ),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: _showAnswers && isTrue
                        ? AppColors.success
                        : (isDark ? AppColors.grey400 : AppColors.grey500),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    isBangla ? 'সত্য' : 'TRUE',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: _showAnswers && isTrue
                          ? AppColors.success
                          : (isDark ? Colors.white : AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              color: _showAnswers && isFalse
                  ? AppColors.error.withOpacity(0.15)
                  : (isDark ? AppColors.grey800 : AppColors.grey100),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: _showAnswers && isFalse
                    ? AppColors.error
                    : (isDark ? AppColors.borderDark : AppColors.border),
                width: _showAnswers && isFalse ? 2 : 1,
              ),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cancel,
                    color: _showAnswers && isFalse
                        ? AppColors.error
                        : (isDark ? AppColors.grey400 : AppColors.grey500),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    isBangla ? 'মিথ্যা' : 'FALSE',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: _showAnswers && isFalse
                          ? AppColors.error
                          : (isDark ? Colors.white : AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShortAnswerPreview(
    QuestionBankFormProvider formProvider,
    bool isDark,
    bool isBangla,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 80.h,
          decoration: BoxDecoration(
            color: isDark ? AppColors.grey800 : AppColors.grey100,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
          ),
          padding: EdgeInsets.all(12.w),
          child: Text(
            isBangla ? 'উত্তর লিখুন...' : 'Write your answer...',
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? AppColors.grey400 : AppColors.grey500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        if (_showAnswers && formProvider.correctAnswer.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBangla ? 'প্রত্যাশিত উত্তর:' : 'Expected Answer:',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  formProvider.correctAnswer,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEssayPreview(
    QuestionBankFormProvider formProvider,
    bool isDark,
    bool isBangla,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (formProvider.wordLimit != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.text_fields, size: 16.sp, color: AppColors.primary),
                SizedBox(width: 8.w),
                Text(
                  isBangla
                      ? 'শব্দ সীমা: ${formProvider.wordLimit}'
                      : 'Word Limit: ${formProvider.wordLimit}',
                  style: TextStyle(fontSize: 13.sp, color: AppColors.primary),
                ),
              ],
            ),
          ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          height: 120.h,
          decoration: BoxDecoration(
            color: isDark ? AppColors.grey800 : AppColors.grey100,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
          ),
          padding: EdgeInsets.all(12.w),
          child: Text(
            isBangla ? 'আপনার প্রবন্ধ লিখুন...' : 'Write your essay...',
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? AppColors.grey400 : AppColors.grey500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchingPreview(
    QuestionBankFormProvider formProvider,
    bool isDark,
    bool isBangla,
  ) {
    if (formProvider.matchingPairs.isEmpty) {
      return Text(
        isBangla ? 'কোন জোড়া যোগ করা হয়নি' : 'No pairs added',
        style: TextStyle(
          fontSize: 13.sp,
          color: isDark ? Colors.white60 : AppColors.textSecondary,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    isBangla ? 'বাম কলাম' : 'Column A',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 24.w),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    isBangla ? 'ডান কলাম' : 'Column B',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ...formProvider.matchingPairs.asMap().entries.map((entry) {
          final index = entry.key;
          final pair = entry.value;
          final label = String.fromCharCode(65 + index);

          return Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.grey800 : AppColors.grey100,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 22.w,
                          height: 22.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Center(
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            pair['left'] ?? '',
                            style: TextStyle(fontSize: 13.sp),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Icon(
                    _showAnswers ? Icons.arrow_forward : Icons.help_outline,
                    size: 16.sp,
                    color: _showAnswers ? AppColors.success : AppColors.grey400,
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.grey800 : AppColors.grey100,
                      borderRadius: BorderRadius.circular(6.r),
                      border: _showAnswers
                          ? Border.all(color: AppColors.success, width: 2)
                          : null,
                    ),
                    child: Text(
                      _showAnswers
                          ? (pair['right'] ?? '')
                          : '${index + 1}. ___',
                      style: TextStyle(fontSize: 13.sp),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFillBlankPreview(
    QuestionBankFormProvider formProvider,
    bool isDark,
    bool isBangla,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_showAnswers && formProvider.blankAnswers.isNotEmpty) ...[
          Text(
            isBangla ? 'উত্তর:' : 'Answers:',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.success,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: formProvider.blankAnswers.asMap().entries.map((entry) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.success),
                ),
                child: Text(
                  '[${entry.key + 1}] ${entry.value}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ] else
          Text(
            isBangla ? 'শূন্যস্থানগুলো পূরণ করুন' : 'Fill in the blanks',
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? Colors.white60 : AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  Widget _buildMathPreview(
    QuestionBankFormProvider formProvider,
    bool isDark,
    bool isBangla,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (formProvider.solutionSteps.isNotEmpty && _showAnswers) ...[
          Text(
            isBangla ? 'সমাধানের ধাপ:' : 'Solution Steps:',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 8.h),
          ...formProvider.solutionSteps.asMap().entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22.w,
                    height: 22.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: 12.h),
        ],
        if (formProvider.correctAnswer.isNotEmpty && _showAnswers)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.success),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 20.sp, color: AppColors.success),
                SizedBox(width: 8.w),
                Text(
                  '${isBangla ? 'উত্তর' : 'Answer'}: ${formProvider.correctAnswer}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCreativePreview(
    QuestionBankFormProvider formProvider,
    bool isDark,
    bool isBangla,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (formProvider.stimulus.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBangla ? 'উদ্দীপক:' : 'Stimulus:',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  formProvider.stimulus,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
        ],
        if (formProvider.subQuestions.isNotEmpty) ...[
          Text(
            isBangla ? 'উপ-প্রশ্নসমূহ:' : 'Sub-Questions:',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          ...formProvider.subQuestions.asMap().entries.map((entry) {
            final index = entry.key;
            final subQ = entry.value;
            final label = isBangla
                ? ['ক', 'খ', 'গ', 'ঘ', 'ঙ', 'চ'][index % 6]
                : ['a', 'b', 'c', 'd', 'e', 'f'][index % 6];

            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isDark ? AppColors.grey800 : AppColors.grey100,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Center(
                      child: Text(
                        '($label)',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subQ['text'] ?? '',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${subQ['marks'] ?? 0} ${isBangla ? 'নম্বর' : 'marks'}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}

class _MetadataChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _MetadataChip({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : AppColors.grey100,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.sp,
            color: isDark ? AppColors.grey400 : AppColors.grey600,
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
