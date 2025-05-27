import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

import '../global.dart';
import '../models/supabase_auth_service.dart';
import '../models/user_repository.dart';
import '../models/user_model.dart';
import '../widgets/rank_badge_widget.dart';

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
  UserModel? _userModel;
  bool _isLoading = true;

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
        final userModel = await UserRepository.instance.get(user.id);
        if (userModel != null && mounted) {
          setState(() {
            _userModel = userModel;
            _displayNameController.text = userModel.displayName;
            _isLoading = false;
          });
        } else if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        logger.severe('Error loading user data: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });
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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          context.l10n.account,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<SupabaseAuthService>(
        builder: (context, authService, _) {
          final user = authService.user;

          if (user == null) {
            return const Center(
              child: Text('No user logged in'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          // Rank Badge
                          if (_userModel != null)
                            RankBadgeWidget(
                              eloRating: _userModel!.eloRating,
                              size: 140, // Increased size for better text fitting
                              showStars: true,
                              showElo: true,
                            )
                          else
                            // Fallback avatar for users without data
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: Text(
                                (_displayNameController.text.isNotEmpty
                                  ? _displayNameController.text[0].toUpperCase()
                                  : user.email?.isNotEmpty == true
                                    ? user.email![0].toUpperCase()
                                    : 'U'),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                          const SizedBox(height: 16),

                          // Name
                          Text(
                            _displayNameController.text.isNotEmpty
                              ? _displayNameController.text
                              : authService.isAnonymous
                                ? context.l10n.guestUser
                                : user.email ?? 'User',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Email or status
                          Text(
                            authService.isAnonymous
                              ? context.l10n.joinedDate('2021')
                              : user.email ?? '',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                ),

                const SizedBox(height: 24),

                // Stats Section
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: context.l10n.eloRating,
                        value: _userModel?.eloRating.toString() ?? '1200',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: context.l10n.gamesWon,
                        value: _userModel?.gamesWon.toString() ?? '0',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: context.l10n.gamesLost,
                        value: _userModel?.gamesLost.toString() ?? '0',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Account Actions Section
                _buildSettingItem(
                  title: context.l10n.changePassword,
                  trailing: const Icon(Icons.chevron_right),
                ),

                const SizedBox(height: 16),

                // Show delete profile for anonymous users, logout for authenticated users
                if (authService.isAnonymous)
                  _buildDeleteProfileButton()
                else
                  _buildSettingItem(
                    title: context.l10n.logOut,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _signOut,
                  ),

                const Spacer(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteProfileButton() {
    return GestureDetector(
      onTap: _deleteProfile,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.delete_forever,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                context.l10n.deleteProfile,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor ?? Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: (textColor ?? Theme.of(context).colorScheme.onSurface).withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      final authService = Provider.of<SupabaseAuthService>(context, listen: false);
      await authService.signOut();

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        MyDialog.alert('Sign out failed: $e');
      }
    }
  }

  Future<void> _deleteProfile() async {
    // Show confirmation dialog
    final confirmed = await MyDialog.confirm(
      context.l10n.deleteProfileConfirmation,
      title: context.l10n.deleteProfile,
      buttonText: context.l10n.deleteProfile,
      cancelText: context.l10n.cancel,
    );

    if (confirmed != true) return;

    final authService = Provider.of<SupabaseAuthService>(context, listen: false);
    final loadingController = MyDialog.loading('Deleting profile...');

    try {
      await authService.deleteAnonymousProfile();

      // Hide loading indicator
      loadingController.close();

      if (mounted) {
        MyDialog.toast(
          'Profile deleted successfully',
          iconType: IconType.success,
        );

        // Navigate back to login/main screen
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      // Hide loading indicator
      loadingController.close();

      if (mounted) {
        MyDialog.alert(
          'Failed to delete profile: $e',
          title: context.l10n.error,
        );
      }
    }
  }
}
