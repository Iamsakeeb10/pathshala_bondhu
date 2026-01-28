/// Short Answer Step
/// Form for Short Answer question expected answer

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../../shared/utils/app_colors.dart';
import '../../../../presentation/providers/question_bank_form_provider.dart';

class ShortAnswerStep extends StatelessWidget {
  const ShortAnswerStep({super.key});

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
          // Info banner
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
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outline,
                    size: 20.sp,
                    color: AppColors.info,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    isBangla
                        ? 'সংক্ষিপ্ত উত্তর প্রশ্নে প্রত্যাশিত উত্তর ঐচ্ছিক। এটি শুধুমাত্র রেফারেন্সের জন্য ব্যবহৃত হয়।'
                        : 'Expected answer is optional for short answer questions. It is used only for reference.',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.info,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 28.h),

          // Expected answer
          Text(
            isBangla
                ? 'প্রত্যাশিত উত্তর (ঐচ্ছিক)'
                : 'Expected Answer (Optional)',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          TextFormField(
            initialValue: formProvider.correctAnswer,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: isBangla
                  ? 'শিক্ষার্থীদের কাছ থেকে প্রত্যাশিত উত্তর...'
                  : 'Expected answer from students...',
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
            onChanged: formProvider.setCorrectAnswerText,
          ),

          SizedBox(height: 28.h),

          // Grading hints
          Text(
            isBangla
                ? 'মূল্যায়ন নির্দেশনা (ঐচ্ছিক)'
                : 'Grading Hints (Optional)',
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
                  ? 'উত্তর মূল্যায়নের জন্য মূল পয়েন্ট বা কীওয়ার্ড...'
                  : 'Key points or keywords for evaluating answers...',
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

          SizedBox(height: 28.h),

          // Character limit option
          Text(
            isBangla ? 'উত্তরের অক্ষর সীমা' : 'Answer Character Limit',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 14.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: [
              _CharLimitChip(
                label: isBangla ? 'কোন সীমা নেই' : 'No Limit',
                isSelected: formProvider.wordLimit == null,
                onTap: () => formProvider.setWordLimit(null),
                isDark: isDark,
              ),
              _CharLimitChip(
                label: '50',
                isSelected: formProvider.wordLimit == 50,
                onTap: () => formProvider.setWordLimit(50),
                isDark: isDark,
              ),
              _CharLimitChip(
                label: '100',
                isSelected: formProvider.wordLimit == 100,
                onTap: () => formProvider.setWordLimit(100),
                isDark: isDark,
              ),
              _CharLimitChip(
                label: '200',
                isSelected: formProvider.wordLimit == 200,
                onTap: () => formProvider.setWordLimit(200),
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CharLimitChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _CharLimitChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.15)
              : (isDark ? AppColors.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.border),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? AppColors.primary
                : (isDark ? Colors.white70 : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
