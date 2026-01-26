/// MCQ Options Step
/// Form for Multiple Choice Question options

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

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            t('qb_options'),
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

          // Options list
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: formProvider.options.length,
            onReorder: formProvider.reorderOptions,
            itemBuilder: (context, index) {
              final option = formProvider.options[index];
              final optionLabel = String.fromCharCode(
                65 + index,
              ); // A, B, C, D...

              return _MCQOptionTile(
                key: ValueKey('option_$index'),
                index: index,
                label: optionLabel,
                option: option,
                isDark: isDark,
                onTextChanged: (text) {
                  formProvider.updateOption(index, option.copyWith(text: text));
                },
                onCorrectChanged: () {
                  formProvider.setCorrectAnswer(index);
                },
                onRemove: formProvider.options.length > 2
                    ? () => formProvider.removeOption(index)
                    : null,
              );
            },
          ),

          SizedBox(height: 16.h),

          // Add option button
          if (formProvider.options.length < 6)
            Center(
              child: TextButton.icon(
                onPressed: formProvider.addOption,
                icon: const Icon(Icons.add_circle_outline),
                label: Text(t('qb_add_option')),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
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

class _MCQOptionTile extends StatelessWidget {
  final int index;
  final String label;
  final QuestionOption option;
  final bool isDark;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onCorrectChanged;
  final VoidCallback? onRemove;

  const _MCQOptionTile({
    super.key,
    required this.index,
    required this.label,
    required this.option,
    required this.isDark,
    required this.onTextChanged,
    required this.onCorrectChanged,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        decoration: BoxDecoration(
          color: option.isCorrect
              ? AppColors.success.withOpacity(0.1)
              : (isDark ? AppColors.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: option.isCorrect
                ? AppColors.success
                : (isDark ? AppColors.borderDark : AppColors.border),
            width: option.isCorrect ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Drag handle
            ReorderableDragStartListener(
              index: index,
              child: Container(
                padding: EdgeInsets.all(12.w),
                child: Icon(
                  Icons.drag_handle,
                  color: isDark ? AppColors.grey500 : AppColors.grey400,
                ),
              ),
            ),

            // Option label
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: option.isCorrect ? AppColors.success : AppColors.grey300,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: option.isCorrect
                        ? Colors.white
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),

            // Text field
            Expanded(
              child: TextFormField(
                initialValue: option.text,
                decoration: InputDecoration(
                  hintText: 'Option $label',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                onChanged: onTextChanged,
              ),
            ),

            // Correct answer radio
            Radio<bool>(
              value: true,
              groupValue: option.isCorrect,
              activeColor: AppColors.success,
              onChanged: (_) => onCorrectChanged(),
            ),

            // Remove button
            if (onRemove != null)
              IconButton(
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: AppColors.error.withOpacity(0.7),
                ),
                onPressed: onRemove,
              ),
          ],
        ),
      ),
    );
  }
}
