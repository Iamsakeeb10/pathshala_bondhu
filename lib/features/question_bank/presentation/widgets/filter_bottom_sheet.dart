/// Filter Bottom Sheet Widget
/// Allows filtering questions by class, subject, type, and marks

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../shared/utils/app_colors.dart';
import '../../data/models/filter_state_model.dart';
import '../../data/models/question_model.dart';
import '../../presentation/providers/question_bank_list_provider.dart';
import '../../utils/question_bank_translations.dart';
import '../../utils/question_type_icons.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late QuestionFilterState _localFilterState;
  late RangeValues _marksRange;

  bool get _isBangla {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'bn';
  }

  String _t(String key) => QuestionBankTranslations.t(key, _isBangla);

  @override
  void initState() {
    super.initState();
    final provider = context.read<QuestionBankListProvider>();
    _localFilterState = provider.filterState;
    _marksRange = RangeValues(
      _localFilterState.minMarks,
      _localFilterState.maxMarks,
    );
  }

  void _applyFilters() {
    final provider = context.read<QuestionBankListProvider>();
    provider.updateFilters(
      _localFilterState.copyWith(
        minMarks: _marksRange.start,
        maxMarks: _marksRange.end,
      ),
    );
    Navigator.of(context).pop();
  }

  void _resetFilters() {
    setState(() {
      _localFilterState = const QuestionFilterState();
      _marksRange = const RangeValues(0.5, 20.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<QuestionBankListProvider>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  _t('qb_filter'),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _resetFilters,
                  child: Text(_t('qb_reset')),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Filter content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Class filter
                  _buildSectionTitle(_t('qb_filter_class')),
                  SizedBox(height: 8.h),
                  _buildClassChips(provider.classes, isDark),
                  SizedBox(height: 24.h),

                  // Subject filter
                  _buildSectionTitle(_t('qb_filter_subject')),
                  SizedBox(height: 8.h),
                  _buildSubjectChips(provider.subjects, isDark),
                  SizedBox(height: 24.h),

                  // Type filter
                  _buildSectionTitle(_t('qb_filter_type')),
                  SizedBox(height: 8.h),
                  _buildTypeChips(isDark),
                  SizedBox(height: 24.h),

                  // Marks range
                  _buildSectionTitle(_t('qb_filter_marks')),
                  SizedBox(height: 8.h),
                  _buildMarksRangeSlider(isDark),
                ],
              ),
            ),
          ),

          // Apply button
          SafeArea(
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    _t('qb_apply'),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      title,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textDarkSecondary : AppColors.textSecondary,
      ),
    );
  }

  Widget _buildClassChips(List<QuestionClass> classes, bool isDark) {
    if (classes.isEmpty) {
      return Text(
        'Loading...',
        style: TextStyle(
          fontSize: 13.sp,
          color: isDark ? AppColors.textDarkSecondary : AppColors.textSecondary,
        ),
      );
    }

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        _buildFilterChip(
          label: _t('qb_all'),
          isSelected: _localFilterState.selectedClassIds.isEmpty,
          onTap: () {
            setState(() {
              _localFilterState = _localFilterState.copyWith(
                selectedClassIds: [],
              );
            });
          },
          isDark: isDark,
        ),
        ...classes.map(
          (c) => _buildFilterChip(
            label: c.name,
            isSelected: _localFilterState.selectedClassIds.contains(c.id),
            onTap: () {
              setState(() {
                _localFilterState = _localFilterState.toggleClass(c.id);
              });
            },
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectChips(List<QuestionSubject> subjects, bool isDark) {
    if (subjects.isEmpty) {
      return Text(
        'Loading...',
        style: TextStyle(
          fontSize: 13.sp,
          color: isDark ? AppColors.textDarkSecondary : AppColors.textSecondary,
        ),
      );
    }

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        _buildFilterChip(
          label: _t('qb_all'),
          isSelected: _localFilterState.selectedSubjectIds.isEmpty,
          onTap: () {
            setState(() {
              _localFilterState = _localFilterState.copyWith(
                selectedSubjectIds: [],
              );
            });
          },
          isDark: isDark,
        ),
        ...subjects.map(
          (s) => _buildFilterChip(
            label: s.name,
            isSelected: _localFilterState.selectedSubjectIds.contains(s.id),
            onTap: () {
              setState(() {
                _localFilterState = _localFilterState.toggleSubject(s.id);
              });
            },
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeChips(bool isDark) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        _buildFilterChip(
          label: _t('qb_all'),
          isSelected: _localFilterState.selectedTypes.isEmpty,
          onTap: () {
            setState(() {
              _localFilterState = _localFilterState.copyWith(selectedTypes: []);
            });
          },
          isDark: isDark,
        ),
        ...QuestionType.values.map((type) {
          final typeData = QuestionTypeCardData(type);
          return _buildFilterChip(
            label: type.getDisplayName(_isBangla),
            isSelected: _localFilterState.selectedTypes.contains(type),
            color: typeData.color,
            onTap: () {
              setState(() {
                _localFilterState = _localFilterState.toggleType(type);
              });
            },
            isDark: isDark,
          );
        }),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    Color? color,
  }) {
    final selectedColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withOpacity(0.15)
              : (isDark ? AppColors.grey700 : AppColors.grey100),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? selectedColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? selectedColor
                : (isDark
                      ? AppColors.textDarkSecondary
                      : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildMarksRangeSlider(bool isDark) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_marksRange.start.toStringAsFixed(1)}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            Text(
              '${_marksRange.end.toStringAsFixed(1)}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        RangeSlider(
          values: _marksRange,
          min: 0.5,
          max: 20.0,
          divisions: 39,
          activeColor: AppColors.primary,
          inactiveColor: isDark ? AppColors.grey600 : AppColors.grey300,
          labels: RangeLabels(
            _marksRange.start.toStringAsFixed(1),
            _marksRange.end.toStringAsFixed(1),
          ),
          onChanged: (values) {
            setState(() {
              _marksRange = values;
            });
          },
        ),
      ],
    );
  }
}
