import 'package:flutter/material.dart';

import '../global.dart';
import '../game_board.dart';
import '../models/play_mode.dart';
import '../models/game_manager.dart';

class NewGameScreen extends StatefulWidget {
  const NewGameScreen({super.key});

  @override
  State<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen> {
  PlayMode? _selectedMode;
  int _selectedDifficulty = 0; // 0: Easy, 1: Medium, 2: Hard

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(context.l10n.newGame),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Game Mode Section
            Text(
              context.l10n.gameMode,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),

            // Single Player Option
            _buildGameModeOption(
              title: context.l10n.singlePlayer,
              subtitle: context.l10n.playAgainstTheComputer,
              isSelected: _selectedMode == PlayMode.modeRobot,
              onTap: () {
                setState(() {
                  _selectedMode = PlayMode.modeRobot;
                });
              },
            ),

            // Local Multiplayer Option - Hidden for MVP
            // const SizedBox(height: 12),
            // _buildGameModeOption(
            //   title: context.l10n.localMultiplayer,
            //   subtitle: context.l10n.playWithAFriendOnTheSameDevice,
            //   isSelected: _selectedMode == PlayMode.modeFree,
            //   onTap: () {
            //     setState(() {
            //       _selectedMode = PlayMode.modeFree;
            //     });
            //   },
            // ),

            const SizedBox(height: 32),

            // Difficulty Section (only show for single player)
            if (_selectedMode == PlayMode.modeRobot) ...[
              Text(
                context.l10n.difficulty,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 16),

              _buildDifficultyOption(
                title: context.l10n.easy,
                isSelected: _selectedDifficulty == 0,
                onTap: () {
                  setState(() {
                    _selectedDifficulty = 0;
                  });
                },
              ),

              const SizedBox(height: 12),

              _buildDifficultyOption(
                title: context.l10n.medium,
                isSelected: _selectedDifficulty == 1,
                onTap: () {
                  setState(() {
                    _selectedDifficulty = 1;
                  });
                },
              ),

              const SizedBox(height: 12),

              _buildDifficultyOption(
                title: context.l10n.hard,
                isSelected: _selectedDifficulty == 2,
                onTap: () {
                  setState(() {
                    _selectedDifficulty = 2;
                  });
                },
              ),
            ],

            const Spacer(),

            // Start Game Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _selectedMode != null ? _startGame : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  context.l10n.startGame,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameModeOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  void _startGame() {
    if (_selectedMode != null) {
      // Set difficulty level for AI if single player mode
      if (_selectedMode == PlayMode.modeRobot) {
        // Map difficulty to engine level (10: Easy, 11: Medium, 12: Hard)
        final engineLevel = 10 + _selectedDifficulty;
        // You might want to update the game setting here
      }

      // Navigate to game board with selected mode
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const GameBoard(),
        ),
      );
    }
  }
}
