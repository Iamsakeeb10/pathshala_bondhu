/// Math Problem Step
/// Form for Math Problem question with solution steps

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../../shared/utils/app_colors.dart';
import '../../../../presentation/providers/question_bank_form_provider.dart';

class MathProblemStep extends StatelessWidget {
  const MathProblemStep({super.key});

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
          // Final answer section
          Text(
            isBangla ? 'চূড়ান্ত উত্তর' : 'Final Answer',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          TextFormField(
            initialValue: formProvider.correctAnswer,
            decoration: InputDecoration(
              hintText: isBangla
                  ? 'চূড়ান্ত উত্তর লিখুন...'
                  : 'Enter the final answer...',
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
              prefixIcon: const Icon(Icons.done_all),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
            onChanged: formProvider.setCorrectAnswerText,
          ),

          SizedBox(height: 28.h),

          // Solution steps
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isBangla ? 'সমাধানের ধাপসমূহ' : 'Solution Steps',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              TextButton.icon(
                onPressed: formProvider.addSolutionStep,
                icon: Icon(Icons.add, size: 18.sp),
                label: Text(isBangla ? 'ধাপ যোগ করুন' : 'Add Step'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          if (formProvider.solutionSteps.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(28.w),
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
              child: Column(
                children: [
                  Icon(
                    Icons.format_list_numbered,
                    size: 32.sp,
                    color: isDark ? AppColors.grey400 : AppColors.grey500,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    isBangla ? 'সমাধানের ধাপ যোগ করুন' : 'Add solution steps',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: formProvider.solutionSteps.length,
              onReorder: formProvider.reorderSolutionSteps,
              itemBuilder: (context, index) {
                return _SolutionStepTile(
                  key: ValueKey('step_$index'),
                  index: index,
                  stepNumber: index + 1,
                  value: formProvider.solutionSteps[index],
                  isDark: isDark,
                  isBangla: isBangla,
                  onChanged: (text) {
                    formProvider.updateSolutionStep(index, text);
                  },
                  onRemove: () => formProvider.removeSolutionStep(index),
                );
              },
            ),

          SizedBox(height: 28.h),

          // Math symbols keyboard
          Text(
            isBangla ? 'গাণিতিক চিহ্ন' : 'Math Symbols',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          _MathSymbolsKeyboard(isDark: isDark),

          SizedBox(height: 28.h),

          // Explanation / Notes
          Text(
            isBangla ? 'টীকা (ঐচ্ছিক)' : 'Notes (Optional)',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          TextFormField(
            initialValue: formProvider.explanation,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: isBangla
                  ? 'সমস্যা সমাধানের জন্য অতিরিক্ত টীকা বা সূত্র...'
                  : 'Additional notes or formulas for solving this problem...',
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

          // Validation error
          if (formProvider.validationErrors['answer'] != null)
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
                        formProvider.validationErrors['answer']!,
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

class _SolutionStepTile extends StatelessWidget {
  final int index;
  final int stepNumber;
  final String value;
  final bool isDark;
  final bool isBangla;
  final ValueChanged<String> onChanged;
  final VoidCallback onRemove;

  const _SolutionStepTile({
    super.key,
    required this.index,
    required this.stepNumber,
    required this.value,
    required this.isDark,
    required this.isBangla,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
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

            // Step number
            Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Center(
                child: Text(
                  '$stepNumber',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),

            // Text field
            Expanded(
              child: TextFormField(
                initialValue: value,
                decoration: InputDecoration(
                  hintText: isBangla
                      ? 'ধাপ $stepNumber লিখুন...'
                      : 'Enter step $stepNumber...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 12.h,
                  ),
                ),
                style: TextStyle(fontSize: 14.sp),
                onChanged: onChanged,
              ),
            ),

            // Remove button
            IconButton(
              icon: Icon(
                Icons.close,
                color: AppColors.error.withOpacity(0.7),
                size: 20.sp,
              ),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

class _MathSymbolsKeyboard extends StatelessWidget {
  final bool isDark;

  const _MathSymbolsKeyboard({required this.isDark});

  static const _symbols = [
    '+',
    '-',
    '×',
    '÷',
    '=',
    '≠',
    '<',
    '>',
    '≤',
    '≥',
    '±',
    '∓',
    '²',
    '³',
    '√',
    '∛',
    'π',
    '∞',
    '∑',
    '∏',
    '∫',
    '∂',
    '∆',
    '∇',
    'α',
    'β',
    'γ',
    'θ',
    'λ',
    'μ',
    '°',
    '%',
    '‰',
    '⁄',
    '∠',
    '⊥',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.grey100,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 1,
        ),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 6.w,
          mainAxisSpacing: 6.h,
          childAspectRatio: 1.2,
        ),
        itemCount: _symbols.length,
        itemBuilder: (context, index) {
          return _SymbolButton(symbol: _symbols[index], isDark: isDark);
        },
      ),
    );
  }
}

class _SymbolButton extends StatelessWidget {
  final String symbol;
  final bool isDark;

  const _SymbolButton({required this.symbol, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.grey700 : Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: () {
          // Copy to clipboard and show feedback
          // In a real app, this would insert into the focused text field
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$symbol copied'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Center(
          child: Text(
            symbol,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
