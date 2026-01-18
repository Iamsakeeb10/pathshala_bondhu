import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/utils/app_colors.dart';

class TypingIndicator extends StatefulWidget {
  final bool isTyping;
  final String? userName;
  final Duration debounceTime;

  const TypingIndicator({
    super.key,
    required this.isTyping,
    this.userName,
    this.debounceTime = const Duration(milliseconds: 500),
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _visibilityController;
  late Animation<double> _visibilityAnimation;
  bool _isVisible = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _visibilityController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _visibilityAnimation = CurvedAnimation(
      parent: _visibilityController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(TypingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isTyping != oldWidget.isTyping) {
      _handleTypingChange();
    }
  }

  void _handleTypingChange() {
    _hideTimer?.cancel();

    if (widget.isTyping) {
      setState(() => _isVisible = true);
      _visibilityController.forward();
    } else {
      _hideTimer = Timer(widget.debounceTime, () {
        if (mounted) {
          _visibilityController.reverse().then((_) {
            if (mounted) {
              setState(() => _isVisible = false);
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _animationController.dispose();
    _visibilityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _visibilityAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.5),
          end: Offset.zero,
        ).animate(_visibilityAnimation),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.only(left: 12.w, bottom: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                SizedBox(width: 4.w),
                _buildDot(1),
                SizedBox(width: 4.w),
                _buildDot(2),
                if (widget.userName != null) ...[
                  SizedBox(width: 8.w),
                  Text(
                    '${widget.userName} is typing',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final progress = (_animationController.value * 3 - index).clamp(0.0, 1.0);
        final scale = 1.0 + (0.4 * (1 - (2 * progress - 1).abs()));

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.7 + 0.3 * progress),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
