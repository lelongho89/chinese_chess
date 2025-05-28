import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../models/matchmaking_queue_model.dart';
import '../models/user_model.dart';
import '../models/supabase_auth_service.dart';
import '../services/matchmaking_service.dart';
import '../repositories/user_repository.dart';
import '../utils/populate_test_users.dart';
import '../config/app_config.dart';
import '../global.dart';
import '../l10n/generated/app_localizations.dart';

class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({super.key});

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> {
  // QueueType _selectedQueueType = QueueType.ranked; // Always ranked
  // Removed time control and color preference - now using AppConfig
  bool _isSearching = false;
  MatchmakingQueueModel? _currentQueue;
  UserModel? _currentUser;
  Timer? _updateTimer;
  Map<String, dynamic>? _queueStats;

  // New state variables for pendingConfirmation UI
  Timer? _confirmationCountdownTimer;
  int _confirmationTimeLeft = 10; // seconds
  String? _opponentDisplayName;
  int? _opponentElo;
  String? _playerColor; // 'Red' or 'Black'

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
    _confirmationCountdownTimer?.cancel();
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
          // _selectedQueueType = existingQueue.queueType; // Always ranked
          // Time control and color preference no longer stored in queue
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
    if (_currentUser == null || !_isSearching) {
      // If not searching but an update is called, ensure timer is stopped.
      _confirmationCountdownTimer?.cancel();
      return;
    }

    try {
      final queue = await MatchmakingService.instance.getUserActiveQueue(_currentUser!.uid);
      
      if (!mounted) return; // Check if the widget is still in the tree

      setState(() {
        _currentQueue = queue;
      });

      if (queue != null) {
        switch (queue.status) {
          case MatchmakingStatus.waiting:
            _stopConfirmationCountdown(); // Ensure countdown is stopped if we somehow revert to waiting
            // Keep _updateTimer running for MatchmakingStatus.waiting
            break;
          case MatchmakingStatus.pendingConfirmation:
            if (_confirmationCountdownTimer == null || !_confirmationCountdownTimer!.isActive) {
              _startConfirmationCountdown(queue.confirmationExpiresAt);
            }
            await _loadOpponentDetails(queue);
            // _updateTimer will continue to check status, which is fine.
            break;
          case MatchmakingStatus.matched:
            _stopConfirmationCountdown();
            _stopSearching(); // This cancels _updateTimer
            logger.info("Match found and confirmed! Navigating to game screen for match: ${queue.matchId}");
            if (mounted && queue.matchId != null) {
              // IMPORTANT: Replace with your actual game screen route and arguments
              // For example:
              // Navigator.of(context).pushReplacementNamed(
              //   '/game_screen', 
              //   arguments: {
              //     'gameId': queue.matchId!,
              //     'opponentName': _opponentDisplayName ?? 'Opponent', // Use cached opponent name
              //     'opponentElo': _opponentElo ?? 1200, // Use cached opponent Elo
              //     'playerColor': _playerColor, // Pass determined player color
              //     'timeControl': AppConfig.instance.matchTimeControlFormatted, // Pass time control string
              //   },
              // );
              // For now, just show a dialog as a placeholder for navigation
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Match Ready!"),
                  content: Text("Navigating to game ${queue.matchId}.\nOpponent: ${_opponentDisplayName ?? 'Opponent'} (Elo: ${_opponentElo ?? 1200})\nYour Color: ${_playerColor ?? 'Unknown'}"),
                  actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("OK"))],
                )
              );
            }
            break;
          case MatchmakingStatus.cancelled:
          case MatchmakingStatus.expired:
            _stopConfirmationCountdown();
            // _isSearching remains true to show "cancelled/expired, try again?" UI
            // _updateTimer is stopped by _stopSearching() if called,
            // but for cancelled/expired, we might want to stop it explicitly if _isSearching is kept true.
            _updateTimer?.cancel(); 
            break;
        }
      } else {
        // Queue is null, meaning user is not in queue or it was resolved (matched, cancelled, expired)
        _stopConfirmationCountdown();
        // If _isSearching is still true, it means the queue was likely resolved externally or timed out.
        // The build method will handle showing "No match found" or "Cancelled" based on _currentQueue being null.
        if (_isSearching) {
            _updateTimer?.cancel(); // Stop polling if queue is null but we thought we were searching.
        }
      }
    } catch (e) {
      logger.severe('Error updating queue status: $e');
      if (mounted) {
        // Optionally show a generic error to the user if status updates fail.
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Error updating match status. Please try again.')),
        // );
      }
      _stopConfirmationCountdown();
      // Consider stopping search on error to prevent rapid error loops.
      // _stopSearching(); 
    }
  }

  void _startConfirmationCountdown(DateTime? expiresAt) {
    _confirmationCountdownTimer?.cancel();
    if (expiresAt == null) return;

    final now = DateTime.now();
    final initialDuration = expiresAt.difference(now);
    
    if (initialDuration.isNegative) {
      setState(() {
        _confirmationTimeLeft = 0;
      });
      // Timeout logic will be handled by MatchmakingService and _updateQueueStatus
      return;
    }

    setState(() {
      _confirmationTimeLeft = initialDuration.inSeconds;
    });

    _confirmationCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final timeLeft = expiresAt.difference(DateTime.now()).inSeconds;
      if (timeLeft <= 0) {
        timer.cancel();
        setState(() {
          _confirmationTimeLeft = 0;
        });
        // MatchmakingService will handle the timeout and update status to cancelled.
        // _updateQueueStatus will then pick up this change.
        logger.info("Confirmation countdown finished for queue: ${_currentQueue?.id}");
      } else {
        setState(() {
          _confirmationTimeLeft = timeLeft;
        });
      }
    });
  }

  void _stopConfirmationCountdown() {
    _confirmationCountdownTimer?.cancel();
    _confirmationCountdownTimer = null; // Ensure it's reset
    setState(() {
      _confirmationTimeLeft = 10; // Reset to default
    });
  }

  Future<void> _loadOpponentDetails(MatchmakingQueueModel queue) async {
    if (queue.matchedWithUserId == null) return;

    // Check if AI opponent from metadata
    if (queue.metadata?['ai_opponent_id'] == queue.matchedWithUserId) {
      setState(() {
        _opponentDisplayName = queue.metadata?['ai_opponent_name'] as String? ?? 'AI Opponent';
        _opponentElo = queue.metadata?['ai_opponent_elo'] as int? ?? 1200;
        // TODO: Determine player color based on side_assignment in metadata if available
        // For now, default or leave null
        _playerColor = _determinePlayerColor(queue.metadata?['side_assignment']);

      });
    } else {
      // Human opponent
      try {
        final opponent = await UserRepository.instance.get(queue.matchedWithUserId!);
        if (opponent != null) {
          setState(() {
            _opponentDisplayName = opponent.displayName;
            _opponentElo = opponent.eloRating;
             _playerColor = _determinePlayerColor(queue.metadata?['side_assignment']);
          });
        }
      } catch (e) {
        logger.severe("Error loading opponent details: $e");
        setState(() {
          _opponentDisplayName = "Opponent"; // Fallback
          _opponentElo = null;
        });
      }
    }
  }

  String? _determinePlayerColor(Map<String, dynamic>? sideAssignment) {
    if (_currentUser == null || sideAssignment == null) return null;
    if (sideAssignment['red_player_id'] == _currentUser!.uid) return 'Red';
    if (sideAssignment['black_player_id'] == _currentUser!.uid) return 'Black';
    return null; // Should not happen if side assignment is correct
  }


  Future<void> _joinQueue() async {
    if (_currentUser == null) return;

    // Reset any previous opponent/confirmation details
    _resetPendingMatchState();

    setState(() {
      _isSearching = true;
      _currentQueue = null; // Clear previous queue state before joining new
    });

    try {
      await MatchmakingService.instance.joinQueue(userId: _currentUser!.uid);
      // _updateQueueStatus will be called by _startUpdateTimer and fetch the new queue entry.
      _startUpdateTimer();
      _loadQueueStats(); // Refresh queue stats
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error joining queue: ${e.toString()}')),
      );
    }
  }

  Future<void> _leaveQueue() async {
    if (_currentQueue == null) return;
    final queueIdToLeave = _currentQueue!.id; // Cache, as _currentQueue might change
    
    _resetPendingMatchState(); // Clear confirmation UI elements

    try {
      await MatchmakingService.instance.leaveQueue(queueIdToLeave);
      // _stopSearching also sets _currentQueue to null and cancels _updateTimer.
      _stopSearching(); 
      _loadQueueStats(); // Refresh queue stats
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error leaving queue: ${e.toString()}')),
      );
    }
  }
  
  Future<void> _confirmReady() async {
    if (_currentUser == null || _currentQueue == null || _currentQueue!.status != MatchmakingStatus.pendingConfirmation) {
      return;
    }
    try {
      await MatchmakingService.instance.confirmReady(_currentUser!.uid, _currentQueue!.id);
      // Status will be updated by _updateQueueStatus, which should then trigger navigation if matched.
      // No need to stop countdown here, _updateQueueStatus will handle it.
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error confirming ready: ${e.toString()}')),
      );
      // If confirm fails, we might want to refresh status or leave queue
      _updateQueueStatus(); 
    }
  }

  void _stopSearching() {
    _updateTimer?.cancel();
    _updateTimer = null;
    _stopConfirmationCountdown(); // Also stop confirmation countdown if it's running
    setState(() {
      _isSearching = false;
      _currentQueue = null; // Important to clear queue
      _opponentDisplayName = null;
      _opponentElo = null;
      _playerColor = null;
    });
  }

  void _resetPendingMatchState() {
    _stopConfirmationCountdown();
    setState(() {
      _opponentDisplayName = null;
      _opponentElo = null;
      _playerColor = null;
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

            // Main content based on matchmaking state
            _buildMatchmakingContent(),

            // Debug Section (for testing) - Conditionally show if not in an active search/confirmation
            if (!_isSearching || (_currentQueue == null && _isSearching) || (_currentQueue != null && (_currentQueue!.status == MatchmakingStatus.cancelled || _currentQueue!.status == MatchmakingStatus.expired))) ...[
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

  // Widget _buildQueueTypeSelector() { // Removed queue type selector
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Queue Type',
  //         style: Theme.of(context).textTheme.titleMedium?.copyWith(
  //           fontWeight: FontWeight.w600,
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       Row(
  //         children: [
  //           Expanded(
  //             child: _buildQueueTypeOption(QueueType.ranked, 'Ranked', 'Affects Elo rating'),
  //           ),
  //           const SizedBox(width: 12),
  //           Expanded(
  //             child: _buildQueueTypeOption(QueueType.casual, 'Casual', 'Just for fun'),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildQueueTypeOption(QueueType type, String title, String subtitle) { // Removed queue type option
  //   final isSelected = _selectedQueueType == type;
  //   return GestureDetector(
  //     onTap: () => setState(() => _selectedQueueType = type),
  //     child: Container(
  //       padding: const EdgeInsets.all(12),
  //       decoration: BoxDecoration(
  //         border: Border.all(
  //           color: isSelected
  //               ? Theme.of(context).colorScheme.primary
  //               : Theme.of(context).colorScheme.outline,
  //           width: isSelected ? 2 : 1,
  //         ),
  //         borderRadius: BorderRadius.circular(12),
  //         color: isSelected
  //             ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
  //             : null,
  //       ),
  //       child: Column(
  //         children: [
  //           Text(
  //             title,
  //             style: Theme.of(context).textTheme.titleSmall?.copyWith(
  //               fontWeight: FontWeight.w600,
  //               color: isSelected ? Theme.of(context).colorScheme.primary : null,
  //             ),
  //           ),
  //           const SizedBox(height: 4),
  //           Text(
  //             subtitle,
  //             style: Theme.of(context).textTheme.bodySmall,
  //             textAlign: TextAlign.center,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildTimeControlDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Match Settings', 
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          child: Row(
            children: [
              Icon(
                Icons.timer,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConfig.instance.matchTimeControlFormatted,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      'All games are Ranked: ${AppConfig.instance.matchTimeControlFormatted}', // Combined info
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'RANKED', 
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Side assignment (Red/Black) is automatically balanced for fair play',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMatchmakingContent() {
    if (_isSearching) {
      if (_currentQueue == null) {
        // This state means search started, but queue is null (e.g. initial join or after a full timeout/external cancel)
        return _buildNoMatchFoundUI(); // Or a generic "Searching..." if preferred for this brief state
      }
      switch (_currentQueue!.status) {
        case MatchmakingStatus.waiting:
          return _buildSearchingUI();
        case MatchmakingStatus.pendingConfirmation:
          return _buildPendingConfirmationUI();
        case MatchmakingStatus.matched:
          // Usually, navigation would have happened. This is a fallback.
          return Center(child: Text('Match confirmed! Preparing game...', style: Theme.of(context).textTheme.titleLarge));
        case MatchmakingStatus.cancelled:
        case MatchmakingStatus.expired:
          return _buildMatchCancelledOrExpiredUI();
        default: // Should not happen
          return _buildInitialUI();
      }
    } else {
      // Not searching: initial state or after cancelling a search that didn't reach pendingConfirmation.
      return _buildInitialUI();
    }
  }

  Widget _buildInitialUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimeControlDisplay(),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _currentUser != null ? _joinQueue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(context.l10n.findMatch, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchingUI() {
    return Card(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3)),
                const SizedBox(width: 16),
                Text(
                  'Searching for a match...',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Elapsed time: ${_formatTime(_currentQueue?.waitTimeSeconds ?? 0)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _leaveQueue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                ),
                child: Text(context.l10n.cancelSearch),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingConfirmationUI() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Match Found!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.onTertiaryContainer)),
            const SizedBox(height: 16),
            if (_opponentDisplayName != null) ...[
              Text('Playing as ${_playerColor ?? "Unknown"}', style: Theme.of(context).textTheme.titleMedium),
              Text('vs ${_opponentDisplayName!} (Elo: ${_opponentElo ?? 'N/A'})', style: Theme.of(context).textTheme.titleMedium),
            ] else ...[
              const CircularProgressIndicator(), // Show loading if opponent details are still fetching
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_outlined, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('Confirm within: $_confirmationTimeLeft seconds', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _confirmReady,
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).colorScheme.onPrimary),
                child: Text(l10n.confirmReady.toUpperCase(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _leaveQueue, // This will cancel the pending confirmation
                child: Text(l10n.cancelSearch, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchCancelledOrExpiredUI() {
    final l10n = AppLocalizations.of(context)!;
    String message;
    if (_currentQueue?.status == MatchmakingStatus.cancelled) {
      message = "Match canceled by you or opponent.";
    } else if (_currentQueue?.status == MatchmakingStatus.expired) {
      message = "Match search timed out.";
    } else if (_currentQueue?.status == MatchmakingStatus.pendingConfirmation && _confirmationTimeLeft == 0) {
      message = "Confirmation failed. Opponent may not have confirmed or time ran out.";
    } else {
      // Generic fallback if queue becomes null while _isSearching
      message = "No suitable match found."; 
    }

    return Card(
      color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.7),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onErrorContainer)),
            const SizedBox(height: 8),
            Text("Please try again.", style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _stopSearching(); // Clear old state
                      _joinQueue();     // Start new search
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                    child: Text(l10n.retry, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextButton(
                    onPressed: _stopSearching, // Go back to initial screen
                    child: Text(l10n.cancel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNoMatchFoundUI() {
     final l10n = AppLocalizations.of(context)!;
     return Card(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("No match found this time.", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text("The queue was empty or no suitable opponent was available.", style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
             Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                       _stopSearching(); 
                       _joinQueue();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                    child: Text(l10n.retry, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextButton(
                    onPressed: _stopSearching,
                    child: Text(l10n.cancel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
