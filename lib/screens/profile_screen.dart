import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

import '../global.dart';
import '../models/supabase_auth_service.dart';
import '../models/user_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _showConvertForm = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _loadUserData() async {
    final authService = Provider.of<SupabaseAuthService>(context, listen: false);
    final user = authService.user;
    
    if (user != null) {
      try {
        final userModel = await UserRepository.instance.getUser(user.id);
        if (userModel != null && mounted) {
          setState(() {
            _displayNameController.text = userModel.displayName;
          });
        }
      } catch (e) {
        logger.severe('Error loading user data: $e');
      }
    }
  }

  Future<void> _updateDisplayName() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<SupabaseAuthService>(context, listen: false);
    final loadingController = MyDialog.loading('Updating profile...');

    try {
      final user = authService.user;
      if (user != null) {
        await UserRepository.instance.update(user.id, {
          'display_name': _displayNameController.text.trim(),
        });

        // Hide loading indicator
        loadingController.close();

        if (context.mounted) {
          MyDialog.toast(
            context.l10n.profileUpdated,
            iconType: IconType.success,
          );
        }
      }
    } catch (e) {
      // Hide loading indicator
      loadingController.close();

      if (context.mounted) {
        MyDialog.alert(
          '${context.l10n.profileUpdateFailed}: $e',
          title: context.l10n.error,
        );
      }
    }
  }

  Future<void> _convertToAccount() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<SupabaseAuthService>(context, listen: false);
    final loadingController = MyDialog.loading('Creating account...');

    try {
      await authService.convertAnonymousUser(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Hide loading indicator
      loadingController.close();

      if (context.mounted) {
        MyDialog.toast(
          'Account created successfully!',
          iconType: IconType.success,
        );
        setState(() {
          _showConvertForm = false;
        });
      }
    } catch (e) {
      // Hide loading indicator
      loadingController.close();

      if (context.mounted) {
        MyDialog.alert(
          'Failed to create account: $e',
          title: context.l10n.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.profile),
        actions: [
          TextButton.icon(
            onPressed: _updateDisplayName,
            icon: const Icon(Icons.save),
            label: Text(context.l10n.saveProfile),
          ),
        ],
      ),
      body: Consumer<SupabaseAuthService>(
        builder: (context, authService, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.editProfile,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),

                          // Display Name field
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

                          // Show current status
                          if (authService.isAnonymous)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info, color: Colors.orange),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      context.l10n.currentlyPlayingAsGuest,
                                      style: const TextStyle(color: Colors.orange),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Convert to Account Section (only for anonymous users)
                  if (authService.isAnonymous) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.convertToAccount,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.l10n.convertToAccountDescription,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),

                            if (!_showConvertForm) ...[
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _showConvertForm = true;
                                  });
                                },
                                child: Text(context.l10n.convertToAccount),
                              ),
                            ] else ...[
                              // Email field
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: context.l10n.email,
                                  prefixIcon: const Icon(Icons.email),
                                  border: const OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.emailAddress,
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

                              // Confirm Password field
                              TextFormField(
                                controller: _confirmPasswordController,
                                decoration: InputDecoration(
                                  labelText: context.l10n.confirmPassword,
                                  prefixIcon: const Icon(Icons.lock),
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

                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          _showConvertForm = false;
                                          _emailController.clear();
                                          _passwordController.clear();
                                          _confirmPasswordController.clear();
                                        });
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _convertToAccount,
                                      child: Text(context.l10n.convertToAccount),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
