import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../global.dart';
import '../models/supabase_auth_service.dart';
import '../supabase_client.dart' as client;

class EmailVerificationScreen extends StatefulWidget {
  final VoidCallback onVerificationComplete;

  const EmailVerificationScreen({
    super.key,
    required this.onVerificationComplete,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  late SupabaseAuthService _authService;
  Timer? _timer;
  bool _canResendEmail = true;
  int _resendCountdown = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _authService = Provider.of<SupabaseAuthService>(context, listen: false);
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startVerificationCheck() {
    // Check every 3 seconds if the email has been verified
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        // Refresh the session to check if email is verified
        await _authService.refreshSession();

        if (_authService.isEmailVerified) {
          _timer?.cancel();
          widget.onVerificationComplete();
        }
      } catch (e) {
        logger.severe('Error checking email verification: $e');
      }
    });
  }

  Future<void> _resendVerificationEmail() async {
    if (!_canResendEmail) return;

    setState(() {
      _canResendEmail = false;
      _resendCountdown = 60; // 60 seconds cooldown
    });

    try {
      // Get current user email
      final email = _authService.user?.email;
      if (email == null) {
        throw Exception('User email is null');
      }

      // Resend verification email
      await client.SupabaseClientWrapper.instance.auth.resend(
        type: OtpType.email,
        email: email,
      );

      if (context.mounted) {
        MyDialog.toast(
          context.l10n.verificationEmailSent,
          iconType: IconType.success,
        );
      }

      // Start countdown for resend button
      _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_resendCountdown > 0) {
            _resendCountdown--;
          } else {
            _canResendEmail = true;
            _resendTimer?.cancel();
          }
        });
      });
    } catch (e) {
      setState(() {
        _canResendEmail = true;
      });

      String errorMessage;
      if (e is AuthException) {
        errorMessage = '${context.l10n.failedToSendVerificationEmail}: ${e.message}';
      } else {
        errorMessage = '${context.l10n.failedToSendVerificationEmail}: $e';
      }

      if (context.mounted) {
        MyDialog.alert(
          errorMessage,
          title: context.l10n.error,
        );
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      String errorMessage;
      if (e is AuthException) {
        errorMessage = '${context.l10n.signOutFailed}: ${e.message}';
      } else {
        errorMessage = '${context.l10n.signOutFailed}: $e';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.emailVerification),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: context.l10n.signOut,
            onPressed: _signOut,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                const Icon(
                  Icons.mark_email_unread,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  context.l10n.verifyYourEmail,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  context.l10n.verificationEmailSentDescription,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Email address
                Text(
                  _authService.user?.email ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Resend button
                ElevatedButton.icon(
                  onPressed: _canResendEmail ? _resendVerificationEmail : null,
                  icon: const Icon(Icons.send),
                  label: Text(
                    _canResendEmail
                        ? context.l10n.resendVerificationEmail
                        : '${context.l10n.resendIn} $_resendCountdown ${context.l10n.seconds}',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Sign out button
                TextButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout),
                  label: Text(context.l10n.signOut),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
