import '../global.dart';
import '../models/match_model.dart';
import 'supabase_base_repository.dart';

/// Repository for handling match data in Supabase
class MatchRepository extends SupabaseBaseRepository<MatchModel> {
  // Singleton pattern
  static MatchRepository? _instance;
  static MatchRepository get instance => _instance ??= MatchRepository._();

  MatchRepository._() : super('matches');

  @override
  MatchModel fromSupabase(Map<String, dynamic> data, String id) {
    return MatchModel.fromSupabase(data, id);
  }

  @override
  Map<String, dynamic> toSupabase(MatchModel model) {
    return model.toMap();
  }

  // Create a new match
  Future<String> createMatch({
    String? tournamentId,
    required String redPlayerId,
    required String blackPlayerId,
    required DateTime scheduledTime,
    required int round,
    required int matchNumber,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final matchModel = MatchModel(
        id: '', // Will be set by Supabase
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
        'start_time': DateTime.now().toIso8601String(),
        'game_id': gameId,
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
        'end_time': DateTime.now().toIso8601String(),
        'winner_id': winnerId,
        'is_draw': isDraw,
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
      final response = await table
          .select()
          .eq('tournament_id', tournamentId)
          .order('round')
          .order('match_number');

      return response.map((record) {
        final id = record['id'] as String;
        return fromSupabase(record, id);
      }).toList();
    } catch (e) {
      logger.severe('Error getting matches by tournament: $e');
      rethrow;
    }
  }

  // Get matches by player
  Future<List<MatchModel>> getMatchesByPlayer(String playerId, {int limit = 10}) async {
    try {
      final response = await table
          .select()
          .or('red_player_id.eq.$playerId,black_player_id.eq.$playerId')
          .order('scheduled_time', ascending: false)
          .limit(limit);

      return response.map((record) {
        final id = record['id'] as String;
        return fromSupabase(record, id);
      }).toList();
    } catch (e) {
      logger.severe('Error getting matches by player: $e');
      rethrow;
    }
  }

  // Get upcoming matches by player
  Future<List<MatchModel>> getUpcomingMatchesByPlayer(String playerId) async {
    try {
      final now = DateTime.now().toIso8601String();

      final response = await table
          .select()
          .or('red_player_id.eq.$playerId,black_player_id.eq.$playerId')
          .eq('status', MatchStatus.scheduled.index)
          .gt('scheduled_time', now)
          .order('scheduled_time');

      return response.map((record) {
        final id = record['id'] as String;
        return fromSupabase(record, id);
      }).toList();
    } catch (e) {
      logger.severe('Error getting upcoming matches by player: $e');
      rethrow;
    }
  }

  // Get match details (renamed from listenToMatch)
  Future<MatchModel?> getMatchDetails(String matchId) async {
    try {
      final response = await table
          .select()
          .eq('id', matchId)
          .maybeSingle();

      if (response != null) {
        final id = response['id'] as String;
        return fromSupabase(response, id);
      }
      return null;
    } catch (e) {
      logger.severe('Error getting match details: $e');
      rethrow;
    }
  }
}
