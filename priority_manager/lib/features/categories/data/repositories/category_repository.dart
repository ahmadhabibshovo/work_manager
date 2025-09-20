import 'package:hive/hive.dart';
import '../models/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories();
  Future<void> addCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);
}

class CategoryRepositoryImpl implements CategoryRepository {
  final Box<Category> _categoriesBox = Hive.box<Category>('categoriesBox');

  @override
  Future<List<Category>> getCategories() async {
    return _categoriesBox.values.toList();
  }

  @override
  Future<void> addCategory(Category category) async {
    await _categoriesBox.put(category.id, category);
  }

  @override
  Future<void> updateCategory(Category category) async {
    await category.save();
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _categoriesBox.delete(id);
  }
}