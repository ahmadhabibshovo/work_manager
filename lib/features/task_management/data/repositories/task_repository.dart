import 'package:hive/hive.dart';
import '../../../../core/services/sync_service.dart';
import '../models/task.dart';
import '../models/priority.dart';

abstract class TaskRepository {
  Future<List<Task>> getAllTasks();
  Future<Task?> getTaskById(String id);
  Future<Task> createTask(Task task);
  Future<Task> updateTask(Task task);
  Future<void> deleteTask(String id);
  Future<List<Task>> getTasksByPriority(Priority priority);
  Future<List<Task>> getCompletedTasks();
  Future<List<Task>> getPendingTasks();
  Future<void> initialize();
}

class TaskRepositoryImpl implements TaskRepository {
  static const String _boxName = 'tasks';
  late Box<Task> _box;
  final SyncService _syncService;

  TaskRepositoryImpl(this._syncService);

  @override
  Future<void> initialize() async {
    _box = await Hive.openBox<Task>(_boxName);
  }

  @override
  Future<List<Task>> getAllTasks() async {
    final tasks = _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return tasks;
  }

  @override
  Future<Task?> getTaskById(String id) async {
    return _box.get(id);
  }

  @override
  Future<Task> createTask(Task task) async {
    await _box.put(task.id, task);
    // Sync if online
    if (_syncService.isOnline) {
      try {
        await _syncService.manualSync();
      } catch (e) {
        // Sync failed, but don't fail the operation
        print('Sync failed after creating task: $e');
      }
    }
    return task;
  }

  @override
  Future<Task> updateTask(Task task) async {
    final updatedTask = task.copyWith(updatedAt: DateTime.now());
    await _box.put(task.id, updatedTask);
    // Sync if online
    if (_syncService.isOnline) {
      try {
        await _syncService.manualSync();
      } catch (e) {
        // Sync failed, but don't fail the operation
        print('Sync failed after updating task: $e');
      }
    }
    return updatedTask;
  }

  @override
  Future<void> deleteTask(String id) async {
    await _box.delete(id);
    // Sync if online
    if (_syncService.isOnline) {
      try {
        await _syncService.manualSync();
      } catch (e) {
        // Sync failed, but don't fail the operation
        print('Sync failed after deleting task: $e');
      }
    }
  }

  @override
  Future<List<Task>> getTasksByPriority(Priority priority) async {
    final tasks = _box.values.where((task) => task.priority == priority).toList();
    return tasks;
  }

  @override
  Future<List<Task>> getCompletedTasks() async {
    final tasks = _box.values.where((task) => task.isCompleted).toList();
    return tasks;
  }

  @override
  Future<List<Task>> getPendingTasks() async {
    final tasks = _box.values.where((task) => !task.isCompleted).toList();
    return tasks;
  }
}