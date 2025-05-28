import 'dart:async';
import 'dart:math';

import '../global.dart';
import '../models/matchmaking_queue_model.dart';
import '../models/user_model.dart';
import '../repositories/matchmaking_queue_repository.dart';
import '../repositories/user_repository.dart';
import '../config/app_config.dart';
import 'game_service.dart';
import 'side_alternation_service.dart';

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

  // AI matching configuration
  static const Duration _minWaitTimeForAI = Duration(seconds: 10); // Spawn AI after 10s wait
  static const Duration _confirmationTimeout = Duration(seconds: 10); // 10s confirmation timeout
  static const bool _enableAIMatching = true;
  static const int _maxAICandidates = 3; // Number of top AI candidates to randomly choose from

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

  /// Join the matchmaking queue with simplified parameters
  Future<String> joinQueue({
    required String userId,
    QueueType queueType = QueueType.ranked,
    int? customMaxEloDifference,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Get user's current Elo rating
      final user = await UserRepository.instance.get(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      final maxEloDifference = customMaxEloDifference ?? AppConfig.instance.maxEloDifference;
      final timeControl = AppConfig.instance.matchTimeControl;

      // Join the queue with simplified parameters
      final queueId = await MatchmakingQueueRepository.instance.joinQueue(
        userId: userId,
        eloRating: user.eloRating,
        queueType: queueType,
        timeControl: timeControl,
        maxEloDifference: maxEloDifference,
        queueTimeout: AppConfig.instance.queueTimeout,
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
    if (players.isEmpty) return;

    logger.info('Processing ${players.length} players in queue');

    // Sort players by join time (FIFO for fairness)
    players.sort((a, b) => a.joinedAt.compareTo(b.joinedAt));

    final matched = <String>{};

    for (int i = 0; i < players.length; i++) {
      final player1 = players[i];
      if (matched.contains(player1.id)) continue;

      logger.info('Processing player ${player1.userId} (Elo: ${player1.eloRating})');

      // Find the best match for this player among other human players
      final bestMatch = await _findBestMatch(player1, players, matched);
      if (bestMatch != null) {
        logger.info('Found human match for ${player1.userId}: ${bestMatch.userId}');
        await _createMatch(player1, bestMatch);
        matched.add(player1.id);
        matched.add(bestMatch.id);
      } else if (_enableAIMatching) {
        logger.info('No human match found for ${player1.userId}, trying AI match');
        // No human opponent found, try to match with AI user
        await _tryMatchWithAI(player1);
        matched.add(player1.id);
      } else {
        logger.info('AI matching disabled, player ${player1.userId} remains in queue');
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

  /// Create a match between two players with confirmation
  Future<void> _createMatch(MatchmakingQueueModel player1, MatchmakingQueueModel player2) async {
    try {
      logger.info('Creating match between ${player1.userId} and ${player2.userId}');

      // Move both players to pending confirmation status
      await MatchmakingQueueRepository.instance.setPendingConfirmation(
        queueId1: player1.id,
        queueId2: player2.id,
        confirmationTimeout: _confirmationTimeout,
      );

      // Wait for both players to confirm or timeout
      await Future.delayed(_confirmationTimeout);

      // Check if both players confirmed
      final updatedPlayer1 = await MatchmakingQueueRepository.instance.get(player1.id);
      final updatedPlayer2 = await MatchmakingQueueRepository.instance.get(player2.id);

      if (updatedPlayer1?.isConfirmed != true || updatedPlayer2?.isConfirmed != true) {
        // At least one player didn't confirm, return them to queue
        await MatchmakingQueueRepository.instance.returnToQueue(
          queueId1: player1.id,
          queueId2: player2.id,
        );
        return;
      }

      // Both players confirmed, create the game
      final colors = await SideAlternationService.instance.determineSideAssignment(
        player1Id: player1.userId,
        player2Id: player2.userId,
      );
      final redPlayerId = colors['red']!;
      final blackPlayerId = colors['black']!;

      // Create the game with the new 5+3 time control
      final gameId = await GameService.instance.startGame(
        redPlayerId: redPlayerId,
        blackPlayerId: blackPlayerId,
        isRanked: player1.queueType == QueueType.ranked,
        timeControl: AppConfig.instance.matchTimeControl,
        incrementSeconds: AppConfig.instance.incrementSeconds,
        metadata: {
          'matchmaking': true,
          'queue_type': player1.queueType.name,
          'time_control': player1.timeControl,
          'increment_seconds': player1.incrementSeconds,
          'player1_wait_time': player1.waitTimeSeconds,
          'player2_wait_time': player2.waitTimeSeconds,
          'elo_difference': (player1.eloRating - player2.eloRating).abs(),
          'side_assignment': {
            'red_player_id': redPlayerId,
            'black_player_id': blackPlayerId,
            'alternation_applied': true,
          },
        },
      );

      // Update side history for both players
      await SideAlternationService.instance.updatePlayerSideHistory(
        playerId: redPlayerId,
        side: 'red',
      );
      await SideAlternationService.instance.updatePlayerSideHistory(
        playerId: blackPlayerId,
        side: 'black',
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

  /// Create a match with an AI opponent
  Future<void> _createAIMatch(MatchmakingQueueModel player) async {
    try {
      // Find suitable AI opponent
      final aiOpponent = await _findSuitableAIOpponent(player);
      if (aiOpponent == null) {
        logger.warning('No suitable opponent found for player ${player.userId} (Elo: ${player.eloRating})');
        return;
      }

      // Move player to pending confirmation
      await MatchmakingQueueRepository.instance.setPendingConfirmation(
        queueId1: player.id,
        queueId2: null,
        confirmationTimeout: _confirmationTimeout,
      );

      // Wait for player confirmation
      await Future.delayed(_confirmationTimeout);

      // Check if player confirmed
      final updatedPlayer = await MatchmakingQueueRepository.instance.get(player.id);
      if (updatedPlayer?.isConfirmed != true) {
        // Player didn't confirm, return to queue
        await MatchmakingQueueRepository.instance.returnToQueue(
          queueId1: player.id,
          queueId2: null,
        );
        return;
      }

      // Determine colors using side alternation service (appear like a normal match)
      final colors = await SideAlternationService.instance.determineSideAssignment(
        player1Id: player.userId,
        player2Id: aiOpponent.uid,
      );
      final redPlayerId = colors['red']!;
      final blackPlayerId = colors['black']!;

      // Create the game with AI opponent disguised as a regular match
      final gameId = await GameService.instance.startGame(
        redPlayerId: redPlayerId,
        blackPlayerId: blackPlayerId,
        isRanked: player.queueType == QueueType.ranked,
        timeControl: AppConfig.instance.matchTimeControl,
        incrementSeconds: AppConfig.instance.incrementSeconds,
        metadata: {
          'matchmaking': true,
          'queue_type': player.queueType.name,
          'time_control': player.timeControl,
          'increment_seconds': player.incrementSeconds,
          'player_wait_time': player.waitTimeSeconds,
          'elo_difference': (player.eloRating - aiOpponent.eloRating).abs(),
          'side_assignment': {
            'red_player_id': redPlayerId,
            'black_player_id': blackPlayerId,
            'alternation_applied': true,
          },
        },
      );

      // Update side history for human player
      final humanSide = redPlayerId == player.userId ? 'red' : 'black';
      await SideAlternationService.instance.updatePlayerSideHistory(
        playerId: player.userId,
        side: humanSide,
      );

      // Mark queue entry as matched
      await MatchmakingQueueRepository.instance.markAsMatched(
        queueId1: player.id,
        queueId2: null,
        matchId: gameId,
      );

      logger.info('Created match for player ${player.userId} (${player.eloRating})');
    } catch (e) {
      logger.severe('Error creating match: $e');
    }
  }

  /// Handle match confirmation for a player
  Future<void> confirmMatch(String queueId) async {
    try {
      await MatchmakingQueueRepository.instance.confirmMatch(queueId);
      logger.info('Player confirmed match: $queueId');
    } catch (e) {
      logger.severe('Error confirming match: $e');
      rethrow;
    }
  }

  /// Cancel match confirmation for a player
  Future<void> declineMatch(String queueId) async {
    try {
      await MatchmakingQueueRepository.instance.declineMatch(queueId);
      logger.info('Player declined match: $queueId');
    } catch (e) {
      logger.severe('Error declining match: $e');
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
    if (players.isEmpty) return;

    logger.info('Processing ${players.length} players in queue');

    // Sort players by join time (FIFO for fairness)
    players.sort((a, b) => a.joinedAt.compareTo(b.joinedAt));

    final matched = <String>{};

    for (int i = 0; i < players.length; i++) {
      final player1 = players[i];
      if (matched.contains(player1.id)) continue;

      logger.info('Processing player ${player1.userId} (Elo: ${player1.eloRating})');

      // Find the best match for this player among other human players
      final bestMatch = await _findBestMatch(player1, players, matched);
      if (bestMatch != null) {
        logger.info('Found human match for ${player1.userId}: ${bestMatch.userId}');
        await _createMatch(player1, bestMatch);
        matched.add(player1.id);
        matched.add(bestMatch.id);
      } else if (_enableAIMatching) {
        logger.info('No human match found for ${player1.userId}, trying AI match');
        // No human opponent found, try to match with AI user
        await _tryMatchWithAI(player1);
        matched.add(player1.id);
      } else {
        logger.info('AI matching disabled, player ${player1.userId} remains in queue');
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
      logger.info('Creating match between ${player1.userId} and ${player2.userId}');

      // Move both players to pending confirmation status
      await MatchmakingQueueRepository.instance.setPendingConfirmation(
        queueId1: player1.id,
        queueId2: player2.id,
        confirmationTimeout: _confirmationTimeout,
      );

      // Wait for both players to confirm or timeout
      await Future.delayed(_confirmationTimeout);

      // Check if both players confirmed
      final updatedPlayer1 = await MatchmakingQueueRepository.instance.get(player1.id);
      final updatedPlayer2 = await MatchmakingQueueRepository.instance.get(player2.id);

      if (updatedPlayer1?.isConfirmed != true || updatedPlayer2?.isConfirmed != true) {
        // At least one player didn't confirm, return them to queue
        await MatchmakingQueueRepository.instance.returnToQueue(
          queueId1: player1.id,
          queueId2: player2.id,
        );
        return;
      }

      // Both players confirmed, create the game
      final colors = await SideAlternationService.instance.determineSideAssignment(
        player1Id: player1.userId,
        player2Id: player2.userId,
      );
      final redPlayerId = colors['red']!;
      final blackPlayerId = colors['black']!;

      // Create the game with the new 5+3 time control
      final gameId = await GameService.instance.startGame(
        redPlayerId: redPlayerId,
        blackPlayerId: blackPlayerId,
        isRanked: player1.queueType == QueueType.ranked,
        timeControl: AppConfig.instance.matchTimeControl,
        incrementSeconds: AppConfig.instance.incrementSeconds,
        metadata: {
          'matchmaking': true,
          'queue_type': player1.queueType.name,
          'time_control': player1.timeControl,
          'increment_seconds': player1.incrementSeconds,
          'player1_wait_time': player1.waitTimeSeconds,
          'player2_wait_time': player2.waitTimeSeconds,
          'elo_difference': (player1.eloRating - player2.eloRating).abs(),
          'side_assignment': {
            'red_player_id': redPlayerId,
            'black_player_id': blackPlayerId,
            'alternation_applied': true,
          },
        },
      );

      // Update side history for both players
      await SideAlternationService.instance.updatePlayerSideHistory(
        playerId: redPlayerId,
        side: 'red',
      );
      await SideAlternationService.instance.updatePlayerSideHistory(
        playerId: blackPlayerId,
        side: 'black',
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

  /// Try to match a player with an AI user when no human opponents are available
  Future<void> _tryMatchWithAI(MatchmakingQueueModel player) async {
    try {
      final waitTime = DateTime.now().difference(player.joinedAt);

      if (waitTime < _minWaitTimeForAI) {
        logger.info('Player ${player.userId} not yet eligible for AI match (${waitTime.inSeconds}s < ${_minWaitTimeForAI.inSeconds}s)');
        return;
      }

      // Create AI match
      await _createAIMatch(player);
    } catch (e) {
      logger.severe('Error in AI matching: $e');
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
