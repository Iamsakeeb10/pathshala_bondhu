import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/providers/auth_provider.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../features/notifications/providers/notification_provider.dart';
import '../../../../features/students/provider/student_provider.dart';
import '../../../../shared/utils/app_colors.dart';
import '../../../../shared/widgets/modern_premium_slider.dart';
import '../../../../shared/widgets/student_selection_bottom_sheet.dart';
import '../../../teacher_attendance/ui/widgets/class_selection_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isParent) {
        context.read<StudentProvider>().fetchStudents();
        // Fetch extended profile for job title
        authProvider.fetchExtendedProfile();
      }

      // Fetch notification unread count
      context.read<NotificationProvider>().fetchUnreadCount();

      // Request notification permission
      NotificationService.requestPermission();
    });
  }

  /// Simple version with consistent greetings
  String _getGreeting() {
    final now = DateTime.now();
    final hour = now.hour;
    final day = now.weekday;

    // Weekend check
    final isWeekend = day == DateTime.saturday || day == DateTime.sunday;

    // Early Morning (12 AM - 5 AM)
    if (hour >= 0 && hour < 5) {
      final messages = [
        'Burning the midnight oil',
        'Still awake',
        'Working late',
        'Night owl',
      ];
      return messages[now.second % messages.length];
    }
    // Dawn (5 AM - 7 AM)
    else if (hour >= 5 && hour < 7) {
      final messages = [
        'Rise and shine',
        'Early bird',
        'Good morning',
        'Beautiful morning',
      ];
      return messages[now.second % messages.length];
    }
    // Morning (7 AM - 12 PM)
    else if (hour >= 7 && hour < 12) {
      if (isWeekend) {
        final messages = [
          'Happy weekend',
          'Good morning',
          'Lovely morning',
          'Great morning',
        ];
        return messages[now.second % messages.length];
      } else {
        final messages = [
          'Good morning',
          'Great morning',
          'Wonderful morning',
          'Beautiful morning',
        ];
        return messages[now.second % messages.length];
      }
    }
    // Afternoon (12 PM - 5 PM)
    else if (hour >= 12 && hour < 17) {
      if (isWeekend) {
        final messages = [
          'Happy afternoon',
          'Good afternoon',
          'Lovely afternoon',
          'Great afternoon',
        ];
        return messages[now.second % messages.length];
      } else {
        final messages = [
          'Good afternoon',
          'Great afternoon',
          'Wonderful afternoon',
          'Nice afternoon',
        ];
        return messages[now.second % messages.length];
      }
    }
    // Evening (5 PM - 9 PM)
    else if (hour >= 17 && hour < 21) {
      final messages = [
        'Good evening',
        'Great evening',
        'Lovely evening',
        'Beautiful evening',
      ];
      return messages[now.second % messages.length];
    }
    // Night (9 PM - 12 AM)
    else {
      final messages = [
        'Good evening',
        'Working late',
        'Night time',
        'Late evening',
      ];
      return messages[now.second % messages.length];
    }
  }

  final List<String> _bannerImages = [
    'https://images.unsplash.com/photo-1546410531-bb4caa6b424d?w=800',
    'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=800',
    'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=800',
  ];

  final List<Map<String, dynamic>> _categories = [
    {
      'icon': Icons.book_outlined,
      'label': 'Books',
      'color': const Color(0xFFEFC45D),
      'route': '/books',
    },
    {
      'icon': Icons.book, // Using book icon for Diary as placeholder
      'label': 'Diary',
      'color': const Color(0xFF8B5CF6),
      'route': null,
    },
    {
      'icon': Icons.dashboard_outlined,
      'label': 'Class Routine',
      'color': const Color(0xFFEFA35F),
      'route': '/routines',
    },
    {
      'icon': Icons.school_outlined,
      'label': 'Exam Routine',
      'color': const Color(0xFFEE9C70),
      'route': '/exam-routines',
    },
    {
      'icon': Icons.calendar_today_outlined,
      'label': 'Attendance',
      'color': const Color(0xFF22C55E),
      'route': '/attendance',
    },
    {
      'icon': Icons.payment_outlined,
      'label': 'Fees',
      'color': const Color(0xFF3B82F6),
      'route': '/fees',
    },
    // {
    //   'icon': Icons.description_outlined,
    //   'label': 'Notice',
    //   'color': const Color(0xFF8B5CF6),
    //   'route': null,
    // },
    // {
    //   'icon': Icons.assignment_outlined,
    //   'label': 'Circular',
    //   'color': const Color(0xFFEC4899),
    //   'route': null,
    // },
    // {
    //   'icon': Icons.analytics_outlined,
    //   'label': 'Reports',
    //   'color': const Color(0xFF06B6D4),
    //   'route': null,
    // },
    // {
    //   'icon': Icons.people_outline,
    //   'label': 'Profile',
    //   'color': const Color(0xFFEFC45D),
    //   'route': null,
    // },
  ];

  // Filter categories based on role
  List<Map<String, dynamic>> get _visibleCategories {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isTeacher) {
      return _categories
          .where(
            (c) => [
              'Attendance',
              'Diary',
              'Class Routine', // User said "Routine", assuming mapping to "Class Routine"
            ].contains(c['label']),
          )
          .toList();
    }
    // For parents, show everything? Or should we hide Diary?
    // User didn't specify for parents. Leaving as is (shows all).
    return _categories;
  }

  void _handleCategoryTap(Map<String, dynamic> category) {
    final route = category['route'] as String?;
    final label = category['label'] as String;

    final authProvider = context.read<AuthProvider>();

    // 1. Handle Teacher specific overrides first (allows 'Diary' which has null route in map)
    if (authProvider.isTeacher) {
      if (label == 'Attendance') {
        ClassSelectionBottomSheet.show(
          context,
          onConfirmed: (selectedClass, selectedSession) {
            final uri = Uri(
              path: '/teacher-attendance',
              queryParameters: {
                'classId': selectedClass.id.toString(),
                'sessionId': selectedSession.id.toString(),
                'className': selectedClass.name,
                'sessionName': selectedSession.title,
              },
            );
            context.push(uri.toString());
          },
        );
        return;
      } else if (label == 'Class Routine') {
        context.push('/teacher/routines');
        return;
      } else if (label == 'Diary') {
        context.push('/teacher/diaries');
        return;
      }
    }

    // 2. Handle Parent logic
    if (authProvider.isParent) {
      // Handle Diary specifically
      if (label == 'Diary') {
        final studentProvider = context.read<StudentProvider>();

        if (studentProvider.students.isEmpty && !studentProvider.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No students found. Please contact support.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        if (studentProvider.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Loading student information...'),
              duration: Duration(seconds: 1),
            ),
          );
          return;
        }

        if (studentProvider.hasSingleStudent) {
          final student = studentProvider.students.first;
          context.push(
            Uri(
              path: '/parent/diaries',
              queryParameters: {'studentId': student.studentId},
            ).toString(),
          );
          return;
        }

        if (studentProvider.hasMultipleStudents) {
          StudentSelectionBottomSheet.show(
            context,
            students: studentProvider.students,
            onStudentSelected: (student) {
              studentProvider.selectStudent(student);
              context.push(
                Uri(
                  path: '/parent/diaries',
                  queryParameters: {'studentId': student.studentId},
                ).toString(),
              );
            },
          );
          return;
        }
      }

      // Generic parent routing logic (if route is null, it will fall through)
    }

    // 3. Check if route is null for other cases
    if (route == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label coming soon!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 4. Handle standard Teacher routes
    if (authProvider.isTeacher) {
      context.push(route);
      return;
    }

    // 5. Handle standard Parent routes (with student selection)
    if (authProvider.isParent) {
      final studentProvider = context.read<StudentProvider>();

      if (studentProvider.students.isEmpty && !studentProvider.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No students found. Please contact support.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (studentProvider.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loading student information...'),
            duration: Duration(seconds: 1),
          ),
        );
        return;
      }

      if (studentProvider.hasSingleStudent) {
        context.push(route);
        return;
      }

      if (studentProvider.hasMultipleStudents) {
        StudentSelectionBottomSheet.show(
          context,
          students: studentProvider.students,
          onStudentSelected: (student) {
            studentProvider.selectStudent(student);
            context.push(route);
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sliderHeight = 150.h;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with floating slider
            Stack(
              clipBehavior: Clip.none,
              children: [
                _buildTopSection(sliderHeight),
                // Floating slider positioned half inside, half outside
                Positioned(
                  left: 24.w,
                  right: 24.w,
                  bottom: -(sliderHeight / 2),
                  child: _buildSlider(sliderHeight),
                ),
              ],
            ),
            // Add spacing equal to half the slider height plus margin
            SizedBox(height: (sliderHeight / 2) + 24.h),
            _buildSectionTitle(),
            SizedBox(height: 16.h),
            _buildCategoriesSection(),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'Quick Access',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.only(left: 12.w),
            child: Text(
              'Explore all features',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSection(double sliderHeight) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark, AppColors.accent],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28.r),
          bottomRight: Radius.circular(28.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 6.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            SizedBox(height: 16.h),
            // Empty space for the slider
            SizedBox(height: sliderHeight / 2),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final userName = authProvider.currentUser?.name ?? 'Guest';
              final designation = authProvider.currentUser?.designation;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting with wave emoji
                  Row(
                    children: [
                      Text(
                        _getGreeting(),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.85),
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text('👋', style: TextStyle(fontSize: 16.sp)),
                    ],
                  ),
                  SizedBox(height: 6.h),

                  // Name - Bold and prominent
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.15),
                          offset: Offset(0, 2.h),
                          blurRadius: 8.r,
                        ),
                      ],
                    ),
                  ),

                  // Designation Badge - Modern pill design
                  if (designation != null && designation.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.25),
                            Colors.white.withOpacity(0.15),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8.r,
                            offset: Offset(0, 3.h),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.work_outline_rounded,
                              size: 14.sp,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Flexible(
                            child: Text(
                              designation,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),

        // 🔔 Notification Bell Icon with Badge
        Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            return InkWell(
              borderRadius: BorderRadius.circular(50.r),
              onTap: () {
                context.push('/notifications').then((_) {
                  provider.fetchUnreadCount();
                });
              },
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.notifications_rounded,
                      color: Colors.white,
                      size: 24.sp,
                    ),

                    // 🔴 Unread badge
                    if (provider.unreadCount > 0)
                      Positioned(
                        right: -6.w,
                        top: -6.h,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: provider.unreadCount > 99 ? 4.w : 5.w,
                            vertical: provider.unreadCount > 99 ? 2.h : 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.error.withOpacity(0.4),
                                blurRadius: 4.r,
                                offset: Offset(0, 2.h),
                              ),
                            ],
                          ),
                          child: Text(
                            provider.unreadCount > 99
                                ? '99+'
                                : '${provider.unreadCount}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: provider.unreadCount > 99 ? 8.sp : 9.sp,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
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
      ],
    );
  }

  Widget _buildSlider(double sliderHeight) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: ModernPremiumSlider(
          bannerImages: _bannerImages,
          height: sliderHeight,
          autoPlayInterval: const Duration(seconds: 5),
          borderRadius: 20.r,
          showControls: false,
          showPlayPauseButton: false,
          onImageTap: (index) {
            print('Tapped image at index: $index');
          },
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - (2 * 14.w)) / 3;
          final itemHeight = itemWidth / 0.95;

          return Wrap(
            spacing: 14.w,
            runSpacing: 14.h,
            children: _visibleCategories.map((category) {
              return SizedBox(
                width: itemWidth,
                height: itemHeight,
                child: _buildCategoryCard(category),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleCategoryTap(category),
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: AppColors.grey200.withOpacity(0.6),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (category['color'] as Color).withOpacity(0.15),
                      (category['color'] as Color).withOpacity(0.08),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (category['color'] as Color).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  category['icon'] as IconData,
                  size: 28.sp,
                  color: category['color'] as Color,
                ),
              ),
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Text(
                  category['label'] as String,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.3,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
