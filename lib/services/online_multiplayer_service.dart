import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../global.dart';
import '../models/game_data_model.dart';
import '../models/game_move_model.dart';
import '../repositories/game_repository.dart';
import '../repositories/game_move_repository.dart';
import '../supabase_client.dart' as supabase;

/// Service for handling online multiplayer game synchronization
class OnlineMultiplayerService {
  // Singleton pattern
  static OnlineMultiplayerService? _instance;
  static OnlineMultiplayerService get instance => _instance ??= OnlineMultiplayerService._();

  OnlineMultiplayerService._();

  // Real-time subscriptions
  final Map<String, RealtimeChannel> _gameSubscriptions = {};
  final Map<String, RealtimeChannel> _moveSubscriptions = {};

  // Stream controllers for game events
  final Map<String, StreamController<GameDataModel>> _gameStreamControllers = {};
  final Map<String, StreamController<GameMoveModel>> _moveStreamControllers = {};
  final Map<String, StreamController<PlayerConnectionStatus>> _connectionStreamControllers = {};

  /// Subscribe to real-time game updates
  Stream<GameDataModel> subscribeToGame(String gameId) {
    // Return existing stream if already subscribed
    if (_gameStreamControllers.containsKey(gameId)) {
      return _gameStreamControllers[gameId]!.stream;
    }

    // Create new stream controller
    final controller = StreamController<GameDataModel>.broadcast();
    _gameStreamControllers[gameId] = controller;

    // Set up Supabase real-time subscription
    _setupGameSubscription(gameId, controller);

    return controller.stream;
  }

  /// Subscribe to real-time move updates
  Stream<GameMoveModel> subscribeToMoves(String gameId) {
    // Return existing stream if already subscribed
    if (_moveStreamControllers.containsKey(gameId)) {
      return _moveStreamControllers[gameId]!.stream;
    }

    // Create new stream controller
    final controller = StreamController<GameMoveModel>.broadcast();
    _moveStreamControllers[gameId] = controller;

    // Set up Supabase real-time subscription
    _setupMoveSubscription(gameId, controller);

    return controller.stream;
  }

  /// Subscribe to player connection status updates
  Stream<PlayerConnectionStatus> subscribeToConnectionStatus(String gameId) {
    // Return existing stream if already subscribed
    if (_connectionStreamControllers.containsKey(gameId)) {
      return _connectionStreamControllers[gameId]!.stream;
    }

    // Create new stream controller
    final controller = StreamController<PlayerConnectionStatus>.broadcast();
    _connectionStreamControllers[gameId] = controller;

    return controller.stream;
  }

  /// Set up real-time subscription for game updates
  void _setupGameSubscription(String gameId, StreamController<GameDataModel> controller) {
    try {
      final client = supabase.SupabaseClientWrapper.instance.database;

      final subscription = client
          .channel('game_$gameId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'games',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'id',
              value: gameId,
            ),
            callback: (payload) => _handleGameUpdate(payload, controller),
          )
          .subscribe();

      _gameSubscriptions[gameId] = subscription;
      logger.info('Subscribed to game updates: $gameId');
    } catch (e) {
      logger.severe('Error setting up game subscription: $e');
      controller.addError(e);
    }
  }

  /// Set up real-time subscription for move updates
  void _setupMoveSubscription(String gameId, StreamController<GameMoveModel> controller) {
    try {
      final client = supabase.SupabaseClientWrapper.instance.database;

      final subscription = client
          .channel('moves_$gameId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'game_moves',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'game_id',
              value: gameId,
            ),
            callback: (payload) => _handleMoveUpdate(payload, controller),
          )
          .subscribe();

      _moveSubscriptions[gameId] = subscription;
      logger.info('Subscribed to move updates: $gameId');
    } catch (e) {
      logger.severe('Error setting up move subscription: $e');
      controller.addError(e);
    }
  }

  /// Handle game update from Supabase real-time
  void _handleGameUpdate(PostgresChangePayload payload, StreamController<GameDataModel> controller) {
    try {
      final data = payload.newRecord;
      final gameId = data['id'] as String;
      final game = GameDataModel.fromSupabase(data, gameId);
      controller.add(game);

      // Also update connection status stream if it exists
      if (_connectionStreamControllers.containsKey(gameId)) {
        _connectionStreamControllers[gameId]!.add(game.connectionStatus);
      }

      logger.info('Game update received: $gameId');
    } catch (e) {
      logger.severe('Error handling game update: $e');
      controller.addError(e);
    }
  }

  /// Handle move update from Supabase real-time
  void _handleMoveUpdate(PostgresChangePayload payload, StreamController<GameMoveModel> controller) {
    try {
      final data = payload.newRecord;
      final moveId = data['id'] as String;
      final move = GameMoveModel.fromSupabase(data, moveId);
      controller.add(move);
      logger.info('Move update received: ${move.gameId} - ${move.moveNotation}');
    } catch (e) {
      logger.severe('Error handling move update: $e');
      controller.addError(e);
    }
  }

  /// Make a move in an online game
  Future<void> makeMove({
    required String gameId,
    required String playerId,
    required String moveNotation,
    required String fenAfterMove,
    required int timeRemaining,
    required int moveTime,
    bool isCheck = false,
    bool isCheckmate = false,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Get current game state to determine move number
      final game = await GameRepository.instance.get(gameId);
      if (game == null) {
        throw Exception('Game not found: $gameId');
      }

      // Validate it's the player's turn
      if (!game.isPlayerTurn(playerId)) {
        throw Exception('Not your turn');
      }

      // Validate game is active
      if (!game.isActive) {
        throw Exception('Game is not active');
      }

      final moveNumber = game.moveCount + 1;

      // Add the move to the database (this will trigger real-time updates)
      await GameMoveRepository.instance.addMove(
        gameId: gameId,
        playerId: playerId,
        moveNumber: moveNumber,
        moveNotation: moveNotation,
        fenAfterMove: fenAfterMove,
        timeRemaining: timeRemaining,
        moveTime: moveTime,
        isCheck: isCheck,
        isCheckmate: isCheckmate,
        metadata: metadata,
      );

      logger.info('Move made: $gameId - $moveNotation');
    } catch (e) {
      logger.severe('Error making move: $e');
      rethrow;
    }
  }

  /// Update player connection status
  Future<void> updateConnectionStatus(String gameId, String playerId, ConnectionStatus status) async {
    try {
      final game = await GameRepository.instance.get(gameId);
      if (game == null) {
        throw Exception('Game not found: $gameId');
      }

      // Determine which player to update
      PlayerConnectionStatus newStatus;
      if (playerId == game.redPlayerId) {
        newStatus = game.connectionStatus.copyWith(red: status);
      } else if (playerId == game.blackPlayerId) {
        newStatus = game.connectionStatus.copyWith(black: status);
      } else {
        throw Exception('Player not in this game');
      }

      // Update the game's connection status
      await GameRepository.instance.update(gameId, {
        'connection_status': newStatus.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      logger.info('Connection status updated: $gameId - $playerId: ${status.name}');
    } catch (e) {
      logger.severe('Error updating connection status: $e');
      rethrow;
    }
  }

  /// Pause a game (when a player disconnects)
  Future<void> pauseGame(String gameId, String reason) async {
    try {
      await GameRepository.instance.update(gameId, {
        'game_status': GameStatus.paused.name,
        'updated_at': DateTime.now().toIso8601String(),
        'metadata': {
          'pause_reason': reason,
          'paused_at': DateTime.now().toIso8601String(),
        },
      });

      logger.info('Game paused: $gameId - $reason');
    } catch (e) {
      logger.severe('Error pausing game: $e');
      rethrow;
    }
  }

  /// Resume a paused game
  Future<void> resumeGame(String gameId) async {
    try {
      await GameRepository.instance.update(gameId, {
        'game_status': GameStatus.active.name,
        'updated_at': DateTime.now().toIso8601String(),
      });

      logger.info('Game resumed: $gameId');
    } catch (e) {
      logger.severe('Error resuming game: $e');
      rethrow;
    }
  }

  /// Abandon a game (when a player leaves permanently)
  Future<void> abandonGame(String gameId, String playerId, String reason) async {
    try {
      final game = await GameRepository.instance.get(gameId);
      if (game == null) {
        throw Exception('Game not found: $gameId');
      }

      // Determine the winner (the player who didn't abandon)
      final winnerId = game.getOpponentId(playerId);

      await GameRepository.instance.update(gameId, {
        'game_status': GameStatus.abandoned.name,
        'winner_id': winnerId,
        'ended_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'metadata': {
          'abandon_reason': reason,
          'abandoned_by': playerId,
          'abandoned_at': DateTime.now().toIso8601String(),
        },
      });

      logger.info('Game abandoned: $gameId by $playerId - $reason');
    } catch (e) {
      logger.severe('Error abandoning game: $e');
      rethrow;
    }
  }

  /// Unsubscribe from game updates
  void unsubscribeFromGame(String gameId) {
    // Close stream controller
    _gameStreamControllers[gameId]?.close();
    _gameStreamControllers.remove(gameId);

    // Unsubscribe from Supabase
    _gameSubscriptions[gameId]?.unsubscribe();
    _gameSubscriptions.remove(gameId);

    logger.info('Unsubscribed from game: $gameId');
  }

  /// Unsubscribe from move updates
  void unsubscribeFromMoves(String gameId) {
    // Close stream controller
    _moveStreamControllers[gameId]?.close();
    _moveStreamControllers.remove(gameId);

    // Unsubscribe from Supabase
    _moveSubscriptions[gameId]?.unsubscribe();
    _moveSubscriptions.remove(gameId);

    logger.info('Unsubscribed from moves: $gameId');
  }

  /// Unsubscribe from connection status updates
  void unsubscribeFromConnectionStatus(String gameId) {
    // Close stream controller
    _connectionStreamControllers[gameId]?.close();
    _connectionStreamControllers.remove(gameId);

    logger.info('Unsubscribed from connection status: $gameId');
  }

  /// Clean up all subscriptions for a game
  void cleanupGame(String gameId) {
    unsubscribeFromGame(gameId);
    unsubscribeFromMoves(gameId);
    unsubscribeFromConnectionStatus(gameId);
  }

  /// Clean up all subscriptions
  void dispose() {
    // Close all stream controllers
    for (final controller in _gameStreamControllers.values) {
      controller.close();
    }
    for (final controller in _moveStreamControllers.values) {
      controller.close();
    }
    for (final controller in _connectionStreamControllers.values) {
      controller.close();
    }

    // Unsubscribe from all Supabase subscriptions
    for (final subscription in _gameSubscriptions.values) {
      subscription.unsubscribe();
    }
    for (final subscription in _moveSubscriptions.values) {
      subscription.unsubscribe();
    }

    // Clear all maps
    _gameStreamControllers.clear();
    _moveStreamControllers.clear();
    _connectionStreamControllers.clear();
    _gameSubscriptions.clear();
    _moveSubscriptions.clear();

    logger.info('OnlineMultiplayerService disposed');
  }
}
