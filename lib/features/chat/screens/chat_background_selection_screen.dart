import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../shared/utils/app_colors.dart';
import '../providers/chat_background_provider.dart';

class ChatBackgroundSelectionScreen extends StatelessWidget {
  const ChatBackgroundSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Chat Background'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          Consumer<ChatBackgroundProvider>(
            builder: (context, provider, _) {
              return TextButton(
                onPressed: () => provider.resetToDefault(),
                child: Text(
                  'Reset',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            // Tab bar
            Container(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              child: TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(text: 'Colors'),
                  Tab(text: 'Gradients'),
                  Tab(text: 'Patterns'),
                  Tab(text: 'Image'),
                ],
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                children: [
                  _buildColorsTab(context, isDark),
                  _buildGradientsTab(context, isDark),
                  _buildPatternsTab(context, isDark),
                  _buildImageTab(context, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorsTab(BuildContext context, bool isDark) {
    return Consumer<ChatBackgroundProvider>(
      builder: (context, provider, _) {
        final colors = ChatBackgroundProvider.backgroundColors;

        return GridView.builder(
          padding: EdgeInsets.all(16.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12.w,
            crossAxisSpacing: 12.w,
          ),
          itemCount: colors.length,
          itemBuilder: (context, index) {
            final isSelected = provider.backgroundType == BackgroundType.color &&
                provider.colorIndex == index;

            return GestureDetector(
              onTap: () => provider.setColor(index),
              child: Container(
                decoration: BoxDecoration(
                  color: colors[index],
                  borderRadius: BorderRadius.circular(12.r),
                  border: isSelected
                      ? Border.all(color: AppColors.primary, width: 3)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isSelected
                    ? Center(
                        child: Icon(
                          Icons.check,
                          color: AppColors.textPrimary,
                          size: 24.sp,
                        ),
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGradientsTab(BuildContext context, bool isDark) {
    return Consumer<ChatBackgroundProvider>(
      builder: (context, provider, _) {
        final gradients = ChatBackgroundProvider.backgroundGradients;

        return GridView.builder(
          padding: EdgeInsets.all(16.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12.w,
            crossAxisSpacing: 12.w,
            childAspectRatio: 0.7,
          ),
          itemCount: gradients.length,
          itemBuilder: (context, index) {
            final isSelected =
                provider.backgroundType == BackgroundType.gradient &&
                    provider.gradientIndex == index;

            return GestureDetector(
              onTap: () => provider.setGradient(index),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradients[index],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  border: isSelected
                      ? Border.all(color: AppColors.primary, width: 3)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isSelected
                    ? Center(
                        child: Icon(
                          Icons.check,
                          color: AppColors.textPrimary,
                          size: 24.sp,
                        ),
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPatternsTab(BuildContext context, bool isDark) {
    return Consumer<ChatBackgroundProvider>(
      builder: (context, provider, _) {
        final patterns = ChatBackgroundProvider.patternEmoji;

        return GridView.builder(
          padding: EdgeInsets.all(16.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12.w,
            crossAxisSpacing: 12.w,
          ),
          itemCount: patterns.length,
          itemBuilder: (context, index) {
            final isSelected =
                provider.backgroundType == BackgroundType.pattern &&
                    provider.patternIndex == index;

            return GestureDetector(
              onTap: () => provider.setPattern(index),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.grey700 : AppColors.grey100,
                  borderRadius: BorderRadius.circular(12.r),
                  border: isSelected
                      ? Border.all(color: AppColors.primary, width: 3)
                      : null,
                ),
                child: Center(
                  child: Text(
                    patterns[index],
                    style: TextStyle(fontSize: 32.sp),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildImageTab(BuildContext context, bool isDark) {
    return Consumer<ChatBackgroundProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // Preview
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.grey700 : AppColors.grey100,
                    borderRadius: BorderRadius.circular(16.r),
                    image: provider.customImagePath != null
                        ? DecorationImage(
                            image: FileImage(File(provider.customImagePath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                    border: provider.backgroundType == BackgroundType.image
                        ? Border.all(color: AppColors.primary, width: 3)
                        : null,
                  ),
                  child: provider.customImagePath == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                size: 60.sp,
                                color: AppColors.grey400,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'No custom image',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : null,
                ),
              ),

              SizedBox(height: 16.h),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: provider.isLoading
                          ? null
                          : () => provider.pickCustomImage(),
                      icon: provider.isLoading
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.add_photo_alternate_outlined),
                      label: Text(
                        provider.customImagePath == null
                            ? 'Choose Image'
                            : 'Change Image',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textPrimary,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                    ),
                  ),
                  if (provider.customImagePath != null) ...[
                    SizedBox(width: 12.w),
                    IconButton(
                      onPressed: () => provider.clearCustomImage(),
                      icon: Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor:
                            isDark ? AppColors.grey700 : AppColors.grey100,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
