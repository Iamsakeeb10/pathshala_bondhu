/// Creative Question Step
/// Form for Creative Question with sub-questions

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../../shared/utils/app_colors.dart';
import '../../../../presentation/providers/question_bank_form_provider.dart';

class CreativeQuestionStep extends StatelessWidget {
  const CreativeQuestionStep({super.key});

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
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.secondary.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    size: 20.sp,
                    color: AppColors.secondary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    isBangla
                        ? 'সৃজনশীল প্রশ্নে একটি উদ্দীপক এবং একাধিক উপ-প্রশ্ন থাকে। প্রতিটি উপ-প্রশ্নের জন্য আলাদা নম্বর নির্ধারণ করুন।'
                        : 'Creative questions have a stimulus and multiple sub-questions. Set separate marks for each sub-question.',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.secondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 28.h),

          // Stimulus section
          Text(
            isBangla ? 'উদ্দীপক' : 'Stimulus',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          TextFormField(
            initialValue: formProvider.stimulus,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: isBangla
                  ? 'উদ্দীপক/প্যাসেজ লিখুন...'
                  : 'Enter the stimulus/passage...',
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
            onChanged: formProvider.setStimulus,
          ),

          SizedBox(height: 28.h),

          // Sub-questions header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isBangla ? 'উপ-প্রশ্নসমূহ' : 'Sub-Questions',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              if (formProvider.subQuestions.length < 6)
                TextButton.icon(
                  onPressed: formProvider.addSubQuestion,
                  icon: Icon(Icons.add, size: 18.sp),
                  label: Text(isBangla ? 'উপ-প্রশ্ন যোগ করুন' : 'Add Sub-Q'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),

          // Sub-questions list
          if (formProvider.subQuestions.isEmpty)
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
                    Icons.quiz_outlined,
                    size: 32.sp,
                    color: isDark ? AppColors.grey400 : AppColors.grey500,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    isBangla
                        ? 'উপ-প্রশ্ন যোগ করতে "উপ-প্রশ্ন যোগ করুন" বাটনে ক্লিক করুন'
                        : 'Click "Add Sub-Q" to add sub-questions',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...formProvider.subQuestions.asMap().entries.map((entry) {
              final index = entry.key;
              final subQ = entry.value;
              final label = _getSubQuestionLabel(index, isBangla);

              return _SubQuestionCard(
                index: index,
                label: label,
                questionText: subQ['text'] ?? '',
                marks: subQ['marks'] ?? 0,
                cognitiveLevel: subQ['level'] ?? 'knowledge',
                isDark: isDark,
                isBangla: isBangla,
                onTextChanged: (text) {
                  formProvider.updateSubQuestion(index, text: text);
                },
                onMarksChanged: (marks) {
                  formProvider.updateSubQuestion(index, marks: marks);
                },
                onLevelChanged: (level) {
                  formProvider.updateSubQuestion(index, level: level);
                },
                onRemove: formProvider.subQuestions.length > 1
                    ? () => formProvider.removeSubQuestion(index)
                    : null,
              );
            }).toList(),

          // Total marks summary
          if (formProvider.subQuestions.isNotEmpty) ...[
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isBangla ? 'মোট নম্বর:' : 'Total Marks:',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '${_calculateTotalMarks(formProvider.subQuestions)}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Validation error
          if (formProvider.validationErrors['subQuestions'] != null)
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
                        formProvider.validationErrors['subQuestions']!,
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

  String _getSubQuestionLabel(int index, bool isBangla) {
    if (isBangla) {
      const labels = ['ক', 'খ', 'গ', 'ঘ', 'ঙ', 'চ'];
      return labels[index % labels.length];
    } else {
      const labels = ['a', 'b', 'c', 'd', 'e', 'f'];
      return labels[index % labels.length];
    }
  }

  int _calculateTotalMarks(List<Map<String, dynamic>> subQuestions) {
    return subQuestions.fold<int>(
      0,
      (sum, sq) => sum + ((sq['marks'] as int?) ?? 0),
    );
  }
}

class _SubQuestionCard extends StatelessWidget {
  final int index;
  final String label;
  final String questionText;
  final int marks;
  final String cognitiveLevel;
  final bool isDark;
  final bool isBangla;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<int> onMarksChanged;
  final ValueChanged<String> onLevelChanged;
  final VoidCallback? onRemove;

  const _SubQuestionCard({
    required this.index,
    required this.label,
    required this.questionText,
    required this.marks,
    required this.cognitiveLevel,
    required this.isDark,
    required this.isBangla,
    required this.onTextChanged,
    required this.onMarksChanged,
    required this.onLevelChanged,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    '($label)',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  isBangla ? 'উপ-প্রশ্ন ($label)' : 'Sub-question ($label)',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
              if (onRemove != null)
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: AppColors.error.withOpacity(0.7),
                    size: 20.sp,
                  ),
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
                ),
            ],
          ),
          SizedBox(height: 12.h),

          // Question text
          TextFormField(
            initialValue: questionText,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: isBangla
                  ? 'উপ-প্রশ্ন ($label) লিখুন...'
                  : 'Enter sub-question ($label)...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.grey400,
                  width: 1.2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.grey400,
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.secondary, width: 2),
              ),
              contentPadding: EdgeInsets.all(12.w),
              filled: true,
              fillColor: isDark ? AppColors.grey800 : AppColors.grey100,
            ),
            style: TextStyle(fontSize: 14.sp),
            onChanged: onTextChanged,
          ),
          SizedBox(height: 12.h),

          // Marks and cognitive level section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Marks section
              Text(
                isBangla ? 'নম্বর' : 'Marks',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [1, 2, 3, 4, 5].map((m) {
                  final isSelected = marks == m;
                  return InkWell(
                    onTap: () => onMarksChanged(m),
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? AppColors.grey700 : AppColors.grey200),
                        borderRadius: BorderRadius.circular(8.r),
                        border: isSelected
                            ? Border.all(color: AppColors.primary, width: 2)
                            : Border.all(
                                color: isDark
                                    ? AppColors.borderDark
                                    : AppColors.grey300,
                                width: 1,
                              ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '$m',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                      ? Colors.white70
                                      : AppColors.textPrimary),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16.h),

              // Cognitive level section
              Text(
                isBangla ? 'স্তর' : 'Level',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                height: 48.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.grey800 : AppColors.grey100,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.grey400,
                    width: 1.2,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: cognitiveLevel,
                    isExpanded: true,
                    items: _cognitiveLevels.map((level) {
                      return DropdownMenuItem(
                        value: level['value'],
                        child: Text(
                          isBangla ? level['bn']! : level['en']!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) onLevelChanged(value);
                    },
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const _cognitiveLevels = [
    {'value': 'knowledge', 'en': 'Knowledge', 'bn': 'জ্ঞান'},
    {'value': 'comprehension', 'en': 'Comprehension', 'bn': 'অনুধাবন'},
    {'value': 'application', 'en': 'Application', 'bn': 'প্রয়োগ'},
    {'value': 'higher', 'en': 'Higher Ability', 'bn': 'উচ্চতর দক্ষতা'},
  ];
}
