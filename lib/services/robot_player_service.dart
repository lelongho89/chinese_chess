import 'dart:math';

import '../driver/driver_robot_online.dart';
import '../driver/player_driver.dart';
import '../global.dart';
import '../models/game_data_model.dart';
import '../models/game_manager.dart';
import '../models/user_model.dart';

/// Service for managing robot players in online multiplayer games
class RobotPlayerService {
  // Singleton pattern
  static RobotPlayerService? _instance;
  static RobotPlayerService get instance => _instance ??= RobotPlayerService._();

  RobotPlayerService._();

  // Active robot drivers by game ID
  final Map<String, DriverRobotOnline> _activeRobots = {};

  /// Initialize a robot player for an online game
  Future<void> initializeRobotPlayer({
    required String gameId,
    required String robotPlayerId,
    required GameManager gameManager,
    required bool isRedPlayer,
    required int humanPlayerElo,
    Map<String, dynamic>? gameMetadata,
  }) async {
    try {
      logger.info('🤖 Initializing robot player for game: $gameId');

      // Calculate robot difficulty based on human player Elo
      final difficulty = _calculateDifficultyFromElo(humanPlayerElo);

      // Get the robot player from game manager
      final playerIndex = isRedPlayer ? 0 : 1;
      final robotPlayer = gameManager.hands[playerIndex];

      // Set the driver type to robot online
      robotPlayer.driverType = DriverType.robotOnline;

      // Get the robot driver and initialize it for online play
      final robotDriver = robotPlayer.driver as DriverRobotOnline;
      await robotDriver.initOnline(
        gameId: gameId,
        playerId: robotPlayerId,
        difficulty: difficulty,
      );

      // Store the active robot
      _activeRobots[gameId] = robotDriver;

      logger.info('🤖 Robot player initialized: gameId=$gameId, difficulty=$difficulty, isRed=$isRedPlayer');
    } catch (e) {
      logger.severe('🤖 Error initializing robot player: $e');
      rethrow;
    }
  }

  /// Calculate robot difficulty based on human player's Elo rating
  int _calculateDifficultyFromElo(int humanElo) {
    // Map Elo ratings to difficulty levels (1-10)
    // Lower Elo = easier robot, Higher Elo = harder robot

    if (humanElo < 800) return 2;      // Very easy
    if (humanElo < 1000) return 3;     // Easy
    if (humanElo < 1200) return 4;     // Easy-Medium
    if (humanElo < 1400) return 5;     // Medium
    if (humanElo < 1600) return 6;     // Medium-Hard
    if (humanElo < 1800) return 7;     // Hard
    if (humanElo < 2000) return 8;     // Very Hard
    if (humanElo < 2200) return 9;     // Expert
    return 10;                         // Master
  }

  /// Check if a game has an active robot player
  bool hasActiveRobot(String gameId) {
    return _activeRobots.containsKey(gameId);
  }

  /// Get the robot driver for a game
  DriverRobotOnline? getRobotDriver(String gameId) {
    return _activeRobots[gameId];
  }

  /// Update robot difficulty during a game
  void updateRobotDifficulty(String gameId, int newDifficulty) {
    final robot = _activeRobots[gameId];
    if (robot != null) {
      robot.setDifficulty(newDifficulty);
      logger.info('🤖 Updated robot difficulty for game $gameId: $newDifficulty');
    }
  }

  /// Clean up robot player when game ends
  Future<void> cleanupRobotPlayer(String gameId) async {
    try {
      final robot = _activeRobots.remove(gameId);
      if (robot != null) {
        await robot.dispose();
        logger.info('🤖 Robot player cleaned up for game: $gameId');
      }
    } catch (e) {
      logger.warning('🤖 Error cleaning up robot player: $e');
    }
  }

  /// Check if a user is an AI player
  bool isAIUser(UserModel user) {
    return user.email.endsWith('@aitest.com');
  }

  /// Check if a game involves an AI player
  bool isAIGame(GameDataModel game, List<UserModel> users) {
    try {
      final redPlayer = users.firstWhere((u) => u.uid == game.redPlayerId);
      final blackPlayer = users.firstWhere((u) => u.uid == game.blackPlayerId);

      return isAIUser(redPlayer) || isAIUser(blackPlayer);
    } catch (e) {
      // If players not found in the list, assume it's not an AI game
      return false;
    }
  }

  /// Get AI player from a game
  UserModel? getAIPlayer(GameDataModel game, List<UserModel> users) {
    try {
      final redPlayer = users.firstWhere((u) => u.uid == game.redPlayerId);
      final blackPlayer = users.firstWhere((u) => u.uid == game.blackPlayerId);

      if (isAIUser(redPlayer)) return redPlayer;
      if (isAIUser(blackPlayer)) return blackPlayer;
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get human player from a game
  UserModel? getHumanPlayer(GameDataModel game, List<UserModel> users) {
    try {
      final redPlayer = users.firstWhere((u) => u.uid == game.redPlayerId);
      final blackPlayer = users.firstWhere((u) => u.uid == game.blackPlayerId);

      if (!isAIUser(redPlayer)) return redPlayer;
      if (!isAIUser(blackPlayer)) return blackPlayer;
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Generate a realistic robot player name
  String generateRobotName() {
    final prefixes = [
      'Dragon', 'Phoenix', 'Tiger', 'Eagle', 'Lion', 'Wolf', 'Bear', 'Hawk',
      'Storm', 'Thunder', 'Lightning', 'Fire', 'Ice', 'Wind', 'Earth', 'Water',
      'Golden', 'Silver', 'Iron', 'Steel', 'Diamond', 'Ruby', 'Emerald', 'Jade',
      'Master', 'Grand', 'Supreme', 'Elite', 'Royal', 'Noble', 'Wise', 'Swift'
    ];

    final suffixes = [
      'Player', 'Master', 'Warrior', 'Champion', 'Knight', 'Guardian', 'Sage',
      'Strategist', 'Tactician', 'General', 'Commander', 'Leader', 'Expert',
      'Genius', 'Prodigy', 'Legend', 'Hero', 'Defender', 'Conqueror', 'Victor'
    ];

    final random = Random();
    final prefix = prefixes[random.nextInt(prefixes.length)];
    final suffix = suffixes[random.nextInt(suffixes.length)];

    return '$prefix $suffix';
  }

  /// Get difficulty description
  String getDifficultyDescription(int difficulty) {
    switch (difficulty) {
      case 1: return 'Beginner';
      case 2: return 'Very Easy';
      case 3: return 'Easy';
      case 4: return 'Easy-Medium';
      case 5: return 'Medium';
      case 6: return 'Medium-Hard';
      case 7: return 'Hard';
      case 8: return 'Very Hard';
      case 9: return 'Expert';
      case 10: return 'Master';
      default: return 'Medium';
    }
  }

  /// Get all active robot games
  List<String> getActiveRobotGames() {
    return _activeRobots.keys.toList();
  }

  /// Get robot statistics
  Map<String, dynamic> getRobotStats() {
    return {
      'active_robots': _activeRobots.length,
      'active_games': _activeRobots.keys.toList(),
      'difficulties': _activeRobots.values.map((r) => r.difficulty).toList(),
    };
  }

  /// Dispose all active robots (cleanup on app shutdown)
  Future<void> disposeAll() async {
    final futures = _activeRobots.values.map((robot) => robot.dispose());
    await Future.wait(futures);
    _activeRobots.clear();
    logger.info('🤖 All robot players disposed');
  }
}
