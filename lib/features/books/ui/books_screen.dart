import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../shared/utils/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../students/provider/student_provider.dart';
import '../data/models/books_models.dart';
import '../provider/books_provider.dart';

/// Books screen - displays book list for students in Bangladesh style
class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BooksProvider>().fetchBookList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          CustomAppBar(title: 'Books', showBackButton: true),
          Expanded(
            child: Consumer<BooksProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return _buildLoadingState();
                }

                if (provider.errorMessage != null) {
                  return ErrorState(
                    message: provider.errorMessage!,
                    onRetry: provider.retry,
                  );
                }

                if (provider.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      await provider.fetchBookList();
                    },
                    color: AppColors.primary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: const EmptyState(
                          icon: Icons.book_outlined,
                          message: 'No books found',
                          subMessage: 'There are no books assigned yet.',
                        ),
                      ),
                    ),
                  );
                }

                if (provider.hasData) {
                  return _buildBookList(provider.data!);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: LoadingShimmer.list(itemCount: 5, itemHeight: 120),
    );
  }

  Widget _buildBookList(BookListResponse data) {
    final studentProvider = context.watch<StudentProvider>();
    final selectedStudent = studentProvider.selectedStudent;

    List<ChildBookList> booksToShow = data.childrenBookLists;
    if (selectedStudent != null && studentProvider.hasMultipleStudents) {
      booksToShow = data.childrenBookLists
          .where((b) => b.studentId == selectedStudent.studentId)
          .toList();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<BooksProvider>().fetchBookList();
      },
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - School Info
            _buildSchoolHeader(data),
            SizedBox(height: 20.h),

            // Books by student
            ...booksToShow.map((child) => _buildStudentBookList(child)),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolHeader(BookListResponse data) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.school, size: 40.sp, color: AppColors.primary),
          SizedBox(height: 8.h),
          Text(
            data.schoolName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color:
                  Theme.of(context).textTheme.titleLarge?.color ??
                  AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Parent: ${data.parentName}',
            style: TextStyle(
              fontSize: 14.sp,
              color:
                  Theme.of(context).textTheme.bodyMedium?.color ??
                  AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentBookList(ChildBookList child) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.person, color: Colors.white, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child.studentName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${child.classInfo} • Roll: ${child.studentId}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Table Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.15),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 40.w,
                  child: Text(
                    'ক্রমিক',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'বইয়ের নাম ও বিবরণ',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Book Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: child.books.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              thickness: 1,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.shade200,
            ),
            itemBuilder: (context, index) {
              final book = child.books[index];
              return _buildBookRow(book, index + 1);
            },
          ),

          // Footer note
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.08),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12.r),
                bottomRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16.sp, color: AppColors.primary),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Total Books: ${child.books.length}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookRow(BookInfo book, int serialNo) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Serial Number
          SizedBox(
            width: 40.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                '${serialNo}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // Book Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book Name with Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        book.bookName,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color:
                              Theme.of(context).textTheme.titleMedium?.color ??
                              AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ),
                    if (book.mandatory)
                      Container(
                        margin: EdgeInsets.only(left: 8.w),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'আবশ্যক',
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 6.h),

                // Subject
                _buildDetailRow('বিষয়', book.subject),
                _buildDetailRow('লেখক', book.author),
                _buildDetailRow('প্রকাশক', book.publisher),
                _buildDetailRow('সংস্করণ', book.edition),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 3.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                color:
                    Theme.of(context).textTheme.bodySmall?.color ??
                    AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
