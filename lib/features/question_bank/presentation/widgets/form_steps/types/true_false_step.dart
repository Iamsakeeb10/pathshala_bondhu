/// True/False Step
/// Form for True/False question answer selection

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../../shared/utils/app_colors.dart';
import '../../../../presentation/providers/question_bank_form_provider.dart';
import '../../../../utils/question_bank_translations.dart';

class TrueFalseStep extends StatelessWidget {
  const TrueFalseStep({super.key});

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
            t('qb_select_answer'),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 24.h),

          // True/False toggle cards
          Row(
            children: [
              Expanded(
                child: _AnswerCard(
                  label: isBangla ? 'সত্য' : 'TRUE',
                  icon: Icons.check_circle,
                  isSelected: formProvider.correctAnswer == 'true',
                  color: AppColors.success,
                  isDark: isDark,
                  onTap: () => formProvider.setCorrectAnswerText('true'),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _AnswerCard(
                  label: isBangla ? 'মিথ্যা' : 'FALSE',
                  icon: Icons.cancel,
                  isSelected: formProvider.correctAnswer == 'false',
                  color: AppColors.error,
                  isDark: isDark,
                  onTap: () => formProvider.setCorrectAnswerText('false'),
                ),
              ),
            ],
          ),

          SizedBox(height: 32.h),

          // Optional explanation
          Text(
            isBangla ? 'ব্যাখ্যা (ঐচ্ছিক)' : 'Explanation (Optional)',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          TextFormField(
            initialValue: formProvider.explanation,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: isBangla
                  ? 'সঠিক উত্তরের ব্যাখ্যা লিখুন...'
                  : 'Explain why this answer is correct...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              filled: true,
              fillColor: isDark ? AppColors.grey800 : AppColors.grey100,
            ),
            onChanged: formProvider.setExplanation,
          ),

          // Validation error
          if (formProvider.validationErrors['correct'] != null)
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
                        formProvider.validationErrors['correct']!,
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

class _AnswerCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _AnswerCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : (isDark ? AppColors.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? AppColors.borderDark : AppColors.border),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48.sp,
              color: isSelected
                  ? color
                  : (isDark ? AppColors.grey400 : AppColors.grey500),
            ),
            SizedBox(height: 12.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? color
                    : (isDark ? Colors.white70 : AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
