import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/providers/auth_provider.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../../../students/ui/students_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Different pages for parents and teachers
    final List<Widget> pages = [
      const HomeScreen(),
      if (authProvider.isParent) const StudentsScreen(),
      const Center(child: Text('Teachers')), // Placeholder for Teachers
      const ProfileScreen(),
    ];

    final List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      if (authProvider.isParent)
        const BottomNavigationBarItem(
            icon: Icon(Icons.people), label: 'Students'),
      const BottomNavigationBarItem(
          icon: Icon(Icons.school), label: 'Teachers'),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: navItems,
      ),
    );
  }
}
