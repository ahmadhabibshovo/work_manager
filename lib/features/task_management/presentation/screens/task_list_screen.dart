import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/task.dart';
import '../../data/models/priority.dart';
import '../../../categories/data/models/category.dart';
import '../widgets/task_card.dart';
import 'create_task_screen.dart';
import 'edit_task_screen.dart';

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
      categoryId: '1', // Work category
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Task(
      id: '2',
      title: 'Review code changes',
      description: 'Review pull requests and provide feedback',
      priority: Priority.medium,
      isCompleted: true,
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
      categoryId: '1', // Work category
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Task(
      id: '3',
      title: 'Update dependencies',
      description: 'Update all project dependencies to latest versions',
      priority: Priority.low,
      isCompleted: false,
      categoryId: '1', // Work category
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Task(
      id: '4',
      title: 'Morning workout',
      description: '30 minutes cardio and strength training',
      priority: Priority.medium,
      isCompleted: false,
      categoryId: '3', // Health category
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Task(
      id: '5',
      title: 'Grocery shopping',
      description: 'Buy groceries for the week',
      priority: Priority.low,
      isCompleted: false,
      categoryId: '2', // Personal category
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  Priority _selectedFilter = Priority.medium;
  bool _showCompleted = true;
  String? _selectedCategoryId; // null means "all categories"

  // Available categories for filtering
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

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _getFilteredTasks();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          // Category filter
          PopupMenuButton<String?>(
            onSelected: (categoryId) => setState(() => _selectedCategoryId = categoryId),
            itemBuilder: (context) => [
              PopupMenuItem<String?>(
                value: null,
                child: const Text('All Categories'),
              ),
              ..._availableCategories.map((category) => PopupMenuItem<String?>(
                    value: category.id,
                    child: Row(
                      children: [
                        Icon(
                          category.icon,
                          size: 20.sp,
                          color: category.color,
                        ),
                        SizedBox(width: 8.w),
                        Text(category.name),
                      ],
                    ),
                  )),
            ],
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Icon(
                    _selectedCategoryId != null
                        ? _availableCategories
                            .firstWhere((cat) => cat.id == _selectedCategoryId)
                            .icon
                        : Icons.category,
                    size: 20.sp,
                    color: _selectedCategoryId != null
                        ? _availableCategories
                            .firstWhere((cat) => cat.id == _selectedCategoryId)
                            .color
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    _selectedCategoryId != null
                        ? _availableCategories
                            .firstWhere((cat) => cat.id == _selectedCategoryId)
                            .name
                        : 'All',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  Icon(Icons.arrow_drop_down, size: 20.sp),
                ],
              ),
            ),
          ),
          // Priority filter
          PopupMenuButton<Priority>(
            onSelected: (priority) => setState(() => _selectedFilter = priority),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: Priority.medium, // Using medium as "all" filter
                child: Row(
                  children: [
                    Icon(
                      Icons.list,
                      size: 20.sp,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    SizedBox(width: 8.w),
                    const Text('All Priorities'),
                  ],
                ),
              ),
              ...Priority.values.map((priority) => PopupMenuItem(
                    value: priority,
                    child: Row(
                      children: [
                        Icon(
                          priority.icon,
                          size: 20.sp,
                          color: priority.color,
                        ),
                        SizedBox(width: 8.w),
                        Text(priority.displayName),
                      ],
                    ),
                  )),
            ],
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Icon(
                    _selectedFilter == Priority.medium
                        ? Icons.list
                        : _selectedFilter.icon,
                    size: 20.sp,
                    color: _selectedFilter == Priority.medium
                        ? Theme.of(context).colorScheme.onSurface
                        : _selectedFilter.color,
                  ),
                  SizedBox(width: 4.w),
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
                        onEdit: () => _editTask(task),
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

    // Filter by category
    if (_selectedCategoryId != null) {
      tasks = tasks.where((task) => task.categoryId == _selectedCategoryId).toList();
    }

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

  void _addNewTask() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateTaskScreen(),
      ),
    );

    if (result != null && result is Task) {
      setState(() {
        _tasks.add(result);
      });
    }
  }

  void _editTask(Task task) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditTaskScreen(task: task),
      ),
    );

    if (result != null && result is Task) {
      setState(() {
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks[index] = result;
        }
      });
    }
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
}