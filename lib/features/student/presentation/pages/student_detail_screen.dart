import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../shared/widgets/loading_indicator.dart';
import '../../data/models/student_model.dart';
import '../../data/repositories/student_repository.dart';

class StudentDetailScreen extends StatefulWidget {
  final String studentId;

  const StudentDetailScreen({super.key, required this.studentId});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  final StudentRepository _repository = StudentRepository();
  late Future<Student?> _studentFuture;

  @override
  void initState() {
    super.initState();
    _studentFuture = _repository.getStudentById(widget.studentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Details'),
      ),
      body: FutureBuilder<Student?>(
        future: _studentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Student not found'));
          }

          final student = snapshot.data!;
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50.r,
                    child: Text(
                      student.name[0].toUpperCase(),
                      style: TextStyle(fontSize: 40.sp),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                _buildInfoRow('Name', student.name),
                _buildInfoRow('Email', student.email),
                _buildInfoRow('Grade', student.grade),
                _buildInfoRow('Section', student.section),
                _buildInfoRow('Roll Number', student.rollNumber),
                SizedBox(height: 24.h),
                const Divider(),
                SizedBox(height: 16.h),
                Text(
                  'Parent Information',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 16.h),
                _buildInfoRow('Parent Name', student.parentName),
                _buildInfoRow('Parent Phone', student.parentPhone),
                _buildInfoRow('Address', student.address),
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
