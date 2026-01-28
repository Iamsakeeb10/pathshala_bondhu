/// Question Type Selector Step
/// First step in the form wizard - select question type

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/utils/app_colors.dart';
import '../../../data/models/question_model.dart';
import '../../../data/services/question_bank_draft_service.dart';
import '../../../presentation/providers/question_bank_form_provider.dart';
import '../../../utils/question_bank_translations.dart';
import '../../../utils/question_type_icons.dart';

class QuestionTypeSelector extends StatefulWidget {
  const QuestionTypeSelector({super.key});

  @override
  State<QuestionTypeSelector> createState() => _QuestionTypeSelectorState();
}

class _QuestionTypeSelectorState extends State<QuestionTypeSelector> {
  List<QuestionType> _recentTypes = [];

  bool get _isBangla {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'bn';
  }

  String _t(String key) => QuestionBankTranslations.t(key, _isBangla);

  @override
  void initState() {
    super.initState();
    _loadRecentTypes();
  }

  Future<void> _loadRecentTypes() async {
    final recentTypes = await QuestionBankDraftService.instance
        .getRecentTypes();
    if (mounted) {
      setState(() {
        _recentTypes = recentTypes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recent types section
              if (_recentTypes.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 18.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      _t('qb_recent_types'),
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: _recentTypes.map((type) {
                    final typeData = QuestionTypeCardData(type);
                    return _RecentTypeChip(
                      type: type,
                      typeData: typeData,
                      isBangla: _isBangla,
                      onTap: () => _selectType(type),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20.h),
                Divider(
                  color: isDark ? AppColors.borderDark : AppColors.grey200,
                ),
                SizedBox(height: 16.h),
              ],

              // All types grid
              Row(
                children: [
                  Icon(
                    Icons.dashboard_customize_rounded,
                    size: 18.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _t('qb_step_type'),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),

              Column(
                children: QuestionType.values.map((type) {
                  final typeData = QuestionTypeCardData(type);
                  return Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: _QuestionTypeCard(
                      type: type,
                      typeData: typeData,
                      isBangla: _isBangla,
                      onTap: () => _selectType(type),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  void _selectType(QuestionType type) {
    context.read<QuestionBankFormProvider>().setQuestionType(type);
  }
}

class _RecentTypeChip extends StatelessWidget {
  final QuestionType type;
  final QuestionTypeCardData typeData;
  final bool isBangla;
  final VoidCallback onTap;

  const _RecentTypeChip({
    required this.type,
    required this.typeData,
    required this.isBangla,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                typeData.color.withOpacity(0.15),
                typeData.color.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: typeData.color.withOpacity(0.3),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: typeData.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(typeData.icon, size: 13.sp, color: typeData.color),
              ),
              SizedBox(width: 5.w),
              Text(
                type.getDisplayName(isBangla),
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : typeData.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionTypeCard extends StatelessWidget {
  final QuestionType type;
  final QuestionTypeCardData typeData;
  final bool isBangla;
  final VoidCallback onTap;

  const _QuestionTypeCard({
    required this.type,
    required this.typeData,
    required this.isBangla,
    required this.onTap,
  });

  String _getDescription() {
    final key = 'qb_type_${type.apiValue}_desc';
    return QuestionBankTranslations.t(key, isBangla);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isDark
                ? AppColors.borderDark.withOpacity(0.3)
                : AppColors.grey300.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Simple icon
            Icon(typeData.icon, size: 24.sp, color: typeData.color),
            SizedBox(width: 12.w),

            // Type name
            Expanded(
              child: Text(
                type.getDisplayName(isBangla),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),

            // Arrow
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.sp,
              color: isDark
                  ? AppColors.textDarkSecondary
                  : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showTooltip(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        title: Row(
          children: [
            Icon(typeData.icon, color: typeData.color),
            SizedBox(width: 8.w),
            Text(type.getDisplayName(isBangla)),
          ],
        ),
        content: Text(_getDescription()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
