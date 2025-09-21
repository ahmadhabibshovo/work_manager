import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/task.dart';
import '../../../categories/data/models/category.dart';
import '../../../../core/services/service_locator.dart';
import '../widgets/task_form.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
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

  bool _isSaving = false;
  final GlobalKey<TaskFormState> _formKey = GlobalKey<TaskFormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Task',
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
          if (_isSaving)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: SizedBox(
                width: 20.w,
                height: 20.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            )
          else
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
            availableCategories: _availableCategories,
            onSave: _onTaskSaved,
          ),
        ),
      ),
    );
  }

  void _saveTask() {
    // Trigger the form's save method
    _formKey.currentState?.save();
  }

  void _onTaskSaved(Task task) async {
    setState(() => _isSaving = true);

    try {
      final repository = await ServiceLocator.getTaskRepository();
      await repository.createTask(task);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task "${task.title}" created successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate back to the previous screen
        Navigator.of(context).pop(task);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create task: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}