import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

import '../global.dart';
import '../models/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final VoidCallback onBackToLogin;

  const ForgotPasswordScreen({
    super.key,
    required this.onBackToLogin,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    
    try {
      // Show loading indicator
      MyDialog.showLoading(context, message: context.l10n.sendingResetLink);
      
      // Send password reset email
      await authService.resetPassword(_emailController.text.trim());
      
      // Hide loading indicator
      if (context.mounted) Navigator.of(context).pop();
      
      // Show success dialog
      if (context.mounted) {
        MyDialog.alert(
          context.l10n.resetLinkSentDescription,
          title: context.l10n.resetLinkSent,
        ).then((_) {
          widget.onBackToLogin();
        });
      }
    } on FirebaseAuthException catch (e) {
      // Hide loading indicator
      if (context.mounted) Navigator.of(context).pop();
      
      String errorMessage;
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = context.l10n.userNotFound;
          break;
        case 'invalid-email':
          errorMessage = context.l10n.invalidEmail;
          break;
        default:
          errorMessage = '${context.l10n.resetPasswordFailed}: ${e.message}';
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
          '${context.l10n.resetPasswordFailed}: $e',
          title: context.l10n.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.forgotPassword),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBackToLogin,
        ),
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
                    context.l10n.resetPassword,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    context.l10n.resetPasswordDescription,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
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
                  const SizedBox(height: 24),
                  
                  // Reset password button
                  ElevatedButton(
                    onPressed: _resetPassword,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(context.l10n.sendResetLink),
                  ),
                  const SizedBox(height: 16),
                  
                  // Back to login button
                  TextButton(
                    onPressed: widget.onBackToLogin,
                    child: Text(context.l10n.backToLogin),
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
