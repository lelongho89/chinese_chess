import 'package:cchess/cchess.dart';

import '../driver/driver_online.dart';
import '../driver/player_driver.dart';
import '../global.dart';
import '../models/game_data_model.dart';
import '../models/game_event.dart';
import '../models/game_manager.dart';
import '../models/game_move_model.dart';
import 'online_multiplayer_service.dart';

/// Service to manage online games and integrate with GameManager
class OnlineGameManager {
  // Singleton pattern
  static OnlineGameManager? _instance;
  static OnlineGameManager get instance => _instance ??= OnlineGameManager._();

  OnlineGameManager._();

  String? _currentGameId;
  String? _currentUserId;
  GameManager? _gameManager;

  /// Initialize an online game with the given game data
  Future<void> initializeOnlineGame({
    required GameDataModel gameData,
    required String currentUserId,
    required GameManager gameManager,
  }) async {
    try {
      _currentGameId = gameData.id;
      _currentUserId = currentUserId;
      _gameManager = gameManager;

      logger.info('Initializing online game: ${gameData.id}');

      // Determine player roles
      final isRedPlayer = gameData.redPlayerId == currentUserId;
      final isBlackPlayer = gameData.blackPlayerId == currentUserId;

      if (!isRedPlayer && !isBlackPlayer) {
        throw Exception('Current user is not a player in this game');
      }

      // Set up the game manager for online play
      await _setupGameManager(gameData, isRedPlayer);

      // Set up online drivers with game information
      _setupOnlineDrivers(gameData.id, currentUserId);

      // Subscribe to game state updates
      _subscribeToGameUpdates(gameData.id);

      logger.info('Online game initialized successfully');
    } catch (e) {
      logger.severe('Error initializing online game: $e');
      rethrow;
    }
  }

  /// Set up the game manager for online play
  Future<void> _setupGameManager(GameDataModel gameData, bool isRedPlayer) async {
    if (_gameManager == null) return;

    // Initialize the game manager
    await _gameManager!.init();

    // Set up the game state from the online game data
    _gameManager!.manual.initFen(gameData.currentFen);
    _gameManager!.rule = ChessRule(_gameManager!.manual.currentFen);

    // Set player titles
    _gameManager!.hands[0].title = 'Red Player';
    _gameManager!.hands[1].title = 'Black Player';

    // Set driver types based on player role
    if (isRedPlayer) {
      // Current user is red, opponent is black (online)
      _gameManager!.hands[0].driverType = DriverType.user;
      _gameManager!.hands[1].driverType = DriverType.online;
    } else {
      // Current user is black, opponent is red (online)
      _gameManager!.hands[0].driverType = DriverType.online;
      _gameManager!.hands[1].driverType = DriverType.user;
    }

    // Set current turn
    _gameManager!.curHand = gameData.currentPlayer;

    logger.info('Game manager set up for online play');
  }

  /// Set up online drivers with game information
  void _setupOnlineDrivers(String gameId, String currentUserId) {
    if (_gameManager == null) return;

    // Find and configure online drivers
    for (final player in _gameManager!.hands) {
      if (player.driverType == DriverType.online) {
        final driver = player.driver;
        if (driver is DriverOnline) {
          // Determine the opponent's player ID
          String opponentId;
          if (currentUserId == _getCurrentGameData()?.redPlayerId) {
            opponentId = _getCurrentGameData()?.blackPlayerId ?? '';
          } else {
            opponentId = _getCurrentGameData()?.redPlayerId ?? '';
          }

          driver.setGameInfo(gameId, opponentId);
          logger.info('Online driver configured for player: ${player.title}');
        }
      }
    }
  }

  /// Subscribe to game state updates
  void _subscribeToGameUpdates(String gameId) {
    OnlineMultiplayerService.instance
        .subscribeToGame(gameId)
        .listen(
          _handleGameUpdate,
          onError: (error) {
            logger.severe('Error in game subscription: $error');
          },
        );

    logger.info('Subscribed to game updates: $gameId');
  }

  /// Handle game state updates from the server
  void _handleGameUpdate(GameDataModel gameData) {
    if (_gameManager == null) return;

    try {
      // Update game state if needed
      if (gameData.currentFen != _gameManager!.manual.currentFen.fen) {
        // Game state has changed, update local state
        _updateLocalGameState(gameData);
      }

      // Handle game status changes
      if (gameData.gameStatus == GameStatus.ended) {
        _handleGameEnd(gameData);
      } else if (gameData.gameStatus == GameStatus.paused) {
        _handleGamePause(gameData);
      }

      // Update connection status indicators
      _updateConnectionStatus(gameData.connectionStatus);

      logger.info('Game state updated from server');
    } catch (e) {
      logger.severe('Error handling game update: $e');
    }
  }

  /// Update local game state to match server state
  void _updateLocalGameState(GameDataModel gameData) {
    if (_gameManager == null) return;

    // Update FEN if different
    if (gameData.currentFen != _gameManager!.manual.currentFen.fen) {
      _gameManager!.manual.initFen(gameData.currentFen);
      _gameManager!.rule = ChessRule(_gameManager!.manual.currentFen);
    }

    // Update current turn
    _gameManager!.curHand = gameData.currentPlayer;

    // Trigger UI update
    _gameManager!.add(GameLoadEvent(0));
  }

  /// Handle game end
  void _handleGameEnd(GameDataModel gameData) {
    if (_gameManager == null) return;

    String result;
    String description = 'Game ended';

    if (gameData.isDraw) {
      result = ChessManual.resultFstDraw;
      description = 'Draw';
    } else if (gameData.winnerId != null) {
      // Determine if current user won or lost
      final currentUserWon = gameData.winnerId == _currentUserId;
      result = currentUserWon ? ChessManual.resultFstWin : ChessManual.resultFstLoose;
      description = currentUserWon ? 'You won!' : 'You lost';
    } else {
      result = ChessManual.resultFstDraw;
      description = 'Game abandoned';
    }

    _gameManager!.setResult(result, description);
    logger.info('Game ended: $description');
  }

  /// Handle game pause
  void _handleGamePause(GameDataModel gameData) {
    if (_gameManager == null) return;

    // Lock the game UI
    _gameManager!.add(GameLockEvent(true));

    // TODO: Show pause dialog to user
    logger.info('Game paused');
  }

  /// Update connection status indicators
  void _updateConnectionStatus(PlayerConnectionStatus connectionStatus) {
    // TODO: Update UI to show connection status
    if (connectionStatus.anyDisconnected) {
      logger.info('Player disconnected');
    } else if (connectionStatus.bothConnected) {
      logger.info('Both players connected');
    }
  }

  /// Get current game data
  GameDataModel? _getCurrentGameData() {
    // This would typically be cached or fetched from the repository
    // For now, return null and let the caller handle it
    return null;
  }

  /// Make a move in the online game
  Future<void> makeMove(String moveNotation) async {
    if (_currentGameId == null || _currentUserId == null || _gameManager == null) {
      throw Exception('Online game not properly initialized');
    }

    try {
      final currentFen = _gameManager!.fenStr;
      final timeRemaining = _getCurrentPlayerTimeRemaining();
      final moveTime = _getLastMoveTime();
      final isCheck = _gameManager!.isCheckMate;

      await OnlineMultiplayerService.instance.makeMove(
        gameId: _currentGameId!,
        playerId: _currentUserId!,
        moveNotation: moveNotation,
        fenAfterMove: currentFen,
        timeRemaining: timeRemaining,
        moveTime: moveTime,
        isCheck: isCheck,
        isCheckmate: false, // TODO: Implement checkmate detection
      );

      logger.info('Move made in online game: $moveNotation');
    } catch (e) {
      logger.severe('Error making move in online game: $e');
      rethrow;
    }
  }

  /// Get current player's remaining time
  int _getCurrentPlayerTimeRemaining() {
    if (_gameManager == null) return 0;

    final currentPlayer = _gameManager!.hands[_gameManager!.curHand];
    return currentPlayer.totalTime;
  }

  /// Get time taken for last move
  int _getLastMoveTime() {
    if (_gameManager == null) return 0;

    final currentPlayer = _gameManager!.hands[_gameManager!.curHand];
    return currentPlayer.stepTime;
  }

  /// Clean up online game resources
  void dispose() {
    if (_currentGameId != null) {
      OnlineMultiplayerService.instance.cleanupGame(_currentGameId!);
    }

    _currentGameId = null;
    _currentUserId = null;
    _gameManager = null;

    logger.info('Online game manager disposed');
  }

  /// Check if currently in an online game
  bool get isInOnlineGame => _currentGameId != null;

  /// Get current game ID
  String? get currentGameId => _currentGameId;

  /// Get current user ID
  String? get currentUserId => _currentUserId;
}
