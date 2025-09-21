import 'package:flutter/material.dart';
import '../../data/repositories/auth_service.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/signup_screen.dart';
import '../../presentation/screens/forgot_password_screen.dart';

class AuthWrapper extends StatelessWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is authenticated, show the main app
          return child;
        } else {
          // User is not authenticated, show login screen within the main app structure
          return MaterialApp(
            home: const LoginScreen(),
            routes: {
              '/signup': (context) => const SignupScreen(),
              '/forgot-password': (context) => const ForgotPasswordScreen(),
            },
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
            ),
            debugShowCheckedModeBanner: false,
          );
        }
      },
    );
  }
}