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
  Future<List<Task>>? _tasksFuture;
  Priority _selectedFilter = Priority.medium;
  bool _showCompleted = true;
  String _selectedCategoryId = 'all'; // 'all' means "all categories"

  // Dynamic categories loaded from database
  List<Category> _availableCategories = [];
  bool _isLoadingCategories = true;
  late CategoryRepository _categoryRepository;

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

  void _loadTasks() {
    _tasksFuture = ServiceLocator.getTaskRepository().then((repo) => repo.getAllTasks());
  }

  void _refreshTasks() {
    setState(() {
      _loadTasks();
    });
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
      body: _tasksFuture == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Task>>(
              future: _tasksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64.sp,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Failed to load tasks',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          snapshot.error.toString(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final tasks = snapshot.data ?? [];
                final filteredTasks = _getFilteredTasks(tasks);

          return Column(
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
                child: RefreshIndicator(
                  onRefresh: () async {
                    _refreshTasks();
                  },
                  child: filteredTasks.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
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
                              task: task,
                              category: taskCategory,
                              onTap: () => _editTask(task),
                              onToggleComplete: () => _toggleTaskComplete(task),
                              onEdit: () => _editTask(task),
                              onDelete: () => _deleteTask(task),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
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
    if (_selectedFilter != Priority.medium) { // medium represents "all"
      filteredTasks = filteredTasks.where((task) => task.priority == _selectedFilter).toList();
    }

    // Filter by completion status
    if (!_showCompleted) {
      filteredTasks = filteredTasks.where((task) => !task.isCompleted).toList();
    }

    // Sort by priority (high to low) then by due date
    filteredTasks.sort((a, b) {
      if (a.priority.value != b.priority.value) {
        return b.priority.value.compareTo(a.priority.value);
      }
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      return a.createdAt.compareTo(b.createdAt);
    });

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
      try {
        final repository = await ServiceLocator.getTaskRepository();
        await repository.updateTask(result);
        _refreshTasks();
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
  }

  void _toggleTaskComplete(Task task) async {
    try {
      final repository = await ServiceLocator.getTaskRepository();
      final updatedTask = task.copyWith(
        isCompleted: !task.isCompleted,
        updatedAt: DateTime.now(),
      );
      await repository.updateTask(updatedTask);
      _refreshTasks();
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

  void _deleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final repository = await ServiceLocator.getTaskRepository();
        await repository.deleteTask(task.id);
        _refreshTasks();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete task: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}
