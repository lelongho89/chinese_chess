import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../global.dart';
import '../driver/player_driver.dart';
import '../models/game_event.dart';
import '../models/game_manager.dart';
import '../models/game_timer_manager.dart';
import '../models/chess_timer.dart';
import '../widgets/list_item.dart';
import 'chess_timer_widget.dart';

/// 单个玩家框
class PlaySinglePlayer extends StatefulWidget {
  final int team;
  final Alignment placeAt;
  final bool showTimer;

  const PlaySinglePlayer({
    super.key,
    required this.team,
    this.placeAt = Alignment.topCenter,
    this.showTimer = true,
  });

  @override
  State<PlaySinglePlayer> createState() => PlaySinglePlayerState();
}

class PlaySinglePlayerState extends State<PlaySinglePlayer> {
  late GameManager gamer = GameManager.instance;
  int currentTeam = 0;

  @override
  void initState() {
    super.initState();

    gamer.on<GamePlayerEvent>(onChangePlayer);
    gamer.on<GameLoadEvent>(onReloadGame);
    gamer.on<GameResultEvent>(onResult);
  }

  @override
  void dispose() {
    gamer.off<GamePlayerEvent>(onChangePlayer);
    gamer.off<GameLoadEvent>(onReloadGame);
    gamer.off<GameResultEvent>(onResult);
    super.dispose();
  }

  void onResult(GameEvent event) {
    setState(() {});
  }

  void onReloadGame(GameEvent event) {
    if (event.data != 0) return;
    setState(() {});
  }

  void onChangePlayer(GameEvent event) {
    setState(() {
      currentTeam = event.data;
    });
  }

  Widget switchRobot(int team) {
    // Check if gamer is initialized before accessing hands
    if (!gamer.isInitialized || team >= gamer.hands.length) {
      return const SizedBox();
    }

    final player = gamer.hands[team];

    // Don't show robot switch for online robot players (they're managed by the server)
    if (player.isRobotOnline) {
      return Container(
        padding: const EdgeInsets.all(8),
        child: const Icon(
          Icons.smart_toy,
          color: Colors.orange,
          size: 20,
        ),
      );
    }

    if (player.isUser) {
      return IconButton(
        icon: const Icon(Icons.android),
        tooltip: context.l10n.trusteeshipToRobots,
        onPressed: () {
          changePlayDriver(team, DriverType.robot);
        },
      );
    } else if (player.isRobot) {
      return IconButton(
        icon: const Icon(
          Icons.android,
          color: Colors.blueAccent,
        ),
        tooltip: context.l10n.cancelRobots,
        onPressed: () {
          changePlayDriver(team, DriverType.user);
        },
      );
    }
    return const SizedBox();
  }

  void changePlayDriver(int team, DriverType driverType) {
    setState(() {
      gamer.switchDriver(team, driverType);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if gamer is properly initialized before accessing players
    if (!gamer.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    Widget leading;
    Widget trailing;
    TextDirection tDirect;
    if (widget.placeAt == Alignment.topCenter) {
      leading = Icon(
        Icons.person,
        size: 28,
        color: currentTeam == widget.team ? Colors.blueAccent : Colors.black12,
      );
      trailing = switchRobot(widget.team);
      tDirect = TextDirection.ltr;
    } else {
      trailing = Icon(
        Icons.person,
        size: 28,
        color: currentTeam == widget.team ? Colors.blueAccent : Colors.black12,
      );
      leading = switchRobot(widget.team);
      tDirect = TextDirection.rtl;
    }
    List<Widget> childs = [
      SizedBox(
        width: 280,
        child: Row(
          children: widget.placeAt == Alignment.topCenter
              ? [
                  // Top player: Avatar on left
                  // Circular avatar with countdown highlight
                  Consumer<GameTimerManager>(
                    builder: (context, timerManager, child) {
                      final isPlayerTurn = timerManager.isEnabled &&
                                         timerManager.gameManager.curHand == widget.team;
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
                        _buildPlayerNameBox(gamer.getPlayer(widget.team).title),

                        const SizedBox(height: 6),

                        // Timer box
                        if (widget.showTimer)
                          Consumer<GameTimerManager>(
                            builder: (context, timerManager, child) {
                              final isPlayerTurn = timerManager.isEnabled &&
                                                 timerManager.gameManager.curHand == widget.team;
                              return _buildTimerBox(
                                timerManager.getTimerForPlayer(widget.team),
                                isPlayerTurn,
                              );
                            },
                          ),
                      ],
                    ),
                  ),

                  // Robot switch button for top player
                  switchRobot(widget.team),
                ]
              : [
                  // Bottom player: Avatar on right
                  // Player info and timer boxes
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Player name/ID box
                        _buildPlayerNameBox(gamer.getPlayer(widget.team).title),

                        const SizedBox(height: 6),

                        // Timer box
                        if (widget.showTimer)
                          Consumer<GameTimerManager>(
                            builder: (context, timerManager, child) {
                              final isPlayerTurn = timerManager.isEnabled &&
                                                 timerManager.gameManager.curHand == widget.team;
                              return _buildTimerBox(
                                timerManager.getTimerForPlayer(widget.team),
                                isPlayerTurn,
                              );
                            },
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Circular avatar with countdown highlight
                  Consumer<GameTimerManager>(
                    builder: (context, timerManager, child) {
                      final isPlayerTurn = timerManager.isEnabled &&
                                         timerManager.gameManager.curHand == widget.team;
                      return _buildCircularAvatar(isPlayerTurn);
                    },
                  ),
                ],
        ),
      ),
      const SizedBox(width: 10),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: widget.placeAt == Alignment.topCenter
            ? MainAxisAlignment.start // Top player: align to left
            : MainAxisAlignment.end,   // Bottom player: align to right
        children: childs,
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
