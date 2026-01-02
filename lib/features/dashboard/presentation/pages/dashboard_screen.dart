import 'package:flutter/material.dart';

import '../../../profile/presentation/pages/profile_screen.dart';
import '../../../student/presentation/pages/student_list_screen.dart';
import '../../../teacher/presentation/pages/teacher_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  // Pages for each tab
  // Note: We're using the screens directly.
  // Ideally, we might want a minimal version for the tab or the full screen is fine.
  final List<Widget> _pages = [
    const Center(child: Text('Home')), // Placeholder for Home
    const StudentListScreen(),
    const TeacherListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Students'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Teachers'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
