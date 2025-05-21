import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../global.dart';
import '../models/supabase_auth_service.dart';
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
    final authService = Provider.of<SupabaseAuthService>(context, listen: false);
    final loadingController = MyDialog.loading(context.l10n.loggingIn);

    try {
      // Sign in with Google
      final user = await authService.signInWithGoogle();

      // Hide loading indicator
      loadingController.close();

      if (user != null) {
        // Call the onLoginSuccess callback
        onLoginSuccess();
      }
    } catch (e) {
      // Hide loading indicator
      loadingController.close();

      String errorMessage;
      if (e is AuthException) {
        switch (e.statusCode) {
          case '400':
            errorMessage = context.l10n.invalidCredential;
            break;
          case '403':
            errorMessage = context.l10n.userDisabled;
            break;
          case '409':
            errorMessage = context.l10n.accountExistsWithDifferentCredential;
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

  Future<void> _handleFacebookSignIn(BuildContext context) async {
    final authService = Provider.of<SupabaseAuthService>(context, listen: false);
    final loadingController = MyDialog.loading(context.l10n.loggingIn);

    try {
      // Sign in with Facebook
      final user = await authService.signInWithFacebook();

      // Hide loading indicator
      loadingController.close();

      if (user != null) {
        // Call the onLoginSuccess callback
        onLoginSuccess();
      }
    } catch (e) {
      // Hide loading indicator
      loadingController.close();

      String errorMessage;
      if (e is AuthException) {
        switch (e.statusCode) {
          case '400':
            errorMessage = context.l10n.invalidCredential;
            break;
          case '403':
            errorMessage = context.l10n.userDisabled;
            break;
          case '409':
            errorMessage = context.l10n.accountExistsWithDifferentCredential;
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
