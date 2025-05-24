import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../global.dart';
import '../driver/player_driver.dart';
import '../models/game_event.dart';
import '../widgets/game_wrapper.dart';
import '../models/game_manager.dart';
import '../models/game_timer_manager.dart';
import '../models/chess_timer.dart';
import '../widgets/tab_card.dart';
import 'chess_timer_widget.dart';

/// 组合玩家框及对局双方信息框
class PlayPlayer extends StatefulWidget {
  const PlayPlayer({super.key});

  @override
  State<PlayPlayer> createState() => PlayPlayerState();
}

class PlayPlayerState extends State<PlayPlayer> {
  late GameManager gamer = GameManager.instance;
  int currentTeam = 0;

  @override
  void initState() {
    super.initState();
    GameWrapperState gameWrapper =
        context.findAncestorStateOfType<GameWrapperState>()!;
    gamer = gameWrapper.gamer;
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

    if (gamer.hands[team].isUser) {
      return IconButton(
        icon: const Icon(Icons.android),
        tooltip: context.l10n.trusteeshipToRobots,
        onPressed: () {
          changePlayDriver(team, DriverType.robot);
        },
      );
    } else if (gamer.hands[team].isRobot) {
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
    // Check if gamer is properly initialized before accessing players and manual
    if (!gamer.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    BoxDecoration decoration = BoxDecoration(
      border: Border.all(color: Colors.grey, width: 0.5),
      borderRadius: const BorderRadius.all(Radius.circular(2)),
    );
    return SizedBox(
      width: 229,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
        children: [
          // Black player (team 1) - Avatar on left
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start, // Align row content to the left
              children: [
                // Circular avatar with countdown highlight
                Consumer<GameTimerManager>(
                  builder: (context, timerManager, child) {
                    final isPlayerTurn = timerManager.isEnabled &&
                                       timerManager.gameManager.curHand == 1;
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
                      _buildPlayerNameBox(gamer.getPlayer(1).title),

                      const SizedBox(height: 6),

                      // Timer box
                      Consumer<GameTimerManager>(
                        builder: (context, timerManager, child) {
                          final isPlayerTurn = timerManager.isEnabled &&
                                             timerManager.gameManager.curHand == 1;
                          return _buildTimerBox(
                            timerManager.getTimerForPlayer(1),
                            isPlayerTurn,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Robot switch button
                switchRobot(1),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Red player (team 0) - Avatar on the right
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end, // Align row content to the right
              children: [
                // Robot switch button
                switchRobot(0),

                const SizedBox(width: 12),

                // Player info and timer boxes
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Player name/ID box
                      _buildPlayerNameBox(gamer.getPlayer(0).title),

                      const SizedBox(height: 6),

                      // Timer box
                      Consumer<GameTimerManager>(
                        builder: (context, timerManager, child) {
                          final isPlayerTurn = timerManager.isEnabled &&
                                             timerManager.gameManager.curHand == 0;
                          return _buildTimerBox(
                            timerManager.getTimerForPlayer(0),
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
                                       timerManager.gameManager.curHand == 0;
                    return _buildCircularAvatar(isPlayerTurn);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: decoration,
              child: TabCard(
                titlePadding: const EdgeInsets.only(top: 10, bottom: 10),
                titles: [
                  Text(context.l10n.currentInfo),
                  Text(context.l10n.manual),
                ],
                bodies: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(gamer.manual.event),
                        Text(
                          '${gamer.manual.red} (${gamer.manual.chineseResult}) ${gamer.manual.black}',
                        ),
                        Text(
                          gamer.manual.ecco.isEmpty
                              ? ''
                              : '${gamer.manual.opening}(${gamer.manual.ecco})',
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Table(
                      border: null,
                      columnWidths: const {
                        0: IntrinsicColumnWidth(),
                        1: FlexColumnWidth(),
                      },
                      defaultVerticalAlignment: TableCellVerticalAlignment.top,
                      children: [
                        TableRow(
                          children: [
                            Text(context.l10n.theEvent),
                            Text(gamer.manual.event),
                          ],
                        ),
                        TableRow(
                          children: [
                            Text(context.l10n.theSite),
                            Text(gamer.manual.site),
                          ],
                        ),
                        TableRow(
                          children: [
                            Text(context.l10n.theDate),
                            Text(gamer.manual.date),
                          ],
                        ),
                        TableRow(
                          children: [
                            Text(context.l10n.theRound),
                            Text(gamer.manual.round),
                          ],
                        ),
                        TableRow(
                          children: [
                            Text(context.l10n.theRed),
                            Text(
                              '${gamer.manual.redTeam}/${gamer.manual.red}',
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Text(context.l10n.theBlack),
                            Text(
                              '${gamer.manual.blackTeam}/${gamer.manual.black}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build circular avatar with countdown highlight
  Widget _buildCircularAvatar(bool isPlayerTurn) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isPlayerTurn ? Colors.green : Colors.grey.shade300, // Green highlight
          width: isPlayerTurn ? 3.0 : 2.0,
        ),
        boxShadow: isPlayerTurn ? [
          BoxShadow(
            color: Colors.green.withOpacity(0.3), // Green glow
            blurRadius: 6.0,
            spreadRadius: 1.0,
          ),
        ] : null,
      ),
      child: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.grey.shade200,
        child: Icon(
          Icons.person,
          size: 24,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  /// Build player name/ID box
  Widget _buildPlayerNameBox(String playerName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF8B4513), // Brown color like in screenshot
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF654321), width: 1),
      ),
      child: Text(
        playerName.isEmpty ? 'Anonymous' : playerName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Build timer box
  Widget _buildTimerBox(ChessTimer timer, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
            blurRadius: 3.0,
            spreadRadius: 0.5,
          ),
        ] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: isActive ? Colors.orange : Colors.white70,
            size: 14,
          ),
          const SizedBox(width: 3),
          Text(
            timer.formattedTime,
            style: TextStyle(
              color: isActive ? Colors.orange : Colors.white,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              fontFamily: 'Roboto Mono',
            ),
          ),
        ],
      ),
    );
  }
}
