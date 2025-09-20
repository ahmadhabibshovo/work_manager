import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/priority.dart';

class PriorityBadge extends StatelessWidget {
  final Priority priority;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor;
    final Color textColor;

    switch (priority) {
      case Priority.high:
        backgroundColor = AppTheme.highPriorityColor.withOpacity(0.1);
        textColor = AppTheme.highPriorityColor;
        break;
      case Priority.medium:
        backgroundColor = AppTheme.mediumPriorityColor.withOpacity(0.1);
        textColor = AppTheme.mediumPriorityColor;
        break;
      case Priority.low:
        backgroundColor = AppTheme.lowPriorityColor.withOpacity(0.1);
        textColor = AppTheme.lowPriorityColor;
        break;
    }

    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: textColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        priority.displayName,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize ?? 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}