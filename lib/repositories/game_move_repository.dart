import '../global.dart';
import '../models/game_move_model.dart';
import 'supabase_base_repository.dart';

/// Repository for handling game moves in real-time
class GameMoveRepository extends SupabaseBaseRepository<GameMoveModel> {
  // Singleton pattern
  static GameMoveRepository? _instance;
  static GameMoveRepository get instance => _instance ??= GameMoveRepository._();

  GameMoveRepository._() : super('game_moves');

  @override
  GameMoveModel fromSupabase(Map<String, dynamic> data, String id) {
    return GameMoveModel.fromSupabase(data, id);
  }

  @override
  Map<String, dynamic> toSupabase(GameMoveModel model) {
    return model.toMap();
  }

  /// Add a new move to the game
  Future<String> addMove({
    required String gameId,
    required String playerId,
    required int moveNumber,
    required String moveNotation,
    required String fenAfterMove,
    required int timeRemaining,
    required int moveTime,
    bool isCheck = false,
    bool isCheckmate = false,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final moveModel = GameMoveModel(
        id: '', // Will be set by Supabase
        gameId: gameId,
        playerId: playerId,
        moveNumber: moveNumber,
        moveNotation: moveNotation,
        fenAfterMove: fenAfterMove,
        timeRemaining: timeRemaining,
        moveTime: moveTime,
        isCheck: isCheck,
        isCheckmate: isCheckmate,
        createdAt: DateTime.now(),
        metadata: metadata,
      );

      final moveId = await add(moveModel);
      logger.info('Move added: $moveId for game $gameId');
      return moveId;
    } catch (e) {
      logger.severe('Error adding move: $e');
      rethrow;
    }
  }

  /// Get all moves for a game
  Future<List<GameMoveModel>> getGameMoves(String gameId) async {
    try {
      final response = await table
          .select()
          .eq('game_id', gameId)
          .order('move_number');

      return response.map((record) {
        final id = record['id'] as String;
        return fromSupabase(record, id);
      }).toList();
    } catch (e) {
      logger.severe('Error getting game moves: $e');
      rethrow;
    }
  }

  /// Get moves for a game starting from a specific move number
  Future<List<GameMoveModel>> getMovesFromNumber(String gameId, int fromMoveNumber) async {
    try {
      final response = await table
          .select()
          .eq('game_id', gameId)
          .gte('move_number', fromMoveNumber)
          .order('move_number');

      return response.map((record) {
        final id = record['id'] as String;
        return fromSupabase(record, id);
      }).toList();
    } catch (e) {
      logger.severe('Error getting moves from number: $e');
      rethrow;
    }
  }

  /// Get the latest move for a game
  Future<GameMoveModel?> getLatestMove(String gameId) async {
    try {
      final response = await table
          .select()
          .eq('game_id', gameId)
          .order('move_number', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        final id = response.first['id'] as String;
        return fromSupabase(response.first, id);
      }
      return null;
    } catch (e) {
      logger.severe('Error getting latest move: $e');
      rethrow;
    }
  }

  /// Get moves by a specific player
  Future<List<GameMoveModel>> getPlayerMoves(String gameId, String playerId) async {
    try {
      final response = await table
          .select()
          .eq('game_id', gameId)
          .eq('player_id', playerId)
          .order('move_number');

      return response.map((record) {
        final id = record['id'] as String;
        return fromSupabase(record, id);
      }).toList();
    } catch (e) {
      logger.severe('Error getting player moves: $e');
      rethrow;
    }
  }

  /// Get move count for a game
  Future<int> getMoveCount(String gameId) async {
    try {
      final response = await table
          .select('id')
          .eq('game_id', gameId);

      return response.length;
    } catch (e) {
      logger.severe('Error getting move count: $e');
      rethrow;
    }
  }

  /// Check if a move exists
  Future<bool> moveExists(String gameId, int moveNumber) async {
    try {
      final response = await table
          .select('id')
          .eq('game_id', gameId)
          .eq('move_number', moveNumber)
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      logger.severe('Error checking if move exists: $e');
      rethrow;
    }
  }

  /// Get game statistics
  Future<Map<String, dynamic>> getGameStatistics(String gameId) async {
    try {
      final moves = await getGameMoves(gameId);

      if (moves.isEmpty) {
        return {
          'total_moves': 0,
          'red_moves': 0,
          'black_moves': 0,
          'average_move_time': 0,
          'total_game_time': 0,
          'checks': 0,
          'captures': 0,
        };
      }

      final redMoves = moves.where((m) => m.isRedMove).toList();
      final blackMoves = moves.where((m) => m.isBlackMove).toList();
      final checks = moves.where((m) => m.isCheck).length;

      // Calculate average move time
      final totalMoveTime = moves.fold<int>(0, (sum, move) => sum + move.moveTime);
      final averageMoveTime = totalMoveTime / moves.length;

      // Calculate total game time
      final gameStartTime = moves.first.createdAt;
      final gameEndTime = moves.last.createdAt;
      final totalGameTime = gameEndTime.difference(gameStartTime).inSeconds;

      return {
        'total_moves': moves.length,
        'red_moves': redMoves.length,
        'black_moves': blackMoves.length,
        'average_move_time': averageMoveTime.round(),
        'total_game_time': totalGameTime,
        'checks': checks,
        'captures': 0, // Would need to analyze move notation for captures
      };
    } catch (e) {
      logger.severe('Error getting game statistics: $e');
      rethrow;
    }
  }

  /// Delete all moves for a game (admin function)
  Future<void> deleteGameMoves(String gameId) async {
    try {
      await table
          .delete()
          .eq('game_id', gameId);

      logger.info('Deleted all moves for game: $gameId');
    } catch (e) {
      logger.severe('Error deleting game moves: $e');
      rethrow;
    }
  }

  /// Get recent moves across all games (for debugging/monitoring)
  Future<List<GameMoveModel>> getRecentMoves({int limit = 50}) async {
    try {
      final response = await table
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map((record) {
        final id = record['id'] as String;
        return fromSupabase(record, id);
      }).toList();
    } catch (e) {
      logger.severe('Error getting recent moves: $e');
      rethrow;
    }
  }

  /// Validate move sequence for a game
  Future<bool> validateMoveSequence(String gameId) async {
    try {
      final moves = await getGameMoves(gameId);

      // Check if move numbers are sequential
      for (int i = 0; i < moves.length; i++) {
        if (moves[i].moveNumber != i + 1) {
          logger.warning('Invalid move sequence in game $gameId: expected ${i + 1}, got ${moves[i].moveNumber}');
          return false;
        }
      }

      return true;
    } catch (e) {
      logger.severe('Error validating move sequence: $e');
      return false;
    }
  }
}
