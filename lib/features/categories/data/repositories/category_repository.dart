import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getAllCategories();
  Future<Category?> getCategoryById(String id);
  Future<Category> createCategory(Category category);
  Future<Category> updateCategory(Category category);
  Future<void> deleteCategory(String id);
  Future<List<Category>> getCategoriesByType(CategoryType type);
}

class CategoryRepositoryImpl implements CategoryRepository {
  static const String _categoriesKey = 'categories';
  final SharedPreferences _prefs;

  CategoryRepositoryImpl(this._prefs);

  @override
  Future<List<Category>> getAllCategories() async {
    final categoriesJson = _prefs.getStringList(_categoriesKey) ?? [];
    final categories = categoriesJson
        .map((json) => Category.fromJson(jsonDecode(json)))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Add default categories if none exist
    if (categories.isEmpty) {
      categories.addAll(_getDefaultCategories());
      await _saveCategories(categories);
    }

    return categories;
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    final categories = await getAllCategories();
    return categories.where((category) => category.id == id).firstOrNull;
  }

  @override
  Future<Category> createCategory(Category category) async {
    final categories = await getAllCategories();
    categories.add(category);

    await _saveCategories(categories);
    return category;
  }

  @override
  Future<Category> updateCategory(Category category) async {
    final categories = await getAllCategories();
    final index = categories.indexWhere((c) => c.id == category.id);

    if (index == -1) {
      throw Exception('Category not found');
    }

    final updatedCategory = category.copyWith(updatedAt: DateTime.now());
    categories[index] = updatedCategory;

    await _saveCategories(categories);
    return updatedCategory;
  }

  @override
  Future<void> deleteCategory(String id) async {
    final categories = await getAllCategories();
    categories.removeWhere((category) => category.id == id);

    await _saveCategories(categories);
  }

  @override
  Future<List<Category>> getCategoriesByType(CategoryType type) async {
    final categories = await getAllCategories();
    return categories.where((category) => category.type == type).toList();
  }

  Future<void> _saveCategories(List<Category> categories) async {
    final categoriesJson = categories.map((c) => jsonEncode(c.toJson())).toList();
    await _prefs.setStringList(_categoriesKey, categoriesJson);
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
}