import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../global.dart';
import '../models/game_timer_manager.dart';
import 'chess_timer_widget.dart';

/// A widget to display both player timers
class GameTimerDisplay extends StatelessWidget {
  /// Whether to show the timers in a compact format
  final bool isCompact;
  
  /// Whether to show the timer controls
  final bool showControls;
  
  /// Constructor
  const GameTimerDisplay({
    super.key,
    this.isCompact = false,
    this.showControls = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GameTimerManager>(
      builder: (context, timerManager, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Black player timer
            ChessTimerWidget(
              timer: timerManager.blackTimer,
              isActive: timerManager.isEnabled && timerManager.gameManager.curHand == 1,
              isCompact: isCompact,
              color: Colors.black,
            ),
            
            // Timer controls
            if (showControls) ...[
              const SizedBox(height: 8),
              _buildTimerControls(context, timerManager),
              const SizedBox(height: 8),
            ] else
              const SizedBox(height: 16),
            
            // Red player timer
            ChessTimerWidget(
              timer: timerManager.redTimer,
              isActive: timerManager.isEnabled && timerManager.gameManager.curHand == 0,
              isCompact: isCompact,
              color: Colors.red,
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildTimerControls(BuildContext context, GameTimerManager timerManager) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Enable/disable toggle
        Switch(
          value: timerManager.isEnabled,
          onChanged: (value) {
            timerManager.enabled = value;
          },
        ),
        const SizedBox(width: 8),
        
        // Timer label
        Text(
          timerManager.isEnabled ? context.l10n.timerEnabled : context.l10n.timerDisabled,
          style: TextStyle(
            color: timerManager.isEnabled ? Colors.green : Colors.grey,
          ),
        ),
        
        // Reset button
        if (timerManager.isEnabled) ...[
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: context.l10n.resetTimer,
            onPressed: () {
              timerManager.startNewGame();
            },
          ),
        ],
      ],
    );
  }
}
