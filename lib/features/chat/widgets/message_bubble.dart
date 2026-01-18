import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../shared/utils/app_colors.dart';
import '../models/chat_message_model.dart';

class MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final bool isMe;
  final bool showTimestamp;
  final bool isFirstInGroup;
  final bool isLastInGroup;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showTimestamp = true,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: child,
          ),
        );
      },
      child: Align(
        alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: 280.w),
          margin: EdgeInsets.only(
            left: widget.isMe ? 50.w : 12.w,
            right: widget.isMe ? 12.w : 50.w,
            top: widget.isFirstInGroup ? 8.h : 2.h,
            bottom: widget.isLastInGroup ? 4.h : 0,
          ),
          child: Column(
            crossAxisAlignment:
                widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: widget.isMe
                      ? (isDark ? AppColors.accent : AppColors.primary)
                      : (isDark ? AppColors.surfaceDark : Colors.white),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(widget.isFirstInGroup || widget.isMe ? 16.r : 4.r),
                    topRight: Radius.circular(widget.isFirstInGroup || !widget.isMe ? 16.r : 4.r),
                    bottomLeft: Radius.circular(widget.isLastInGroup || widget.isMe ? 16.r : 4.r),
                    bottomRight: Radius.circular(widget.isLastInGroup || !widget.isMe ? 16.r : 4.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.message.message,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: widget.isMe
                            ? AppColors.textPrimary
                            : (isDark ? Colors.white : AppColors.textPrimary),
                        height: 1.3,
                      ),
                    ),
                    if (widget.showTimestamp) ...[
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(widget.message.createdAt),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: widget.isMe
                                  ? AppColors.textSecondary.withOpacity(0.8)
                                  : (isDark
                                      ? Colors.white54
                                      : AppColors.textSecondary.withOpacity(0.7)),
                            ),
                          ),
                          if (widget.isMe) ...[
                            SizedBox(width: 4.w),
                            Icon(
                              widget.message.isSeen
                                  ? Icons.done_all
                                  : (widget.message.isSent ? Icons.done : Icons.access_time),
                              size: 14.sp,
                              color: widget.message.isSeen
                                  ? Colors.blue
                                  : AppColors.textSecondary.withOpacity(0.7),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime.toLocal());
  }
}
