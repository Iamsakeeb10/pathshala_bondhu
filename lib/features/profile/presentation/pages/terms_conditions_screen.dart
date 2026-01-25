import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../shared/localization/app_localizations.dart';
import '../../../../shared/utils/app_colors.dart';
import '../../../../shared/widgets/custom_appbar.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: loc.translate('terms_conditions_title')),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                AppColors.primary.withOpacity(0.3),
                                AppColors.accent.withOpacity(0.2),
                              ]
                            : [
                                AppColors.primary.withOpacity(0.1),
                                AppColors.accent.withOpacity(0.05),
                              ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceDark
                                : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.description_rounded,
                            size: 48.sp,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          loc.translate('terms_conditions_title'),
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.update_rounded,
                              size: 16.sp,
                              color: isDark
                                  ? AppColors.textDarkSecondary
                                  : AppColors.textSecondary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${loc.translate('last_updated')}: 25 January 2026',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Content
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Introduction
                        _buildIntroCard(context, loc),
                        SizedBox(height: 20.h),

                        // Sections
                        _buildSection(
                          context,
                          Icons.check_circle_outline_rounded,
                          loc.translate('acceptance_terms'),
                          loc.translate('acceptance_terms_desc'),
                        ),
                        SizedBox(height: 16.h),

                        _buildSection(
                          context,
                          Icons.person_outline_rounded,
                          loc.translate('user_responsibilities'),
                          loc.translate('user_responsibilities_desc'),
                        ),
                        SizedBox(height: 16.h),

                        _buildSection(
                          context,
                          Icons.school_outlined,
                          loc.translate('service_description'),
                          loc.translate('service_description_desc'),
                        ),
                        SizedBox(height: 16.h),

                        _buildSection(
                          context,
                          Icons.copyright_rounded,
                          loc.translate('intellectual_property'),
                          loc.translate('intellectual_property_desc'),
                        ),
                        SizedBox(height: 16.h),

                        _buildSection(
                          context,
                          Icons.warning_amber_rounded,
                          loc.translate('limitation_liability'),
                          loc.translate('limitation_liability_desc'),
                        ),
                        SizedBox(height: 16.h),

                        _buildSection(
                          context,
                          Icons.block_rounded,
                          loc.translate('termination'),
                          loc.translate('termination_desc'),
                        ),
                        SizedBox(height: 16.h),

                        _buildSection(
                          context,
                          Icons.gavel_rounded,
                          loc.translate('governing_law'),
                          loc.translate('governing_law_desc'),
                        ),
                        SizedBox(height: 16.h),

                        _buildSection(
                          context,
                          Icons.contact_support_rounded,
                          loc.translate('contact_for_terms'),
                          loc.translate('contact_for_terms_desc'),
                        ),

                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCard(BuildContext context, AppLocalizations loc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppColors.warning.withOpacity(0.2),
                    AppColors.warning.withOpacity(0.1),
                  ]
                : [
                    AppColors.warning.withOpacity(0.1),
                    AppColors.warning.withOpacity(0.05),
                  ],
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: AppColors.warning,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                loc.translate('terms_intro'),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.only(left: 44.w),
              child: Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: isDark
                      ? AppColors.textDarkSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
