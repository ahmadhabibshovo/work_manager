import 'package:hive_flutter/hive_flutter.dart';
import '../../features/categories/data/models/category.dart';
import '../../features/categories/data/repositories/category_repository.dart';
import '../../features/task_management/data/models/priority.dart';
import '../../features/task_management/data/models/task.dart';
import '../../features/task_management/data/models/task_attachment.dart';
import '../../features/task_management/data/repositories/task_repository.dart';

class ServiceLocator {
  static CategoryRepository? _categoryRepository;
  static TaskRepository? _taskRepository;

  static Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapter(CategoryTypeAdapter());
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(PriorityAdapter());
    Hive.registerAdapter(AttachmentTypeAdapter());
    Hive.registerAdapter(TaskAttachmentAdapter());
    Hive.registerAdapter(TaskAdapter());

    _categoryRepository = CategoryRepositoryImpl();
    await _categoryRepository!.initialize();

    _taskRepository = TaskRepositoryImpl();
    await _taskRepository!.initialize();
  }

  static Future<CategoryRepository> getCategoryRepository() async {
    if (_categoryRepository != null) {
      return _categoryRepository!;
    }

    await initialize();
    return _categoryRepository!;
  }

  static Future<TaskRepository> getTaskRepository() async {
    if (_taskRepository != null) {
      return _taskRepository!;
    }

    await initialize();
    return _taskRepository!;
  }
}