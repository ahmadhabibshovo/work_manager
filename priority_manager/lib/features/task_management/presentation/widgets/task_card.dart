import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.r),
      child: ListTile(
        title: Text(task.title),
        subtitle: Text('${task.priority} - ${task.dueDate?.toString() ?? 'No due date'}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            // Delete logic (call repository)
          },
        ),
      ),
    );
  }
}