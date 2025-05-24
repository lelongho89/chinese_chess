import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/chess_timer.dart';
import 'models/game_timer_manager.dart';
import 'models/game_manager.dart';
import 'models/game_event.dart';
import 'components/chess_timer_widget.dart';

/// A test screen to verify timer functionality and positioning
class TestTimerScreen extends StatefulWidget {
  const TestTimerScreen({super.key});

  @override
  State<TestTimerScreen> createState() => _TestTimerScreenState();
}

class _TestTimerScreenState extends State<TestTimerScreen> {
  late GameTimerManager timerManager;
  bool isInitialized = false;
  Timer? _debugTimer;

  @override
  void initState() {
    super.initState();
    _initializeTimer();
  }

  void _initializeTimer() async {
    try {
      final gameManager = GameManager.instance;

      // Initialize the game manager first
      await gameManager.init();

      timerManager = GameTimerManager(
        gameManager: gameManager,
        initialTimeSeconds: 60, // 1 minute for testing
        incrementSeconds: 2,
      );

      // Set the current player to 0 (red player starts)
      gameManager.curHand = 0;

      // Enable the timer and start new game
      timerManager.enabled = true;
      timerManager.startNewGame();

      setState(() {
        isInitialized = true;
      });

      print('TestTimerScreen: Timer initialized and enabled');
      print('TestTimerScreen: Current player: ${gameManager.curHand}');
      print('TestTimerScreen: Timer enabled: ${timerManager.isEnabled}');
      print('TestTimerScreen: Active timer state: ${timerManager.activeTimer.state}');
      print('TestTimerScreen: Red timer state: ${timerManager.redTimer.state}');
      print('TestTimerScreen: Black timer state: ${timerManager.blackTimer.state}');
      print('TestTimerScreen: Red timer time: ${timerManager.redTimer.timeRemaining}');
      print('TestTimerScreen: Black timer time: ${timerManager.blackTimer.timeRemaining}');

      // Start a debug timer to check timer state every second
      _debugTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (isInitialized) {
          print('DEBUG: Red timer: ${timerManager.redTimer.timeRemaining}s (${timerManager.redTimer.state})');
          print('DEBUG: Black timer: ${timerManager.blackTimer.timeRemaining}s (${timerManager.blackTimer.state})');
          print('DEBUG: Current player: ${timerManager.gameManager.curHand}');
        }
      });
    } catch (e) {
      print('TestTimerScreen: Error initializing timer: $e');
    }
  }

  @override
  void dispose() {
    _debugTimer?.cancel();
    if (isInitialized) {
      timerManager.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer Test'),
        backgroundColor: Colors.blue,
      ),
      body: ChangeNotifierProvider.value(
        value: timerManager,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Test the timer positioning like in the game
              _buildPlayerWithTimer('Black Player', 1, Colors.black),

              const SizedBox(height: 40),

              // Chess board placeholder
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.brown, width: 2),
                  color: Colors.brown.shade100,
                ),
                child: const Center(
                  child: Text(
                    'Chess Board\n(Placeholder)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              _buildPlayerWithTimer('Red Player', 0, Colors.red),

              const SizedBox(height: 20),

              // Control buttons
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          timerManager.enabled = !timerManager.isEnabled;
                        },
                        child: Consumer<GameTimerManager>(
                          builder: (context, manager, child) {
                            return Text(manager.isEnabled ? 'Disable' : 'Enable');
                          },
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          timerManager.startNewGame();
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Manually switch players to test timer switching
                      final gameManager = timerManager.gameManager;
                      gameManager.curHand = gameManager.curHand == 0 ? 1 : 0;

                      // Trigger player change event
                      gameManager.add(GamePlayerEvent(gameManager.curHand));

                      print('TestTimerScreen: Switched to player ${gameManager.curHand}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Switch Player'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerWithTimer(String playerName, int team, Color color) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Circular avatar with countdown highlight
          Consumer<GameTimerManager>(
            builder: (context, timerManager, child) {
              final isPlayerTurn = timerManager.isEnabled &&
                                 timerManager.gameManager.curHand == team;
              return _buildCircularAvatar(isPlayerTurn);
            },
          ),

          const SizedBox(width: 12),

          // Player info and timer boxes
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Player name/ID box
                _buildPlayerNameBox(playerName),

                const SizedBox(height: 6),

                // Timer box
                Consumer<GameTimerManager>(
                  builder: (context, timerManager, child) {
                    final isPlayerTurn = timerManager.isEnabled &&
                                       timerManager.gameManager.curHand == team;
                    return _buildTimerBox(
                      timerManager.getTimerForPlayer(team),
                      isPlayerTurn,
                    );
                  },
                ),
              ],
            ),
          ),

          // Robot indicator
          Icon(
            Icons.android,
            color: Colors.grey,
            size: 20,
          ),
        ],
      ),
    );
  }

  /// Build circular avatar with countdown highlight
  Widget _buildCircularAvatar(bool isPlayerTurn) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isPlayerTurn ? Colors.green : Colors.grey.shade300, // Green highlight
          width: isPlayerTurn ? 3.0 : 2.0,
        ),
        boxShadow: isPlayerTurn ? [
          BoxShadow(
            color: Colors.green.withOpacity(0.3), // Green glow
            blurRadius: 8.0,
            spreadRadius: 2.0,
          ),
        ] : null,
      ),
      child: CircleAvatar(
        radius: 26,
        backgroundColor: Colors.grey.shade200,
        child: Icon(
          Icons.person,
          size: 30,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  /// Build player name/ID box
  Widget _buildPlayerNameBox(String playerName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF8B4513), // Brown color like in screenshot
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF654321), width: 1),
      ),
      child: Text(
        playerName.isEmpty ? 'Anonymous' : playerName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Build timer box
  Widget _buildTimerBox(ChessTimer timer, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF8B4513), // Brown color like in screenshot
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isActive ? Colors.orange : const Color(0xFF654321),
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive ? [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 4.0,
            spreadRadius: 1.0,
          ),
        ] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: isActive ? Colors.orange : Colors.white70,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            timer.formattedTime,
            style: TextStyle(
              color: isActive ? Colors.orange : Colors.white,
              fontSize: 14,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              fontFamily: 'Roboto Mono',
            ),
          ),
        ],
      ),
    );
  }
}
