import 'dart:math';

import '../global.dart';
import '../repositories/leaderboard_repository.dart';
import '../repositories/user_repository.dart';

/// Service for handling Elo rating calculations
class EloService {
  // Singleton pattern
  static EloService? _instance;
  static EloService get instance => _instance ??= EloService._();

  // K-factor determines how much ratings change after each game
  // Higher K-factor means more volatile ratings
  static const int kFactor = 32;

  EloService._();

  // Calculate new Elo ratings after a game
  Future<Map<String, int>> calculateNewRatings({
    required String redPlayerId,
    required String blackPlayerId,
    required String? winnerId,
    required bool isDraw,
  }) async {
    try {
      // Get current ratings
      final redPlayer = await UserRepository.instance.get(redPlayerId);
      final blackPlayer = await UserRepository.instance.get(blackPlayerId);
      
      if (redPlayer == null || blackPlayer == null) {
        throw Exception('Player not found');
      }
      
      final redRating = redPlayer.eloRating;
      final blackRating = blackPlayer.eloRating;
      
      // Calculate expected scores
      final expectedRedScore = _getExpectedScore(redRating, blackRating);
      final expectedBlackScore = _getExpectedScore(blackRating, redRating);
      
      // Calculate actual scores
      double actualRedScore;
      double actualBlackScore;
      
      if (isDraw) {
        actualRedScore = 0.5;
        actualBlackScore = 0.5;
      } else if (winnerId == redPlayerId) {
        actualRedScore = 1.0;
        actualBlackScore = 0.0;
      } else {
        actualRedScore = 0.0;
        actualBlackScore = 1.0;
      }
      
      // Calculate new ratings
      final newRedRating = _calculateNewRating(redRating, expectedRedScore, actualRedScore);
      final newBlackRating = _calculateNewRating(blackRating, expectedBlackScore, actualBlackScore);
      
      // Update user ratings
      await UserRepository.instance.updateEloRating(redPlayerId, newRedRating);
      await UserRepository.instance.updateEloRating(blackPlayerId, newBlackRating);
      
      // Update leaderboard entries
      await LeaderboardRepository.instance.updateLeaderboardEntry(
        userId: redPlayerId,
        displayName: redPlayer.displayName,
        eloRating: newRedRating,
        rank: 0, // Will be recalculated later
        gamesPlayed: redPlayer.gamesPlayed + 1,
        gamesWon: redPlayer.gamesWon + (winnerId == redPlayerId ? 1 : 0),
        gamesLost: redPlayer.gamesLost + (winnerId == blackPlayerId ? 1 : 0),
        gamesDraw: redPlayer.gamesDraw + (isDraw ? 1 : 0),
      );
      
      await LeaderboardRepository.instance.updateLeaderboardEntry(
        userId: blackPlayerId,
        displayName: blackPlayer.displayName,
        eloRating: newBlackRating,
        rank: 0, // Will be recalculated later
        gamesPlayed: blackPlayer.gamesPlayed + 1,
        gamesWon: blackPlayer.gamesWon + (winnerId == blackPlayerId ? 1 : 0),
        gamesLost: blackPlayer.gamesLost + (winnerId == redPlayerId ? 1 : 0),
        gamesDraw: blackPlayer.gamesDraw + (isDraw ? 1 : 0),
      );
      
      // Recalculate ranks
      await LeaderboardRepository.instance.recalculateRanks();
      
      return {
        redPlayerId: newRedRating,
        blackPlayerId: newBlackRating,
      };
    } catch (e) {
      logger.severe('Error calculating new ratings: $e');
      rethrow;
    }
  }

  // Calculate expected score based on ratings
  double _getExpectedScore(int playerRating, int opponentRating) {
    return 1.0 / (1.0 + pow(10, (opponentRating - playerRating) / 400));
  }

  // Calculate new rating
  int _calculateNewRating(int oldRating, double expectedScore, double actualScore) {
    return (oldRating + kFactor * (actualScore - expectedScore)).round();
  }
}
