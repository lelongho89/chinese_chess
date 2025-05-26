import 'dart:async';
import 'dart:math';

import '../global.dart';
import '../models/game_event.dart';
import '../services/online_multiplayer_service.dart';
import 'driver_robot.dart';
import 'player_driver.dart';

/// Enhanced robot driver for online multiplayer games
/// Combines AI logic from DriverRobot with online synchronization
class DriverRobotOnline extends DriverRobot {
  String? _gameId;
  String? _playerId;
  int _difficulty = 5; // Default difficulty (1-10 scale)
  bool _isOnlineGame = false;

  DriverRobotOnline(super.player);

  /// Initialize the robot driver for online play
  Future<void> initOnline({
    required String gameId,
    required String playerId,
    int difficulty = 5,
  }) async {
    _gameId = gameId;
    _playerId = playerId;
    _difficulty = difficulty;
    _isOnlineGame = true;

    logger.info('🤖 Robot driver initialized for online game: $gameId, difficulty: $difficulty');
  }

  @override
  Future<PlayerAction?> move() async {
    if (!_isOnlineGame || _gameId == null || _playerId == null) {
      // Fall back to regular robot behavior for offline games
      return super.move();
    }

    requestMove = Completer<PlayerAction>();
    player.manager.add(GameLockEvent(true));

    logger.info('🤖 Robot calculating move for online game...');

    // Add some thinking time based on difficulty (lower difficulty = more thinking time)
    final thinkingTime = _calculateThinkingTime();

    Future.delayed(Duration(milliseconds: thinkingTime)).then((_) async {
      try {
        final move = await _calculateBestMove();
        if (move != null) {
          await _submitOnlineMove(move);
          completeMove(move);
        } else {
          // No valid moves, surrender
          completeMove(PlayerAction(type: PlayerActionType.rstGiveUp));
        }
      } catch (e) {
        logger.severe('🤖 Error calculating robot move: $e');
        // Fall back to random move or surrender
        completeMove(PlayerAction(type: PlayerActionType.rstGiveUp));
      }
    });

    return requestMove?.future;
  }

  /// Calculate thinking time based on difficulty and game state
  int _calculateThinkingTime() {
    // Base thinking time: 500ms to 3000ms
    final baseTime = 500 + (10 - _difficulty) * 250;

    // Add some randomness to make it feel more human-like
    final random = Random();
    final variance = (baseTime * 0.3).round();
    final actualTime = baseTime + random.nextInt(variance * 2) - variance;

    return actualTime.clamp(300, 5000); // Min 300ms, max 5s
  }

  /// Calculate the best move using AI logic with difficulty adjustment
  Future<PlayerAction?> _calculateBestMove() async {
    try {
      // Use engine if available and difficulty is high enough
      if (player.manager.engineOK && _difficulty >= 7) {
        return await _getMoveFromEngine();
      } else {
        return await _getMoveFromLogic();
      }
    } catch (e) {
      logger.severe('🤖 Error in move calculation: $e');
      return null;
    }
  }

  /// Get move from chess engine (for higher difficulties)
  Future<PlayerAction?> _getMoveFromEngine() async {
    if (!engine.inited) {
      return await _getMoveFromLogic();
    }

    try {
      // Adjust engine depth based on difficulty
      final depth = _difficulty.clamp(3, 12);

      engine.position(player.manager.fenStr);
      final move = await engine.go(depth: depth);

      if (move.isNotEmpty) {
        logger.info('🤖 Engine move: $move (depth: $depth)');
        return PlayerAction(move: move);
      }
    } catch (e) {
      logger.warning('🤖 Engine failed, falling back to logic: $e');
    }

    return await _getMoveFromLogic();
  }

  /// Get move from custom logic (for lower difficulties)
  Future<PlayerAction?> _getMoveFromLogic() async {
    final team = player.team == 'r' ? 0 : 1;
    final moves = await getAbleMoves(player.manager.fen, team);

    if (moves.isEmpty) {
      return PlayerAction(type: PlayerActionType.rstGiveUp);
    }

    // Apply difficulty-based move selection
    final moveGroups = await checkMoves(player.manager.fen, team, moves);
    final selectedMove = await _pickMoveByDifficulty(moveGroups);

    logger.info('🤖 Logic move: $selectedMove (difficulty: $_difficulty)');
    return PlayerAction(move: selectedMove);
  }

  /// Pick move based on difficulty level
  Future<String> _pickMoveByDifficulty(Map<String, int> moveGroups) async {
    if (moveGroups.isEmpty) {
      return '';
    }

    final random = Random();

    // For very low difficulty, sometimes pick random moves
    if (_difficulty <= 2 && random.nextDouble() < 0.3) {
      final moves = moveGroups.keys.toList();
      return moves[random.nextInt(moves.length)];
    }

    // For low difficulty, reduce the weight of good moves
    if (_difficulty <= 4) {
      final adjustedGroups = <String, int>{};
      for (final entry in moveGroups.entries) {
        // Reduce weights of good moves to make mistakes more likely
        final adjustedWeight = (entry.value * 0.7).round();
        adjustedGroups[entry.key] = adjustedWeight.clamp(1, entry.value);
      }
      return await pickMove(adjustedGroups);
    }

    // For medium to high difficulty, use normal logic
    return await pickMove(moveGroups);
  }

  /// Submit the move to the online multiplayer service
  Future<void> _submitOnlineMove(PlayerAction action) async {
    if (_gameId == null || _playerId == null || action.move == null) {
      return;
    }

    try {
      // Calculate game state after move
      final currentFen = player.manager.fenStr;
      final timeRemaining = _getTimeRemaining();
      final moveTime = _calculateThinkingTime();

      // Check for check/checkmate
      final isCheck = player.manager.isCheckMate;

      await OnlineMultiplayerService.instance.makeMove(
        gameId: _gameId!,
        playerId: _playerId!,
        moveNotation: action.move!,
        fenAfterMove: currentFen,
        timeRemaining: timeRemaining,
        moveTime: moveTime,
        isCheck: isCheck,
        isCheckmate: false, // TODO: Implement proper checkmate detection
        metadata: {
          'robot_move': true,
          'difficulty': _difficulty,
          'thinking_time': moveTime,
        },
      );

      logger.info('🤖 Robot move submitted to server: ${action.move}');
    } catch (e) {
      logger.severe('🤖 Error submitting robot move: $e');
      rethrow;
    }
  }

  /// Get remaining time for the robot player
  int _getTimeRemaining() {
    // For now, return a default time
    // TODO: Integrate with actual timer system
    return 180; // 3 minutes default
  }

  @override
  Future<void> completeMove(PlayerAction move) async {
    await player.onMove(move);
    requestMove?.complete(move);

    // Unlock the game UI
    player.manager.add(GameLockEvent(false));
  }

  /// Set the difficulty level (1-10 scale)
  void setDifficulty(int difficulty) {
    _difficulty = difficulty.clamp(1, 10);
    logger.info('🤖 Robot difficulty set to: $_difficulty');
  }

  /// Get current difficulty level
  int get difficulty => _difficulty;

  /// Check if this is an online robot
  bool get isOnlineRobot => _isOnlineGame;

  @override
  String toString() => "DriverRobotOnline ${player.team} (difficulty: $_difficulty)";
}
