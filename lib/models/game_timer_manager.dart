import 'dart:async';

import 'package:flutter/foundation.dart';

import '../global.dart';
import 'chess_timer.dart';
import 'game_event.dart';
import 'game_manager.dart';

/// Manages the timers for both players in a chess game
class GameTimerManager extends ChangeNotifier {
  /// Timer for the red player (player 0)
  final ChessTimer redTimer;
  
  /// Timer for the black player (player 1)
  final ChessTimer blackTimer;
  
  /// Reference to the game manager
  final GameManager gameManager;
  
  /// Whether the timer is enabled
  bool _enabled = false;
  
  /// Current active player (0 for red, 1 for black)
  int _currentPlayer = 0;
  
  /// Subscription to game events
  StreamSubscription<GameEvent>? _eventSubscription;
  
  /// Constructor
  GameTimerManager({
    required this.gameManager,
    int initialTimeSeconds = 180, // 3 minutes
    int incrementSeconds = 2,     // 2 seconds per move
  }) : 
    redTimer = ChessTimer(initialTime: initialTimeSeconds, increment: incrementSeconds),
    blackTimer = ChessTimer(initialTime: initialTimeSeconds, increment: incrementSeconds) {
    
    // Listen for game events
    _eventSubscription = gameManager.gameEvent.stream.listen(_handleGameEvent);
  }
  
  /// Get the timer for a specific player
  ChessTimer getTimerForPlayer(int player) {
    return player == 0 ? redTimer : blackTimer;
  }
  
  /// Get the current active timer
  ChessTimer get activeTimer => _currentPlayer == 0 ? redTimer : blackTimer;
  
  /// Get the current inactive timer
  ChessTimer get inactiveTimer => _currentPlayer == 0 ? blackTimer : redTimer;
  
  /// Check if the timer is enabled
  bool get isEnabled => _enabled;
  
  /// Enable or disable the timer
  set enabled(bool value) {
    if (_enabled == value) return;
    
    _enabled = value;
    
    if (_enabled) {
      // Start the active timer if enabled
      activeTimer.start();
    } else {
      // Pause both timers if disabled
      redTimer.pause();
      blackTimer.pause();
    }
    
    notifyListeners();
    logger.info('Timer ${_enabled ? 'enabled' : 'disabled'}');
  }
  
  /// Start a new game with fresh timers
  void startNewGame() {
    // Reset both timers
    redTimer.reset();
    blackTimer.reset();
    
    // Set the current player based on the game manager
    _currentPlayer = gameManager.curHand;
    
    // Start the active timer if enabled
    if (_enabled) {
      activeTimer.start();
    }
    
    notifyListeners();
    logger.info('New game started, current player: $_currentPlayer');
  }
  
  /// Switch the active player
  void switchPlayer() {
    if (!_enabled) return;
    
    // Add increment to the player who just moved
    activeTimer.addIncrement();
    
    // Pause the current active timer
    activeTimer.pause();
    
    // Switch the current player
    _currentPlayer = 1 - _currentPlayer;
    
    // Start the new active timer
    activeTimer.start();
    
    notifyListeners();
    logger.info('Switched to player: $_currentPlayer');
  }
  
  /// Handle game events
  void _handleGameEvent(GameEvent event) {
    switch (event.type) {
      case GameEventType.player:
        // Player changed
        final newPlayer = event.data as int;
        if (_currentPlayer != newPlayer) {
          _currentPlayer = newPlayer;
          
          if (_enabled) {
            // Pause the inactive timer
            inactiveTimer.pause();
            
            // Start the active timer
            activeTimer.start();
          }
          
          notifyListeners();
        }
        break;
        
      case GameEventType.load:
        // Game loaded or reset
        final state = event.data as int;
        if (state == 0) {
          // New game
          startNewGame();
        }
        break;
        
      case GameEventType.result:
        // Game ended
        redTimer.stop();
        blackTimer.stop();
        break;
        
      default:
        // Ignore other events
        break;
    }
  }
  
  /// Check if a player has lost on time
  bool hasPlayerLostOnTime(int player) {
    final timer = getTimerForPlayer(player);
    return timer.isExpired;
  }
  
  /// Set the time remaining for a player (for synchronization)
  void setTimeRemaining(int player, int seconds) {
    final timer = getTimerForPlayer(player);
    timer.setTimeRemaining(seconds);
    notifyListeners();
  }
  
  /// Pause both timers
  void pauseAll() {
    redTimer.pause();
    blackTimer.pause();
    notifyListeners();
  }
  
  /// Resume the active timer
  void resumeActive() {
    if (_enabled) {
      activeTimer.start();
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
    _eventSubscription?.cancel();
    redTimer.dispose();
    blackTimer.dispose();
    super.dispose();
  }
}
