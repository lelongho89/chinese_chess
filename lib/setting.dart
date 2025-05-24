import 'package:engine/engine.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

import 'global.dart';
import 'l10n/generated/app_localizations.dart';
import 'models/game_manager.dart';
import 'models/game_setting.dart';
import 'models/locale_provider.dart';
import 'models/play_mode.dart';

/// 设置页
class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  GameSetting? setting;

  @override
  void initState() {
    super.initState();
    GameSetting.getInstance().then(
      (value) => setState(() {
        setting = value;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          context.l10n.settings,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: setting == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Game Section
                    _buildSectionTitle(context.l10n.gameSettings),
                    const SizedBox(height: 16),

                    _buildSettingItem(
                      title: context.l10n.aiDifficulty,
                      subtitle: context.l10n.setTheAIDifficultyLevel,
                      trailing: Text(
                        _getDifficultyDisplayName(setting!.difficulty),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      onTap: () {
                        _showDifficultyDialog();
                      },
                    ),

                    const SizedBox(height: 32),

                    // Sound Section
                    _buildSectionTitle(context.l10n.sound),
                    const SizedBox(height: 16),

                    _buildSettingItem(
                      title: context.l10n.soundEffects,
                      subtitle: context.l10n.enableSoundEffectsForMovesAndGames,
                      trailing: Switch(
                        value: setting!.sound,
                        onChanged: (value) {
                          setState(() {
                            setting!.sound = value;
                            setting!.save();
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildSettingItem(
                      title: context.l10n.soundVolume,
                      subtitle: context.l10n.adjustTheVolumeOfSoundEffects,
                      trailing: Text(
                        '${(setting!.soundVolume * 100).toInt()}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      child: Slider(
                        value: setting!.soundVolume,
                        min: 0,
                        max: 1,
                        divisions: 10,
                        onChanged: (value) {
                          setState(() {
                            setting!.soundVolume = value;
                          });
                        },
                        onChangeEnd: (value) {
                          setting!.save();
                        },
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Appearance Section
                    _buildSectionTitle(context.l10n.appearance),
                    const SizedBox(height: 16),

                    _buildSettingItem(
                      title: context.l10n.pieceStyle,
                      subtitle: context.l10n.chooseTheVisualStyleOfTheChessPieces,
                      trailing: Text(
                        context.l10n.classic,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildSettingItem(
                      title: context.l10n.boardStyle,
                      subtitle: context.l10n.selectTheAppearanceOfTheChessboard,
                      trailing: Text(
                        setting!.skin == 'woods' ? context.l10n.wood : context.l10n.skinStones,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      onTap: () {
                        _showBoardStyleDialog();
                      },
                    ),

                    const SizedBox(height: 32),

                    // Game Timer Section
                    _buildSectionTitle(context.l10n.gameTimer),
                    const SizedBox(height: 16),

                    _buildSettingItem(
                      title: context.l10n.turnTimeLimit,
                      subtitle: context.l10n.setTheTimeLimitForEachPlayersMove,
                      trailing: Text(
                        '10 min',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildSettingItem(
                      title: context.l10n.enableTimer,
                      subtitle: context.l10n.enableOrDisableTheGameTimer,
                      trailing: Switch(
                        value: true, // You might want to add this to GameSetting
                        onChanged: (value) {
                          // Handle timer enable/disable
                        },
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onBackground,
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required String subtitle,
    Widget? trailing,
    Widget? child,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
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
                if (trailing != null) trailing,
              ],
            ),
            if (child != null) ...[
              const SizedBox(height: 12),
              child,
            ],
          ],
        ),
      ),
    );
  }

  void _showBoardStyleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.boardStyle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(context.l10n.wood),
              leading: Radio<String>(
                value: 'woods',
                groupValue: setting!.skin,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      setting!.skin = value;
                      GameManager.instance.updateSkin(value);
                      setting!.save();
                    });
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            ListTile(
              title: Text(context.l10n.skinStones),
              leading: Radio<String>(
                value: 'stones',
                groupValue: setting!.skin,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      setting!.skin = value;
                      GameManager.instance.updateSkin(value);
                      setting!.save();
                    });
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
  }

  String _getDifficultyDisplayName(int difficulty) {
    switch (difficulty) {
      case 0:
        return context.l10n.easy;
      case 1:
        return context.l10n.medium;
      case 2:
        return context.l10n.hard;
      default:
        return context.l10n.easy;
    }
  }

  void _showDifficultyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.difficulty),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(context.l10n.easy),
              leading: Radio<int>(
                value: 0,
                groupValue: setting!.difficulty,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      setting!.difficulty = value;
                      setting!.save();
                    });
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            ListTile(
              title: Text(context.l10n.medium),
              leading: Radio<int>(
                value: 1,
                groupValue: setting!.difficulty,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      setting!.difficulty = value;
                      setting!.save();
                    });
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            ListTile(
              title: Text(context.l10n.hard),
              leading: Radio<int>(
                value: 2,
                groupValue: setting!.difficulty,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      setting!.difficulty = value;
                      setting!.save();
                    });
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
        ],
      ),
    );
  }
}
