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
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.option.text);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
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
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect = widget.option.isCorrect;
    final borderColor = isCorrect
        ? AppColors.success
        : _isFocused
        ? AppColors.primary
        : (widget.isDark
              ? AppColors.borderDark.withOpacity(0.3)
              : AppColors.grey300.withOpacity(0.5));
    final bgColor = isCorrect
        ? AppColors.success.withOpacity(0.08)
        : (widget.isDark ? AppColors.surfaceDark : Colors.white);

    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: widget.onCorrectChanged,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: EdgeInsets.all(0),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: borderColor,
                width: isCorrect || _isFocused ? 2 : 1,
              ),
              boxShadow: isCorrect
                  ? [
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.10),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selection indicator (vertical, left)
                Padding(
                  padding: EdgeInsets.only(left: 10.w, top: 18.h, right: 0),
                  child: GestureDetector(
                    onTap: widget.onCorrectChanged,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCorrect
                            ? AppColors.success
                            : Colors.transparent,
                        border: Border.all(
                          color: isCorrect
                              ? AppColors.success
                              : (widget.isDark
                                    ? AppColors.grey500
                                    : AppColors.grey400),
                          width: isCorrect ? 0 : 2,
                        ),
                      ),
                      child: isCorrect
                          ? Icon(
                              Icons.check_rounded,
                              size: 16.sp,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                // Main content
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 12.h,
                      horizontal: 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 28.w,
                              height: 28.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7.r),
                                color: isCorrect
                                    ? AppColors.success
                                    : (widget.isDark
                                          ? AppColors.grey700
                                          : AppColors.grey200),
                              ),
                              child: Center(
                                child: Text(
                                  widget.label,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: isCorrect
                                        ? Colors.white
                                        : (widget.isDark
                                              ? Colors.white
                                              : AppColors.textPrimary),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            if (isCorrect)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  widget.isBangla ? 'সঠিক' : 'Correct',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        // Option text field
                        TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            hintText: widget.isBangla
                                ? 'অপশন ${widget.label} লিখুন'
                                : 'Enter option ${widget.label}',
                            filled: true,
                            fillColor: widget.isDark
                                ? AppColors.grey800
                                : AppColors.grey100,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 12.h,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(
                                color: _isFocused
                                    ? AppColors.primary.withOpacity(0.5)
                                    : (widget.isDark
                                          ? AppColors.borderDark.withOpacity(
                                              0.15,
                                            )
                                          : AppColors.grey300.withOpacity(0.5)),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            hintStyle: TextStyle(
                              fontSize: 13.sp,
                              color: widget.isDark
                                  ? AppColors.textDarkSecondary.withOpacity(0.5)
                                  : AppColors.textSecondary.withOpacity(0.5),
                            ),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: widget.isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                          onChanged: widget.onTextChanged,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
