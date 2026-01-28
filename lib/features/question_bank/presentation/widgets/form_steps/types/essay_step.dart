/// Essay Step
/// Form for Essay question settings

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../../shared/utils/app_colors.dart';
import '../../../../presentation/providers/question_bank_form_provider.dart';

class EssayStep extends StatelessWidget {
  const EssayStep({super.key});

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
          // Word count section
          Text(
            isBangla ? 'শব্দ সীমা' : 'Word Limit',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            isBangla
                ? 'শিক্ষার্থীদের জন্য প্রত্যাশিত শব্দ সংখ্যা নির্বাচন করুন'
                : 'Select expected word count for students',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark
                  ? AppColors.textDarkSecondary
                  : AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 20.h),

          // Word limit grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 14.w,
            mainAxisSpacing: 14.h,
            childAspectRatio: 2.5,
            children: [
              _WordLimitCard(
                label: '100',
                sublabel: isBangla ? 'সংক্ষিপ্ত' : 'Brief',
                isSelected: formProvider.wordLimit == 100,
                onTap: () => formProvider.setWordLimit(100),
                isDark: isDark,
              ),
              _WordLimitCard(
                label: '200',
                sublabel: isBangla ? 'মাঝারি' : 'Medium',
                isSelected: formProvider.wordLimit == 200,
                onTap: () => formProvider.setWordLimit(200),
                isDark: isDark,
              ),
              _WordLimitCard(
                label: '300',
                sublabel: isBangla ? 'মানক' : 'Standard',
                isSelected: formProvider.wordLimit == 300,
                onTap: () => formProvider.setWordLimit(300),
                isDark: isDark,
              ),
              _WordLimitCard(
                label: '500',
                sublabel: isBangla ? 'বিস্তারিত' : 'Detailed',
                isSelected: formProvider.wordLimit == 500,
                onTap: () => formProvider.setWordLimit(500),
                isDark: isDark,
              ),
              _WordLimitCard(
                label: '750',
                sublabel: isBangla ? 'দীর্ঘ' : 'Long',
                isSelected: formProvider.wordLimit == 750,
                onTap: () => formProvider.setWordLimit(750),
                isDark: isDark,
              ),
              _WordLimitCard(
                label: '1000+',
                sublabel: isBangla ? 'প্রবন্ধ' : 'Essay',
                isSelected: formProvider.wordLimit == 1000,
                onTap: () => formProvider.setWordLimit(1000),
                isDark: isDark,
              ),
            ],
          ),

          SizedBox(height: 28.h),

          // Grading rubric
          Text(
            isBangla ? 'মূল্যায়ন মানদণ্ড' : 'Grading Rubric',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          TextFormField(
            initialValue: formProvider.explanation,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: isBangla
                  ? 'প্রবন্ধ মূল্যায়নের জন্য মানদণ্ড ও নির্দেশনা...\n\n• বিষয়বস্তু: X নম্বর\n• উপস্থাপনা: X নম্বর\n• ভাষা: X নম্বর'
                  : 'Criteria and guidelines for essay evaluation...\n\n• Content: X marks\n• Presentation: X marks\n• Language: X marks',
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
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
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

          // Key points to cover
          Text(
            isBangla ? 'মূল পয়েন্ট' : 'Key Points to Cover',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          TextFormField(
            initialValue: formProvider.correctAnswer,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: isBangla
                  ? 'উত্তরে অবশ্যই থাকতে হবে এমন মূল পয়েন্ট...'
                  : 'Key points that must be included in the answer...',
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
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
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

          // Validation error
          if (formProvider.validationErrors['wordLimit'] != null)
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
                        formProvider.validationErrors['wordLimit']!,
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

class _WordLimitCard extends StatelessWidget {
  final String label;
  final String sublabel;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _WordLimitCard({
    required this.label,
    required this.sublabel,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.15)
              : (isDark ? AppColors.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.border),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? Colors.white : AppColors.textPrimary),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              sublabel,
              style: TextStyle(
                fontSize: 11.sp,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? Colors.white60 : AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
