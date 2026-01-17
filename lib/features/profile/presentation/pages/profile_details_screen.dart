import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/providers/auth_provider.dart';
import '../../../../shared/utils/app_colors.dart';
import '../../../auth/data/models/parent_models.dart';
import '../../../auth/data/models/teacher_models.dart';
import '../../providers/profile_provider.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final profile = context.read<ProfileProvider>();

      if (auth.isParent) {
        profile.fetchProfile(ProfileType.parent);
      } else if (auth.isTeacher) {
        profile.fetchProfile(ProfileType.teacher);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Personal Information',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: () => context.push('/profile/details/edit'),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final auth = context.read<AuthProvider>();

          if (auth.isParent && provider.parentProfile != null) {
            return _buildParentProfile(provider.parentProfile!);
          } else if (auth.isTeacher && provider.teacherProfile != null) {
            return _buildTeacherProfile(provider.teacherProfile!);
          }

          return const Center(child: Text('No profile data found'));
        },
      ),
    );
  }

  Widget _buildParentProfile(ParentUser user) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        _buildAvatarSection(user.fatherName, null),
        SizedBox(height: 24.h),
        _buildSectionTitle('Personal Information'),
        _buildInfoTile('Father Name', user.fatherName),
        _buildInfoTile('Mother Name', user.motherName ?? 'N/A'),
        _buildInfoTile('Father Job', user.fatherJob ?? 'N/A'),
        _buildInfoTile('Mother Job', user.motherJob ?? 'N/A'),
        SizedBox(height: 16.h),
        _buildSectionTitle('Contact Details'),
        _buildInfoTile('Phone', user.parentPhone),
        _buildInfoTile('Address', user.address ?? 'N/A'),
        SizedBox(height: 32.h),
        _buildChangePasswordButton(),
      ],
    );
  }

  Widget _buildTeacherProfile(TeacherUserWithDetails user) {
    final teacher = user.teacher;
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        _buildAvatarSection(user.name, user.avatar),
        SizedBox(height: 24.h),
        _buildSectionTitle('Personal Information'),
        _buildInfoTile('Name', user.name),
        _buildInfoTile('Email', user.email),
        if (teacher != null) ...[
          _buildInfoTile('Department', teacher.department),
          _buildInfoTile('Specialization', teacher.specialization),
          _buildInfoTile('Bio', teacher.bio ?? 'N/A'),
        ],
        SizedBox(height: 32.h),
        _buildChangePasswordButton(),
      ],
    );
  }

  Widget _buildAvatarSection(String name, String? avatar) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50.r,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: avatar != null ? NetworkImage(avatar) : null,
            child: avatar == null
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          SizedBox(height: 12.h),
          Text(
            name,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.grey600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangePasswordButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: OutlinedButton(
        onPressed: () => context.push('/profile/details/change-password'),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          'Change Password',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
