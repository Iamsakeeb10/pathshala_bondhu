/// MCQ Options Step
/// Form for MCQ (Multiple Choice Question) options

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../../shared/utils/app_colors.dart';
import '../../../../data/models/question_model.dart';
import '../../../../presentation/providers/question_bank_form_provider.dart';
import '../../../../utils/question_bank_translations.dart';

class MCQOptionsStep extends StatelessWidget {
  const MCQOptionsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBangla = Localizations.localeOf(context).languageCode == 'bn';
    final formProvider = context.watch<QuestionBankFormProvider>();

    String t(String key) => QuestionBankTranslations.t(key, isBangla);

    // Ensure exactly 4 options for MCQ (Bangladeshi standard)
    if (formProvider.options.length != 4) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        formProvider.initializeMCQOptions();
      });
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            '${t('qb_options')} (MCQ)',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            t('qb_select_correct'),
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark
                  ? AppColors.textDarkSecondary
                  : AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 16.h),

          // Exactly 4 options (A, B, C, D)
          ...List.generate(4, (index) {
            final option = formProvider.options.length > index
                ? formProvider.options[index]
                : QuestionOption(text: '', isCorrect: false);
            final optionLabel = String.fromCharCode(65 + index); // A, B, C, D

            return _MCQOptionTile(
              key: ValueKey('option_$index'),
              index: index,
              label: optionLabel,
              option: option,
              isDark: isDark,
              isBangla: isBangla,
              onTextChanged: (text) {
                formProvider.updateOption(index, option.copyWith(text: text));
              },
              onCorrectChanged: () {
                formProvider.setCorrectAnswer(index);
              },
            );
          }),

          SizedBox(height: 16.h),

          // Info box
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18.sp, color: AppColors.info),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    isBangla
                        ? 'MCQ প্রশ্নে ঠিক ৪টি অপশন থাকবে (A, B, C, D) এবং একটি সঠিক উত্তর নির্বাচন করুন'
                        : 'MCQ must have exactly 4 options (A, B, C, D). Select one correct answer.',
                    style: TextStyle(fontSize: 12.sp, color: AppColors.info),
                  ),
                ),
              ],
            ),
          ),

          // Validation errors
          if (formProvider.validationErrors['options'] != null ||
              formProvider.validationErrors['correct'] != null)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 18.sp,
                      color: AppColors.error,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        formProvider.validationErrors['options'] ??
                            formProvider.validationErrors['correct'] ??
                            '',
                        style: TextStyle(
                          fontSize: 13.sp,
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
}

class _MCQOptionTile extends StatefulWidget {
  final int index;
  final String label;
  final QuestionOption option;
  final bool isDark;
  final bool isBangla;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onCorrectChanged;

  const _MCQOptionTile({
    super.key,
    required this.index,
    required this.label,
    required this.option,
    required this.isDark,
    required this.isBangla,
    required this.onTextChanged,
    required this.onCorrectChanged,
  });

  @override
  State<_MCQOptionTile> createState() => _MCQOptionTileState();
}

class _MCQOptionTileState extends State<_MCQOptionTile> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.option.text);
  }

  @override
  void didUpdateWidget(_MCQOptionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller if the option text changed externally
    if (widget.option.text != oldWidget.option.text &&
        _controller.text != widget.option.text) {
      _controller.text = widget.option.text;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        decoration: BoxDecoration(
          color: widget.option.isCorrect
              ? AppColors.success.withOpacity(0.08)
              : (widget.isDark ? AppColors.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: widget.option.isCorrect
                ? AppColors.success
                : (widget.isDark ? AppColors.borderDark : AppColors.border),
            width: widget.option.isCorrect ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            SizedBox(width: 12.w),

            // Radio button
            Radio<bool>(
              value: true,
              groupValue: widget.option.isCorrect,
              activeColor: AppColors.success,
              onChanged: (_) => widget.onCorrectChanged(),
            ),

            // Option label (A, B, C, D)
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: widget.option.isCorrect
                    ? AppColors.success
                    : (widget.isDark ? AppColors.grey600 : AppColors.grey300),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: widget.option.isCorrect
                        ? Colors.white
                        : (widget.isDark
                              ? Colors.white
                              : AppColors.textPrimary),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),

            // Text field
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: widget.isBangla
                      ? 'অপশন ${widget.label} লিখুন'
                      : 'Enter option ${widget.label}',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                  hintStyle: TextStyle(
                    color: widget.isDark
                        ? AppColors.textDarkSecondary.withOpacity(0.6)
                        : AppColors.textSecondary.withOpacity(0.6),
                  ),
                ),
                style: TextStyle(
                  color: widget.isDark ? Colors.white : AppColors.textPrimary,
                ),
                onChanged: widget.onTextChanged,
              ),
            ),

            SizedBox(width: 12.w),
          ],
        ),
      ),
    );
  }
}
