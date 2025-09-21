import 'dart:async';
import 'package:hive/hive.dart';
import '../../../../core/services/sync_service.dart';
import '../models/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getAllCategories();
  Future<Category?> getCategoryById(String id);
  Future<Category> createCategory(Category category);
  Future<Category> updateCategory(Category category);
  Future<void> deleteCategory(String id);
  Future<List<Category>> getCategoriesByType(CategoryType type);
  Future<void> initialize();
  Stream<List<Category>> get categoriesStream;
  Future<void> refreshCategories();
}

class CategoryRepositoryImpl implements CategoryRepository {
  static const String _boxName = 'categories';
  late Box<Category> _box;
  final SyncService _syncService;
  final StreamController<List<Category>> _categoriesController = StreamController<List<Category>>.broadcast();

  CategoryRepositoryImpl(this._syncService);

  @override
  Stream<List<Category>> get categoriesStream => _categoriesController.stream;

  @override
  Future<void> refreshCategories() async {
    final categories = await getAllCategories();
    _categoriesController.add(categories);
  }

  @override
  Future<void> initialize() async {
    _box = await Hive.openBox<Category>(_boxName);

    // Add default categories if box is empty
    if (_box.isEmpty) {
      final defaultCategories = _getDefaultCategories();
      for (final category in defaultCategories) {
        await _box.put(category.id, category);
      }
    }

    // Emit initial categories
    await refreshCategories();
  }

  @override
  Future<List<Category>> getAllCategories() async {
    final categories = _box.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return categories;
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    return _box.get(id);
  }

  @override
  Future<Category> createCategory(Category category) async {
    await _box.put(category.id, category);
    await refreshCategories(); // Emit updated categories
    // Sync if online
    if (_syncService.isOnline) {
      try {
        await _syncService.manualSync();
      } catch (e) {
        // Sync failed, but don't fail the operation
        print('Sync failed after creating category: $e');
      }
    }
    return category;
  }

  @override
  Future<Category> updateCategory(Category category) async {
    final updatedCategory = category.copyWith(updatedAt: DateTime.now());
    await _box.put(category.id, updatedCategory);
    await refreshCategories(); // Emit updated categories
    // Sync if online
    if (_syncService.isOnline) {
      try {
        await _syncService.manualSync();
      } catch (e) {
        // Sync failed, but don't fail the operation
        print('Sync failed after updating category: $e');
      }
    }
    return updatedCategory;
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _box.delete(id);
    await refreshCategories(); // Emit updated categories
    // Sync if online
    if (_syncService.isOnline) {
      try {
        await _syncService.manualSync();
      } catch (e) {
        // Sync failed, but don't fail the operation
        print('Sync failed after deleting category: $e');
      }
    }
  }

  @override
  Future<List<Category>> getCategoriesByType(CategoryType type) async {
    final categories = _box.values.where((category) => category.type == type).toList();
    return categories;
  }

  List<Category> _getDefaultCategories() {
    return [
      Category(
        id: 'personal',
        name: 'Personal',
        type: CategoryType.personal,
        description: 'Personal tasks and activities',
        createdAt: DateTime.now(),
      ),
      Category(
        id: 'work',
        name: 'Work',
        type: CategoryType.work,
        description: 'Professional tasks and projects',
        createdAt: DateTime.now(),
      ),
      Category(
        id: 'health',
        name: 'Health',
        type: CategoryType.health,
        description: 'Health and fitness related tasks',
        createdAt: DateTime.now(),
      ),
      Category(
        id: 'finance',
        name: 'Finance',
        type: CategoryType.finance,
        description: 'Financial tasks and planning',
        createdAt: DateTime.now(),
      ),
      Category(
        id: 'education',
        name: 'Education',
        type: CategoryType.education,
        description: 'Learning and educational tasks',
        createdAt: DateTime.now(),
      ),
    ];
  }

  void dispose() {
    _categoriesController.close();
  }
}