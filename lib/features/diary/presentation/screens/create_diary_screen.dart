import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../shared/utils/app_colors.dart';
import '../../../teacher_attendance/data/models/teacher_attendance_models.dart';
import '../../data/models/teacher_diary_model.dart';
import '../../provider/teacher_diary_provider.dart';

class CreateDiaryScreen extends StatefulWidget {
  const CreateDiaryScreen({super.key});

  @override
  State<CreateDiaryScreen> createState() => _CreateDiaryScreenState();
}

class _CreateDiaryScreenState extends State<CreateDiaryScreen> {
  final _formKey = GlobalKey<FormState>();

  // Selections
  TeacherClass? _selectedClass;
  TeacherAcademicSession? _selectedSession;
  DiarySubject? _selectedSubject;
  String _status = 'published'; // Default

  // Date Controllers
  final TextEditingController _diaryDateController = TextEditingController();
  final TextEditingController _submissionDateController =
      TextEditingController();

  // Text Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _selectedDiaryDate;
  DateTime? _selectedSubmissionDate;

  @override
  void initState() {
    super.initState();
    // Default dates
    _selectedDiaryDate = DateTime.now();
    _diaryDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(_selectedDiaryDate!);

    // Default submission date same as diary date? Or empty?
    _selectedSubmissionDate = DateTime.now();
    _submissionDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(_selectedSubmissionDate!);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<TeacherDiaryProvider>().fetchMetadata();
      _autoSelectSession();
    });
  }

  void _autoSelectSession() {
    final provider = context.read<TeacherDiaryProvider>();
    if (provider.sessions.isNotEmpty) {
      try {
        setState(() {
          _selectedSession = provider.sessions.firstWhere(
            (s) => s.isCurrent == '1',
          );
        });
      } catch (_) {
        if (provider.sessions.isNotEmpty) {
          setState(() {
            _selectedSession = provider.sessions.first;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _diaryDateController.dispose();
    _submissionDateController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isDiaryDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDiaryDate
          ? (_selectedDiaryDate ?? DateTime.now())
          : (_selectedSubmissionDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.primary,
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isDiaryDate) {
          _selectedDiaryDate = picked;
          _diaryDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        } else {
          _selectedSubmissionDate = picked;
          _submissionDateController.text = DateFormat(
            'yyyy-MM-dd',
          ).format(picked);
        }
      });
    }
  }

  Future<void> _submitDiary() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedClass == null ||
          _selectedSession == null ||
          _selectedSubject == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select Class, Session and Subject'),
          ),
        );
        return;
      }

      final diaryData = {
        "class_id": _selectedClass!.id,
        "academic_session_id": _selectedSession!.id,
        "subject_id": _selectedSubject!.id,
        "diary_date": _diaryDateController.text,
        "submission_date": _submissionDateController.text,
        "title": _titleController.text,
        "description": _descriptionController.text,
        "status": _status,
      };

      try {
        await context.read<TeacherDiaryProvider>().createDiary(diaryData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Diary created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop(); // Go back to list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Create Diary',
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
      body: Consumer<TeacherDiaryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.classes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDropdown<TeacherClass>(
                    label: 'Select Class',
                    value: _selectedClass,
                    items: provider.classes,
                    hint: 'Choose Class',
                    onChanged: (val) => setState(() => _selectedClass = val),
                    itemLabel: (item) => item.name,
                  ),
                  SizedBox(height: 16.h),
                  _buildDropdown<TeacherAcademicSession>(
                    label: 'Academic Session',
                    value: _selectedSession,
                    items: provider.sessions,
                    hint: 'Choose Session',
                    onChanged: (val) => setState(() => _selectedSession = val),
                    itemLabel: (item) => item.title,
                  ),
                  SizedBox(height: 16.h),
                  _buildDropdown<DiarySubject>(
                    label: 'Subject',
                    value: _selectedSubject,
                    items: provider.subjects,
                    hint: 'Choose Subject',
                    onChanged: (val) => setState(() => _selectedSubject = val),
                    itemLabel: (item) => item.name,
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePickerField(
                          controller: _diaryDateController,
                          label: 'Diary Date',
                          onTap: () => _selectDate(context, true),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildDatePickerField(
                          controller: _submissionDateController,
                          label: 'Submission Date',
                          onTap: () => _selectDate(context, false),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _buildTextField(
                    controller: _titleController,
                    label: 'Title',
                    hint: 'Enter topic or chapter name',
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  SizedBox(height: 16.h),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'Enter detailed description',
                    maxLines: 4,
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  SizedBox(height: 16.h),
                  _buildStatusSelector(),
                  SizedBox(height: 32.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: provider.isLoading ? null : _submitDiary,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 2,
                      ),
                      child: provider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _status == 'published'
                                  ? 'Publish Diary'
                                  : 'Save as Draft',
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

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String hint,
    required Function(T?) onChanged,
    required String Function(T) itemLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.grey300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              hint: Text(
                hint,
                style: TextStyle(color: AppColors.grey400, fontSize: 14.sp),
              ),
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.grey600,
              ),
              items: items.map((T item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemLabel(item),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: 'Select Date',
            suffixIcon: const Icon(Icons.calendar_today, size: 20),
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
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.grey400, fontSize: 14.sp),
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
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _status = 'published'),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: _status == 'published'
                        ? Colors.green.withOpacity(0.1)
                        : Colors.white,
                    border: Border.all(
                      color: _status == 'published'
                          ? Colors.green
                          : AppColors.grey300,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text(
                      'Published',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _status == 'published'
                            ? Colors.green
                            : AppColors.grey600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _status = 'draft'),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: _status == 'draft'
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.white,
                    border: Border.all(
                      color: _status == 'draft'
                          ? Colors.orange
                          : AppColors.grey300,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text(
                      'Draft',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _status == 'draft'
                            ? Colors.orange
                            : AppColors.grey600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
