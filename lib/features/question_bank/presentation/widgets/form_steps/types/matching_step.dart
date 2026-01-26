/// Matching Step
/// Form for Matching question pairs

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../../shared/utils/app_colors.dart';
import '../../../../presentation/providers/question_bank_form_provider.dart';

class MatchingStep extends StatelessWidget {
  const MatchingStep({super.key});

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
          Text(
            isBangla ? 'মিলকরণ জোড়া' : 'Matching Pairs',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            isBangla
                ? 'বাম ও ডান কলামের আইটেম যোগ করুন যা মিলাতে হবে'
                : 'Add items for left and right columns to be matched',
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark
                  ? AppColors.textDarkSecondary
                  : AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 16.h),

          // Column headers
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
                      isBangla ? 'বাম কলাম' : 'Left Column',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 32.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Text(
                      isBangla ? 'ডান কলাম' : 'Right Column',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Pairs list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: formProvider.matchingPairs.length,
            itemBuilder: (context, index) {
              final pair = formProvider.matchingPairs[index];
              final pairLabel = String.fromCharCode(65 + index); // A, B, C...

              return _MatchingPairRow(
                index: index,
                label: pairLabel,
                leftValue: pair['left'] ?? '',
                rightValue: pair['right'] ?? '',
                isDark: isDark,
                isBangla: isBangla,
                onLeftChanged: (text) {
                  formProvider.updateMatchingPair(index, left: text);
                },
                onRightChanged: (text) {
                  formProvider.updateMatchingPair(index, right: text);
                },
                onRemove: formProvider.matchingPairs.length > 2
                    ? () => formProvider.removeMatchingPair(index)
                    : null,
              );
            },
          ),

          SizedBox(height: 16.h),

          // Add pair button
          if (formProvider.matchingPairs.length < 10)
            Center(
              child: TextButton.icon(
                onPressed: formProvider.addMatchingPair,
                icon: const Icon(Icons.add_circle_outline),
                label: Text(isBangla ? 'জোড়া যোগ করুন' : 'Add Pair'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ),

          SizedBox(height: 16.h),

          // Info card
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shuffle, size: 20.sp, color: AppColors.info),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    isBangla
                        ? 'পরীক্ষায় ডান কলামের আইটেমগুলো এলোমেলো করে দেখানো হবে। শিক্ষার্থীদের সঠিক জোড়া মিলাতে হবে।'
                        : 'Right column items will be shuffled during the exam. Students need to match the correct pairs.',
                    style: TextStyle(fontSize: 12.sp, color: AppColors.info),
                  ),
                ),
              ],
            ),
          ),

          // Validation error
          if (formProvider.validationErrors['matching'] != null)
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
                        formProvider.validationErrors['matching']!,
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

class _MatchingPairRow extends StatelessWidget {
  final int index;
  final String label;
  final String leftValue;
  final String rightValue;
  final bool isDark;
  final bool isBangla;
  final ValueChanged<String> onLeftChanged;
  final ValueChanged<String> onRightChanged;
  final VoidCallback? onRemove;

  const _MatchingPairRow({
    required this.index,
    required this.label,
    required this.leftValue,
    required this.rightValue,
    required this.isDark,
    required this.isBangla,
    required this.onLeftChanged,
    required this.onRightChanged,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Row number
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: isDark ? AppColors.grey700 : AppColors.grey200,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),

          // Left input
          Expanded(
            child: TextFormField(
              initialValue: leftValue,
              decoration: InputDecoration(
                hintText: isBangla ? 'আইটেম $label' : 'Item $label',
                hintStyle: TextStyle(fontSize: 13.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 10.h,
                ),
                filled: true,
                fillColor: isDark ? AppColors.grey800 : AppColors.grey100,
              ),
              style: TextStyle(fontSize: 13.sp),
              onChanged: onLeftChanged,
            ),
          ),

          // Arrow icon
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Icon(
              Icons.compare_arrows,
              size: 20.sp,
              color: isDark ? AppColors.grey400 : AppColors.grey500,
            ),
          ),

          // Right input
          Expanded(
            child: TextFormField(
              initialValue: rightValue,
              decoration: InputDecoration(
                hintText: isBangla ? 'মিল $label' : 'Match $label',
                hintStyle: TextStyle(fontSize: 13.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 10.h,
                ),
                filled: true,
                fillColor: isDark ? AppColors.grey800 : AppColors.grey100,
              ),
              style: TextStyle(fontSize: 13.sp),
              onChanged: onRightChanged,
            ),
          ),

          SizedBox(width: 8.w),

          // Remove button
          if (onRemove != null)
            IconButton(
              icon: Icon(
                Icons.remove_circle_outline,
                color: AppColors.error.withOpacity(0.7),
                size: 22.sp,
              ),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
              onPressed: onRemove,
            )
          else
            SizedBox(width: 32.w),
        ],
      ),
    );
  }
}
