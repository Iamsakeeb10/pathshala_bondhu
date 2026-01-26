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
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent types section
          if (_recentTypes.isNotEmpty) ...[
            Text(
              _t('qb_recent_types'),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textDarkSecondary
                    : AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
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
            SizedBox(height: 24.h),
            Divider(color: isDark ? AppColors.borderDark : AppColors.border),
            SizedBox(height: 16.h),
          ],

          // All types grid
          Text(
            _t('qb_step_type'),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.1,
            ),
            itemCount: QuestionType.values.length,
            itemBuilder: (context, index) {
              final type = QuestionType.values[index];
              final typeData = QuestionTypeCardData(type);
              return _QuestionTypeCard(
                type: type,
                typeData: typeData,
                isBangla: _isBangla,
                onTap: () => _selectType(type),
              );
            },
          ),
        ],
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: typeData.backgroundColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: typeData.borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(typeData.icon, size: 18.sp, color: typeData.color),
            SizedBox(width: 6.w),
            Text(
              type.getDisplayName(isBangla),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: typeData.color,
              ),
            ),
          ],
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

    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showTooltip(context),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                color: typeData.backgroundColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Icon(typeData.icon, size: 28.sp, color: typeData.color),
              ),
            ),
            SizedBox(height: 12.h),

            // Type name
            Text(
              type.getDisplayName(isBangla),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
