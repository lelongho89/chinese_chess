import 'package:cloud_firestore/cloud_firestore.dart';

import '../global.dart';
import '../models/game_data_model.dart';
import '../repositories/game_repository.dart';
import '../repositories/user_repository.dart';
import 'elo_service.dart';

/// Service for handling game operations
class GameService {
  // Singleton pattern
  static GameService? _instance;
  static GameService get instance => _instance ??= GameService._();

  GameService._();

  // Start a new game
  Future<String> startGame({
    required String redPlayerId,
    required String blackPlayerId,
    bool isRanked = true,
    int? tournamentId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Create a new game
      final gameId = await GameRepository.instance.createGame(
        redPlayerId,
        blackPlayerId,
        isRanked: isRanked,
        tournamentId: tournamentId,
        metadata: metadata,
      );
      
      logger.info('Game started: $gameId');
      return gameId;
    } catch (e) {
      logger.severe('Error starting game: $e');
      rethrow;
    }
  }

  // End a game
  Future<void> endGame({
    required String gameId,
    String? winnerId,
    bool isDraw = false,
    required String finalFen,
    required int redTimeRemaining,
    required int blackTimeRemaining,
    required List<String> moves,
  }) async {
    try {
      // Get the game
      final game = await GameRepository.instance.get(gameId);
      
      if (game == null) {
        throw Exception('Game not found');
      }
      
      // End the game
      await GameRepository.instance.endGame(
        gameId,
        winnerId: winnerId,
        isDraw: isDraw,
        finalFen: finalFen,
        redTimeRemaining: redTimeRemaining,
        blackTimeRemaining: blackTimeRemaining,
        moves: moves,
      );
      
      // Update player statistics
      await _updatePlayerStats(game, winnerId, isDraw);
      
      // Update Elo ratings if the game is ranked
      if (game.isRanked) {
        await EloService.instance.calculateNewRatings(
          redPlayerId: game.redPlayerId,
          blackPlayerId: game.blackPlayerId,
          winnerId: winnerId,
          isDraw: isDraw,
        );
      }
      
      logger.info('Game ended: $gameId');
    } catch (e) {
      logger.severe('Error ending game: $e');
      rethrow;
    }
  }

  // Update player statistics
  Future<void> _updatePlayerStats(GameDataModel game, String? winnerId, bool isDraw) async {
    try {
      // Update red player stats
      await UserRepository.instance.updateGameStats(
        game.redPlayerId,
        winnerId == game.redPlayerId,
        isDraw,
      );
      
      // Update black player stats
      await UserRepository.instance.updateGameStats(
        game.blackPlayerId,
        winnerId == game.blackPlayerId,
        isDraw,
      );
    } catch (e) {
      logger.severe('Error updating player stats: $e');
      rethrow;
    }
  }

  // Add a move to a game
  Future<void> addMove(String gameId, String move) async {
    try {
      await GameRepository.instance.addMove(gameId, move);
    } catch (e) {
      logger.severe('Error adding move to game: $e');
      rethrow;
    }
  }

  // Update time remaining
  Future<void> updateTimeRemaining(String gameId, int redTimeRemaining, int blackTimeRemaining) async {
    try {
      await GameRepository.instance.updateTimeRemaining(gameId, redTimeRemaining, blackTimeRemaining);
    } catch (e) {
      logger.severe('Error updating time remaining: $e');
      rethrow;
    }
  }

  // Get player's game history
  Future<List<GameDataModel>> getPlayerGameHistory(String playerId, {int limit = 10}) async {
    try {
      return await GameRepository.instance.getGamesByPlayer(playerId, limit: limit);
    } catch (e) {
      logger.severe('Error getting player game history: $e');
      rethrow;
    }
  }

  // Get player's active games
  Future<List<GameDataModel>> getPlayerActiveGames(String playerId) async {
    try {
      return await GameRepository.instance.getActiveGamesByPlayer(playerId);
    } catch (e) {
      logger.severe('Error getting player active games: $e');
      rethrow;
    }
  }

  // Listen to a game
  Stream<GameDataModel?> listenToGame(String gameId) {
    return GameRepository.instance.listenToActiveGame(gameId);
  }
}
