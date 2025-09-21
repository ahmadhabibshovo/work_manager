import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/task.dart';
import '../../../categories/data/models/category.dart';
import '../widgets/task_form.dart';
import '../../../../core/services/service_locator.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({
    super.key,
    required this.task,
  });

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  // Mock categories - replace with actual data from repository
  final List<Category> _availableCategories = [
    Category(
      id: '1',
      name: 'Work',
      type: CategoryType.work,
      createdAt: DateTime.now(),
    ),
    Category(
      id: '2',
      name: 'Personal',
      type: CategoryType.personal,
      createdAt: DateTime.now(),
    ),
    Category(
      id: '3',
      name: 'Health',
      type: CategoryType.health,
      createdAt: DateTime.now(),
    ),
    Category(
      id: '4',
      name: 'Education',
      type: CategoryType.education,
      createdAt: DateTime.now(),
    ),
  ];
  
  final GlobalKey<TaskFormState> _formKey = GlobalKey<TaskFormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Task',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: Text(
              'Save',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: TaskForm(
            key: _formKey,
            task: widget.task,
            availableCategories: _availableCategories,
            onSave: _onTaskSaved,
            onDelete: _deleteTask,
          ),
        ),
      ),
    );
  }

  void _saveTask() {
    // Trigger the form's save method
    _formKey.currentState?.save();
  }

  void _deleteTask() async {
    try {
      final repository = await ServiceLocator.getTaskRepository();
      await repository.deleteTask(widget.task.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task "${widget.task.title}" deleted successfully!'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 2),
        ),
      );
      // Navigate back to the previous screen with deletion result
      Navigator.of(context).pop('deleted');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to delete task. Please try again.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _onTaskSaved(Task task) {
    // Handle the saved task - for now just show a success message and go back
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task "${task.title}" updated successfully!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );

    // Navigate back to the previous screen with the updated task
    Navigator.of(context).pop(task);
  }
}