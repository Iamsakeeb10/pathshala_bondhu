import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../shared/utils/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/person_card.dart';
import '../data/models/teacher_model.dart';
import '../provider/teachers_provider.dart';

/// Screen displaying list of all teachers
/// 
/// Shared between Parent and Teacher roles
class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch teachers on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TeachersProvider>();
      if (provider.teachers.isEmpty && !provider.isLoading) {
        provider.fetchTeachers(refresh: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Teachers'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<TeachersProvider>(
        builder: (context, provider, child) {
          // Loading state
          if (provider.isLoading && provider.teachers.isEmpty) {
            return Padding(
              padding: EdgeInsets.all(16.w),
              child: LoadingShimmer.list(itemCount: 5, itemHeight: 100),
            );
          }

          // Error state
          if (provider.errorMessage != null && provider.teachers.isEmpty) {
            return ErrorState(
              message: provider.errorMessage!,
              onRetry: provider.retry,
            );
          }

          // Empty state
          if (provider.isEmpty) {
            return const EmptyState(
              icon: Icons.school_outlined,
              message: 'No teachers found',
              subMessage: 'Teachers list is empty.',
            );
          }

          // Data state
          return RefreshIndicator(
            onRefresh: () => provider.fetchTeachers(refresh: true),
            color: AppColors.primary,
            child: _buildTeachersList(provider),
          );
        },
      ),
    );
  }

  Widget _buildTeachersList(TeachersProvider provider) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Load more when reaching near the end
        if (notification is ScrollEndNotification) {
          final metrics = notification.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent - 200) {
            provider.loadMore();
          }
        }
        return false;
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: provider.teachers.length + (provider.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Show loading indicator at the end
          if (index == provider.teachers.length) {
            return Padding(
              padding: EdgeInsets.all(16.w),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final teacher = provider.teachers[index];
          return _buildTeacherCard(teacher);
        },
      ),
    );
  }

  Widget _buildTeacherCard(TeacherListModel teacher) {
    // Build chips from teacher details
    final chips = <PersonCardChip>[];

    if (teacher.teacher?.department != null &&
        teacher.teacher!.department!.isNotEmpty) {
      chips.add(PersonCardChip(
        icon: Icons.business_outlined,
        label: teacher.teacher!.department!,
      ));
    }

    if (teacher.teacher?.specialization != null &&
        teacher.teacher!.specialization!.isNotEmpty) {
      chips.add(PersonCardChip(
        icon: Icons.star_outline,
        label: teacher.teacher!.specialization!,
      ));
    }

    if (teacher.school != null && teacher.school!.name.isNotEmpty) {
      chips.add(PersonCardChip(
        icon: Icons.school_outlined,
        label: teacher.school!.name,
      ));
    }

    return PersonCard(
      title: teacher.name,
      subtitle: teacher.teacher?.department,
      chips: chips,
      avatarUrl: teacher.avatar, // Will need full URL handling if relative
      accentColor: AppColors.teacher,
      onTap: () {
        // For now, just show a snackbar - can add detail screen later
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${teacher.name}'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );
  }
}
