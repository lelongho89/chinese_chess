import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../global.dart';
import '../models/supabase_auth_service.dart';
import '../models/user_repository.dart';
import '../widgets/social_login_buttons.dart';
import '../debug/guest_login_debug.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onRegisterPressed;
  final VoidCallback onForgotPasswordPressed;
  final VoidCallback onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.onRegisterPressed,
    required this.onForgotPasswordPressed,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<SupabaseAuthService>(context, listen: false);
    final loadingController = MyDialog.loading(context.l10n.loggingIn);

    try {
      // Sign in with email and password
      final user = await authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Hide loading indicator
      loadingController.close();

      if (user != null) {
        // Update last login time
        await UserRepository.instance.updateLastLogin(user.id);

        // Check if email is verified
        if (!authService.isEmailVerified) {
          if (context.mounted) {
            MyDialog.alert(
              context.l10n.emailNotVerified,
              title: context.l10n.verificationRequired,
            );
          }
          return;
        }

        // Call the onLoginSuccess callback
        widget.onLoginSuccess();
      }
    } catch (e) {
      // Hide loading indicator
      loadingController.close();

      String errorMessage;
      if (e is AuthException) {
        switch (e.statusCode) {
          case '400':
            errorMessage = context.l10n.invalidCredentials;
            break;
          case '401':
            errorMessage = context.l10n.userNotFound;
            break;
          case '403':
            errorMessage = context.l10n.userDisabled;
            break;
          case '429':
            errorMessage = context.l10n.tooManyRequests;
            break;
          default:
            errorMessage = '${context.l10n.loginFailed}: ${e.message}';
        }
      } else {
        errorMessage = '${context.l10n.loginFailed}: $e';
      }

      if (context.mounted) {
        MyDialog.alert(
          errorMessage,
          title: context.l10n.error,
        );
      }
    }
  }

  Future<void> _continueAsGuest() async {
    final authService = Provider.of<SupabaseAuthService>(context, listen: false);
    final loadingController = MyDialog.loading(context.l10n.loggingIn);

    try {
      // Sign in anonymously
      final user = await authService.signInAnonymously();

      // Hide loading indicator
      loadingController.close();

      if (user != null) {
        // Call the onLoginSuccess callback
        widget.onLoginSuccess();
      }
    } catch (e) {
      // Hide loading indicator
      loadingController.close();

      String errorMessage = '${context.l10n.loginFailed}: $e';

      if (context.mounted) {
        MyDialog.alert(
          errorMessage,
          title: context.l10n.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.login),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 100,
                    ),
                  ),

                  // Title
                  Text(
                    context.l10n.welcomeBack,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: context.l10n.email,
                      prefixIcon: const Icon(Icons.email),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.l10n.emailRequired;
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return context.l10n.invalidEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: context.l10n.password,
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: !_isPasswordVisible,
                    autofillHints: const [AutofillHints.password],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.l10n.passwordRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Remember me and Forgot password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? true;
                              });
                            },
                          ),
                          Text(context.l10n.rememberMe),
                        ],
                      ),
                      TextButton(
                        onPressed: widget.onForgotPasswordPressed,
                        child: Text(context.l10n.forgotPassword),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Login button
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(context.l10n.login),
                  ),
                  const SizedBox(height: 16),

                  // Continue as Guest button
                  OutlinedButton(
                    onPressed: _continueAsGuest,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(context.l10n.continueAsGuest),
                  ),
                  const SizedBox(height: 16),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(context.l10n.dontHaveAccount),
                      TextButton(
                        onPressed: widget.onRegisterPressed,
                        child: Text(context.l10n.register),
                      ),
                    ],
                  ),

                  // Social login buttons
                  SocialLoginButtons(
                    onLoginSuccess: widget.onLoginSuccess,
                  ),

                  // Debug button (only in debug mode)
                  if (kDebugMode) ...[
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const GuestLoginDebugScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                      ),
                      child: const Text('🔧 Debug Guest Login'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
