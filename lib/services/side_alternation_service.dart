import '../global.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

/// Service for managing side alternation in online matches
/// Ensures players alternate between Red and Black sides for fairness
class SideAlternationService {
  // Singleton pattern
  static SideAlternationService? _instance;
  static SideAlternationService get instance => _instance ??= SideAlternationService._();

  SideAlternationService._();

  /// Determine optimal side assignment for two players based on alternation history
  /// Returns a map with 'red' and 'black' player IDs
  /// In simplified mode, preferences are optional and may be null
  Future<Map<String, String>> determineSideAssignment({
    required String player1Id,
    required String player2Id,
    String? player1PreferredSide,
    String? player2PreferredSide,
  }) async {
    try {
      // Get player data
      final player1 = await UserRepository.instance.get(player1Id);
      final player2 = await UserRepository.instance.get(player2Id);

      if (player1 == null || player2 == null) {
        logger.warning('Could not fetch player data for side assignment');
        return _defaultAssignment(player1Id, player2Id);
      }

      // If both players have preferences and they're different, honor them
      if (player1PreferredSide != null && player2PreferredSide != null) {
        if (player1PreferredSide != player2PreferredSide) {
          return {
            'red': player1PreferredSide == 'red' ? player1Id : player2Id,
            'black': player1PreferredSide == 'black' ? player1Id : player2Id,
          };
        }
      }

      // If only one has a preference, try to honor it while considering alternation
      if (player1PreferredSide != null && player2PreferredSide == null) {
        final shouldHonorPreference = _shouldHonorPreference(player1, player1PreferredSide);
        if (shouldHonorPreference) {
          return {
            'red': player1PreferredSide == 'red' ? player1Id : player2Id,
            'black': player1PreferredSide == 'black' ? player1Id : player2Id,
          };
        }
      }

      if (player2PreferredSide != null && player1PreferredSide == null) {
        final shouldHonorPreference = _shouldHonorPreference(player2, player2PreferredSide);
        if (shouldHonorPreference) {
          return {
            'red': player2PreferredSide == 'red' ? player2Id : player1Id,
            'black': player2PreferredSide == 'black' ? player2Id : player1Id,
          };
        }
      }

      // Apply alternation logic
      return _applyAlternationLogic(player1, player2);
    } catch (e) {
      logger.severe('Error determining side assignment: $e');
      return _defaultAssignment(player1Id, player2Id);
    }
  }

  /// Determine side assignment for human vs AI match
  /// In simplified mode, human preference is optional and may be null
  Future<Map<String, String>> determineSideAssignmentWithAI({
    required String humanPlayerId,
    required String aiPlayerId,
    String? humanPreferredSide,
  }) async {
    try {
      final humanPlayer = await UserRepository.instance.get(humanPlayerId);

      if (humanPlayer == null) {
        logger.warning('Could not fetch human player data for AI side assignment');
        return _defaultAssignment(humanPlayerId, aiPlayerId);
      }

      // If human has a preference, check if we should honor it
      if (humanPreferredSide != null) {
        final shouldHonorPreference = _shouldHonorPreference(humanPlayer, humanPreferredSide);
        if (shouldHonorPreference) {
          return {
            'red': humanPreferredSide == 'red' ? humanPlayerId : aiPlayerId,
            'black': humanPreferredSide == 'black' ? humanPlayerId : aiPlayerId,
          };
        }
      }

      // Apply alternation for human player
      final preferredSide = _getPreferredSideForAlternation(humanPlayer);

      return {
        'red': preferredSide == 'red' ? humanPlayerId : aiPlayerId,
        'black': preferredSide == 'black' ? humanPlayerId : aiPlayerId,
      };
    } catch (e) {
      logger.severe('Error determining AI side assignment: $e');
      return _defaultAssignment(humanPlayerId, aiPlayerId);
    }
  }

  /// Apply alternation logic between two human players
  Map<String, String> _applyAlternationLogic(UserModel player1, UserModel player2) {
    // Priority 1: Player who should alternate (played same side recently)
    final player1ShouldAlternate = _shouldAlternate(player1);
    final player2ShouldAlternate = _shouldAlternate(player2);

    if (player1ShouldAlternate && !player2ShouldAlternate) {
      final preferredSide = _getPreferredSideForAlternation(player1);
      return {
        'red': preferredSide == 'red' ? player1.uid : player2.uid,
        'black': preferredSide == 'black' ? player1.uid : player2.uid,
      };
    }

    if (player2ShouldAlternate && !player1ShouldAlternate) {
      final preferredSide = _getPreferredSideForAlternation(player2);
      return {
        'red': preferredSide == 'red' ? player2.uid : player1.uid,
        'black': preferredSide == 'black' ? player2.uid : player1.uid,
      };
    }

    // Priority 2: Balance side distribution
    final player1RedRatio = _getRedRatio(player1);
    final player2RedRatio = _getRedRatio(player2);

    // Give Red to player with lower Red ratio
    if (player1RedRatio < player2RedRatio) {
      return {'red': player1.uid, 'black': player2.uid};
    } else if (player2RedRatio < player1RedRatio) {
      return {'red': player2.uid, 'black': player1.uid};
    }

    // Priority 3: Alternate based on last played side
    if (player1.lastPlayedSide == 'red') {
      return {'red': player2.uid, 'black': player1.uid};
    } else if (player1.lastPlayedSide == 'black') {
      return {'red': player1.uid, 'black': player2.uid};
    }

    // Default: Higher Elo gets Red (traditional advantage)
    if (player1.eloRating >= player2.eloRating) {
      return {'red': player1.uid, 'black': player2.uid};
    } else {
      return {'red': player2.uid, 'black': player1.uid};
    }
  }

  /// Check if a player should alternate sides
  bool _shouldAlternate(UserModel player) {
    // If player has played at least 2 games and has a strong side bias
    if (player.gamesPlayed >= 2) {
      final redRatio = _getRedRatio(player);
      // Should alternate if played same side 70% or more of the time
      return redRatio >= 0.7 || redRatio <= 0.3;
    }
    return false;
  }

  /// Get the preferred side for alternation (opposite of what they played more)
  String _getPreferredSideForAlternation(UserModel player) {
    if (player.lastPlayedSide == 'red') {
      return 'black';
    } else if (player.lastPlayedSide == 'black') {
      return 'red';
    }

    // If no last played side, check overall balance
    final redRatio = _getRedRatio(player);
    return redRatio > 0.5 ? 'black' : 'red';
  }

  /// Check if we should honor a player's preference
  bool _shouldHonorPreference(UserModel player, String preferredSide) {
    // Always honor preference for new players (< 3 games)
    if (player.gamesPlayed < 3) {
      return true;
    }

    // Check if honoring preference would create imbalance
    final redRatio = _getRedRatio(player);

    // Don't honor preference if it would increase an existing bias
    if (preferredSide == 'red' && redRatio >= 0.6) {
      return false;
    }
    if (preferredSide == 'black' && redRatio <= 0.4) {
      return false;
    }

    return true;
  }

  /// Calculate the ratio of Red games played
  double _getRedRatio(UserModel player) {
    final totalSideGames = player.redGamesPlayed + player.blackGamesPlayed;
    if (totalSideGames == 0) return 0.5; // Equal if no games played
    return player.redGamesPlayed / totalSideGames;
  }

  /// Default assignment when data is unavailable
  Map<String, String> _defaultAssignment(String player1Id, String player2Id) {
    return {'red': player1Id, 'black': player2Id};
  }

  /// Update player's side history after a game
  Future<void> updatePlayerSideHistory({
    required String playerId,
    required String side, // 'red' or 'black'
  }) async {
    try {
      final player = await UserRepository.instance.get(playerId);
      if (player == null) return;

      final updates = <String, dynamic>{
        'last_played_side': side,
      };

      if (side == 'red') {
        updates['red_games_played'] = player.redGamesPlayed + 1;
      } else if (side == 'black') {
        updates['black_games_played'] = player.blackGamesPlayed + 1;
      }

      await UserRepository.instance.update(playerId, updates);
      logger.info('Updated side history for player $playerId: $side');
    } catch (e) {
      logger.severe('Error updating player side history: $e');
    }
  }

  /// Get side statistics for a player
  Map<String, dynamic> getPlayerSideStats(UserModel player) {
    final totalSideGames = player.redGamesPlayed + player.blackGamesPlayed;
    final redRatio = _getRedRatio(player);

    return {
      'total_games': player.gamesPlayed,
      'total_side_tracked_games': totalSideGames,
      'red_games': player.redGamesPlayed,
      'black_games': player.blackGamesPlayed,
      'red_ratio': redRatio,
      'black_ratio': 1.0 - redRatio,
      'last_played_side': player.lastPlayedSide,
      'should_alternate': _shouldAlternate(player),
      'preferred_next_side': _getPreferredSideForAlternation(player),
    };
  }

  /// Reset side history for a player (admin function)
  Future<void> resetPlayerSideHistory(String playerId) async {
    try {
      await UserRepository.instance.update(playerId, {
        'last_played_side': null,
        'red_games_played': 0,
        'black_games_played': 0,
      });
      logger.info('Reset side history for player: $playerId');
    } catch (e) {
      logger.severe('Error resetting player side history: $e');
    }
  }
}
