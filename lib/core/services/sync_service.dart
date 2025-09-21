import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/task_management/data/models/task.dart';
import '../../features/categories/data/models/category.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final Connectivity _connectivity = Connectivity();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  Future<void> initialize() async {
    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    _isOnline = result != ConnectivityResult.none;

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) {
        final wasOnline = _isOnline;
        _isOnline = result != ConnectivityResult.none;

        // If we just came online, trigger sync
        if (!wasOnline && _isOnline) {
          _syncAllData();
        }
      },
    );
  }

  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
  }

  Future<void> manualSync() async {
    if (_isOnline) {
      await _syncAllData();
    } else {
      throw Exception('No internet connection available');
    }
  }

  Future<void> _syncAllData() async {
    try {
      await _syncTasks();
      await _syncCategories();
    } catch (e) {
      print('Sync failed: $e');
      // Continue with other syncs even if one fails
    }
  }

  Future<void> _syncTasks() async {
    final taskBox = await Hive.openBox<Task>('tasks');
    final tasks = taskBox.values.toList();

    // Get user ID (for now, using a default. In real app, use Firebase Auth UID)
    const userId = 'default_user';

    final batch = _firestore.batch();
    final tasksRef = _firestore.collection('users').doc(userId).collection('tasks');

    // Upload local tasks to Firestore
    for (final task in tasks) {
      final taskRef = tasksRef.doc(task.id);
      batch.set(taskRef, {
        'id': task.id,
        'title': task.title,
        'description': task.description,
        'isCompleted': task.isCompleted,
        'priority': task.priority.index,
        'categoryId': task.categoryId,
        'dueDate': task.dueDate?.toIso8601String(),
        'createdAt': task.createdAt.toIso8601String(),
        'updatedAt': task.updatedAt?.toIso8601String(),
      });
    }

    await batch.commit();
  }

  Future<void> _syncCategories() async {
    final categoryBox = await Hive.openBox<Category>('categories');
    final categories = categoryBox.values.toList();

    // Get user ID
    const userId = 'default_user';

    final batch = _firestore.batch();
    final categoriesRef = _firestore.collection('users').doc(userId).collection('categories');

    // Upload local categories to Firestore
    for (final category in categories) {
      final categoryRef = categoriesRef.doc(category.id);
      batch.set(categoryRef, {
        'id': category.id,
        'name': category.name,
        'color': category.color.value,
        'icon': category.icon.codePoint,
        'createdAt': category.createdAt.toIso8601String(),
        'updatedAt': category.updatedAt?.toIso8601String(),
      });
    }

    await batch.commit();
  }

  // Future methods for downloading from Firestore (to be implemented)
  Future<void> downloadTasks() async {
    // TODO: Implement downloading tasks from Firestore and merging with local
  }

  Future<void> downloadCategories() async {
    // TODO: Implement downloading categories from Firestore and merging with local
  }
}