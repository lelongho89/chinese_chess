import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../models/matchmaking_queue_model.dart';
import '../models/user_model.dart';
import '../models/supabase_auth_service.dart';
import '../services/matchmaking_service.dart';
import '../repositories/user_repository.dart';
import '../utils/populate_test_users.dart';
import '../global.dart';
import '../l10n/generated/app_localizations.dart';

class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({super.key});

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> {
  QueueType _selectedQueueType = QueueType.ranked;
  int _selectedTimeControl = 180; // 3 minutes
  PreferredColor? _selectedColor;
  bool _isSearching = false;
  MatchmakingQueueModel? _currentQueue;
  UserModel? _currentUser;
  Timer? _updateTimer;
  Map<String, dynamic>? _queueStats;

  final List<int> _timeControlOptions = [60, 180, 300, 600]; // 1, 3, 5, 10 minutes

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadQueueStats();
    _checkExistingQueue();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    try {
      // Get current authenticated user from Supabase
      final authService = Provider.of<SupabaseAuthService>(context, listen: false);
      if (authService.isAuthenticated && authService.user != null) {
        final userId = authService.user!.id;
        final user = await UserRepository.instance.get(userId);
        if (user != null) {
          setState(() {
            _currentUser = user;
          });
        } else {
          // User not found in database, create a new user record
          final newUser = UserModel(
            uid: userId,
            displayName: authService.user!.userMetadata?['display_name'] ?? 'Anonymous User',
            email: authService.user!.email ?? '',
            eloRating: 1200,
            gamesPlayed: 0,
            gamesWon: 0,
            gamesLost: 0,
            gamesDraw: 0,
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
          );
          await UserRepository.instance.add(newUser);
          setState(() {
            _currentUser = newUser;
          });
        }
      }
    } catch (e) {
      logger.severe('Error loading current user: $e');
    }
  }

  Future<void> _loadQueueStats() async {
    try {
      final stats = await MatchmakingService.instance.getQueueStats();
      setState(() {
        _queueStats = stats;
      });
    } catch (e) {
      logger.severe('Error loading queue stats: $e');
    }
  }

  Future<void> _checkExistingQueue() async {
    if (_currentUser == null) return;

    try {
      final existingQueue = await MatchmakingService.instance.getUserActiveQueue(_currentUser!.uid);
      if (existingQueue != null) {
        setState(() {
          _currentQueue = existingQueue;
          _isSearching = true;
          _selectedQueueType = existingQueue.queueType;
          _selectedTimeControl = existingQueue.timeControl;
          _selectedColor = existingQueue.preferredColor;
        });
        _startUpdateTimer();
      }
    } catch (e) {
      logger.severe('Error checking existing queue: $e');
    }
  }

  void _startUpdateTimer() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateQueueStatus();
    });
  }

  Future<void> _updateQueueStatus() async {
    if (_currentUser == null || !_isSearching) return;

    try {
      final queue = await MatchmakingService.instance.getUserActiveQueue(_currentUser!.uid);
      setState(() {
        _currentQueue = queue;
      });

      if (queue == null || queue.status != MatchmakingStatus.waiting) {
        _stopSearching();
      }
    } catch (e) {
      logger.severe('Error updating queue status: $e');
    }
  }

  Future<void> _joinQueue() async {
    if (_currentUser == null) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final queueId = await MatchmakingService.instance.joinQueue(
        userId: _currentUser!.uid,
        queueType: _selectedQueueType,
        timeControl: _selectedTimeControl,
        preferredColor: _selectedColor,
      );

      final queue = await MatchmakingService.instance.getUserActiveQueue(_currentUser!.uid);
      setState(() {
        _currentQueue = queue;
      });

      _startUpdateTimer();
      _loadQueueStats();
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error joining queue: $e')),
        );
      }
    }
  }

  Future<void> _leaveQueue() async {
    if (_currentQueue == null) return;

    try {
      await MatchmakingService.instance.leaveQueue(_currentQueue!.id);
      _stopSearching();
      _loadQueueStats();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error leaving queue: $e')),
        );
      }
    }
  }

  void _stopSearching() {
    _updateTimer?.cancel();
    setState(() {
      _isSearching = false;
      _currentQueue = null;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.matchmaking),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_currentUser != null) ...[
              // Player Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          _currentUser!.displayName.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentUser!.displayName,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              'Elo: ${_currentUser!.eloRating}',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${_currentUser!.gamesWon}W ${_currentUser!.gamesLost}L ${_currentUser!.gamesDraw}D',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            if (_isSearching && _currentQueue != null) ...[
              // Searching Status
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _currentQueue!.statusDescription,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Wait time: ${_formatTime(_currentQueue!.waitTimeSeconds)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '${_currentQueue!.queueType.name.toUpperCase()} • ${_formatTime(_currentQueue!.timeControl)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _leaveQueue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  child: Text(context.l10n.cancelSearch),
                ),
              ),
            ] else ...[
              // Queue Configuration
              Text(
                'Game Settings',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Queue Type Selection
              _buildQueueTypeSelector(),
              const SizedBox(height: 16),

              // Time Control Selection
              _buildTimeControlSelector(),
              const SizedBox(height: 16),

              // Color Preference
              _buildColorPreferenceSelector(),
              const SizedBox(height: 24),

              // Start Search Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _currentUser != null ? _joinQueue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    context.l10n.findMatch,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],

            // Debug Section (for testing)
            if (_currentQueue == null) ...[
              const SizedBox(height: 24),
              Card(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🤖 Testing Tools',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _populateAIUsers,
                              icon: const Icon(Icons.smart_toy, size: 18),
                              label: const Text('Add AI Users'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _clearAIUsers,
                              icon: const Icon(Icons.clear_all, size: 18),
                              label: const Text('Clear AI'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _testAIMatching,
                          icon: const Icon(Icons.psychology, size: 18),
                          label: const Text('Test AI Matching'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade600,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const Spacer(),

            // Queue Statistics
            if (_queueStats != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Queue Statistics',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Players waiting: ${_queueStats!['total_waiting']}'),
                          Text('Avg wait: ${_formatTime(_queueStats!['average_wait_time_seconds'])}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQueueTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Queue Type',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildQueueTypeOption(QueueType.ranked, 'Ranked', 'Affects Elo rating'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQueueTypeOption(QueueType.casual, 'Casual', 'Just for fun'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQueueTypeOption(QueueType type, String title, String subtitle) {
    final isSelected = _selectedQueueType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedQueueType = type),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
              : null,
        ),
        child: Column(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeControlSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time Control',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _timeControlOptions.map((timeControl) {
            final isSelected = _selectedTimeControl == timeControl;
            return ChoiceChip(
              label: Text(_formatTime(timeControl)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedTimeControl = timeControl);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorPreferenceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color Preference (Optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('Red'),
                selected: _selectedColor == PreferredColor.red,
                onSelected: (selected) {
                  setState(() {
                    _selectedColor = selected ? PreferredColor.red : null;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: const Text('Black'),
                selected: _selectedColor == PreferredColor.black,
                onSelected: (selected) {
                  setState(() {
                    _selectedColor = selected ? PreferredColor.black : null;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: const Text('No Preference'),
                selected: _selectedColor == null,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedColor = null);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Populate database with AI test users
  Future<void> _populateAIUsers() async {
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text('Creating AI users...'),
              ],
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }

      await PopulateTestUsers.populateAIUsers(count: 15);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Successfully created 15 AI users!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Refresh queue stats to show new users
      _loadQueueStats();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error creating AI users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Clear all AI test users from database
  Future<void> _clearAIUsers() async {
    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Clear AI Users'),
          content: const Text('Are you sure you want to remove all AI test users?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Clear'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text('Clearing AI users...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      await PopulateTestUsers.clearAIUsers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ AI users cleared successfully!'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      // Refresh queue stats
      _loadQueueStats();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error clearing AI users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Test AI matching by creating AI users and joining queue
  Future<void> _testAIMatching() async {
    if (_currentUser == null) return;

    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text('Setting up AI matching test...'),
              ],
            ),
            duration: Duration(seconds: 5),
          ),
        );
      }

      // Step 1: Ensure AI users exist
      await PopulateTestUsers.populateAIUsers(count: 10);

      // Step 2: Join the queue
      await _joinQueue();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎮 AI matching test started! You should be matched with an AI opponent within 15 seconds.'),
            backgroundColor: Colors.purple,
            duration: Duration(seconds: 4),
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error setting up AI matching test: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
