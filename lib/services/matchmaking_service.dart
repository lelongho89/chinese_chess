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
  static const Duration _minWaitTimeForAI = Duration(seconds: 10); // As per requirements
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
    // QueueType queueType = QueueType.ranked, // Always ranked
    // int? customMaxEloDifference, // Use AppConfig
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Get user's current Elo rating
      final user = await UserRepository.instance.get(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      final maxEloDifference = AppConfig.instance.maxEloDifference;
      // Use fixed time control from AppConfig
      final timeControl = AppConfig.instance.getTimeBonusControl; 
      final timeIncrement = AppConfig.instance.timeIncrementControl;

      // Join the queue with fixed parameters
      final queueId = await MatchmakingQueueRepository.instance.joinQueue(
        userId: userId,
        eloRating: user.eloRating,
        queueType: QueueType.ranked, // Always ranked
        timeControl: timeControl,
        timeIncrement: timeIncrement, // Added timeIncrement
        maxEloDifference: maxEloDifference,
        queueTimeout: AppConfig.instance.queueTimeout,
        metadata: metadata,
      );

      // Start matchmaking if not already active
      startMatchmaking();

      logger.info('User $userId joined ranked queue with Elo ${user.eloRating}, Time Control: $timeControl+$timeIncrement');
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

      // Handle pending confirmation timeouts
      final pendingEntries = await MatchmakingQueueRepository.instance.getPendingConfirmationEntries();
      for (final entry in pendingEntries) {
        if (entry.confirmationExpiresAt != null && DateTime.now().isAfter(entry.confirmationExpiresAt!)) {
          logger.info('Confirmation for queue entry ${entry.id} (user ${entry.userId}) has expired.');
          
          // If it's a human-human match, cancel both entries if opponent hasn't confirmed
          if (entry.matchedWithUserId != null && entry.metadata?['ai_opponent_id'] == null) {
            final opponentQueueEntry = await MatchmakingQueueRepository.instance.findOpponentQueueEntry(entry.matchedWithUserId!, entry.matchId!);
            // If opponent also timed out or hasn't confirmed, cancel their entry too
            if (opponentQueueEntry != null && opponentQueueEntry.status == MatchmakingStatus.pendingConfirmation && !opponentQueueEntry.player1Confirmed) {
              await MatchmakingQueueRepository.instance.update(opponentQueueEntry.id, status: MatchmakingStatus.cancelled, matchedWithUserId: null, matchId: null, confirmationExpiresAt: null, player1Confirmed: false, player2Confirmed: false);
              logger.info('Cancelled opponent queue entry ${opponentQueueEntry.id} for user ${opponentQueueEntry.userId} due to timeout or non-confirmation.');
            }
          }
          // Cancel the current entry
          await MatchmakingQueueRepository.instance.update(entry.id, status: MatchmakingStatus.cancelled, matchedWithUserId: null, matchId: null, confirmationExpiresAt: null, player1Confirmed: false, player2Confirmed: false);
          logger.info('Cancelled queue entry ${entry.id} for user ${entry.userId} due to timeout.');
        }
      }
      
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
        // Transition both players to pendingConfirmation
        final confirmationDeadline = DateTime.now().add(const Duration(seconds: 10));
        final tempMatchId = 'temp_match_${player1.id}_${bestMatch.id}'; // Temporary ID

        await MatchmakingQueueRepository.instance.update(
          player1.id,
          status: MatchmakingStatus.pendingConfirmation,
          matchedWithUserId: bestMatch.userId,
          matchId: tempMatchId, // Store temporary match ID
          confirmationExpiresAt: confirmationDeadline,
          player1Confirmed: false, // Player1 (current player) has not confirmed yet
          player2Confirmed: false, // Player2 (opponent) has not confirmed yet
        );
        await MatchmakingQueueRepository.instance.update(
          bestMatch.id,
          status: MatchmakingStatus.pendingConfirmation,
          matchedWithUserId: player1.userId,
          matchId: tempMatchId, // Store temporary match ID
          confirmationExpiresAt: confirmationDeadline,
          player1Confirmed: false, // Player1 (opponent) has not confirmed yet
          player2Confirmed: false, // Player2 (current player) has not confirmed yet
        );

        matched.add(player1.id);
        matched.add(bestMatch.id);
        logger.info('Players ${player1.userId} and ${bestMatch.userId} moved to pendingConfirmation with deadline $confirmationDeadline');

      } else if (AppConfig.instance.enableAIMatching) { // Use AppConfig for AI matching
        logger.info('No human match found for ${player1.userId}, trying AI match');
        // No human opponent found, try to match with AI user
        await _tryMatchWithAI(player1); // This will also set to pendingConfirmation
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
  Future<void> _createMatch(MatchmakingQueueModel player1Queue, MatchmakingQueueModel player2Queue) async {
    try {
      // Ensure both are provided and valid, and their matchId corresponds
      if (player1Queue.matchedWithUserId != player2Queue.userId || 
          player2Queue.matchedWithUserId != player1Queue.userId ||
          player1Queue.matchId != player2Queue.matchId) {
        logger.severe('Mismatch in player queue entries for creating match. P1Q: ${player1Queue.id}, P2Q: ${player2Queue.id}');
        await MatchmakingQueueRepository.instance.update(player1Queue.id, status: MatchmakingStatus.cancelled, matchedWithUserId: null, matchId: null, confirmationExpiresAt: null, player1Confirmed: false, player2Confirmed: false);
        await MatchmakingQueueRepository.instance.update(player2Queue.id, status: MatchmakingStatus.cancelled, matchedWithUserId: null, matchId: null, confirmationExpiresAt: null, player1Confirmed: false, player2Confirmed: false);
        return;
      }
      
      final user1 = await UserRepository.instance.get(player1Queue.userId);
      final user2 = await UserRepository.instance.get(player2Queue.userId);

      if (user1 == null || user2 == null) {
        logger.severe('One or both users not found for match creation. User1: ${player1Queue.userId}, User2: ${player2Queue.userId}');
        await MatchmakingQueueRepository.instance.update(player1Queue.id, status: MatchmakingStatus.cancelled, matchedWithUserId: null, matchId: null, confirmationExpiresAt: null, player1Confirmed: false, player2Confirmed: false);
        await MatchmakingQueueRepository.instance.update(player2Queue.id, status: MatchmakingStatus.cancelled, matchedWithUserId: null, matchId: null, confirmationExpiresAt: null, player1Confirmed: false, player2Confirmed: false);
        return;
      }

      // Determine colors using side alternation service
      final colors = await SideAlternationService.instance.determineSideAssignment(
        player1Id: user1.uid,
        player2Id: user2.uid,
      );
      final redPlayerId = colors['red']!;
      final blackPlayerId = colors['black']!;

      // Create the game
      final gameId = await GameService.instance.startGame(
        redPlayerId: redPlayerId,
        blackPlayerId: blackPlayerId,
        isRanked: player1Queue.queueType == QueueType.ranked, // Both should have same queue type from AppConfig
        timeControlBase: player1Queue.timeControl, // Time control from queue (AppConfig.getTimeBonusControl)
        timeControlIncrement: AppConfig.instance.timeIncrementControl, // Increment from AppConfig
        metadata: {
          'matchmaking': true,
          'queue_type': player1Queue.queueType.name,
          'time_control_base': player1Queue.timeControl,
          'time_control_increment': AppConfig.instance.timeIncrementControl,
          'player1_wait_time': player1Queue.waitTimeSeconds, // This might be from pending state, not full queue time
          'player2_wait_time': player2Queue.waitTimeSeconds, // Same as above
          'elo_difference': (user1.eloRating - user2.eloRating).abs(),
          'side_assignment': {
            'red_player_id': redPlayerId,
            'black_player_id': blackPlayerId,
            'alternation_applied': true,
          },
        },
      );

      // Update side history for both players
      await SideAlternationService.instance.updatePlayerSideHistory(playerId: redPlayerId, side: 'red');
      await SideAlternationService.instance.updatePlayerSideHistory(playerId: blackPlayerId, side: 'black');

      // Mark queue entries as matched
      await MatchmakingQueueRepository.instance.markAsMatched(queueId1: player1Queue.id, queueId2: player2Queue.id, matchId: gameId);

      logger.info('Created H-H match: ${user1.uid} (${user1.eloRating}) vs ${user2.uid} (${user2.eloRating}), Game ID: $gameId');
    } catch (e) {
      logger.severe('Error creating H-H match between ${player1Queue.userId} and ${player2Queue.userId}: $e');
      try {
        await MatchmakingQueueRepository.instance.update(player1Queue.id, status: MatchmakingStatus.cancelled, matchedWithUserId: null, matchId: null, confirmationExpiresAt: null, player1Confirmed: false, player2Confirmed: false);
        await MatchmakingQueueRepository.instance.update(player2Queue.id, status: MatchmakingStatus.cancelled, matchedWithUserId: null, matchId: null, confirmationExpiresAt: null, player1Confirmed: false, player2Confirmed: false);
      } catch (cancelError) {
        logger.severe('Error cancelling queue entries after failed H-H match creation: $cancelError');
      }
    }
  }

  /// Try to match a player with an AI user when no human opponents are available
  Future<void> _tryMatchWithAI(MatchmakingQueueModel player) async {
    try {
      logger.info('🤖 Attempting AI match for player ${player.userId}');

      final waitTime = DateTime.now().difference(player.joinedAt);
      if (waitTime < _minWaitTimeForAI && !AppConfig.instance.showDebugTools) { // Allow instant AI match in debug
        logger.info('Player ${player.userId} waiting ${waitTime.inSeconds}s, not yet eligible for AI match (min: ${_minWaitTimeForAI.inSeconds}s)');
        return;
      }

      logger.info('Player ${player.userId} eligible for AI match after ${waitTime.inSeconds}s wait');

      final aiOpponent = await _findSuitableAIOpponent(player);
      if (aiOpponent == null) {
        logger.warning('No suitable AI opponent found for player ${player.userId} (Elo: ${player.eloRating})');
        return;
      }

      // Transition human player to pendingConfirmation
      final confirmationDeadline = DateTime.now().add(const Duration(seconds: 10)); // 10s for human to confirm
      final tempMatchId = 'temp_ai_match_${player.id}_${aiOpponent.uid}';

      await MatchmakingQueueRepository.instance.update(
        player.id,
        status: MatchmakingStatus.pendingConfirmation,
        matchedWithUserId: aiOpponent.uid, // Store AI opponent ID
        matchId: tempMatchId,
        confirmationExpiresAt: confirmationDeadline,
        player1Confirmed: false, // Human player not yet confirmed
        // player2Confirmed is not applicable for AI matches or AI auto-confirms
        metadata: {
          ...(player.metadata ?? {}), // Preserve existing metadata
          'ai_opponent_name': aiOpponent.displayName,
          'ai_opponent_elo': aiOpponent.eloRating,
          'ai_opponent_id': aiOpponent.uid,
        },
      );

      logger.info('Human player ${player.userId} moved to pendingConfirmation for AI match with ${aiOpponent.displayName}. Deadline: $confirmationDeadline');
      // AI auto-confirms, game creation will happen when human confirms.

    } catch (e) {
      logger.severe('Error processing AI match for ${player.userId}: $e');
      // Optionally, set player's queue status back to 'waiting' or 'cancelled'
      // await MatchmakingQueueRepository.instance.update(player.id, status: MatchmakingStatus.waiting, matchedWithUserId: null, matchId: null);
    }
  }

  /// Find a suitable AI opponent based on Elo rating and preferences
  Future<UserModel?> _findSuitableAIOpponent(MatchmakingQueueModel player) async {
    try {
      logger.info('🔍 Searching for AI opponent for player ${player.userId}');

      // Get all AI users
      final allUsers = await UserRepository.instance.getAll();
      logger.info('Found ${allUsers.length} total users in database');

      final aiUsers = allUsers.where((user) =>
        user.email.endsWith('@aitest.com')).toList();

      logger.info('Found ${aiUsers.length} AI users available');

      if (aiUsers.isEmpty) {
        logger.warning('No AI users available for matching - need to create AI users first!');
        return null;
      }

      // Calculate acceptable Elo range
      final waitTime = DateTime.now().difference(player.joinedAt);
      final maxEloDifference = _calculateExpandedEloDifference(player.eloRating, waitTime);

      // Filter AI users by Elo proximity
      final suitableAI = aiUsers.where((ai) {
        final eloDifference = (player.eloRating - ai.eloRating).abs();
        return eloDifference <= maxEloDifference;
      }).toList();

      if (suitableAI.isEmpty) {
        logger.info('No AI users within Elo range ${player.eloRating} ± $maxEloDifference');
        return null;
      }

      // Sort by Elo proximity and pick the closest one
      suitableAI.sort((a, b) {
        final diffA = (player.eloRating - a.eloRating).abs();
        final diffB = (player.eloRating - b.eloRating).abs();
        return diffA.compareTo(diffB);
      });

      // Add some randomness to avoid always picking the same AI
      final random = Random();
      final topCandidates = suitableAI.take(min(_maxAICandidates, suitableAI.length)).toList();
      final selectedAI = topCandidates[random.nextInt(topCandidates.length)];

      logger.info('Selected AI opponent: ${selectedAI.displayName} (Elo: ${selectedAI.eloRating}) for player ${player.userId} (Elo: ${player.eloRating})');
      return selectedAI;
    } catch (e) {
      logger.severe('Error finding suitable AI opponent: $e');
      return null;
    }
  }

  // Removed old color determination methods - now using SideAlternationService

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

  /// Confirm readiness for a pending match
  Future<void> confirmReady(String userId, String queueId) async {
    try {
      logger.info('User $userId confirming ready for queue entry $queueId');
      final playerQueueEntry = await MatchmakingQueueRepository.instance.getById(queueId);

      if (playerQueueEntry == null || playerQueueEntry.userId != userId) {
        logger.warning('Queue entry $queueId not found or does not belong to user $userId');
        throw Exception('Queue entry not found or invalid.');
      }

      if (playerQueueEntry.status != MatchmakingStatus.pendingConfirmation) {
        logger.warning('Queue entry $queueId is not in pendingConfirmation status. Current status: ${playerQueueEntry.status}');
        throw Exception('Match is not awaiting confirmation.');
      }

      if (playerQueueEntry.confirmationExpiresAt != null && DateTime.now().isAfter(playerQueueEntry.confirmationExpiresAt!)) {
        logger.warning('Confirmation for $queueId has expired.');
        // The periodic check in _processMatchmaking will handle setting this to cancelled.
        // For now, just prevent confirmation and let the user know.
        throw Exception('Confirmation period has expired. Please queue again.');
      }

      final opponentUserId = playerQueueEntry.matchedWithUserId;
      if (opponentUserId == null) {
        logger.severe('Error: Opponent user ID is null for pending confirmation queue entry $queueId');
        await MatchmakingQueueRepository.instance.update(queueId, status: MatchmakingStatus.cancelled, matchedWithUserId: null, matchId: null, confirmationExpiresAt: null, player1Confirmed: false, player2Confirmed: false);
        throw Exception('Internal error: Opponent details missing. Please queue again.');
      }

      final bool isAIMatch = playerQueueEntry.metadata?['ai_opponent_id'] == opponentUserId;

      if (isAIMatch) {
        // Human vs AI: AI auto-confirms. Human confirms here.
        logger.info('AI Match: User $userId confirmed for queue $queueId. AI auto-confirms.');
        // Mark player as confirmed (player1Confirmed is true for the human player's entry)
        await MatchmakingQueueRepository.instance.update(playerQueueEntry.id, player1Confirmed: true);
        // Create the match directly
        await _createMatchWithAI(playerQueueEntry.copyWith(player1Confirmed: true), opponentUserId);
      } else {
        // Human vs Human
        logger.info('Human vs Human Match: User $userId confirmed for queue $queueId.');
        
        // Mark current player as confirmed.
        // We need to know if this user is 'player1' or 'player2' in the context of the match.
        // Let's assume playerQueueEntry.userId is the one who initiated their queue entry.
        // The MatchmakingQueueModel has player1Confirmed and player2Confirmed.
        // If playerQueueEntry.userId is user who joined queue first, they are P1.
        // This is complex. Simpler: just update the current user's entry.

        MatchmakingQueueModel updatedPlayerEntry = playerQueueEntry;

        // Find the opponent's queue entry using the matchId
        final opponentQueueEntry = await MatchmakingQueueRepository.instance.findOpponentQueueEntry(
            opponentUserId, playerQueueEntry.matchId!);

        if (opponentQueueEntry == null || opponentQueueEntry.status != MatchmakingStatus.pendingConfirmation) {
          logger.warning('Opponent queue entry for match ${playerQueueEntry.matchId} not found or not pending. Cancelling for user $userId.');
          await MatchmakingQueueRepository.instance.update(playerQueueEntry.id, status: MatchmakingStatus.cancelled, matchedWithUserId: null, matchId: null, confirmationExpiresAt: null, player1Confirmed: false, player2Confirmed: false);
          throw Exception('Opponent has left or declined. Please queue again.');
        }
        
        // Determine which player is confirming
        // Player A (playerQueueEntry) confirms. Player B (opponentQueueEntry)
        // If playerQueueEntry.userId was the one who initially created *this specific* queue entry, they are P1 *for this entry*.
        // The other player is P2 *for this entry*.
        // This requires careful handling of player1Confirmed and player2Confirmed fields.

        // Let's simplify: the player who is calling confirmReady is player1 for their own entry.
        // The other player is player2 for that entry.
        // We need to update player1Confirmed on playerQueueEntry.
        // And check player1Confirmed on opponentQueueEntry (which is their own confirmation).

        bool currentEntryIsPlayer1 = playerQueueEntry.userId == userId; // This is always true here.

        if (currentEntryIsPlayer1) {
            await MatchmakingQueueRepository.instance.update(playerQueueEntry.id, player1Confirmed: true);
            updatedPlayerEntry = playerQueueEntry.copyWith(player1Confirmed: true);
        }
        // No else, because this method is called by the owner of playerQueueEntry.

        // Now check if the opponent has also confirmed (their player1Confirmed field on their entry)
        if (updatedPlayerEntry.player1Confirmed && opponentQueueEntry.player1Confirmed) {
          logger.info('Both players ($userId and $opponentUserId) confirmed for match ${playerQueueEntry.matchId}. Creating match.');
          // Determine who is player1 and player2 for the actual game based on who joined the queue first.
          if (updatedPlayerEntry.joinedAt.isBefore(opponentQueueEntry.joinedAt)) {
            await _createMatch(updatedPlayerEntry, opponentQueueEntry);
          } else {
            await _createMatch(opponentQueueEntry, updatedPlayerEntry);
          }
        } else {
          logger.info('User $userId confirmed for match ${playerQueueEntry.matchId}. Waiting for opponent $opponentUserId.');
        }
      }
    } catch (e) {
      logger.severe('Error in confirmReady for user $userId, queue $queueId: $e');
      // Rethrow to allow UI to display specific error messages.
      rethrow;
    }
  }

  /// Create a match with an AI opponent after human confirmation
  Future<void> _createMatchWithAI(MatchmakingQueueModel humanPlayerQueue, String aiUserIdFromQueue) async {
    try {
      final humanPlayer = await UserRepository.instance.get(humanPlayerQueue.userId);
      if (humanPlayer == null) {
        logger.severe('Human player ${humanPlayerQueue.userId} not found for AI match.');
        await MatchmakingQueueRepository.instance.update(humanPlayerQueue.id, status: MatchmakingStatus.cancelled, matchedWithUserId: null, matchId: null, confirmationExpiresAt: null, player1Confirmed: false, player2Confirmed: false);
        return;
      }

      // AI details should be in humanPlayerQueue.metadata
      final aiOpponentName = humanPlayerQueue.metadata?['ai_opponent_name'] as String? ?? 'AI Bot';
      final aiOpponentElo = humanPlayerQueue.metadata?['ai_opponent_elo'] as int? ?? 1200;
      final aiOpponentId = humanPlayerQueue.metadata?['ai_opponent_id'] as String?;

      if (aiOpponentId == null || aiOpponentId != aiUserIdFromQueue) {
          logger.severe('AI opponent ID mismatch or missing in metadata for queue ${humanPlayerQueue.id}. Expected $aiUserIdFromQueue, found $aiOpponentId');
          await MatchmakingQueueRepository.instance.update(humanPlayerQueue.id, status: MatchmakingStatus.cancelled, matchedWithUserId: null, matchId: null, confirmationExpiresAt: null, player1Confirmed: false, player2Confirmed: false);
          return;
      }
      
      // Determine colors using side alternation service for AI matches
      final colors = await SideAlternationService.instance.determineSideAssignmentWithAI(
        humanPlayerId: humanPlayer.uid,
        aiPlayerId: aiOpponentId,
      );
      final redPlayerId = colors['red']!;
      final blackPlayerId = colors['black']!;

      // Create the game
      final gameId = await GameService.instance.startGame(
        redPlayerId: redPlayerId,
        blackPlayerId: blackPlayerId,
        isRanked: humanPlayerQueue.queueType == QueueType.ranked,
        timeControlBase: humanPlayerQueue.timeControl,
        timeControlIncrement: AppConfig.instance.timeIncrementControl,
        metadata: {
          'matchmaking': true,
          'ai_match': true, 
          'queue_type': humanPlayerQueue.queueType.name,
          'time_control_base': humanPlayerQueue.timeControl,
          'time_control_increment': AppConfig.instance.timeIncrementControl,
          'player_wait_time': humanPlayerQueue.waitTimeSeconds,
          'elo_difference': (humanPlayer.eloRating - aiOpponentElo).abs(),
          'ai_opponent_id': aiOpponentId,
          'ai_opponent_name': aiOpponentName, 
          'ai_opponent_elo': aiOpponentElo,   
          'side_assignment': {
            'red_player_id': redPlayerId,
            'black_player_id': blackPlayerId,
            'alternation_applied': true,
            'human_player_id': humanPlayer.uid,
          },
        },
      );

      // Update side history for human player only
      final humanSide = redPlayerId == humanPlayer.uid ? 'red' : 'black';
      await SideAlternationService.instance.updatePlayerSideHistory(playerId: humanPlayer.uid, side: humanSide);

      // Mark human player's queue entry as matched
      await MatchmakingQueueRepository.instance.markAsMatched(queueId1: humanPlayerQueue.id, queueId2: null, matchId: gameId);

      logger.info('Created AI match: ${humanPlayer.uid} (${humanPlayer.eloRating}) vs AI ${aiOpponentName} (${aiOpponentElo}), Game ID: $gameId');
    } catch (e) {
      logger.severe('Error creating AI match for ${humanPlayerQueue.userId}: $e');
      try {
        await MatchmakingQueueRepository.instance.update(humanPlayerQueue.id, status: MatchmakingStatus.cancelled, matchedWithUserId: null, matchId: null, confirmationExpiresAt: null, player1Confirmed: false, player2Confirmed: false);
      } catch (cancelError) {
        logger.severe('Error cancelling queue entry after failed AI match creation: $cancelError');
      }
    }
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
