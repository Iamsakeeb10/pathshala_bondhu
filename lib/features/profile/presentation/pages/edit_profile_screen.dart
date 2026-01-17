import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/providers/auth_provider.dart';
import '../../../../shared/utils/app_colors.dart';
import '../../providers/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final provider = context.read<ProfileProvider>();
    final auth = context.read<AuthProvider>();

    if (auth.isParent && provider.parentProfile != null) {
      final p = provider.parentProfile!;
      _controllers['father_name'] = TextEditingController(text: p.fatherName);
      _controllers['mother_name'] = TextEditingController(text: p.motherName);
      _controllers['father_job'] = TextEditingController(text: p.fatherJob);
      _controllers['mother_job'] = TextEditingController(text: p.motherJob);
      _controllers['parent_phone'] = TextEditingController(text: p.parentPhone);
      _controllers['address'] = TextEditingController(text: p.address);
    } else if (auth.isTeacher && provider.teacherProfile != null) {
      final t = provider.teacherProfile!;
      final details = t.teacher;
      _controllers['name'] = TextEditingController(text: t.name);
      _controllers['email'] = TextEditingController(text: t.email);
      if (details != null) {
        _controllers['department'] = TextEditingController(
          text: details.department,
        );
        _controllers['specialization'] = TextEditingController(
          text: details.specialization,
        );
        _controllers['bio'] = TextEditingController(text: details.bio);
      }
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<ProfileProvider>();
      final auth = context.read<AuthProvider>();

      final Map<String, dynamic> data = {};
      _controllers.forEach((key, controller) {
        data[key] = controller.text;
      });

      bool success = false;
      if (auth.isParent) {
        success = await provider.updateParentProfile(data);
      } else if (auth.isTeacher) {
        success = await provider.updateTeacherProfile(data);
      }

      if (success && mounted) {
        // Sync AuthProvider state
        if (auth.isParent && provider.parentProfile != null) {
          await auth.updateCurrentUser(
            name: provider.parentProfile!.fatherName,
          );
        } else if (auth.isTeacher && provider.teacherProfile != null) {
          await auth.updateCurrentUser(
            name: provider.teacherProfile!.name,
            email: provider.teacherProfile!.email,
            avatarUrl: provider.teacherProfile!.avatar,
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
        context.pop();
      } else if (mounted && provider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ProfileProvider>(
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
                    'Saving changes...',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoBox(),
                  SizedBox(height: 24.h),
                  if (auth.isParent) ...[
                    _buildSectionHeader('Personal Information'),
                    SizedBox(height: 12.h),
                    ..._buildParentFields(),
                  ],
                  if (auth.isTeacher) ...[
                    _buildSectionHeader('Personal Information'),
                    SizedBox(height: 12.h),
                    ..._buildTeacherFields(),
                  ],
                  SizedBox(height: 32.h),
                  _buildSaveButton(),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primaryLight.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: AppColors.primary,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              'Update your profile information below. All required fields must be filled.',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
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
            color: AppColors.textPrimary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildParentFields() {
    return [
      _buildTextField(
        'father_name',
        'Father Name',
        Icons.person_outline,
        required: true,
      ),
      _buildTextField('mother_name', 'Mother Name', Icons.person_outline),
      _buildTextField('father_job', 'Father Job', Icons.work_outline),
      _buildTextField('mother_job', 'Mother Job', Icons.work_outline),
      _buildTextField(
        'parent_phone',
        'Phone Number',
        Icons.phone_outlined,
        required: true,
        keyboardType: TextInputType.phone,
      ),
      _buildTextField(
        'address',
        'Address',
        Icons.location_on_outlined,
        maxLines: 3,
      ),
    ];
  }

  List<Widget> _buildTeacherFields() {
    return [
      _buildTextField('name', 'Name', Icons.person_outline, required: true),
      _buildTextField(
        'email',
        'Email',
        Icons.email_outlined,
        required: true,
        keyboardType: TextInputType.emailAddress,
      ),
      _buildTextField(
        'department',
        'Department',
        Icons.school_outlined,
        required: true,
      ),
      _buildTextField(
        'specialization',
        'Specialization',
        Icons.stars_outlined,
        required: true,
      ),
      _buildTextField('bio', 'Bio', Icons.description_outlined, maxLines: 4),
    ];
  }

  Widget _buildTextField(
    String key,
    String label,
    IconData icon, {
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: AppColors.primary),
              SizedBox(width: 6.w),
              Text(
                label + (required ? ' *' : ''),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: _controllers[key],
              maxLines: maxLines,
              keyboardType: keyboardType,
              validator: required
                  ? (v) => v?.isEmpty == true ? 'This field is required' : null
                  : null,
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: 'Enter $label',
                hintStyle: TextStyle(
                  color: AppColors.grey400,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
                fillColor: Colors.white,
                filled: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: maxLines > 1 ? 16.h : 16.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(
                    color: AppColors.grey200.withOpacity(0.6),
                    width: 1.2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(
                    color: AppColors.grey200.withOpacity(0.6),
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(color: AppColors.error, width: 1.2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(color: AppColors.error, width: 2),
                ),
                errorStyle: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
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
          onTap: _saveProfile,
          borderRadius: BorderRadius.circular(14.r),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.white,
                  size: 22.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Save Changes',
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
