import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/providers/auth_provider.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../parents/ui/parents_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../../../students/ui/students_screen.dart';
import '../../../teachers/ui/teachers_screen.dart';

/// Dashboard screen with role-based bottom navigation.
/// 
/// Handles different navigation items based on user role:
/// - Parent: Home | Students | Teachers | Profile
/// - Teacher: Home | Teachers | Parents | Profile
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

    // Build pages and nav items based on role
    final List<Widget> pages = _buildPages(authProvider);
    final List<BottomNavigationBarItem> navItems = _buildNavItems(authProvider);

    // CRITICAL: Clamp currentIndex to prevent assertion error on logout
    // When user logs out and pages list changes, ensure index is valid
    final clampedIndex = _currentIndex.clamp(0, pages.length - 1);
    if (clampedIndex != _currentIndex) {
      // Schedule state update for next frame to avoid build-time setState
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _currentIndex = 0);
        }
      });
    }

    return Scaffold(
      body: IndexedStack(index: clampedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: clampedIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: navItems,
      ),
    );
  }

  /// Build pages list based on user role
  /// 
  /// Parent: Home | Students | Teachers | Profile
  /// Teacher: Home | Teachers | Parents | Profile
  List<Widget> _buildPages(AuthProvider authProvider) {
    if (authProvider.isTeacher) {
      return const [
        HomeScreen(),
        TeachersScreen(),
        ParentsScreen(),
        ProfileScreen(),
      ];
    }
    
    // Parent role (or default)
    return const [
      HomeScreen(),
      StudentsScreen(),
      TeachersScreen(),
      ProfileScreen(),
    ];
  }

  /// Build navigation items based on user role
  List<BottomNavigationBarItem> _buildNavItems(AuthProvider authProvider) {
    if (authProvider.isTeacher) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Teachers'),
        BottomNavigationBarItem(
          icon: Icon(Icons.family_restroom),
          label: 'Parents',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ];
    }

    // Parent role (or default)
    return const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Students'),
      BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Teachers'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ];
  }
}

