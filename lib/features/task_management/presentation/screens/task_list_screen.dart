import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/task.dart';
import '../../data/models/priority.dart';
import '../../../categories/data/models/category.dart';
import '../../../categories/data/repositories/category_repository.dart';
import '../../../../core/services/service_locator.dart';
import '../widgets/task_card.dart';
import 'edit_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  // Global key to access the state from outside
  static final GlobalKey<TaskListScreenState> globalKey = GlobalKey<TaskListScreenState>();

  @override
  TaskListScreenState createState() => TaskListScreenState();
}

class TaskListScreenState extends State<TaskListScreen> with WidgetsBindingObserver {
  List<Task> _tasks = [];
  bool _isLoading = true;
  String _selectedFilter = 'all'; // 'all' means "all priorities"
  String _taskStatusFilter = 'pending'; // 'all', 'pending', 'completed'
  String _selectedCategoryId = 'all'; // 'all' means "all categories"

  // Dynamic categories loaded from database
  List<Category> _availableCategories = [];
  bool _isLoadingCategories = true;
  late CategoryRepository _categoryRepository;

  // Track if priorities have been adjusted by dragging
  bool _hasPriorityBeenAdjusted = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _initializeData() async {
    await _loadCategories();
    _loadTasks();
  }

  Future<void> _loadCategories() async {
    try {
      _categoryRepository = await ServiceLocator.getCategoryRepository();
      final categories = await _categoryRepository.getAllCategories();
      if (mounted) {
        setState(() {
          _availableCategories = categories;
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh both tasks and categories when app comes back into focus
      _refreshData();
    }
  }

  void _refreshData() {
    _loadCategories();
    _refreshTasks();
  }

  void _loadTasks() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final repository = await ServiceLocator.getTaskRepository();
      final tasks = await repository.getAllTasks();
      if (mounted) {
        setState(() {
          _tasks = tasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading tasks: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _refreshTasks() {
    _loadTasks();
  }

  // Public method to refresh tasks from outside
  void refreshTasks() {
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          // Category filter
          PopupMenuButton<String>(
            onSelected: (categoryId) => setState(() => _selectedCategoryId = categoryId),
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'all',
                child: Row(
                  children: [
                    Icon(
                      Icons.category,
                      size: 20.sp,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    SizedBox(width: 8.w),
                    const Text('All Categories'),
                  ],
                ),
              ),
              if (_isLoadingCategories)
                PopupMenuItem<String>(
                  value: null,
                  enabled: false,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20.sp,
                        height: 20.sp,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      const Text('Loading categories...'),
                    ],
                  ),
                )
              else
                ..._availableCategories.map((category) => PopupMenuItem<String>(
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
                    _selectedCategoryId == 'all' || _isLoadingCategories || _availableCategories.isEmpty
                        ? Icons.category
                        : _availableCategories
                            .firstWhere(
                              (cat) => cat.id == _selectedCategoryId,
                              orElse: () => _availableCategories.isNotEmpty ? _availableCategories.first : Category(
                                id: 'all',
                                name: 'All Categories',
                                type: CategoryType.other,
                                createdAt: DateTime.now(),
                              ),
                            )
                            .icon,
                    size: 20.sp,
                    color: _selectedCategoryId == 'all' || _isLoadingCategories || _availableCategories.isEmpty
                        ? Theme.of(context).colorScheme.onSurface
                        : _availableCategories
                            .firstWhere(
                              (cat) => cat.id == _selectedCategoryId,
                              orElse: () => _availableCategories.isNotEmpty ? _availableCategories.first : Category(
                                id: 'all',
                                name: 'All Categories',
                                type: CategoryType.other,
                                createdAt: DateTime.now(),
                              ),
                            )
                            .color,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    _selectedCategoryId == 'all' || _isLoadingCategories || _availableCategories.isEmpty
                        ? 'All'
                        : _availableCategories
                            .firstWhere(
                              (cat) => cat.id == _selectedCategoryId,
                              orElse: () => _availableCategories.isNotEmpty ? _availableCategories.first : Category(
                                id: 'all',
                                name: 'All Categories',
                                type: CategoryType.other,
                                createdAt: DateTime.now(),
                              ),
                            )
                            .name,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  Icon(Icons.arrow_drop_down, size: 20.sp),
                ],
              ),
            ),
          ),
          // Priority filter
          PopupMenuButton<String>(
            onSelected: (filter) => setState(() => _selectedFilter = filter),
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'all', // 'all' means "all priorities"
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
              ...Priority.values.map((priority) => PopupMenuItem<String>(
                    value: priority.name,
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
                    _selectedFilter == 'all'
                        ? Icons.list
                        : _getPriorityFromName(_selectedFilter).icon,
                    size: 20.sp,
                    color: _selectedFilter == 'all'
                        ? Theme.of(context).colorScheme.onSurface
                        : _getPriorityFromName(_selectedFilter).color,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    _selectedFilter == 'all'
                        ? 'All'
                        : _getPriorityFromName(_selectedFilter).displayName,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  Icon(Icons.arrow_drop_down, size: 20.sp),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildTaskList(),
    );
  }

  Widget _buildTaskList() {
    final filteredTasks = _getFilteredTasks(_tasks);

    return Column(
      children: [
        // Filter chips
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            children: [
              FilterChip(
                label: const Text('Pending'),
                selected: _taskStatusFilter == 'pending',
                onSelected: (selected) => setState(() => _taskStatusFilter = selected ? 'pending' : 'all'),
              ),
              SizedBox(width: 8.w),
              FilterChip(
                label: const Text('Completed'),
                selected: _taskStatusFilter == 'completed',
                onSelected: (selected) => setState(() => _taskStatusFilter = selected ? 'completed' : 'all'),
              ),
              SizedBox(width: 8.w),
              FilterChip(
                label: const Text('All'),
                selected: _taskStatusFilter == 'all',
                onSelected: (selected) => setState(() => _taskStatusFilter = selected ? 'all' : 'pending'),
              ),
            ],
          ),
        ),

        // Task list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _refreshTasks();
            },
            child: filteredTasks.isEmpty
                ? _buildEmptyState()
                : Scrollbar(
                    child: ReorderableListView.builder(
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        final taskCategory = task.categoryId != null
                            ? _availableCategories.firstWhere(
                                (cat) => cat.id == task.categoryId,
                                orElse: () {
                                  // Try to find by type if ID doesn't match
                                  final categoryByType = _availableCategories.firstWhere(
                                    (cat) => cat.type.name == task.categoryId,
                                    orElse: () => Category(
                                      id: '',
                                      name: 'Unknown',
                                      type: CategoryType.other,
                                      createdAt: DateTime.now(),
                                    ),
                                  );
                                  if (categoryByType.id.isNotEmpty) {
                                    return categoryByType;
                                  }
                                  // Handle legacy category IDs
                                  return _getCategoryFromLegacyId(task.categoryId!);
                                },
                              )
                            : null;
                        return TaskCard(
                          key: ValueKey(task.id),
                          task: task,
                          category: taskCategory,
                          onTap: () => _editTask(task),
                          onToggleComplete: () => _toggleTaskComplete(task),
                        );
                      },
                      onReorder: (oldIndex, newIndex) async {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final task = filteredTasks.removeAt(oldIndex);
                        filteredTasks.insert(newIndex, task);

                        // Adjust priority based on new position
                        final adjustedTask = _adjustTaskPriorityBasedOnPosition(task, newIndex, filteredTasks);

                        // Update the task in the list
                        filteredTasks[newIndex] = adjustedTask;

                        // Mark that priority has been adjusted by dragging
                        _hasPriorityBeenAdjusted = true;

                        // Update orders for all tasks in the filtered list
                        for (int i = 0; i < filteredTasks.length; i++) {
                          filteredTasks[i] = filteredTasks[i].copyWith(order: i);
                        }

                        // Re-sort the filtered tasks to maintain priority and due date order
                        filteredTasks.sort((a, b) {
                          // First sort by priority (higher priority first)
                          if (a.priority.value != b.priority.value) {
                            return b.priority.value.compareTo(a.priority.value);
                          }
                          // Then sort by due date (earlier dates first)
                          if (a.dueDate != null && b.dueDate != null) {
                            return a.dueDate!.compareTo(b.dueDate!);
                          }
                          // Tasks with due dates come before tasks without due dates
                          if (a.dueDate != null && b.dueDate == null) {
                            return -1;
                          }
                          if (a.dueDate == null && b.dueDate != null) {
                            return 1;
                          }
                          // Finally sort by creation date
                          return a.createdAt.compareTo(b.createdAt);
                        });

                        // Update orders again after sorting to reflect the new order
                        for (int i = 0; i < filteredTasks.length; i++) {
                          filteredTasks[i] = filteredTasks[i].copyWith(order: i);
                        }

                        // Save updated tasks to repository
                        try {
                          final repository = await ServiceLocator.getTaskRepository();
                          for (final updatedTask in filteredTasks) {
                            await repository.updateTask(updatedTask);
                          }
                          
                          // Update local state with the reordered tasks
                          setState(() {
                            // Update the tasks that were reordered
                            for (final updatedTask in filteredTasks) {
                              final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
                              if (index != -1) {
                                _tasks[index] = updatedTask;
                              }
                            }
                          });
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to reorder tasks: $e'),
                                backgroundColor: Theme.of(context).colorScheme.error,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  List<Task> _getFilteredTasks(List<Task> tasks) {
    var filteredTasks = tasks;

    // Filter by category
    if (_selectedCategoryId != 'all') {
      // Find the selected category to get its type
      final selectedCategory = _availableCategories.firstWhere(
        (cat) => cat.id == _selectedCategoryId,
        orElse: () => Category(
          id: _selectedCategoryId,
          name: 'Unknown',
          type: CategoryType.other,
          createdAt: DateTime.now(),
        ),
      );

      // Filter tasks that match either the category ID or the legacy ID
      filteredTasks = filteredTasks.where((task) {
        if (task.categoryId == null) return false;

        // Check if task category ID matches the selected category ID
        if (task.categoryId == _selectedCategoryId) return true;

        // Check if task category ID matches the selected category type
        if (task.categoryId == selectedCategory.type.name) return true;

        // Check legacy ID mapping
        final legacyId = _getLegacyIdFromCategoryId(_selectedCategoryId);
        if (task.categoryId == legacyId) return true;

        return false;
      }).toList();
    }

    // Filter by priority
    if (_selectedFilter != 'all') {
      final selectedPriority = _getPriorityFromName(_selectedFilter);
      filteredTasks = filteredTasks.where((task) => task.priority == selectedPriority).toList();
    }

    // Filter by completion status
    if (_taskStatusFilter == 'pending') {
      filteredTasks = filteredTasks.where((task) => !task.isCompleted).toList();
    } else if (_taskStatusFilter == 'completed') {
      filteredTasks = filteredTasks.where((task) => task.isCompleted).toList();
    }
    // For 'all', no filtering needed

    // Always sort by priority (Urgent > High > Medium > Low) then by due date
    // Manual order is only used when no filters are applied AND tasks haven't been reordered by priority changes
    final hasManualOrder = filteredTasks.any((task) => (task.order ?? 0) > 0) && !_hasPriorityBeenAdjusted;

    if (_selectedFilter == 'all' && _taskStatusFilter == 'all' && _selectedCategoryId == 'all' && hasManualOrder) {
      filteredTasks.sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
    } else {
      filteredTasks.sort((a, b) {
        // First sort by priority (higher priority first)
        if (a.priority.value != b.priority.value) {
          return b.priority.value.compareTo(a.priority.value);
        }
        // Then sort by due date (earlier dates first)
        if (a.dueDate != null && b.dueDate != null) {
          return a.dueDate!.compareTo(b.dueDate!);
        }
        // Tasks with due dates come before tasks without due dates
        if (a.dueDate != null && b.dueDate == null) {
          return -1;
        }
        if (a.dueDate == null && b.dueDate != null) {
          return 1;
        }
        // Finally sort by creation date
        return a.createdAt.compareTo(b.createdAt);
      });
    }

    return filteredTasks;
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

  Category _getCategoryFromLegacyId(String legacyId) {
    // Map legacy category IDs to new category types
    switch (legacyId) {
      case '1':
        return _availableCategories.firstWhere(
          (cat) => cat.type == CategoryType.work,
          orElse: () => Category(
            id: 'work',
            name: 'Work',
            type: CategoryType.work,
            createdAt: DateTime.now(),
          ),
        );
      case '2':
        return _availableCategories.firstWhere(
          (cat) => cat.type == CategoryType.personal,
          orElse: () => Category(
            id: 'personal',
            name: 'Personal',
            type: CategoryType.personal,
            createdAt: DateTime.now(),
          ),
        );
      case '3':
        return _availableCategories.firstWhere(
          (cat) => cat.type == CategoryType.health,
          orElse: () => Category(
            id: 'health',
            name: 'Health',
            type: CategoryType.health,
            createdAt: DateTime.now(),
          ),
        );
      case '4':
        return _availableCategories.firstWhere(
          (cat) => cat.type == CategoryType.education,
          orElse: () => Category(
            id: 'education',
            name: 'Education',
            type: CategoryType.education,
            createdAt: DateTime.now(),
          ),
        );
      default:
        return Category(
          id: '',
          name: 'Unknown',
          type: CategoryType.other,
          createdAt: DateTime.now(),
        );
    }
  }

  String _getLegacyIdFromCategoryId(String categoryId) {
    // Map new category IDs to legacy category IDs
    switch (categoryId) {
      case 'work':
        return '1';
      case 'personal':
        return '2';
      case 'health':
        return '3';
      case 'education':
        return '4';
      default:
        return categoryId; // Return as-is if no mapping found
    }
  }

  void _editTask(Task task) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditTaskScreen(task: task),
      ),
    );

    if (result != null && result is Task) {
      // Task was updated
      try {
        final repository = await ServiceLocator.getTaskRepository();
        final updatedTask = await repository.updateTask(result);
        setState(() {
          final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
          if (index != -1) {
            _tasks[index] = updatedTask;
          }
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update task: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } else if (result == 'deleted') {
      // Task was deleted - remove from local state
      setState(() {
        _tasks.removeWhere((t) => t.id == task.id);
      });
    }
  }

  void _toggleTaskComplete(Task task) async {
    try {
      final repository = await ServiceLocator.getTaskRepository();
      final updatedTask = task.copyWith(
        isCompleted: !task.isCompleted,
        updatedAt: DateTime.now(),
      );
      await repository.updateTask(updatedTask);
      
      // Update local state
      setState(() {
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks[index] = updatedTask;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update task: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Priority _getPriorityFromName(String name) {
    return Priority.values.firstWhere(
      (priority) => priority.name == name,
      orElse: () => Priority.low, // fallback
    );
  }

  Task _adjustTaskPriorityBasedOnPosition(Task task, int newIndex, List<Task> tasks) {
    if (tasks.isEmpty) return task;

    Priority expectedPriority = task.priority;

    // Special cases for top and bottom positions
    if (newIndex == 0) {
      // Dragged to the top - becomes Urgent
      expectedPriority = Priority.urgent;
    } else if (newIndex == tasks.length - 1) {
      // Dragged to the bottom - becomes Low
      expectedPriority = Priority.low;
    } else {
      // For middle positions, match the priority of the task immediately above
      final taskAbove = tasks[newIndex - 1];
      expectedPriority = taskAbove.priority;
    }

    // Only update if priority actually changed
    if (expectedPriority != task.priority) {
      return task.copyWith(
        priority: expectedPriority,
        updatedAt: DateTime.now(),
      );
    }

    return task;
  }
}
