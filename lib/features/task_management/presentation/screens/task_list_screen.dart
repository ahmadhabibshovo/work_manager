import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/task.dart';
import '../../data/models/priority.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // Mock data for now - will be replaced with actual repository
  List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Complete project documentation',
      description: 'Write comprehensive documentation for the Flutter app',
      priority: Priority.high,
      isCompleted: false,
      dueDate: DateTime.now().add(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Task(
      id: '2',
      title: 'Review code changes',
      description: 'Review pull requests and provide feedback',
      priority: Priority.medium,
      isCompleted: true,
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Task(
      id: '3',
      title: 'Update dependencies',
      description: 'Update all project dependencies to latest versions',
      priority: Priority.low,
      isCompleted: false,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  Priority _selectedFilter = Priority.medium;
  bool _showCompleted = true;

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _getFilteredTasks();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          PopupMenuButton<Priority>(
            onSelected: (priority) => setState(() => _selectedFilter = priority),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: Priority.medium, // Using medium as "all" filter
                child: const Text('All Priorities'),
              ),
              ...Priority.values.map((priority) => PopupMenuItem(
                    value: priority,
                    child: Text(priority.displayName),
                  )),
            ],
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Text(
                    _selectedFilter == Priority.medium
                        ? 'All'
                        : _selectedFilter.displayName,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  Icon(Icons.arrow_drop_down, size: 20.sp),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Pending'),
                  selected: !_showCompleted,
                  onSelected: (selected) => setState(() => _showCompleted = !selected),
                ),
                SizedBox(width: 8.w),
                FilterChip(
                  label: const Text('Completed'),
                  selected: _showCompleted,
                  onSelected: (selected) => setState(() => _showCompleted = selected),
                ),
              ],
            ),
          ),

          // Task list
          Expanded(
            child: filteredTasks.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return TaskCard(
                        task: task,
                        onTap: () => _editTask(task),
                        onToggleComplete: () => _toggleTaskComplete(task),
                        onDelete: () => _deleteTask(task),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewTask,
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Task> _getFilteredTasks() {
    var tasks = _tasks;

    // Filter by priority
    if (_selectedFilter != Priority.medium) { // medium represents "all"
      tasks = tasks.where((task) => task.priority == _selectedFilter).toList();
    }

    // Filter by completion status
    if (!_showCompleted) {
      tasks = tasks.where((task) => !task.isCompleted).toList();
    }

    // Sort by priority (high to low) then by due date
    tasks.sort((a, b) {
      if (a.priority.value != b.priority.value) {
        return b.priority.value.compareTo(a.priority.value);
      }
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      return a.createdAt.compareTo(b.createdAt);
    });

    return tasks;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 64.sp,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            'No tasks found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Create your first task to get started',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _addNewTask() {
    _showTaskDialog();
  }

  void _editTask(Task task) {
    _showTaskDialog(task: task);
  }

  void _toggleTaskComplete(Task task) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task.copyWith(
          isCompleted: !task.isCompleted,
          updatedAt: DateTime.now(),
        );
      }
    });
  }

  void _deleteTask(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _tasks.removeWhere((t) => t.id == task.id);
              });
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showTaskDialog({Task? task}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    task != null ? 'Edit Task' : 'New Task',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: TaskForm(
                    task: task,
                    onSave: (savedTask) {
                      setState(() {
                        if (task != null) {
                          // Update existing task
                          final index = _tasks.indexWhere((t) => t.id == task.id);
                          if (index != -1) {
                            _tasks[index] = savedTask;
                          }
                        } else {
                          // Add new task
                          _tasks.add(savedTask);
                        }
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}