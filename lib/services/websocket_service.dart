import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

import '../global.dart';
import '../models/game_timer_manager.dart';

/// Service for handling WebSocket communication
class WebSocketService {
  /// WebSocket channel
  WebSocketChannel? _channel;
  
  /// Stream subscription for WebSocket messages
  StreamSubscription? _subscription;
  
  /// Timer manager for synchronizing timers
  final GameTimerManager _timerManager;
  
  /// Whether the WebSocket is connected
  bool _isConnected = false;
  
  /// Constructor
  WebSocketService(this._timerManager);
  
  /// Connect to the WebSocket server
  Future<bool> connect(String url) async {
    try {
      // Close existing connection if any
      await disconnect();
      
      // Connect to the WebSocket server
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      // Listen for messages
      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDone,
      );
      
      _isConnected = true;
      logger.info('WebSocket connected to $url');
      return true;
    } catch (e) {
      logger.severe('Error connecting to WebSocket: $e');
      _isConnected = false;
      return false;
    }
  }
  
  /// Disconnect from the WebSocket server
  Future<void> disconnect() async {
    if (_channel != null) {
      await _subscription?.cancel();
      _subscription = null;
      
      await _channel!.sink.close(status.normalClosure);
      _channel = null;
      
      _isConnected = false;
      logger.info('WebSocket disconnected');
    }
  }
  
  /// Send a message to the WebSocket server
  void send(Map<String, dynamic> data) {
    if (!_isConnected || _channel == null) {
      logger.warning('Cannot send message: WebSocket not connected');
      return;
    }
    
    try {
      _channel!.sink.add(jsonEncode(data));
    } catch (e) {
      logger.severe('Error sending message: $e');
    }
  }
  
  /// Send timer update to the WebSocket server
  void sendTimerUpdate(int player, int timeRemaining) {
    send({
      'type': 'timer_update',
      'player': player,
      'time_remaining': timeRemaining,
    });
  }
  
  /// Handle incoming WebSocket messages
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final type = data['type'] as String?;
      
      switch (type) {
        case 'timer_update':
          _handleTimerUpdate(data);
          break;
        case 'game_start':
          _handleGameStart(data);
          break;
        case 'game_end':
          _handleGameEnd(data);
          break;
        default:
          logger.warning('Unknown message type: $type');
      }
    } catch (e) {
      logger.severe('Error handling message: $e');
    }
  }
  
  /// Handle timer update messages
  void _handleTimerUpdate(Map<String, dynamic> data) {
    final player = data['player'] as int;
    final timeRemaining = data['time_remaining'] as int;
    
    // Update the timer
    _timerManager.setTimeRemaining(player, timeRemaining);
    
    logger.info('Timer updated: Player $player, Time: $timeRemaining');
  }
  
  /// Handle game start messages
  void _handleGameStart(Map<String, dynamic> data) {
    // Reset timers for new game
    _timerManager.startNewGame();
    
    // Enable timers if specified
    final enableTimer = data['enable_timer'] as bool?;
    if (enableTimer != null) {
      _timerManager.enabled = enableTimer;
    }
    
    logger.info('Game started');
  }
  
  /// Handle game end messages
  void _handleGameEnd(Map<String, dynamic> data) {
    // Disable timers
    _timerManager.enabled = false;
    
    logger.info('Game ended');
  }
  
  /// Handle WebSocket errors
  void _handleError(dynamic error) {
    logger.severe('WebSocket error: $error');
    _isConnected = false;
  }
  
  /// Handle WebSocket connection closed
  void _handleDone() {
    logger.info('WebSocket connection closed');
    _isConnected = false;
  }
  
  /// Check if the WebSocket is connected
  bool get isConnected => _isConnected;
}
