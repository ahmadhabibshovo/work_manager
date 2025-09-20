import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
}

class TaskRepositoryImpl implements TaskRepository {
  static const String _tasksKey = 'tasks';
  final SharedPreferences _prefs;

  TaskRepositoryImpl(this._prefs);

  @override
  Future<List<Task>> getAllTasks() async {
    final tasksJson = _prefs.getStringList(_tasksKey) ?? [];
    return tasksJson.map((json) => Task.fromJson(jsonDecode(json))).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Task?> getTaskById(String id) async {
    final tasks = await getAllTasks();
    return tasks.where((task) => task.id == id).firstOrNull;
  }

  @override
  Future<Task> createTask(Task task) async {
    final tasks = await getAllTasks();
    tasks.add(task);

    final tasksJson = tasks.map((t) => jsonEncode(t.toJson())).toList();
    await _prefs.setStringList(_tasksKey, tasksJson);

    return task;
  }

  @override
  Future<Task> updateTask(Task task) async {
    final tasks = await getAllTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);

    if (index == -1) {
      throw Exception('Task not found');
    }

    final updatedTask = task.copyWith(updatedAt: DateTime.now());
    tasks[index] = updatedTask;

    final tasksJson = tasks.map((t) => jsonEncode(t.toJson())).toList();
    await _prefs.setStringList(_tasksKey, tasksJson);

    return updatedTask;
  }

  @override
  Future<void> deleteTask(String id) async {
    final tasks = await getAllTasks();
    tasks.removeWhere((task) => task.id == id);

    final tasksJson = tasks.map((t) => jsonEncode(t.toJson())).toList();
    await _prefs.setStringList(_tasksKey, tasksJson);
  }

  @override
  Future<List<Task>> getTasksByPriority(Priority priority) async {
    final tasks = await getAllTasks();
    return tasks.where((task) => task.priority == priority).toList();
  }

  @override
  Future<List<Task>> getCompletedTasks() async {
    final tasks = await getAllTasks();
    return tasks.where((task) => task.isCompleted).toList();
  }

  @override
  Future<List<Task>> getPendingTasks() async {
    final tasks = await getAllTasks();
    return tasks.where((task) => !task.isCompleted).toList();
  }
}