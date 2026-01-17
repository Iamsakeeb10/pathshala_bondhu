import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../shared/utils/app_colors.dart';
import '../../data/models/teacher_diary_model.dart';
import '../../provider/teacher_diary_provider.dart';

class TeacherDiaryDetailsScreen extends StatefulWidget {
  final int diaryId;

  const TeacherDiaryDetailsScreen({super.key, required this.diaryId});

  @override
  State<TeacherDiaryDetailsScreen> createState() => _TeacherDiaryDetailsScreenState();
}

class _TeacherDiaryDetailsScreenState extends State<TeacherDiaryDetailsScreen> {
  TeacherDiary? _diary;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final diary = await context.read<TeacherDiaryProvider>().getDiary(widget.diaryId);

    if (mounted) {
      if (diary != null) {
        setState(() {
          _diary = diary;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load diary details';
          _isLoading = false;
        });
      }
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Diary'),
        content: const Text('Are you sure you want to delete this diary?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await context.read<TeacherDiaryProvider>().deleteDiary(_diary!.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Diary deleted successfully')),
                  );
                  context.pop(); // Go back to list
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Diary Details',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_diary != null)
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primary),
              onPressed: () {
                context.push('/teacher/diaries/edit/${_diary!.id}', extra: _diary);
              },
            ),
          if (_diary != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Text(_error!, style: TextStyle(color: Colors.red, fontSize: 16.sp)),
             SizedBox(height: 16.h),
             ElevatedButton(onPressed: _fetchDetails, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_diary == null) {
      return const Center(child: Text('Diary not found'));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 24.h),
          _buildSection('Description', _diary!.description ?? 'No description provided.'),
          SizedBox(height: 16.h),
          _buildInfoGrid(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    bool isPublished = _diary!.status.toLowerCase() == 'published';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _diary!.title,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isPublished ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: isPublished ? Colors.green : Colors.orange),
              ),
              child: Text(
                _diary!.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: isPublished ? Colors.green : Colors.orange,
                ),
              ),
            ),
            SizedBox(width: 12.w),
             Icon(Icons.calendar_today, size: 16.sp, color: AppColors.grey500),
             SizedBox(width: 4.w),
             Text(
               _formatDate(_diary!.diaryDate),
               style: TextStyle(fontSize: 14.sp, color: AppColors.grey600),
             ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          content,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.grey700,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGrid() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          _buildInfoRow('Class', _diary!.diaryClass?.name ?? 'N/A'),
          Divider(height: 24.h),
          _buildInfoRow('Subject', _diary!.subject?.name ?? 'N/A'),
          Divider(height: 24.h),
          _buildInfoRow('Session', _diary!.academicSession?.title ?? 'N/A'),
          Divider(height: 24.h),
          _buildInfoRow('Submission Date', _formatDate(_diary!.submissionDate)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
           label,
           style: TextStyle(fontSize: 14.sp, color: AppColors.grey600),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
