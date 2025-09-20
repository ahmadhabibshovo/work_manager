import 'package:flutter/material.dart';
import '../widgets/home_page.dart';
import '../../features/task_management/presentation/task_management_page.dart';
import '../../features/categories/presentation/categories_page.dart';
import '../../features/settings/presentation/settings_page.dart';

class AppRouter {
  static const String home = '/';
  static const String tasks = '/tasks';
  static const String categories = '/categories';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const HomePage(),
      tasks: (context) => const TaskManagementPage(),
      categories: (context) => const CategoriesPage(),
      settings: (context) => const SettingsPage(),
    };
  }
}