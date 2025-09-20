import 'package:hive/hive.dart';
import '../models/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks();
  Future<void> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);
}

class TaskRepositoryImpl implements TaskRepository {
  final Box<Task> _tasksBox = Hive.box<Task>('tasksBox');

  @override
  Future<List<Task>> getTasks() async {
    return _tasksBox.values.toList();
  }

  @override
  Future<void> addTask(Task task) async {
    await _tasksBox.put(task.id, task);
  }

  @override
  Future<void> updateTask(Task task) async {
    await task.save();
  }

  @override
  Future<void> deleteTask(String id) async {
    await _tasksBox.delete(id);
  }
}