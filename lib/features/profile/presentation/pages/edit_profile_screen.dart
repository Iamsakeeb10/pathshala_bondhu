import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

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
        _controllers['department'] = TextEditingController(text: details.department);
        _controllers['specialization'] = TextEditingController(text: details.specialization);
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
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
        );
        context.pop();
      } else if (mounted && provider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage!), backgroundColor: Colors.red),
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
        title: Text(
          'Edit Profile',
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
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  if (auth.isParent) ..._buildParentFields(),
                  if (auth.isTeacher) ..._buildTeacherFields(),
                  SizedBox(height: 32.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildParentFields() {
    return [
      _buildTextField('father_name', 'Father Name', required: true),
      _buildTextField('mother_name', 'Mother Name'),
      _buildTextField('father_job', 'Father Job'),
      _buildTextField('mother_job', 'Mother Job'),
      _buildTextField('parent_phone', 'Phone Number', required: true, keyboardType: TextInputType.phone),
      _buildTextField('address', 'Address', maxLines: 3),
    ];
  }

  List<Widget> _buildTeacherFields() {
    return [
      _buildTextField('name', 'Name', required: true),
      _buildTextField('email', 'Email', required: true, keyboardType: TextInputType.emailAddress),
      _buildTextField('department', 'Department', required: true),
      _buildTextField('specialization', 'Specialization', required: true),
      _buildTextField('bio', 'Bio', maxLines: 4),
    ];
  }

  Widget _buildTextField(String key, String label, {
    bool required = false, 
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: TextFormField(
        controller: _controllers[key],
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: required ? (v) => v?.isEmpty == true ? 'Required' : null : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.grey600, fontSize: 14.sp),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: AppColors.grey300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: AppColors.grey300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}
