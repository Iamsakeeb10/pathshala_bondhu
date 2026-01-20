import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/providers/auth_provider.dart';
import '../../../../shared/localization/app_localizations.dart';
import '../../../../shared/utils/app_colors.dart';
import '../../../../shared/widgets/custom_appbar.dart';
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: Column(
        children: [
          Builder(
            builder: (context) {
              final localizations = AppLocalizations.of(context)!;
              return CustomAppBar(
                title: localizations.translate('personal_information'),
                showBackButton: true, // show back button
                actions: [
                  IconAction(
                    icon: Icons.edit_rounded,
                    onTap: () => context.push('/profile/details/edit'),
                    tooltip: localizations.translate('edit'),
                  ),
                ],
              );
            },
          ),
          Expanded(
            child: Consumer<ProfileProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.translate('loading_profile'),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color:
                                Theme.of(context).textTheme.bodySmall?.color ??
                                AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.error_outline_rounded,
                              size: 48.sp,
                              color: AppColors.error,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.translate('error_loading_profile'),
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.color ??
                                  AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            provider.errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color:
                                  Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color ??
                                  AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final auth = context.read<AuthProvider>();

                if (auth.isParent && provider.parentProfile != null) {
                  return _buildParentProfile(provider.parentProfile!);
                } else if (auth.isTeacher && provider.teacherProfile != null) {
                  return _buildTeacherProfile(provider.teacherProfile!);
                }

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off_outlined,
                        size: 64.sp,
                        color: AppColors.grey400,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.translate('no_profile_data_found'),
                        style: TextStyle(
                          fontSize: 16.sp,
                          color:
                              Theme.of(context).textTheme.bodyMedium?.color ??
                              AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParentProfile(ParentUser user) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) {
              final localizations = AppLocalizations.of(context)!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatarSection(user.fatherName, null),
                  SizedBox(height: 32.h),
                  _buildSectionTitle(
                    localizations.translate('personal_information'),
                  ),
                  SizedBox(height: 12.h),
                  _buildInfoCard([
                    _InfoItem(
                      icon: Icons.person_outline,
                      label: localizations.translate('father_name'),
                      value: user.fatherName,
                    ),
                    _InfoItem(
                      icon: Icons.person_outline,
                      label: localizations.translate('mother_name'),
                      value: user.motherName ?? 'N/A',
                    ),
                    _InfoItem(
                      icon: Icons.work_outline,
                      label: localizations.translate('father_job'),
                      value: user.fatherJob ?? 'N/A',
                    ),
                    _InfoItem(
                      icon: Icons.work_outline,
                      label: localizations.translate('mother_job'),
                      value: user.motherJob ?? 'N/A',
                    ),
                  ]),
                  SizedBox(height: 24.h),
                  _buildSectionTitle(
                    localizations.translate('contact_details'),
                  ),
                  SizedBox(height: 12.h),
                  _buildInfoCard([
                    _InfoItem(
                      icon: Icons.phone_outlined,
                      label: localizations.translate('phone'),
                      value: user.parentPhone,
                    ),
                    _InfoItem(
                      icon: Icons.location_on_outlined,
                      label: localizations.translate('address'),
                      value: user.address ?? 'N/A',
                    ),
                  ]),
                  SizedBox(height: 32.h),
                ],
              );
            },
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildTeacherProfile(TeacherUserWithDetails user) {
    final teacher = user.teacher;
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) {
              final localizations = AppLocalizations.of(context)!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatarSection(user.name, user.avatar),
                  SizedBox(height: 32.h),
                  _buildSectionTitle(
                    localizations.translate('personal_information'),
                  ),
                  SizedBox(height: 12.h),
                  _buildInfoCard([
                    _InfoItem(
                      icon: Icons.person_outline,
                      label: localizations.translate('name'),
                      value: user.name,
                    ),
                    _InfoItem(
                      icon: Icons.email_outlined,
                      label: localizations.translate('email'),
                      value: user.email,
                    ),
                    if (teacher != null) ...[
                      _InfoItem(
                        icon: Icons.school_outlined,
                        label: localizations.translate('department'),
                        value: teacher.department,
                      ),
                      _InfoItem(
                        icon: Icons.stars_outlined,
                        label: localizations.translate('specialization'),
                        value: teacher.specialization,
                      ),
                      _InfoItem(
                        icon: Icons.description_outlined,
                        label: localizations.translate('bio'),
                        value: teacher.bio ?? 'N/A',
                      ),
                    ],
                  ]),
                  SizedBox(height: 32.h),
                  _buildChangePasswordButton(context),
                ],
              );
            },
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(String name, String? avatar) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.3),
                      AppColors.primary.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).cardColor,
                  ),
                  child: CircleAvatar(
                    radius: 60.r,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: avatar != null
                        ? NetworkImage(avatar)
                        : null,
                    child: avatar == null
                        ? Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: TextStyle(
                              fontSize: 44.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.badge_outlined,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            name,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color:
                  Theme.of(context).textTheme.titleLarge?.color ??
                  AppColors.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color:
                Theme.of(context).textTheme.titleLarge?.color ??
                AppColors.textPrimary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<_InfoItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : AppColors.grey200.withOpacity(0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              if (index > 0)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.borderDark
                      : AppColors.grey200.withOpacity(0.5),
                ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withOpacity(0.15),
                            AppColors.primary.withOpacity(0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        item.icon,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color:
                                  Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color ??
                                  AppColors.grey500,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            item.value,
                            style: TextStyle(
                              fontSize: 15.sp,
                              color:
                                  Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.color ??
                                  AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChangePasswordButton(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      height: 52.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/profile/details/change-password'),
          borderRadius: BorderRadius.circular(14.r),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_reset_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  localizations.translate('change_password'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;

  _InfoItem({required this.icon, required this.label, required this.value});
}
