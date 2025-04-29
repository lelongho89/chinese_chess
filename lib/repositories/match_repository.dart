import 'package:cloud_firestore/cloud_firestore.dart';

import '../global.dart';
import '../models/match_model.dart';
import 'base_repository.dart';

/// Repository for handling match data in Firestore
class MatchRepository extends BaseRepository<MatchModel> {
  // Singleton pattern
  static MatchRepository? _instance;
  static MatchRepository get instance => _instance ??= MatchRepository._();

  MatchRepository._() : super('matches');

  @override
  MatchModel fromFirestore(DocumentSnapshot doc) {
    return MatchModel.fromFirestore(doc);
  }

  @override
  Map<String, dynamic> toFirestore(MatchModel model) {
    return model.toMap();
  }

  // Create a new match
  Future<String> createMatch({
    String? tournamentId,
    required String redPlayerId,
    required String blackPlayerId,
    required Timestamp scheduledTime,
    required int round,
    required int matchNumber,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final matchModel = MatchModel(
        id: '', // Will be set by Firestore
        tournamentId: tournamentId,
        redPlayerId: redPlayerId,
        blackPlayerId: blackPlayerId,
        scheduledTime: scheduledTime,
        round: round,
        matchNumber: matchNumber,
        metadata: metadata,
      );

      final matchId = await add(matchModel);
      logger.info('Match created: $matchId');
      return matchId;
    } catch (e) {
      logger.severe('Error creating match: $e');
      rethrow;
    }
  }

  // Start a match
  Future<void> startMatch(String matchId, String gameId) async {
    try {
      await update(matchId, {
        'status': MatchStatus.inProgress.index,
        'startTime': Timestamp.now(),
        'gameId': gameId,
      });
      
      logger.info('Match started: $matchId -> $gameId');
    } catch (e) {
      logger.severe('Error starting match: $e');
      rethrow;
    }
  }

  // End a match
  Future<void> endMatch(String matchId, {
    String? winnerId,
    bool isDraw = false,
  }) async {
    try {
      await update(matchId, {
        'status': MatchStatus.completed.index,
        'endTime': Timestamp.now(),
        'winnerId': winnerId,
        'isDraw': isDraw,
      });
      
      logger.info('Match ended: $matchId');
    } catch (e) {
      logger.severe('Error ending match: $e');
      rethrow;
    }
  }

  // Cancel a match
  Future<void> cancelMatch(String matchId) async {
    try {
      await update(matchId, {
        'status': MatchStatus.cancelled.index,
      });
      
      logger.info('Match cancelled: $matchId');
    } catch (e) {
      logger.severe('Error cancelling match: $e');
      rethrow;
    }
  }

  // Get matches by tournament
  Future<List<MatchModel>> getMatchesByTournament(String tournamentId) async {
    try {
      return await query((collection) => 
        collection
          .where('tournamentId', isEqualTo: tournamentId)
          .orderBy('round')
          .orderBy('matchNumber')
      );
    } catch (e) {
      logger.severe('Error getting matches by tournament: $e');
      rethrow;
    }
  }

  // Get matches by player
  Future<List<MatchModel>> getMatchesByPlayer(String playerId, {int limit = 10}) async {
    try {
      return await query((collection) => 
        collection
          .where(Filter.or(
            Filter('redPlayerId', isEqualTo: playerId),
            Filter('blackPlayerId', isEqualTo: playerId),
          ))
          .orderBy('scheduledTime', descending: true)
          .limit(limit)
      );
    } catch (e) {
      logger.severe('Error getting matches by player: $e');
      rethrow;
    }
  }

  // Get upcoming matches by player
  Future<List<MatchModel>> getUpcomingMatchesByPlayer(String playerId) async {
    try {
      return await query((collection) => 
        collection
          .where(Filter.or(
            Filter('redPlayerId', isEqualTo: playerId),
            Filter('blackPlayerId', isEqualTo: playerId),
          ))
          .where('status', isEqualTo: MatchStatus.scheduled.index)
          .where('scheduledTime', isGreaterThan: Timestamp.now())
          .orderBy('scheduledTime')
      );
    } catch (e) {
      logger.severe('Error getting upcoming matches by player: $e');
      rethrow;
    }
  }

  // Listen to match
  Stream<MatchModel?> listenToMatch(String matchId) {
    return listen(matchId);
  }
}
