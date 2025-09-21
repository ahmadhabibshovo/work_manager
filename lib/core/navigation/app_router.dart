import 'package:flutter/material.dart';
import '../widgets/home_page.dart';
import '../../features/task_management/presentation/task_management_page.dart';
import '../../features/categories/presentation/categories_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String tasks = '/tasks';
  static const String categories = '/categories';
  static const String settings = '/settings';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const HomePage(),
      tasks: (context) => const TaskManagementPage(),
      categories: (context) => const CategoriesPage(),
      settings: (context) => const SettingsPage(),
      login: (context) => const LoginScreen(),
      signup: (context) => const SignupScreen(),
      forgotPassword: (context) => const ForgotPasswordScreen(),
      profile: (context) => const ProfileScreen(),
    };
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (context) => const HomePage(),
          settings: settings,
        );
      case '/tasks':
        return MaterialPageRoute(
          builder: (context) => const TaskManagementPage(),
          settings: settings,
        );
      case '/categories':
        return MaterialPageRoute(
          builder: (context) => const CategoriesPage(),
          settings: settings,
        );
      case '/settings':
        return MaterialPageRoute(
          builder: (context) => const SettingsPage(),
          settings: settings,
        );
      case '/login':
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
          settings: settings,
        );
      case '/signup':
        return MaterialPageRoute(
          builder: (context) => const SignupScreen(),
          settings: settings,
        );
      case '/forgot-password':
        return MaterialPageRoute(
          builder: (context) => const ForgotPasswordScreen(),
          settings: settings,
        );
      case '/profile':
        return MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
          settings: settings,
        );
      default:
        // Return home page as fallback
        return MaterialPageRoute(
          builder: (context) => const HomePage(),
          settings: settings,
        );
    }
  }
}