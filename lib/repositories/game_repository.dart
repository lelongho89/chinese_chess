import '../global.dart';
import '../models/game_data_model.dart';
import 'supabase_base_repository.dart';

/// Repository for handling game data in Supabase
class GameRepository extends SupabaseBaseRepository<GameDataModel> {
  // Singleton pattern
  static GameRepository? _instance;
  static GameRepository get instance => _instance ??= GameRepository._();

  GameRepository._() : super('games');

  @override
  GameDataModel fromSupabase(Map<String, dynamic> data, String id) {
    return GameDataModel.fromSupabase(data, id);
  }

  @override
  Map<String, dynamic> toSupabase(GameDataModel model) {
    return model.toMap();
  }

  // Create a new game
  Future<String> createGame(String redPlayerId, String blackPlayerId, {
    bool isRanked = true,
    int? tournamentId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final gameModel = GameDataModel(
        id: '', // Will be set by Supabase
        redPlayerId: redPlayerId,
        blackPlayerId: blackPlayerId,
        finalFen: '', // Initial empty FEN
        redTimeRemaining: 180, // 3 minutes in seconds
        blackTimeRemaining: 180, // 3 minutes in seconds
        startedAt: DateTime.now(),
        isRanked: isRanked,
        tournamentId: tournamentId,
        metadata: metadata,
      );

      final gameId = await add(gameModel);
      logger.info('Game created: $gameId');
      return gameId;
    } catch (e) {
      logger.severe('Error creating game: $e');
      rethrow;
    }
  }

  // End a game
  Future<void> endGame(String gameId, {
    String? winnerId,
    bool isDraw = false,
    required String finalFen,
    required int redTimeRemaining,
    required int blackTimeRemaining,
    required List<String> moves,
  }) async {
    try {
      final updates = {
        'winner_id': winnerId,
        'is_draw': isDraw,
        'final_fen': finalFen,
        'red_time_remaining': redTimeRemaining,
        'black_time_remaining': blackTimeRemaining,
        'move_count': moves.length,
        'moves': moves,
        'ended_at': DateTime.now().toIso8601String(),
      };

      await update(gameId, updates);
      logger.info('Game ended: $gameId');
    } catch (e) {
      logger.severe('Error ending game: $e');
      rethrow;
    }
  }

  // Add a move to a game
  Future<void> addMove(String gameId, String move) async {
    try {
      // Get current game data
      final game = await get(gameId);
      if (game == null) return;

      // Add the move to the list
      final List<String> moves = List<String>.from(game.moves);
      moves.add(move);

      // Update the game
      await update(gameId, {
        'moves': moves,
        'move_count': moves.length,
      });

      logger.info('Move added to game: $gameId');
    } catch (e) {
      logger.severe('Error adding move to game: $e');
      rethrow;
    }
  }

  // Update time remaining
  Future<void> updateTimeRemaining(String gameId, int redTimeRemaining, int blackTimeRemaining) async {
    try {
      await update(gameId, {
        'red_time_remaining': redTimeRemaining,
        'black_time_remaining': blackTimeRemaining,
      });
    } catch (e) {
      logger.severe('Error updating time remaining: $e');
      rethrow;
    }
  }

  // Get games by player
  Future<List<GameDataModel>> getGamesByPlayer(String playerId, {int limit = 10}) async {
    try {
      final response = await table
          .select()
          .or('red_player_id.eq.$playerId,black_player_id.eq.$playerId')
          .order('started_at', ascending: false)
          .limit(limit);

      return response.map((record) {
        final id = record['id'] as String;
        return fromSupabase(record, id);
      }).toList();
    } catch (e) {
      logger.severe('Error getting games by player: $e');
      rethrow;
    }
  }

  // Get games by tournament
  Future<List<GameDataModel>> getGamesByTournament(int tournamentId) async {
    try {
      final response = await table
          .select()
          .eq('tournament_id', tournamentId)
          .order('started_at', ascending: false);

      return response.map((record) {
        final id = record['id'] as String;
        return fromSupabase(record, id);
      }).toList();
    } catch (e) {
      logger.severe('Error getting games by tournament: $e');
      rethrow;
    }
  }

  // Get active games by player
  Future<List<GameDataModel>> getActiveGamesByPlayer(String playerId) async {
    try {
      final response = await table
          .select()
          .or('red_player_id.eq.$playerId,black_player_id.eq.$playerId')
          .is_('ended_at', 'null')
          .order('started_at', ascending: false);

      return response.map((record) {
        final id = record['id'] as String;
        return fromSupabase(record, id);
      }).toList();
    } catch (e) {
      logger.severe('Error getting active games by player: $e');
      rethrow;
    }
  }

  // Listen to active game
  Stream<GameDataModel?> listenToActiveGame(String gameId) {
    try {
      return table
          .select()
          .eq('id', gameId)
          .stream()
          .map((response) {
            if (response.isNotEmpty) {
              final record = response.first;
              final id = record['id'] as String;
              return fromSupabase(record, id);
            }
            return null;
          });
    } catch (e) {
      logger.severe('Error listening to active game: $e');
      rethrow;
    }
  }
}
