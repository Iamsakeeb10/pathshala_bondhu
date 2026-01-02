import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../shared/widgets/loading_indicator.dart';
import '../../data/models/teacher_model.dart';
import '../../data/repositories/teacher_repository.dart';

class TeacherDetailScreen extends StatefulWidget {
  final String teacherId;

  const TeacherDetailScreen({super.key, required this.teacherId});

  @override
  State<TeacherDetailScreen> createState() => _TeacherDetailScreenState();
}

class _TeacherDetailScreenState extends State<TeacherDetailScreen> {
  final TeacherRepository _repository = TeacherRepository();
  late Future<Teacher?> _teacherFuture;

  @override
  void initState() {
    super.initState();
    _teacherFuture = _repository.getTeacherById(widget.teacherId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Details'),
      ),
      body: FutureBuilder<Teacher?>(
        future: _teacherFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Teacher not found'));
          }

          final teacher = snapshot.data!;
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50.r,
                    child: Text(
                      teacher.name[0].toUpperCase(),
                      style: TextStyle(fontSize: 40.sp),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                _buildInfoRow('Name', teacher.name),
                _buildInfoRow('Email', teacher.email),
                _buildInfoRow('Department', teacher.department),
                _buildInfoRow('Subject', teacher.subject),
                _buildInfoRow('Qualification', teacher.qualification),
                _buildInfoRow('Experience', '${teacher.yearsOfExperience} years'),
                _buildInfoRow('Phone', teacher.phoneNumber),
                _buildInfoRow('Address', teacher.address),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
