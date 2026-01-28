/// Fill in the Blank Step
/// Form for Fill in the Blank question blanks and answers

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../../shared/utils/app_colors.dart';
import '../../../../presentation/providers/question_bank_form_provider.dart';

class FillBlankStep extends StatefulWidget {
  const FillBlankStep({super.key});

  @override
  State<FillBlankStep> createState() => _FillBlankStepState();
}

class _FillBlankStepState extends State<FillBlankStep> {
  List<_BlankInfo> _detectedBlanks = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _detectBlanks();
  }

  void _detectBlanks() {
    final formProvider = context.read<QuestionBankFormProvider>();
    final questionText = formProvider.questionText;

    // Find all blanks marked with ___ or [blank]
    final blankPattern = RegExp(
      r'_{3,}|\[blank\]|\[শূন্যস্থান\]',
      caseSensitive: false,
    );
    final matches = blankPattern.allMatches(questionText);

    final blanks = <_BlankInfo>[];
    int index = 0;
    for (final match in matches) {
      blanks.add(
        _BlankInfo(
          index: index,
          position: match.start,
          label: '${index + 1}',
          answer: formProvider.blankAnswers.length > index
              ? formProvider.blankAnswers[index]
              : '',
        ),
      );
      index++;
    }

    setState(() {
      _detectedBlanks = blanks;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBangla = Localizations.localeOf(context).languageCode == 'bn';
    final formProvider = context.watch<QuestionBankFormProvider>();

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instructions card
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.info.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lightbulb_outline,
                        size: 20.sp,
                        color: AppColors.info,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      isBangla ? 'নির্দেশনা' : 'Instructions',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  isBangla
                      ? '• প্রশ্নে শূন্যস্থানের জন্য ___ (তিন বা ততোধিক আন্ডারস্কোর) ব্যবহার করুন\n'
                            '• বিকল্প হিসেবে [blank] বা [শূন্যস্থান] ব্যবহার করতে পারেন\n'
                            '• শূন্যস্থানগুলো স্বয়ংক্রিয়ভাবে শনাক্ত হবে'
                      : '• Use ___ (three or more underscores) for blanks in the question\n'
                            '• Alternatively, use [blank] markers\n'
                            '• Blanks will be auto-detected',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.info,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Question preview with highlighted blanks
          Text(
            isBangla ? 'প্রশ্ন পূর্বরূপ' : 'Question Preview',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.grey100,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildHighlightedQuestion(
              formProvider.questionText,
              isDark,
              isBangla,
            ),
          ),

          SizedBox(height: 28.h),

          // Detected blanks and answers
          if (_detectedBlanks.isEmpty)
            _buildNoBlanksWarning(isDark, isBangla)
          else
            _buildBlanksAnswerSection(formProvider, isDark, isBangla),

          // Refresh button
          SizedBox(height: 20.h),
          Center(
            child: TextButton.icon(
              onPressed: _detectBlanks,
              icon: const Icon(Icons.refresh),
              label: Text(
                isBangla ? 'শূন্যস্থান রিফ্রেশ করুন' : 'Refresh Blanks',
              ),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),

          // Validation error
          if (formProvider.validationErrors['blanks'] != null)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.error.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 20.sp,
                      color: AppColors.error,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        formProvider.validationErrors['blanks']!,
                        style: TextStyle(
                          fontSize: 14.sp,
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
    );
  }

  Widget _buildHighlightedQuestion(String text, bool isDark, bool isBangla) {
    final blankPattern = RegExp(
      r'_{3,}|\[blank\]|\[শূন্যস্থান\]',
      caseSensitive: false,
    );
    final spans = <TextSpan>[];
    int lastEnd = 0;
    int blankIndex = 0;

    for (final match in blankPattern.allMatches(text)) {
      // Text before blank
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastEnd, match.start),
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        );
      }

      // Blank placeholder
      blankIndex++;
      spans.add(
        TextSpan(
          text: ' [$blankIndex] ',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            backgroundColor: AppColors.primary.withOpacity(0.1),
          ),
        ),
      );

      lastEnd = match.end;
    }

    // Remaining text
    if (lastEnd < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastEnd),
          style: TextStyle(
            fontSize: 14.sp,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
      );
    }

    if (spans.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildNoBlanksWarning(bool isDark, bool isBangla) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 32.sp,
              color: AppColors.warning,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            isBangla ? 'কোন শূন্যস্থান পাওয়া যায়নি!' : 'No blanks detected!',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.warning,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            isBangla
                ? 'প্রশ্নে ___ বা [blank] যোগ করুন'
                : 'Add ___ or [blank] to your question',
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBlanksAnswerSection(
    QuestionBankFormProvider formProvider,
    bool isDark,
    bool isBangla,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isBangla
              ? 'শূন্যস্থানের উত্তর (${_detectedBlanks.length}টি পাওয়া গেছে)'
              : 'Blank Answers (${_detectedBlanks.length} detected)',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _detectedBlanks.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 14.h),
              child: Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: TextFormField(
                      initialValue: formProvider.blankAnswers.length > index
                          ? formProvider.blankAnswers[index]
                          : '',
                      decoration: InputDecoration(
                        hintText: isBangla
                            ? 'শূন্যস্থান ${index + 1} এর উত্তর'
                            : 'Answer for blank ${index + 1}',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.grey400,
                            width: 1.2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.grey400,
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.grey800
                            : AppColors.grey100,
                      ),
                      onChanged: (value) {
                        formProvider.updateBlankAnswer(index, value);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _BlankInfo {
  final int index;
  final int position;
  final String label;
  final String answer;

  _BlankInfo({
    required this.index,
    required this.position,
    required this.label,
    required this.answer,
  });
}
