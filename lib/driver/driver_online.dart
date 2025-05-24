import 'dart:async';

import '../global.dart';
import '../models/game_event.dart';
import '../models/game_move_model.dart';
import '../services/online_multiplayer_service.dart';
import 'player_driver.dart';

class DriverOnline extends PlayerDriver {
  StreamSubscription<GameMoveModel>? _moveSubscription;
  Completer<PlayerAction>? _moveCompleter;
  String? _gameId;
  String? _playerId;

  DriverOnline(super.player) {
    canBacktrace = false;
  }

  @override
  Future<void> init() async {
    // Initialize online driver
    // Game and player IDs will be set externally via setGameInfo()
    logger.info('DriverOnline initialized, waiting for game info...');
  }

  @override
  Future<void> dispose() async {
    await _moveSubscription?.cancel();
    _moveSubscription = null;

    if (_gameId != null) {
      OnlineMultiplayerService.instance.unsubscribeFromMoves(_gameId!);
    }

    logger.info('DriverOnline disposed');
  }

  /// Subscribe to opponent moves
  void _subscribeToMoves() {
    if (_gameId == null) return;

    _moveSubscription = OnlineMultiplayerService.instance
        .subscribeToMoves(_gameId!)
        .listen(
          _handleOpponentMove,
          onError: (error) {
            logger.severe('Error in move subscription: $error');
            _moveCompleter?.completeError(error);
          },
        );
  }

  /// Handle incoming move from opponent
  void _handleOpponentMove(GameMoveModel move) {
    // Only process moves from the opponent
    if (move.playerId == _playerId) return;

    logger.info('Received opponent move: ${move.moveNotation}');

    // Complete the move request if waiting for opponent
    if (_moveCompleter != null && !_moveCompleter!.isCompleted) {
      final playerAction = PlayerAction(
        type: PlayerActionType.rstMove,
        move: move.moveNotation,
      );

      _moveCompleter!.complete(playerAction);
      _moveCompleter = null;
    }

    // Unlock the game UI for the current player's turn
    player.manager.add(GameLockEvent(false));
  }

  @override
  Future<bool> tryDraw() {
    // TODO: Implement draw request through online service
    return Future.value(true);
  }

  @override
  Future<PlayerAction?> move() {
    // Lock the game UI while waiting for opponent move
    player.manager.add(GameLockEvent(true));

    // Create a completer to wait for the opponent's move
    _moveCompleter = Completer<PlayerAction>();

    logger.info('Waiting for opponent move...');
    return _moveCompleter!.future;
  }

  @override
  Future<String> ponder() {
    // Online players don't need to ponder - they're waiting for network input
    return Future.value('');
  }

  @override
  void completeMove(PlayerAction move) {
    // This is called when the local player makes a move
    // We need to send this move to the opponent through the online service
    if (_gameId == null || _playerId == null) {
      logger.severe('Cannot complete move: missing game or player ID');
      return;
    }

    if (move.type == PlayerActionType.rstMove && move.move != null) {
      _sendMoveToOpponent(move.move!);
    }
  }

  /// Send the local player's move to the opponent
  Future<void> _sendMoveToOpponent(String moveNotation) async {
    if (_gameId == null || _playerId == null) return;

    try {
      // Get current game state to calculate time remaining and other details
      final currentFen = player.manager.fenStr; // Get current FEN from game manager
      final timeRemaining = player.totalTime; // Player's remaining time
      final moveTime = player.stepTime; // Time taken for this move

      // Check if the current move results in check or checkmate
      final isCheck = player.manager.isCheckMate; // Use game manager's check detection
      const isCheckmate = false; // TODO: Implement checkmate detection

      await OnlineMultiplayerService.instance.makeMove(
        gameId: _gameId!,
        playerId: _playerId!,
        moveNotation: moveNotation,
        fenAfterMove: currentFen,
        timeRemaining: timeRemaining,
        moveTime: moveTime,
        isCheck: isCheck,
        isCheckmate: isCheckmate,
      );

      logger.info('Move sent to opponent: $moveNotation');
    } catch (e) {
      logger.severe('Error sending move to opponent: $e');
      // TODO: Handle network errors, show user feedback
    }
  }

  @override
  Future<bool> tryRetract() {
    // TODO: Implement retract request through online service
    // This would need to send a retract request to the opponent
    // and wait for their response
    return Future.value(false);
  }

  /// Update connection status
  Future<void> updateConnectionStatus(ConnectionStatus status) async {
    if (_gameId == null || _playerId == null) return;

    try {
      await OnlineMultiplayerService.instance.updateConnectionStatus(
        _gameId!,
        _playerId!,
        status,
      );
    } catch (e) {
      logger.severe('Error updating connection status: $e');
    }
  }

  /// Handle network disconnection
  void onDisconnected() {
    updateConnectionStatus(ConnectionStatus.disconnected);

    // Complete any pending move requests with an error
    if (_moveCompleter != null && !_moveCompleter!.isCompleted) {
      _moveCompleter!.completeError('Network disconnected');
      _moveCompleter = null;
    }
  }

  /// Handle network reconnection
  void onReconnected() {
    updateConnectionStatus(ConnectionStatus.connected);

    // Re-subscribe to moves if needed
    if (_moveSubscription == null && _gameId != null) {
      _subscribeToMoves();
    }
  }

  /// Set game and player IDs (called from game manager)
  void setGameInfo(String gameId, String playerId) {
    _gameId = gameId;
    _playerId = playerId;

    // Start subscribing to moves now that we have game info
    _subscribeToMoves();

    logger.info('DriverOnline game info set: gameId=$gameId, playerId=$playerId');
  }
}
