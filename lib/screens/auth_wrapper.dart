import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/supabase_auth_service.dart';
import 'email_verification_screen.dart';
import 'forgot_password_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

/// A wrapper widget that handles the authentication flow
class AuthWrapper extends StatefulWidget {
  final Widget child;

  const AuthWrapper({
    super.key,
    required this.child,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  AuthScreen _currentScreen = AuthScreen.login;

  void _navigateToLogin() {
    setState(() {
      _currentScreen = AuthScreen.login;
    });
  }

  void _navigateToRegister() {
    setState(() {
      _currentScreen = AuthScreen.register;
    });
  }

  void _navigateToForgotPassword() {
    setState(() {
      _currentScreen = AuthScreen.forgotPassword;
    });
  }

  void _onAuthSuccess() {
    // This will be called when authentication is successful
    // The Consumer in the build method will handle the navigation
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SupabaseAuthService>(
      builder: (context, authService, _) {
        // Show loading indicator while initializing
        if (!authService.isInitialized) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If user is authenticated and anonymous, show the main app directly
        if (authService.isAuthenticated && authService.isAnonymous) {
          return widget.child;
        }

        // If user is authenticated but email is not verified, show verification screen
        if (authService.isAuthenticated && !authService.isEmailVerified) {
          return EmailVerificationScreen(
            onVerificationComplete: _onAuthSuccess,
          );
        }

        // If user is authenticated and email is verified, show the main app
        if (authService.isAuthenticated && authService.isEmailVerified) {
          return widget.child;
        }

        // Otherwise, show the appropriate auth screen
        switch (_currentScreen) {
          case AuthScreen.login:
            return LoginScreen(
              onRegisterPressed: _navigateToRegister,
              onForgotPasswordPressed: _navigateToForgotPassword,
              onLoginSuccess: _onAuthSuccess,
            );
          case AuthScreen.register:
            return RegisterScreen(
              onLoginPressed: _navigateToLogin,
              onRegisterSuccess: _navigateToLogin,
            );
          case AuthScreen.forgotPassword:
            return ForgotPasswordScreen(
              onBackToLogin: _navigateToLogin,
            );
        }
      },
    );
  }
}

enum AuthScreen {
  login,
  register,
  forgotPassword,
}
