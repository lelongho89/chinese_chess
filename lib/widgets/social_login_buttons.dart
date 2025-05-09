import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

import '../global.dart';
import '../models/auth_service.dart';
import '../models/user_repository.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback onLoginSuccess;
  final bool showDivider;

  const SocialLoginButtons({
    super.key,
    required this.onLoginSuccess,
    this.showDivider = true,
  });

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    try {
      // Show loading indicator
      MyDialog.showLoading(context, message: context.l10n.loggingIn);
      
      // Sign in with Google
      final user = await authService.signInWithGoogle();
      
      // Hide loading indicator
      if (context.mounted) Navigator.of(context).pop();
      
      if (user != null) {
        // Call the onLoginSuccess callback
        onLoginSuccess();
      }
    } on FirebaseAuthException catch (e) {
      // Hide loading indicator
      if (context.mounted) Navigator.of(context).pop();
      
      String errorMessage;
      
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage = context.l10n.accountExistsWithDifferentCredential;
          break;
        case 'invalid-credential':
          errorMessage = context.l10n.invalidCredential;
          break;
        case 'operation-not-allowed':
          errorMessage = context.l10n.operationNotAllowed;
          break;
        case 'user-disabled':
          errorMessage = context.l10n.userDisabled;
          break;
        case 'user-not-found':
          errorMessage = context.l10n.userNotFound;
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

  Future<void> _handleFacebookSignIn(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    try {
      // Show loading indicator
      MyDialog.showLoading(context, message: context.l10n.loggingIn);
      
      // Sign in with Facebook
      final user = await authService.signInWithFacebook();
      
      // Hide loading indicator
      if (context.mounted) Navigator.of(context).pop();
      
      if (user != null) {
        // Call the onLoginSuccess callback
        onLoginSuccess();
      }
    } on FirebaseAuthException catch (e) {
      // Hide loading indicator
      if (context.mounted) Navigator.of(context).pop();
      
      String errorMessage;
      
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage = context.l10n.accountExistsWithDifferentCredential;
          break;
        case 'invalid-credential':
          errorMessage = context.l10n.invalidCredential;
          break;
        case 'operation-not-allowed':
          errorMessage = context.l10n.operationNotAllowed;
          break;
        case 'user-disabled':
          errorMessage = context.l10n.userDisabled;
          break;
        case 'user-not-found':
          errorMessage = context.l10n.userNotFound;
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
    return Column(
      children: [
        if (showDivider) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  context.l10n.orContinueWith,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),
        ],
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google Sign In Button
            _SocialButton(
              icon: 'assets/images/google_logo.png',
              onPressed: () => _handleGoogleSignIn(context),
            ),
            const SizedBox(width: 16),
            
            // Facebook Sign In Button
            _SocialButton(
              icon: 'assets/images/facebook_logo.png',
              onPressed: () => _handleFacebookSignIn(context),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String icon;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Image.asset(
            icon,
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }
}
