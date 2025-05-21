import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../global.dart';
import '../models/supabase_auth_service.dart';
import '../models/user_repository.dart';
import '../widgets/social_login_buttons.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onLoginPressed;
  final VoidCallback onRegisterSuccess;

  const RegisterScreen({
    super.key,
    required this.onLoginPressed,
    required this.onRegisterSuccess,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      MyDialog.alert(
        context.l10n.mustAgreeToTerms,
        title: context.l10n.termsAndConditions,
      );
      return;
    }

    final authService = Provider.of<SupabaseAuthService>(context, listen: false);
    final loadingController = MyDialog.loading(context.l10n.creatingAccount);

    try {
      // Register with email and password
      final user = await authService.registerWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (user != null) {
        // Create or update user in Supabase
        await UserRepository.instance.createOrUpdateUser(user,
          displayName: _displayNameController.text.trim());

        // Hide loading indicator
        loadingController.close();

        // Show verification email sent dialog
        if (context.mounted) {
          MyDialog.alert(
            context.l10n.verificationEmailSentDescription,
            title: context.l10n.verificationEmailSent,
          ).then((_) {
            // Call the onRegisterSuccess callback
            widget.onRegisterSuccess();
          });
        }
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
          case '422':
            errorMessage = context.l10n.emailAlreadyInUse;
            break;
          case '429':
            errorMessage = context.l10n.tooManyRequests;
            break;
          default:
            errorMessage = '${context.l10n.registrationFailed}: ${e.message}';
        }
      } else {
        errorMessage = '${context.l10n.registrationFailed}: $e';
      }

      if (context.mounted) {
        MyDialog.alert(
          errorMessage,
          title: context.l10n.error,
        );
      }
    }
  }

  void _showTermsAndConditions() {
    MyDialog.alert(
      context.l10n.termsAndConditionsText,
      title: context.l10n.termsAndConditions,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.register),
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
                    context.l10n.createAccount,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Display name field
                  TextFormField(
                    controller: _displayNameController,
                    decoration: InputDecoration(
                      labelText: context.l10n.displayName,
                      prefixIcon: const Icon(Icons.person),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.l10n.displayNameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

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
                    autofillHints: const [AutofillHints.newPassword],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.l10n.passwordRequired;
                      }
                      if (value.length < 6) {
                        return context.l10n.passwordTooShort;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm password field
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: context.l10n.confirmPassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: !_isConfirmPasswordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.l10n.confirmPasswordRequired;
                      }
                      if (value != _passwordController.text) {
                        return context.l10n.passwordsDoNotMatch;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Terms and conditions
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreeToTerms = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _agreeToTerms = !_agreeToTerms;
                            });
                          },
                          child: Text.rich(
                            TextSpan(
                              text: '${context.l10n.iAgreeToThe} ',
                              children: [
                                TextSpan(
                                  text: context.l10n.termsAndConditions,
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = _showTermsAndConditions,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Register button
                  ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(context.l10n.register),
                  ),
                  const SizedBox(height: 16),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(context.l10n.alreadyHaveAccount),
                      TextButton(
                        onPressed: widget.onLoginPressed,
                        child: Text(context.l10n.login),
                      ),
                    ],
                  ),

                  // Social login buttons
                  SocialLoginButtons(
                    onLoginSuccess: widget.onRegisterSuccess,
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
