import 'dart:async';

import 'package:flutter/foundation.dart';

import '../global.dart';

/// Represents the state of a chess timer
enum TimerState {
  /// Timer is not running and has not been started
  ready,
  
  /// Timer is currently running
  running,
  
  /// Timer is paused
  paused,
  
  /// Timer has expired (player lost on time)
  expired,
  
  /// Timer is stopped (game ended)
  stopped
}

/// A chess timer model for blitz games
class ChessTimer extends ChangeNotifier {
  /// Initial time in seconds (3 minutes = 180 seconds)
  final int initialTime;
  
  /// Increment in seconds (2 seconds per move)
  final int increment;
  
  /// Current time remaining in seconds
  int _timeRemaining;
  
  /// Current state of the timer
  TimerState _state = TimerState.ready;
  
  /// Timer for counting down
  Timer? _timer;
  
  /// Last time the timer was updated (for accurate timing)
  DateTime? _lastUpdateTime;
  
  /// Constructor
  ChessTimer({
    this.initialTime = 180, // 3 minutes
    this.increment = 2,     // 2 seconds per move
  }) : _timeRemaining = initialTime;
  
  /// Get the current time remaining in seconds
  int get timeRemaining => _timeRemaining;
  
  /// Get the current state of the timer
  TimerState get state => _state;
  
  /// Check if the timer is running
  bool get isRunning => _state == TimerState.running;
  
  /// Check if the timer has expired
  bool get isExpired => _state == TimerState.expired;
  
  /// Format the time remaining as mm:ss
  String get formattedTime {
    final minutes = (_timeRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_timeRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
  
  /// Start the timer
  void start() {
    if (_state == TimerState.running) return;
    
    _state = TimerState.running;
    _lastUpdateTime = DateTime.now();
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), _updateTimer);
    
    notifyListeners();
    logger.info('Timer started: $_timeRemaining seconds');
  }
  
  /// Pause the timer
  void pause() {
    if (_state != TimerState.running) return;
    
    _state = TimerState.paused;
    _timer?.cancel();
    _timer = null;
    
    notifyListeners();
    logger.info('Timer paused: $_timeRemaining seconds');
  }
  
  /// Resume the timer
  void resume() {
    if (_state != TimerState.paused) return;
    
    start();
  }
  
  /// Stop the timer (game ended)
  void stop() {
    _state = TimerState.stopped;
    _timer?.cancel();
    _timer = null;
    
    notifyListeners();
    logger.info('Timer stopped: $_timeRemaining seconds');
  }
  
  /// Reset the timer to the initial time
  void reset() {
    _state = TimerState.ready;
    _timeRemaining = initialTime;
    _timer?.cancel();
    _timer = null;
    
    notifyListeners();
    logger.info('Timer reset: $_timeRemaining seconds');
  }
  
  /// Add increment to the timer (after a move)
  void addIncrement() {
    if (_state == TimerState.expired || _state == TimerState.stopped) return;
    
    _timeRemaining += increment;
    notifyListeners();
    logger.info('Increment added: $_timeRemaining seconds');
  }
  
  /// Set the time remaining (for synchronization)
  void setTimeRemaining(int seconds) {
    _timeRemaining = seconds;
    
    if (_timeRemaining <= 0) {
      _timeRemaining = 0;
      _state = TimerState.expired;
      _timer?.cancel();
      _timer = null;
    }
    
    notifyListeners();
    logger.info('Time set: $_timeRemaining seconds');
  }
  
  /// Update the timer (called by the timer)
  void _updateTimer(Timer timer) {
    final now = DateTime.now();
    final elapsed = now.difference(_lastUpdateTime!).inMilliseconds;
    _lastUpdateTime = now;
    
    // Convert milliseconds to deciseconds (0.1 seconds)
    final elapsedDeciSeconds = elapsed ~/ 100;
    
    // Subtract elapsed time (in deciseconds)
    _timeRemaining -= elapsedDeciSeconds / 10;
    
    // Ensure time doesn't go below zero
    if (_timeRemaining <= 0) {
      _timeRemaining = 0;
      _state = TimerState.expired;
      _timer?.cancel();
      _timer = null;
    }
    
    notifyListeners();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
