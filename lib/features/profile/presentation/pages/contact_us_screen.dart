import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/localization/app_localizations.dart';
import '../../../../shared/utils/app_colors.dart';
import '../../../../shared/widgets/custom_appbar.dart';
import '../../../../shared/widgets/modern_alert.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: loc.translate('contact_us')),
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
                            Icons.contact_support_rounded,
                            size: 48.sp,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          loc.translate('get_in_touch'),
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          loc.translate('contact_us_subtitle'),
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Contact Information Cards
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        // Email Section
                        _buildSectionTitle(
                          context,
                          Icons.email_rounded,
                          loc.translate('email_address'),
                        ),
                        SizedBox(height: 12.h),
                        _ContactCard(
                          icon: Icons.support_agent_rounded,
                          title: loc.translate('support_email'),
                          value: 'azijulhoque076@gmail.com',
                          onCopy: () => _copyToClipboard(
                            context,
                            'azijulhoque076@gmail.com',
                            loc.translate('copied_to_clipboard'),
                          ),
                          onTap: () => _launchEmail('azijulhoque076@gmail.com'),
                          actionIcon: Icons.email_outlined,
                          actionLabel: loc.translate('send_email'),
                        ),
                        SizedBox(height: 12.h),
                        _ContactCard(
                          icon: Icons.help_outline_rounded,
                          title: loc.translate('general_inquiries'),
                          value: 'shakibshovon.10@gmail.com',
                          onCopy: () => _copyToClipboard(
                            context,
                            'shakibshovon.10@gmail.com',
                            loc.translate('copied_to_clipboard'),
                          ),
                          onTap: () =>
                              _launchEmail('shakibshovon.10@gmail.com'),
                          actionIcon: Icons.email_outlined,
                          actionLabel: loc.translate('send_email'),
                        ),

                        SizedBox(height: 32.h),

                        // Phone Section
                        _buildSectionTitle(
                          context,
                          Icons.phone_rounded,
                          loc.translate('phone_number'),
                        ),
                        SizedBox(height: 12.h),
                        _ContactCard(
                          icon: Icons.phone_in_talk_rounded,
                          title: loc.translate('contact_number'),
                          value: '01856820397',
                          onCopy: () => _copyToClipboard(
                            context,
                            '01856820397',
                            loc.translate('copied_to_clipboard'),
                          ),
                          onTap: () => _launchPhone('01856820397'),
                          actionIcon: Icons.call,
                          actionLabel: loc.translate('call'),
                        ),
                        SizedBox(height: 12.h),
                        _ContactCard(
                          icon: Icons.support_rounded,
                          title: loc.translate('whatsapp_number'),
                          value: '01308831689',
                          onCopy: () => _copyToClipboard(
                            context,
                            '01308831689',
                            loc.translate('copied_to_clipboard'),
                          ),
                          onTap: () => _launchPhone('01308831689'),
                          actionIcon: Icons.call,
                          actionLabel: loc.translate('call'),
                        ),

                        SizedBox(height: 32.h),

                        // Office Hours Card
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

  Widget _buildSectionTitle(BuildContext context, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24.sp),
        SizedBox(width: 8.w),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _copyToClipboard(BuildContext context, String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ModernAlert.show(
      context: context,
      type: AlertType.success,
      title: message,
      message: text,
      confirmText: AppLocalizations.of(context)!.translate('ok'),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onCopy;
  final VoidCallback onTap;
  final IconData actionIcon;
  final String actionLabel;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.onCopy,
    required this.onTap,
    required this.actionIcon,
    required this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textDarkSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onCopy,
                    icon: Icon(
                      Icons.copy_rounded,
                      color: AppColors.accent,
                      size: 20.sp,
                    ),
                    tooltip: AppLocalizations.of(
                      context,
                    )!.translate('copy_email'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
