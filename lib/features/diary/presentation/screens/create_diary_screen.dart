import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../shared/utils/app_colors.dart';
import '../../../../shared/widgets/custom_appbar.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../teacher_attendance/data/models/teacher_attendance_models.dart';
import '../../data/models/teacher_diary_model.dart';
import '../../provider/teacher_diary_provider.dart';

class CreateDiaryScreen extends StatefulWidget {
  final TeacherDiary? diary;
  const CreateDiaryScreen({super.key, this.diary});

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

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.diary != null;

    if (_isEditing) {
      _populateFields();
    } else {
      // Default dates
      _selectedDiaryDate = DateTime.now();
      _diaryDateController.text = DateFormat(
        'yyyy-MM-dd',
      ).format(_selectedDiaryDate!);

      _selectedSubmissionDate = DateTime.now();
      _submissionDateController.text = DateFormat(
        'yyyy-MM-dd',
      ).format(_selectedSubmissionDate!);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<TeacherDiaryProvider>();
      if (provider.classes.isEmpty ||
          provider.sessions.isEmpty ||
          provider.subjects.isEmpty) {
        await provider.fetchMetadata();
      }
      if (!_isEditing) {
        _autoSelectSession();
      } else {
        // If editing, ensure we set selected objects from list based on IDs
        _matchSelections();
      }

      // Even if editing, we might need to match selections after fetch
      if (_isEditing) {
        _matchSelections();
      }
    });
  }

  void _populateFields() {
    final diary = widget.diary!;
    _titleController.text = diary.title;
    _descriptionController.text = diary.description ?? '';
    _status = diary.status;

    if (diary.diaryDate != null) {
      try {
        _selectedDiaryDate = DateTime.parse(diary.diaryDate!);
        _diaryDateController.text = DateFormat(
          'yyyy-MM-dd',
        ).format(_selectedDiaryDate!);
      } catch (_) {}
    }

    if (diary.submissionDate != null) {
      try {
        _selectedSubmissionDate = DateTime.parse(diary.submissionDate!);
        _submissionDateController.text = DateFormat(
          'yyyy-MM-dd',
        ).format(_selectedSubmissionDate!);
      } catch (_) {}
    }
  }

  void _matchSelections() {
    if (!mounted || widget.diary == null) return;
    final provider = context.read<TeacherDiaryProvider>();

    setState(() {
      if (widget.diary!.classId != null && provider.classes.isNotEmpty) {
        try {
          _selectedClass = provider.classes.firstWhere(
            (c) => c.id == widget.diary!.classId,
          );
        } catch (_) {}
      }

      if (widget.diary!.academicSessionId != null &&
          provider.sessions.isNotEmpty) {
        try {
          _selectedSession = provider.sessions.firstWhere(
            (s) => s.id == widget.diary!.academicSessionId,
          );
        } catch (_) {}
      }

      if (widget.diary!.subjectId != null && provider.subjects.isNotEmpty) {
        try {
          _selectedSubject = provider.subjects.firstWhere(
            (s) => s.id == widget.diary!.subjectId,
          );
        } catch (_) {}
      }
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
          SnackBar(
            content: const Text('Please select Class, Session and Subject'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
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
        if (_isEditing) {
          await context.read<TeacherDiaryProvider>().updateDiary(
            widget.diary!.id,
            diaryData,
          );
        } else {
          await context.read<TeacherDiaryProvider>().createDiary(diaryData);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing
                    ? 'Diary updated successfully!'
                    : 'Diary created successfully!',
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,

      body: Column(
        children: [
          CustomAppBar(
            title: _isEditing ? 'Edit Diary' : 'Create Diary',
            showBackButton: true,
          ),
          Expanded(
            child: Consumer<TeacherDiaryProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.classes.isEmpty) {
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
                          'Loading form data...',
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
                        _buildFormHeader(),
                        SizedBox(height: 24.h),
                        _buildFormCard(
                          title: 'Basic Information',
                          icon: Icons.info_outline_rounded,
                          children: [
                            _buildDropdown<TeacherClass>(
                              label: 'Select Class',
                              value: _selectedClass,
                              items: provider.classes,
                              hint: 'Choose Class',
                              icon: Icons.class_outlined,
                              onChanged: (val) =>
                                  setState(() => _selectedClass = val),
                              itemLabel: (item) => item.name,
                            ),
                            SizedBox(height: 16.h),
                            _buildDropdown<DiarySubject>(
                              label: 'Subject',
                              value: _selectedSubject,
                              items: provider.subjects,
                              hint: 'Choose Subject',
                              icon: Icons.book_outlined,
                              onChanged: (val) =>
                                  setState(() => _selectedSubject = val),
                              itemLabel: (item) => item.name,
                            ),
                            SizedBox(height: 16.h),
                            _buildDropdown<TeacherAcademicSession>(
                              label: 'Academic Session',
                              value: _selectedSession,
                              items: provider.sessions,
                              hint: 'Choose Session',
                              icon: Icons.school_outlined,
                              onChanged: (val) =>
                                  setState(() => _selectedSession = val),
                              itemLabel: (item) => item.title,
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        _buildFormCard(
                          title: 'Dates',
                          icon: Icons.calendar_today_outlined,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    label: 'Diary Date',
                                    hint: 'Select Date',
                                    controller: _diaryDateController,
                                    readOnly: true,
                                    onTap: () => _selectDate(context, true),
                                    suffixIcon: Icon(
                                      Icons.calendar_today,
                                      size: 20.sp,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: CustomTextField(
                                    label: 'Submission Date',
                                    hint: 'Select Date',
                                    controller: _submissionDateController,
                                    readOnly: true,
                                    onTap: () => _selectDate(context, false),
                                    suffixIcon: Icon(
                                      Icons.event,
                                      size: 20.sp,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        _buildFormCard(
                          title: 'Content',
                          icon: Icons.description_outlined,
                          children: [
                            CustomTextField(
                              label: 'Title',
                              hint: 'Enter topic or chapter name',
                              controller: _titleController,
                              prefixIcon: Icon(
                                Icons.title_rounded,
                                color: AppColors.primary,
                                size: 20.sp,
                              ),
                              validator: (v) => v?.isEmpty == true
                                  ? 'Title is required'
                                  : null,
                            ),
                            SizedBox(height: 16.h),
                            CustomTextField(
                              label: 'Description',
                              hint: 'Enter detailed description',
                              controller: _descriptionController,
                              maxLines: 5,
                              validator: (v) => v?.isEmpty == true
                                  ? 'Description is required'
                                  : null,
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        _buildFormCard(
                          title: 'Status',
                          icon: Icons.toggle_on_outlined,
                          children: [_buildStatusSelector()],
                        ),
                        SizedBox(height: 32.h),
                        _buildSubmitButton(provider),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormHeader() {
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
              _isEditing
                  ? Icons.edit_note_rounded
                  : Icons.add_circle_outline_rounded,
              color: AppColors.primary,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Edit Diary Entry' : 'New Diary Entry',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _isEditing
                      ? 'Update your class diary information below.'
                      : 'Fill in the details to create a new class diary.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.grey200.withOpacity(0.6),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, size: 18.sp, color: AppColors.primary),
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String hint,
    required IconData icon,
    required Function(T?) onChanged,
    required String Function(T) itemLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16.sp, color: AppColors.primary),
            SizedBox(width: 6.w),
            Text(
              label,
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
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: AppColors.grey200.withOpacity(0.6),
                width: 1.2,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                hint: Text(
                  hint,
                  style: TextStyle(
                    color: AppColors.grey400,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.grey600,
                  size: 24.sp,
                ),
                items: items.map((T item) {
                  return DropdownMenuItem<T>(
                    value: item,
                    child: Text(
                      itemLabel(item),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _status = 'published'),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                gradient: _status == 'published'
                    ? LinearGradient(
                        colors: [
                          AppColors.success.withOpacity(0.15),
                          AppColors.success.withOpacity(0.08),
                        ],
                      )
                    : null,
                color: _status == 'published' ? null : Colors.white,
                border: Border.all(
                  color: _status == 'published'
                      ? AppColors.success
                      : AppColors.grey300,
                  width: _status == 'published' ? 2 : 1.2,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_status == 'published')
                    Container(
                      width: 6.w,
                      height: 6.w,
                      margin: EdgeInsets.only(right: 8.w),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Text(
                    'Published',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: _status == 'published'
                          ? AppColors.success
                          : AppColors.grey600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _status = 'draft'),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                gradient: _status == 'draft'
                    ? LinearGradient(
                        colors: [
                          AppColors.warning.withOpacity(0.15),
                          AppColors.warning.withOpacity(0.08),
                        ],
                      )
                    : null,
                color: _status == 'draft' ? null : Colors.white,
                border: Border.all(
                  color: _status == 'draft'
                      ? AppColors.warning
                      : AppColors.grey300,
                  width: _status == 'draft' ? 2 : 1.2,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_status == 'draft')
                    Container(
                      width: 6.w,
                      height: 6.w,
                      margin: EdgeInsets.only(right: 8.w),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Text(
                    'Draft',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: _status == 'draft'
                          ? AppColors.warning
                          : AppColors.grey600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(TeacherDiaryProvider provider) {
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
          onTap: provider.isLoading ? null : _submitDiary,
          borderRadius: BorderRadius.circular(14.r),
          child: Center(
            child: provider.isLoading
                ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isEditing
                            ? Icons.check_circle_outline_rounded
                            : Icons.publish_rounded,
                        color: Colors.white,
                        size: 22.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        _isEditing ? 'Update Diary' : 'Publish Diary',
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
