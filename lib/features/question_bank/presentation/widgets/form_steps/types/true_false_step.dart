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
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            t('qb_select_answer') == 'qb_select_answer'
                ? (isBangla ? 'উত্তর নির্বাচন করুন' : 'Select Answer')
                : t('qb_select_answer'),
            style: TextStyle(
              fontSize: 18.sp,
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
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          TextFormField(
            initialValue: formProvider.explanation,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: isBangla
                  ? 'সঠিক উত্তরের ব্যাখ্যা লিখুন...'
                  : 'Explain why this answer is correct...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.grey400,
                  width: 1.2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.grey400,
                  width: 1.2,
                ),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: isDark ? AppColors.grey800 : AppColors.grey100,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
            onChanged: formProvider.setExplanation,
          ),

          // Validation error
          if (formProvider.validationErrors['correct'] != null)
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
                        formProvider.validationErrors['correct']!,
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
      borderRadius: BorderRadius.circular(20.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 36.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : (isDark ? AppColors.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? AppColors.borderDark : AppColors.border),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                    spreadRadius: 0,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withOpacity(0.2)
                    : (isDark ? AppColors.grey800 : AppColors.grey100),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48.sp,
                color: isSelected
                    ? color
                    : (isDark ? AppColors.grey400 : AppColors.grey500),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? color
                    : (isDark ? Colors.white70 : AppColors.textSecondary),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
