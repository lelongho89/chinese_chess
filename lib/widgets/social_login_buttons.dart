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
        // Check if it's a Google Play Services issue
        if (e.toString().contains('Google Play') || e.toString().contains('GooglePlayServicesUtil')) {
          errorMessage = 'Google Play Services is required for Google Sign-In. Please use a device with Google Play Services installed.';
        } else {
          errorMessage = '${context.l10n.loginFailed}: $e';
        }
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

        Column(
          children: [
            // Google Sign In Button
            _SocialButton(
              icon: 'assets/images/google_logo.png',
              onPressed: () => _handleGoogleSignIn(context),
            ),
            const SizedBox(height: 12),

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
        constraints: const BoxConstraints(
          minWidth: 200,
          maxWidth: 320,
        ),
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Image.asset(
                  icon,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    logger.warning('Failed to load social login icon: $icon');
                    return Icon(
                    Icons.login,
                    size: 24,
                    color: Colors.grey.shade600,
                  );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _getButtonText(icon),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getButtonText(String iconPath) {
    if (iconPath.contains('google')) {
      return 'Continue with Google';
    } else if (iconPath.contains('facebook')) {
      return 'Continue with Facebook';
    }
    return 'Continue';
  }
}
