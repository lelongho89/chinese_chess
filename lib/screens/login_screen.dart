import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

import '../global.dart';
import '../models/auth_service.dart';
import '../models/user_repository.dart';
import '../widgets/social_login_buttons.dart';

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

    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      // Show loading indicator
      MyDialog.showLoading(context, message: context.l10n.loggingIn);

      // Sign in with email and password
      final user = await authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Hide loading indicator
      if (context.mounted) Navigator.of(context).pop();

      if (user != null) {
        // Update last login time
        await UserRepository.instance.updateLastLogin(user.uid);

        // Check if email is verified
        if (!user.emailVerified) {
          if (context.mounted) {
            MyDialog.confirm(
              Text(context.l10n.emailNotVerified),
              title: context.l10n.verificationRequired,
              buttonText: context.l10n.resendVerification,
              cancelText: context.l10n.cancel,
            ).then((confirmed) async {
              if (confirmed ?? false) {
                await authService.sendEmailVerification();
                if (context.mounted) {
                  MyDialog.toast(
                    context.l10n.verificationEmailSent,
                    iconType: IconType.success,
                  );
                }
              }
            });
          }
          return;
        }

        // Call the onLoginSuccess callback
        widget.onLoginSuccess();
      }
    } on FirebaseAuthException catch (e) {
      // Hide loading indicator
      if (context.mounted) Navigator.of(context).pop();

      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = context.l10n.userNotFound;
          break;
        case 'wrong-password':
          errorMessage = context.l10n.wrongPassword;
          break;
        case 'invalid-email':
          errorMessage = context.l10n.invalidEmail;
          break;
        case 'user-disabled':
          errorMessage = context.l10n.userDisabled;
          break;
        case 'too-many-requests':
          errorMessage = context.l10n.tooManyRequests;
          break;
        default:
          errorMessage = '${context.l10n.loginFailed}: ${e.message}';
      }

      if (context.mounted) {
        MyDialog.alert(
          errorMessage,
          title: context.l10n.error,
        );
      }
    } catch (e) {
      // Hide loading indicator
      if (context.mounted) Navigator.of(context).pop();

      if (context.mounted) {
        MyDialog.alert(
          '${context.l10n.loginFailed}: $e',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
