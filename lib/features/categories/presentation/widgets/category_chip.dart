import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/category.dart';

class CategoryChip extends StatelessWidget {
  final Category category;
  final bool selected;
  final VoidCallback? onTap;
  final bool showIcon;
  final double? fontSize;

  const CategoryChip({
    super.key,
    required this.category,
    this.selected = false,
    this.onTap,
    this.showIcon = true,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected
              ? category.color.withOpacity(0.1)
              : category.color.withOpacity(0.05),
          border: Border.all(
            color: selected ? category.color : category.color.withOpacity(0.3),
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(
                category.icon,
                size: 16.sp,
                color: category.color,
              ),
              SizedBox(width: 6.w),
            ],
            Text(
              category.name,
              style: TextStyle(
                color: category.color,
                fontSize: fontSize ?? 14.sp,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}