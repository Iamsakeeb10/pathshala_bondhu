/// Question Detail Screen
/// Displays full question details with edit/delete actions

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../shared/utils/app_colors.dart';
import '../../../../shared/widgets/custom_appbar.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/modern_alert.dart';
import '../../data/models/question_model.dart';
import '../../presentation/providers/question_bank_list_provider.dart';
import '../../utils/question_bank_translations.dart';
import '../../utils/question_type_icons.dart';

class QuestionDetailScreen extends StatefulWidget {
  final String questionId;

  const QuestionDetailScreen({super.key, required this.questionId});

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  bool _showAnswers = false;
  Question? _question;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  Future<void> _loadQuestion() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final listProvider = context.read<QuestionBankListProvider>();
      final question = await listProvider.getQuestion(
        int.parse(widget.questionId),
      );
      setState(() {
        _question = question;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBangla = Localizations.localeOf(context).languageCode == 'bn';

    String t(String key) => QuestionBankTranslations.t(key, isBangla);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: Column(
        children: [
          CustomAppBar(
            title: t('qb_question_details'),
            actions: _question != null
                ? [
                    IconAction(
                      icon: _showAnswers
                          ? Icons.visibility_off
                          : Icons.visibility,
                      tooltip: _showAnswers
                          ? t('qb_hide_answer')
                          : t('qb_show_answer'),
                      onTap: () {
                        setState(() {
                          _showAnswers = !_showAnswers;
                        });
                      },
                    ),
                    SizedBox(width: 8.w),
                    _buildMoreMenu(isDark, isBangla),
                  ]
                : null,
          ),
          Expanded(child: _buildBody(isDark, isBangla)),
        ],
      ),
    );
  }

  Widget _buildMoreMenu(bool isDark, bool isBangla) {
    String t(String key) => QuestionBankTranslations.t(key, isBangla);

    return PopupMenuButton<String>(
      onSelected: (value) => _handleMenuAction(value, context),
      icon: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isDark ? 0.15 : 0.12),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(Icons.more_vert, color: Colors.white, size: 18.sp),
      ),
      color: isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              const Icon(Icons.edit_outlined),
              SizedBox(width: 12.w),
              Text(t('qb_edit')),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'duplicate',
          child: Row(
            children: [
              const Icon(Icons.copy_outlined),
              SizedBox(width: 12.w),
              Text(isBangla ? 'ডুপ্লিকেট' : 'Duplicate'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: AppColors.error),
              SizedBox(width: 12.w),
              Text(t('qb_delete'), style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody(bool isDark, bool isBangla) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            GradientButton(
              text: isBangla ? 'আবার চেষ্টা করুন' : 'Retry',
              onPressed: _loadQuestion,
              icon: Icons.refresh,
              startColor: AppColors.primary,
              height: 48.h,
              width: 200.w,
            ),
          ],
        ),
      );
    }

    if (_question == null) {
      return Center(
        child: Text(
          isBangla ? 'প্রশ্ন পাওয়া যায়নি' : 'Question not found',
          style: TextStyle(
            fontSize: 14.sp,
            color: isDark ? Colors.white70 : AppColors.textSecondary,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question type badge and metadata
          _buildHeader(isDark, isBangla),
          SizedBox(height: 20.h),

          // Question content card
          _buildQuestionCard(isDark, isBangla),
          SizedBox(height: 20.h),

          // Answer section
          _buildAnswerSection(isDark, isBangla),

          // Explanation (if available)
          if (_question!.explanation?.isNotEmpty == true) ...[
            SizedBox(height: 20.h),
            _buildExplanationCard(isDark, isBangla),
          ],

          // Timestamps
          SizedBox(height: 24.h),
          _buildTimestamps(isDark, isBangla),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark, bool isBangla) {
    final typeColor = QuestionTypeIcons.getColor(_question!.questionType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: typeColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: typeColor.withOpacity(0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                QuestionTypeIcons.getIcon(_question!.questionType),
                size: 18.sp,
                color: typeColor,
              ),
              SizedBox(width: 8.w),
              Text(
                _question!.questionType.getDisplayName(isBangla),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: typeColor,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),

        // Metadata chips
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: [
            _MetadataChip(
              icon: Icons.school_outlined,
              label: _question!.questionClass?.name ?? '-',
              isDark: isDark,
            ),
            _MetadataChip(
              icon: Icons.book_outlined,
              label: _question!.subject?.name ?? '-',
              isDark: isDark,
            ),
            _MetadataChip(
              icon: Icons.stars_outlined,
              label: '${_question!.marks} ${isBangla ? 'নম্বর' : 'marks'}',
              isDark: isDark,
              color: AppColors.warning,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestionCard(bool isDark, bool isBangla) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
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
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  isBangla ? 'প্রশ্ন' : 'Question',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            _question!.questionText,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerSection(bool isDark, bool isBangla) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 300),
      crossFadeState: _showAnswers
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      firstChild: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.grey800 : AppColors.grey100,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.visibility_outlined,
              size: 22.sp,
              color: AppColors.grey500,
            ),
            SizedBox(width: 10.w),
            Flexible(
              child: Text(
                isBangla
                    ? 'উত্তর দেখতে চোখের আইকনে ক্লিক করুন'
                    : 'Click the eye icon to show answer',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark ? Colors.white60 : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      secondChild: _buildAnswerContent(isDark, isBangla),
    );
  }

  Widget _buildAnswerContent(bool isDark, bool isBangla) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 20.sp,
                  color: AppColors.success,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                isBangla ? 'সঠিক উত্তর' : 'Correct Answer',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildTypeSpecificAnswer(isDark, isBangla),
        ],
      ),
    );
  }

  Widget _buildTypeSpecificAnswer(bool isDark, bool isBangla) {
    switch (_question!.questionType) {
      case QuestionType.mcq:
        return _buildMCQAnswer(isDark, isBangla);
      case QuestionType.trueFalse:
        return _buildTrueFalseAnswer(isDark, isBangla);
      case QuestionType.matching:
        return _buildMatchingAnswer(isDark, isBangla);
      default:
        return Text(
          _question!.expectedAnswer ?? (isBangla ? 'উত্তর নেই' : 'No answer'),
          style: TextStyle(
            fontSize: 14.sp,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        );
    }
  }

  Widget _buildMCQAnswer(bool isDark, bool isBangla) {
    if (_question!.options == null || _question!.options!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: _question!.options!.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final label = String.fromCharCode(65 + index);

        return Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: option.isCorrect
                ? AppColors.success.withOpacity(0.15)
                : (isDark ? AppColors.grey800 : Colors.white),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: option.isCorrect
                  ? AppColors.success
                  : (isDark ? AppColors.borderDark : AppColors.border),
              width: option.isCorrect ? 2 : 1,
            ),
            boxShadow: option.isCorrect
                ? [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: option.isCorrect
                      ? AppColors.success
                      : (isDark ? AppColors.grey700 : AppColors.grey300),
                  shape: BoxShape.circle,
                  boxShadow: option.isCorrect
                      ? [
                          BoxShadow(
                            color: AppColors.success.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: option.isCorrect
                          ? Colors.white
                          : (isDark ? Colors.white70 : AppColors.textPrimary),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  option.text,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontWeight: option.isCorrect
                        ? FontWeight.w600
                        : FontWeight.normal,
                    height: 1.4,
                  ),
                ),
              ),
              if (option.isCorrect) ...[
                SizedBox(width: 8.w),
                Icon(Icons.check_circle, size: 22.sp, color: AppColors.success),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrueFalseAnswer(bool isDark, bool isBangla) {
    final isTrue = _question!.expectedAnswer?.toLowerCase() == 'true';
    final color = isTrue ? AppColors.success : AppColors.error;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isTrue ? Icons.check_circle : Icons.cancel,
              size: 24.sp,
              color: color,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            isTrue
                ? (isBangla ? 'সত্য' : 'TRUE')
                : (isBangla ? 'মিথ্যা' : 'FALSE'),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchingAnswer(bool isDark, bool isBangla) {
    // This would need the matching pairs from the question data
    return Text(
      _question!.expectedAnswer ?? '',
      style: TextStyle(
        fontSize: 14.sp,
        color: isDark ? Colors.white : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildExplanationCard(bool isDark, bool isBangla) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.info.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  size: 20.sp,
                  color: AppColors.info,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                isBangla ? 'ব্যাখ্যা' : 'Explanation',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            _question!.explanation!,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestamps(bool isDark, bool isBangla) {
    final createdAt = _question!.createdAt != null
        ? DateTime.tryParse(_question!.createdAt!)
        : null;
    final updatedAt = _question!.updatedAt != null
        ? DateTime.tryParse(_question!.updatedAt!)
        : null;

    if (createdAt == null) return const SizedBox.shrink();

    return Row(
      children: [
        Icon(Icons.access_time, size: 14.sp, color: AppColors.grey500),
        SizedBox(width: 6.w),
        Text(
          '${isBangla ? 'তৈরি' : 'Created'}: ${timeago.format(createdAt, locale: isBangla ? 'bn' : 'en')}',
          style: TextStyle(
            fontSize: 11.sp,
            color: isDark ? AppColors.grey400 : AppColors.grey600,
          ),
        ),
        if (updatedAt != null &&
            _question!.updatedAt != _question!.createdAt) ...[
          SizedBox(width: 16.w),
          Text(
            '${isBangla ? 'হালনাগাদ' : 'Updated'}: ${timeago.format(updatedAt, locale: isBangla ? 'bn' : 'en')}',
            style: TextStyle(
              fontSize: 11.sp,
              color: isDark ? AppColors.grey400 : AppColors.grey600,
            ),
          ),
        ],
      ],
    );
  }

  void _handleMenuAction(String action, BuildContext context) {
    final isBangla = Localizations.localeOf(context).languageCode == 'bn';

    switch (action) {
      case 'edit':
        context.push('/question-bank/edit/${_question!.id}');
        break;
      case 'duplicate':
        context.push('/question-bank/create', extra: {'duplicate': _question});
        break;
      case 'delete':
        _showDeleteConfirmation(context, isBangla);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, bool isBangla) {
    String t(String key) => QuestionBankTranslations.t(key, isBangla);

    ModernAlert.show(
      context: context,
      type: AlertType.warning,
      title: t('qb_delete_title'),
      message: '${t('qb_delete_confirm')}\n\n${_question!.previewText}\n\n${t('qb_delete_warning')}',
      confirmText: t('qb_delete'),
      cancelText: t('qb_cancel'),
      onConfirm: () async {
        try {
          final listProvider = context.read<QuestionBankListProvider>();
          await listProvider.deleteQuestion(_question!.id!);
          if (context.mounted) {
            context.pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(t('qb_deleted')),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(16.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${t('qb_error')}: $e'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(16.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            );
          }
        }
      },
    );
  }
}

class _MetadataChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final Color? color;

  const _MetadataChip({
    required this.icon,
    required this.label,
    required this.isDark,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color:
            color?.withOpacity(0.1) ??
            (isDark ? AppColors.grey800 : AppColors.grey100),
        borderRadius: BorderRadius.circular(16.r),
        border: color != null
            ? Border.all(color: color!.withOpacity(0.2), width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: color ?? (isDark ? AppColors.grey400 : AppColors.grey600),
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color:
                  color ?? (isDark ? Colors.white70 : AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
