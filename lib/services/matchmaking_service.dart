import 'dart:async';
import 'dart:math';

import '../global.dart';
import '../models/matchmaking_queue_model.dart';
import '../models/user_model.dart';
import '../repositories/matchmaking_queue_repository.dart';
import '../repositories/user_repository.dart';
import 'game_service.dart';

/// Service for handling matchmaking with Elo proximity
class MatchmakingService {
  // Singleton pattern
  static MatchmakingService? _instance;
  static MatchmakingService get instance => _instance ??= MatchmakingService._();

  MatchmakingService._();

  // Matchmaking configuration
  static const int _baseEloDifference = 200;
  static const int _maxEloDifference = 800;
  static const Duration _waitTimeExpansion = Duration(seconds: 30);
  static const Duration _maxWaitTime = Duration(minutes: 10);

  Timer? _matchmakingTimer;
  bool _isMatchmakingActive = false;

  /// Start the matchmaking service
  void startMatchmaking() {
    if (_isMatchmakingActive) return;

    _isMatchmakingActive = true;
    _matchmakingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _processMatchmaking();
    });

    logger.info('Matchmaking service started');
  }

  /// Stop the matchmaking service
  void stopMatchmaking() {
    _isMatchmakingActive = false;
    _matchmakingTimer?.cancel();
    _matchmakingTimer = null;
    logger.info('Matchmaking service stopped');
  }

  /// Join the matchmaking queue
  Future<String> joinQueue({
    required String userId,
    QueueType queueType = QueueType.ranked,
    int timeControl = 180,
    PreferredColor? preferredColor,
    int? customMaxEloDifference,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Get user's current Elo rating
      final user = await UserRepository.instance.get(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      final maxEloDifference = customMaxEloDifference ?? _calculateMaxEloDifference(user.eloRating);

      // Join the queue
      final queueId = await MatchmakingQueueRepository.instance.joinQueue(
        userId: userId,
        eloRating: user.eloRating,
        queueType: queueType,
        timeControl: timeControl,
        preferredColor: preferredColor,
        maxEloDifference: maxEloDifference,
        metadata: metadata,
      );

      // Start matchmaking if not already active
      startMatchmaking();

      logger.info('User $userId joined queue with Elo ${user.eloRating}');
      return queueId;
    } catch (e) {
      logger.severe('Error joining matchmaking queue: $e');
      rethrow;
    }
  }

  /// Leave the matchmaking queue
  Future<void> leaveQueue(String queueId) async {
    try {
      await MatchmakingQueueRepository.instance.leaveQueue(queueId);
      logger.info('Left matchmaking queue: $queueId');
    } catch (e) {
      logger.severe('Error leaving matchmaking queue: $e');
      rethrow;
    }
  }

  /// Cancel all queue entries for a user
  Future<void> cancelUserQueue(String userId) async {
    try {
      await MatchmakingQueueRepository.instance.cancelUserQueue(userId);
      logger.info('Cancelled queue for user: $userId');
    } catch (e) {
      logger.severe('Error cancelling user queue: $e');
      rethrow;
    }
  }

  /// Get user's active queue entry
  Future<MatchmakingQueueModel?> getUserActiveQueue(String userId) async {
    try {
      return await MatchmakingQueueRepository.instance.getUserActiveQueue(userId);
    } catch (e) {
      logger.severe('Error getting user active queue: $e');
      rethrow;
    }
  }

  /// Get queue statistics
  Future<Map<String, dynamic>> getQueueStats() async {
    try {
      return await MatchmakingQueueRepository.instance.getQueueStats();
    } catch (e) {
      logger.severe('Error getting queue stats: $e');
      rethrow;
    }
  }

  /// Process matchmaking (called periodically)
  Future<void> _processMatchmaking() async {
    if (!_isMatchmakingActive) return;

    try {
      // Expire old entries first
      await MatchmakingQueueRepository.instance.expireOldEntries();

      // Get all waiting players grouped by queue type
      final rankedPlayers = await MatchmakingQueueRepository.instance.getWaitingPlayersByEloRange(
        minElo: 0,
        maxElo: 5000,
        queueType: QueueType.ranked,
      );

      final casualPlayers = await MatchmakingQueueRepository.instance.getWaitingPlayersByEloRange(
        minElo: 0,
        maxElo: 5000,
        queueType: QueueType.casual,
      );

      // Process matches for each queue type
      await _processQueueMatches(rankedPlayers);
      await _processQueueMatches(casualPlayers);

    } catch (e) {
      logger.severe('Error processing matchmaking: $e');
    }
  }

  /// Process matches for a specific queue
  Future<void> _processQueueMatches(List<MatchmakingQueueModel> players) async {
    if (players.length < 2) return;

    // Sort players by join time (FIFO for fairness)
    players.sort((a, b) => a.joinedAt.compareTo(b.joinedAt));

    final matched = <String>{};

    for (int i = 0; i < players.length; i++) {
      final player1 = players[i];
      if (matched.contains(player1.id)) continue;

      // Find the best match for this player
      final bestMatch = await _findBestMatch(player1, players, matched);
      if (bestMatch != null) {
        await _createMatch(player1, bestMatch);
        matched.add(player1.id);
        matched.add(bestMatch.id);
      }
    }
  }

  /// Find the best match for a player
  Future<MatchmakingQueueModel?> _findBestMatch(
    MatchmakingQueueModel player,
    List<MatchmakingQueueModel> candidates,
    Set<String> matched,
  ) async {
    final waitTime = DateTime.now().difference(player.joinedAt);
    final expandedEloDifference = _calculateExpandedEloDifference(player.eloRating, waitTime);

    MatchmakingQueueModel? bestMatch;
    int bestEloDifference = expandedEloDifference + 1;

    for (final candidate in candidates) {
      if (candidate.id == player.id || matched.contains(candidate.id)) continue;

      // Check if they can match based on Elo difference
      final eloDifference = (player.eloRating - candidate.eloRating).abs();
      final candidateWaitTime = DateTime.now().difference(candidate.joinedAt);
      final candidateExpandedEloDifference = _calculateExpandedEloDifference(candidate.eloRating, candidateWaitTime);

      // Both players must accept the Elo difference
      if (eloDifference <= expandedEloDifference && eloDifference <= candidateExpandedEloDifference) {
        // Check time control compatibility
        if (player.timeControl == candidate.timeControl) {
          // Prefer closer Elo ratings
          if (eloDifference < bestEloDifference) {
            bestMatch = candidate;
            bestEloDifference = eloDifference;
          }
        }
      }
    }

    return bestMatch;
  }

  /// Create a match between two players
  Future<void> _createMatch(MatchmakingQueueModel player1, MatchmakingQueueModel player2) async {
    try {
      // Determine colors based on preferences and Elo ratings
      final colors = _determineColors(player1, player2);
      final redPlayerId = colors['red']!;
      final blackPlayerId = colors['black']!;

      // Create the game
      final gameId = await GameService.instance.startGame(
        redPlayerId: redPlayerId,
        blackPlayerId: blackPlayerId,
        isRanked: player1.queueType == QueueType.ranked,
        metadata: {
          'matchmaking': true,
          'queue_type': player1.queueType.name,
          'time_control': player1.timeControl,
          'player1_wait_time': player1.waitTimeSeconds,
          'player2_wait_time': player2.waitTimeSeconds,
          'elo_difference': (player1.eloRating - player2.eloRating).abs(),
        },
      );

      // Mark queue entries as matched
      await MatchmakingQueueRepository.instance.markAsMatched(
        queueId1: player1.id,
        queueId2: player2.id,
        matchId: gameId,
      );

      logger.info('Created match: ${player1.userId} (${player1.eloRating}) vs ${player2.userId} (${player2.eloRating})');
    } catch (e) {
      logger.severe('Error creating match: $e');
      rethrow;
    }
  }

  /// Determine colors for the two players
  Map<String, String> _determineColors(MatchmakingQueueModel player1, MatchmakingQueueModel player2) {
    // If both have preferences and they're different, honor them
    if (player1.preferredColor != null && player2.preferredColor != null) {
      if (player1.preferredColor != player2.preferredColor) {
        return {
          'red': player1.preferredColor == PreferredColor.red ? player1.userId : player2.userId,
          'black': player1.preferredColor == PreferredColor.black ? player1.userId : player2.userId,
        };
      }
    }

    // If only one has a preference, honor it
    if (player1.preferredColor != null && player2.preferredColor == null) {
      return {
        'red': player1.preferredColor == PreferredColor.red ? player1.userId : player2.userId,
        'black': player1.preferredColor == PreferredColor.black ? player1.userId : player2.userId,
      };
    }

    if (player2.preferredColor != null && player1.preferredColor == null) {
      return {
        'red': player2.preferredColor == PreferredColor.red ? player2.userId : player1.userId,
        'black': player2.preferredColor == PreferredColor.black ? player2.userId : player1.userId,
      };
    }

    // Default: higher Elo player gets red (traditional advantage)
    if (player1.eloRating >= player2.eloRating) {
      return {'red': player1.userId, 'black': player2.userId};
    } else {
      return {'red': player2.userId, 'black': player1.userId};
    }
  }

  /// Calculate maximum Elo difference based on player's rating
  int _calculateMaxEloDifference(int eloRating) {
    // Higher rated players have stricter matching
    if (eloRating >= 2000) return 150;
    if (eloRating >= 1600) return 200;
    if (eloRating >= 1200) return 250;
    return 300; // Beginners get more flexible matching
  }

  /// Calculate expanded Elo difference based on wait time
  int _calculateExpandedEloDifference(int eloRating, Duration waitTime) {
    final baseMaxDiff = _calculateMaxEloDifference(eloRating);
    
    // Expand search range every 30 seconds
    final expansions = waitTime.inSeconds ~/ _waitTimeExpansion.inSeconds;
    final expandedDiff = baseMaxDiff + (expansions * 50);
    
    return min(expandedDiff, _maxEloDifference);
  }

  /// Clean up expired entries (call periodically)
  Future<void> cleanupExpiredEntries() async {
    try {
      await MatchmakingQueueRepository.instance.cleanupExpiredEntries();
    } catch (e) {
      logger.severe('Error cleaning up expired entries: $e');
    }
  }
}
