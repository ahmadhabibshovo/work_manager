import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/task.dart';
import '../../data/models/priority.dart';
import '../../../categories/data/models/category.dart';
import '../../../settings/data/models/user_preferences.dart';
import '../../../../core/services/service_locator.dart';
import '../widgets/task_form.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  // Remove hardcoded categories - will load from repository
  List<Category> _availableCategories = [];
  bool _isSaving = false;
  final GlobalKey<TaskFormState> _formKey = GlobalKey<TaskFormState>();
  UserPreferences _preferences = const UserPreferences();
  bool _isLoadingPreferences = true;
  Priority? _defaultPriority;
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final repository = await ServiceLocator.getCategoryRepository();
      final categories = await repository.getAllCategories();
      if (mounted) {
        setState(() {
          _availableCategories = categories;
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load categories: $e')),
        );
      }
    }
  }

  Future<void> _loadPreferences() async {
    try {
      final service = await ServiceLocator.getPreferencesService();
      final preferences = await service.getUserPreferences();
      if (mounted) {
        setState(() {
          _preferences = preferences;
          _defaultPriority = _intToPriority(preferences.defaultTaskPriority);
          _isLoadingPreferences = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingPreferences = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load preferences: $e')),
        );
      }
    }
  }

  Priority _intToPriority(int priorityInt) {
    // Map int (1=low, 2=medium, 3=high, 4=urgent) to Priority enum
    switch (priorityInt) {
      case 1:
        return Priority.low;
      case 2:
        return Priority.medium;
      case 3:
        return Priority.high;
      case 4:
        return Priority.urgent;
      default:
        return Priority.medium;
    }
  }
  @override
  Widget build(BuildContext context) {
    if (_isLoadingPreferences || _isLoadingCategories) {
      return Scaffold(
        appBar: AppBar(title: const Text('Create Task')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
            defaultPriority: _defaultPriority,
            defaultCategoryId: _preferences.defaultCategoryId,
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