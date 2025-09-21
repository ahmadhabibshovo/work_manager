import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/services/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServiceLocator.initialize();
  runApp(const PriorityManagerApp());
}

class PriorityManagerApp extends StatelessWidget {
  const PriorityManagerApp({super.key});

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
          themeMode: ThemeMode.system,
          initialRoute: AppRouter.home,
          routes: AppRouter.routes,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
