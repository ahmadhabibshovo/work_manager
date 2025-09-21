import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/task_management/data/models/task.dart';
import '../../features/task_management/data/models/priority.dart';
import '../../features/categories/data/models/category.dart';
import '../../features/auth/data/repositories/auth_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final Connectivity _connectivity = Connectivity();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  Future<void> initialize() async {
    print('🔄 SyncService: Initializing...');
    // Check initial connectivity
    final results = await _connectivity.checkConnectivity();
    _isOnline = results.any((result) => result != ConnectivityResult.none);
    print('🔄 SyncService: Initial connectivity check - Online: $_isOnline');

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final wasOnline = _isOnline;
        _isOnline = results.any((result) => result != ConnectivityResult.none);
        print('🔄 SyncService: Connectivity changed - Was online: $wasOnline, Now online: $_isOnline');

        // If we just came online, trigger sync
        if (!wasOnline && _isOnline) {
          print('🔄 SyncService: Came online, triggering sync...');
          _syncAllData();
        }
      },
    );
    print('🔄 SyncService: Initialization complete');
  }

  Future<void> downloadAllData() async {
    try {
      print('🔄 SyncService: Starting full data download...');
      await downloadTasks();
      await downloadCategories();
      print('🔄 SyncService: Full data download completed');
    } catch (e) {
      print('❌ SyncService: Data download failed: $e');
      rethrow;
    }
  }

  Future<void> manualSync() async {
    print('🔄 SyncService: Manual sync requested');
    if (_isOnline) {
      print('🔄 SyncService: Online, starting manual sync...');
      await _syncAllData();
      print('🔄 SyncService: Manual sync completed');
    } else {
      print('❌ SyncService: Manual sync failed - no internet connection');
      throw Exception('No internet connection available');
    }
  }

  Future<void> _syncAllData() async {
    try {
      print('🔄 SyncService: Starting full data sync...');
      // First download any new data from Firestore
      await downloadAllData();
      // Then upload local data to Firestore
      await _syncTasks();
      await _syncCategories();
      print('🔄 SyncService: Full data sync completed');
    } catch (e) {
      print('❌ SyncService: Sync failed: $e');
      // Continue with other syncs even if one fails
    }
  }

  Future<void> _syncTasks() async {
    print('🔄 SyncService: Syncing tasks...');
    final taskBox = await Hive.openBox<Task>('tasks');
    final tasks = taskBox.values.toList();
    print('🔄 SyncService: Found ${tasks.length} local tasks');

    // Get current user ID
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      print('❌ SyncService: No authenticated user, skipping task sync');
      return;
    }
    final userId = currentUser.id;

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
    print('🔄 SyncService: Tasks sync completed, uploaded ${tasks.length} tasks');
  }

  Future<void> _syncCategories() async {
    print('🔄 SyncService: Syncing categories...');
    final categoryBox = await Hive.openBox<Category>('categories');
    final categories = categoryBox.values.toList();
    print('🔄 SyncService: Found ${categories.length} local categories');

    // Get current user ID
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      print('❌ SyncService: No authenticated user, skipping category sync');
      return;
    }
    final userId = currentUser.id;

    final batch = _firestore.batch();
    final categoriesRef = _firestore.collection('users').doc(userId).collection('categories');

    // Upload local categories to Firestore
    for (final category in categories) {
      final categoryRef = categoriesRef.doc(category.id);
      batch.set(categoryRef, {
        'id': category.id,
        'name': category.name,
        'color': category.color.toARGB32(),
        'icon': category.icon.codePoint,
        'createdAt': category.createdAt.toIso8601String(),
        'updatedAt': category.updatedAt?.toIso8601String(),
      });
    }

    await batch.commit();
    print('🔄 SyncService: Categories sync completed, uploaded ${categories.length} categories');
  }

  // Future methods for downloading from Firestore (to be implemented)
  Future<void> downloadTasks() async {
    print('🔄 SyncService: Downloading tasks from Firestore...');
    
    // Get current user ID
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      print('❌ SyncService: No authenticated user, skipping task download');
      return;
    }
    final userId = currentUser.id;

    try {
      final taskBox = await Hive.openBox<Task>('tasks');
      final tasksRef = _firestore.collection('users').doc(userId).collection('tasks');
      final querySnapshot = await tasksRef.get();

      print('🔄 SyncService: Found ${querySnapshot.docs.length} tasks in Firestore');

      int downloadedCount = 0;
      int updatedCount = 0;

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        
        // Convert Firestore data to Task object
        final firestoreTask = Task(
          id: data['id'] as String,
          title: data['title'] as String,
          description: data['description'] as String?,
          priority: Priority.values[data['priority'] as int? ?? 0],
          isCompleted: data['isCompleted'] as bool? ?? false,
          dueDate: data['dueDate'] != null ? DateTime.parse(data['dueDate'] as String) : null,
          createdAt: DateTime.parse(data['createdAt'] as String),
          updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt'] as String) : null,
          categoryId: data['categoryId'] as String?,
          attachments: [], // TODO: Handle attachments
          order: data['order'] as int?,
        );

        // Check if task exists locally
        final existingTask = taskBox.get(firestoreTask.id);
        
        if (existingTask == null) {
          // Task doesn't exist locally, add it
          await taskBox.put(firestoreTask.id, firestoreTask);
          downloadedCount++;
          print('🔄 SyncService: Downloaded new task: ${firestoreTask.title}');
        } else {
          // Task exists locally, check if Firestore version is newer
          final localUpdated = existingTask.updatedAt ?? existingTask.createdAt;
          final firestoreUpdated = firestoreTask.updatedAt ?? firestoreTask.createdAt;
          
          if (firestoreUpdated.isAfter(localUpdated)) {
            // Firestore version is newer, update local
            await taskBox.put(firestoreTask.id, firestoreTask);
            updatedCount++;
            print('🔄 SyncService: Updated existing task: ${firestoreTask.title}');
          }
        }
      }

      print('🔄 SyncService: Task download completed - Downloaded: $downloadedCount, Updated: $updatedCount');
    } catch (e) {
      print('❌ SyncService: Task download failed: $e');
      rethrow;
    }
  }

  Future<void> downloadCategories() async {
    print('🔄 SyncService: Downloading categories from Firestore...');
    
    // Get current user ID
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      print('❌ SyncService: No authenticated user, skipping category download');
      return;
    }
    final userId = currentUser.id;

    try {
      final categoryBox = await Hive.openBox<Category>('categories');
      final categoriesRef = _firestore.collection('users').doc(userId).collection('categories');
      final querySnapshot = await categoriesRef.get();

      print('🔄 SyncService: Found ${querySnapshot.docs.length} categories in Firestore');

      int downloadedCount = 0;
      int updatedCount = 0;

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        
        // Convert Firestore data to Category object
        final firestoreCategory = Category(
          id: data['id'] as String,
          name: data['name'] as String,
          type: CategoryType.values.firstWhere(
            (type) => type.name == data['type'],
            orElse: () => CategoryType.other,
          ),
          customColor: data['customColor'] != null ? Color(data['customColor'] as int) : null,
          description: data['description'] as String?,
          createdAt: DateTime.parse(data['createdAt'] as String),
          updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt'] as String) : null,
        );

        // Check if category exists locally
        final existingCategory = categoryBox.get(firestoreCategory.id);
        
        if (existingCategory == null) {
          // Category doesn't exist locally, add it
          await categoryBox.put(firestoreCategory.id, firestoreCategory);
          downloadedCount++;
          print('🔄 SyncService: Downloaded new category: ${firestoreCategory.name}');
        } else {
          // Category exists locally, check if Firestore version is newer
          final localUpdated = existingCategory.updatedAt ?? existingCategory.createdAt;
          final firestoreUpdated = firestoreCategory.updatedAt ?? firestoreCategory.createdAt;
          
          if (firestoreUpdated.isAfter(localUpdated)) {
            // Firestore version is newer, update local
            await categoryBox.put(firestoreCategory.id, firestoreCategory);
            updatedCount++;
            print('🔄 SyncService: Updated existing category: ${firestoreCategory.name}');
          }
        }
      }

      print('🔄 SyncService: Category download completed - Downloaded: $downloadedCount, Updated: $updatedCount');
    } catch (e) {
      print('❌ SyncService: Category download failed: $e');
      rethrow;
    }
  }
}