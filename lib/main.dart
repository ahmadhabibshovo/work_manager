import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/service_locator.dart';
import 'core/services/sync_service.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'core/widgets/home_page.dart';
import 'features/settings/data/models/user_preferences.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/data/repositories/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await ServiceLocator.initialize();
  await SyncService().initialize();
  runApp(PriorityManagerApp(key: PriorityManagerApp._appKey));
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // Show loading screen while determining auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16.h),
                  Text(
                    'Loading...',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ],
              ),
            ),
          );
        }

        // Check if user is authenticated
        final isAuthenticated = snapshot.hasData && snapshot.data != null;

        // Navigate to appropriate screen
        if (isAuthenticated) {
          return const HomePage();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

class PriorityManagerApp extends StatefulWidget {
  const PriorityManagerApp({super.key});

  static final GlobalKey<_PriorityManagerAppState> _appKey = GlobalKey<_PriorityManagerAppState>();

  static _PriorityManagerAppState? get appState => _appKey.currentState;

  @override
  State<PriorityManagerApp> createState() => _PriorityManagerAppState();
}

class _PriorityManagerAppState extends State<PriorityManagerApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final service = await ServiceLocator.getPreferencesService();
      final preferences = await service.getUserPreferences();
      setState(() {
        _themeMode = _convertAppThemeModeToThemeMode(preferences.themeMode);
      });
    } catch (e) {
      // Keep default system theme if loading fails
    }
  }

  ThemeMode _convertAppThemeModeToThemeMode(AppThemeMode appThemeMode) {
    switch (appThemeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  void updateThemeMode(AppThemeMode appThemeMode) {
    setState(() {
      _themeMode = _convertAppThemeModeToThemeMode(appThemeMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Priority Manager',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeMode,
          home: AuthWrapper(),
          onGenerateRoute: AppRouter.generateRoute,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
