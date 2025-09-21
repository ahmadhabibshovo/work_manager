import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sync_service.dart';
import '../../features/categories/data/models/category.dart';
import '../../features/categories/data/repositories/category_repository.dart';
import '../../features/task_management/data/models/priority.dart';
import '../../features/task_management/data/models/task.dart';
import '../../features/task_management/data/models/task_attachment.dart';
import '../../features/task_management/data/repositories/task_repository.dart';
import '../../features/settings/data/services/preferences_service.dart';

class ServiceLocator {
  static CategoryRepository? _categoryRepository;
  static TaskRepository? _taskRepository;
  static PreferencesService? _preferencesService;
  static SyncService? _syncService;

  static Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapter(CategoryTypeAdapter());
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(PriorityAdapter());
    Hive.registerAdapter(AttachmentTypeAdapter());
    Hive.registerAdapter(TaskAttachmentAdapter());
    Hive.registerAdapter(TaskAdapter());

    _syncService = SyncService();
    await _syncService!.initialize();

    _categoryRepository = CategoryRepositoryImpl(_syncService!);
    await _categoryRepository!.initialize();

    _taskRepository = TaskRepositoryImpl(_syncService!);
    await _taskRepository!.initialize();

    final prefs = await SharedPreferences.getInstance();
    _preferencesService = PreferencesServiceImpl(prefs);
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

  static Future<PreferencesService> getPreferencesService() async {
    if (_preferencesService != null) {
      return _preferencesService!;
    }

    await initialize();
    return _preferencesService!;
  }
}