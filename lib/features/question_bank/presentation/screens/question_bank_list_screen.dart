/// Question Bank List Screen
/// Main screen showing all questions with filtering, search, and CRUD operations

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../shared/utils/app_colors.dart';
import '../../data/models/question_model.dart';
import '../../data/services/question_bank_api_service.dart';
import '../../presentation/providers/question_bank_auth_provider.dart';
import '../../presentation/providers/question_bank_list_provider.dart';
import '../../utils/question_bank_translations.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/question_card.dart';
import 'question_bank_auth_modal.dart';

class QuestionBankListScreen extends StatefulWidget {
  const QuestionBankListScreen({super.key});

  @override
  State<QuestionBankListScreen> createState() => _QuestionBankListScreenState();
}

class _QuestionBankListScreenState extends State<QuestionBankListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  bool _isSearchExpanded = false;

  bool get _isBangla {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'bn';
  }

  String _t(String key) => QuestionBankTranslations.t(key, _isBangla);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndLoadData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _checkAuthAndLoadData() async {
    final authProvider = context.read<QuestionBankAuthProvider>();

    // Check existing session
    await authProvider.checkSession();

    if (!authProvider.isAuthenticated) {
      // Show auth modal
      if (!mounted) return;
      final success = await QuestionBankAuthModal.show(context);
      if (!success) {
        if (!mounted) return;
        context.pop();
        return;
      }
    }

    // Load questions
    if (!mounted) return;
    final listProvider = context.read<QuestionBankListProvider>();
    await listProvider.fetchMetadata();
    await listProvider.fetchQuestions(refresh: true);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final listProvider = context.read<QuestionBankListProvider>();
      if (listProvider.hasMore && !listProvider.isMoreLoading) {
        _loadMore();
      }
    }
  }

  Future<void> _loadMore() async {
    try {
      await context.read<QuestionBankListProvider>().fetchQuestions();
    } on SessionExpiredException {
      _handleSessionExpiry();
    }
  }

  Future<void> _refresh() async {
    try {
      await context.read<QuestionBankListProvider>().fetchQuestions(
        refresh: true,
      );
    } on SessionExpiredException {
      _handleSessionExpiry();
    }
  }

  void _handleSessionExpiry() async {
    final authProvider = context.read<QuestionBankAuthProvider>();
    authProvider.handleSessionExpiry();

    // Show auth modal again
    final success = await QuestionBankAuthModal.show(context);
    if (success) {
      _refresh();
    } else {
      if (mounted) context.pop();
    }
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      context.read<QuestionBankListProvider>().updateSearchQuery(query);
    });
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  Future<void> _deleteQuestion(Question question) async {
    final listProvider = context.read<QuestionBankListProvider>();

    final confirmed = await _showDeleteConfirmation(question);
    if (!confirmed) return;

    try {
      final success = await listProvider.deleteQuestion(question.id!);
      if (success && mounted) {
        _showUndoSnackBar();
      }
    } on SessionExpiredException {
      _handleSessionExpiry();
    }
  }

  Future<bool> _showDeleteConfirmation(Question question) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _DeleteConfirmationSheet(question: question, isBangla: _isBangla),
    );
    return result ?? false;
  }

  void _showUndoSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_t('qb_deleted')),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: _t('qb_undo'),
          onPressed: () async {
            await context.read<QuestionBankListProvider>().undoDelete();
          },
        ),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );

    // Clear undo state after snackbar duration
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        context.read<QuestionBankListProvider>().clearUndoState();
      }
    });
  }

  void _showLogoutConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_t('qb_logout_title')),
        content: Text(_t('qb_logout_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(_t('qb_cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(_t('qb_logout')),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      await context.read<QuestionBankAuthProvider>().logout();
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: _buildAppBar(isDark),
      body: Consumer<QuestionBankListProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.questions.isEmpty) {
            return _buildLoadingState();
          }

          if (provider.errorMessage != null && provider.questions.isEmpty) {
            return _buildErrorState(provider.errorMessage!);
          }

          if (provider.isEmpty) {
            return _buildEmptyState();
          }

          return _buildQuestionList(provider);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/question-bank/create'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        icon: const Icon(Icons.add),
        label: Text(_t('qb_create')),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    final listProvider = context.watch<QuestionBankListProvider>();

    return AppBar(
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      surfaceTintColor: Colors.transparent,
      title: _isSearchExpanded
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: _t('qb_search'),
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: isDark
                      ? AppColors.textDarkSecondary
                      : AppColors.textSecondary,
                ),
              ),
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              onChanged: _onSearchChanged,
            )
          : Text(
              _t('qb_title'),
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
      leading: IconButton(
        icon: Icon(
          _isSearchExpanded ? Icons.close : Icons.arrow_back,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
        onPressed: () {
          if (_isSearchExpanded) {
            setState(() {
              _isSearchExpanded = false;
              _searchController.clear();
            });
            listProvider.updateSearchQuery('');
          } else {
            context.pop();
          }
        },
      ),
      actions: [
        if (!_isSearchExpanded) ...[
          IconButton(
            icon: Icon(
              Icons.search,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            onPressed: () => setState(() => _isSearchExpanded = true),
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
                onPressed: _showFilters,
              ),
              if (listProvider.hasActiveFilters)
                Positioned(
                  right: 8.w,
                  top: 8.h,
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutConfirmation();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: AppColors.error),
                    SizedBox(width: 8.w),
                    Text(_t('qb_logout')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 5,
      itemBuilder: (context, index) => _buildShimmerCard(),
    );
  }

  Widget _buildShimmerCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Shimmer.fromColors(
        baseColor: isDark ? AppColors.grey700 : AppColors.grey200,
        highlightColor: isDark ? AppColors.grey600 : AppColors.grey100,
        child: Container(
          height: 120.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              error,
              style: TextStyle(
                fontSize: 16.sp,
                color: isDark
                    ? AppColors.textDarkSecondary
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: Text(_t('qb_try_again')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📚', style: TextStyle(fontSize: 64.sp)),
            SizedBox(height: 16.h),
            Text(
              _t('qb_empty'),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              _t('qb_empty_subtitle'),
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark
                    ? AppColors.textDarkSecondary
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: () => context.push('/question-bank/create'),
              icon: const Icon(Icons.add),
              label: Text(_t('qb_create')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionList(QuestionBankListProvider provider) {
    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(16.w),
        itemCount: provider.questions.length + (provider.isMoreLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == provider.questions.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          final question = provider.questions[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: QuestionCard(
              question: question,
              onTap: () => context.push('/question-bank/detail/${question.id}'),
              onEdit: () => context.push('/question-bank/edit/${question.id}'),
              onDelete: () => _deleteQuestion(question),
            ),
          );
        },
      ),
    );
  }
}

class _DeleteConfirmationSheet extends StatelessWidget {
  final Question question;
  final bool isBangla;

  const _DeleteConfirmationSheet({
    required this.question,
    required this.isBangla,
  });

  String _t(String key) => QuestionBankTranslations.t(key, isBangla);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Warning icon
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 32.sp,
              color: AppColors.error,
            ),
          ),
          SizedBox(height: 16.h),

          // Title
          Text(
            _t('qb_delete_title'),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),

          // Description
          Text(
            _t('qb_delete_confirm'),
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark
                  ? AppColors.textDarkSecondary
                  : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),

          // Question preview
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.grey800 : AppColors.grey100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              question.previewText,
              style: TextStyle(
                fontSize: 13.sp,
                fontStyle: FontStyle.italic,
                color: isDark
                    ? AppColors.textDarkSecondary
                    : AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 12.h),

          // Warning
          Text(
            _t('qb_delete_warning'),
            style: TextStyle(fontSize: 12.sp, color: AppColors.error),
          ),
          SizedBox(height: 24.h),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(_t('qb_cancel')),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(_t('qb_delete')),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
