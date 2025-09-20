import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/task.dart';
import 'priority_badge.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onToggleComplete,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isCompleted
                            ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Checkbox(
                    value: task.isCompleted,
                    onChanged: (value) => onToggleComplete?.call(),
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              if (task.description != null && task.description!.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  task.description!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: 12.h),
              Row(
                children: [
                  PriorityBadge(priority: task.priority),
                  if (task.dueDate != null) ...[
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.calendar_today,
                      size: 16.sp,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _formatDueDate(task.dueDate!),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (onEdit != null)
                    IconButton(
                      onPressed: onEdit,
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 20.sp,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  if (onDelete != null)
                    IconButton(
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete_outline,
                        size: 20.sp,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 0) {
      return 'In $difference days';
    } else {
      return '${difference.abs()} days ago';
    }
  }
}