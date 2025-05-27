import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'chess.dart';
import 'play_step.dart';
import 'play_single_player.dart';
import 'play_bot.dart';
import 'play_player.dart';
import '../global.dart';
import '../widgets/tab_card.dart';
import '../models/game_manager.dart';
import '../models/game_timer_manager.dart';
import '../models/play_mode.dart';
import '../driver/player_driver.dart';

/// 游戏布局框
class PlayPage extends StatefulWidget {
  final PlayMode mode;

  const PlayPage({super.key, required this.mode});

  @override
  State<StatefulWidget> createState() => PlayPageState();
}

class PlayPageState extends State<PlayPage> {
  final GameManager gamer = GameManager.instance;
  late final GameTimerManager timerManager;
  bool inited = false;
  bool isInitializing = true;

  @override
  void initState() {
    super.initState();
    initGame();
  }

  void _checkRedTimer() {
    if (timerManager.redTimer.isExpired) {
      // Red player lost on time
      gamer.handleTimeExpired(0);
    }
  }

  void _checkBlackTimer() {
    if (timerManager.blackTimer.isExpired) {
      // Black player lost on time
      gamer.handleTimeExpired(1);
    }
  }

  void initGame() async {
    logger.info('PlayPage: 初始化游戏 $inited');
    if (inited) return;

    try {
      logger.info('PlayPage: Ensuring GameManager is initialized...');
      // Ensure GameManager is initialized first
      final initResult = await gamer.init();
      logger.info('PlayPage: GameManager init result: $initResult');
      if (!initResult) {
        throw Exception('GameManager initialization failed');
      }

      logger.info('PlayPage: Creating timer manager...');
      // Initialize the timer manager after GameManager is ready
      timerManager = GameTimerManager(
        gameManager: gamer,
        initialTimeSeconds: 180, // 3 minutes
        incrementSeconds: 2,     // 2 seconds per move
      );

      logger.info('PlayPage: Setting up timer listeners...');
      // Listen for timer expiration
      timerManager.redTimer.addListener(_checkRedTimer);
      timerManager.blackTimer.addListener(_checkBlackTimer);

      logger.info('PlayPage: Starting new game...');
      inited = true;

      // Enable timer before starting new game
      timerManager.enabled = true;

      // Start new game (this will set curHand and trigger events)
      gamer.newGame(amyType: DriverType.robot);

      logger.info('PlayPage: Starting timers...');
      // Start new game for timer manager (this will start the active timer)
      timerManager.startNewGame();

      logger.info('PlayPage: Initialization complete, updating UI...');
      // Update UI state
      if (mounted) {
        setState(() {
          isInitializing = false;
        });
      }
    } catch (e) {
      logger.severe('PlayPage: Error initializing game: $e');
      if (mounted) {
        setState(() {
          isInitializing = false;
        });
        // Show error message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize game: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Clean up timer listeners if initialized
    if (inited) {
      timerManager.redTimer.removeListener(_checkRedTimer);
      timerManager.blackTimer.removeListener(_checkBlackTimer);
      timerManager.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isInitializing) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return MediaQuery.of(context).size.width < 980
        ? _mobileContainer()
        : _windowContainer();
  }

  Widget _mobileContainer() {
    return ChangeNotifierProvider.value(
      value: timerManager,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Black player info with timer
          const PlaySinglePlayer(
            team: 1,
          ),

          // Chess board
          RepaintBoundary(
            child: SizedBox(
              width: gamer.skin.width * gamer.scale,
              height: gamer.skin.height * gamer.scale,
              child: const Chess(),
            ),
          ),

          // Red player info with timer
          const PlaySinglePlayer(
            team: 0,
            placeAt: Alignment.bottomCenter,
          ),
        ],
      ),
    );
  }

  Widget _windowContainer() {
    BoxDecoration decoration = BoxDecoration(
      border: Border.all(color: Colors.grey, width: 0.5),
      borderRadius: const BorderRadius.all(Radius.circular(2)),
    );
    return SizedBox(
      width: 980,
      height: 577,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          // Chess board
          RepaintBoundary(
            child: const SizedBox(
              width: 521,
              child: Chess(),
            ),
          ),

          // Right panel
          Container(
            width: 439,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(2)),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, .1),
                  offset: Offset(1, 1),
                  blurRadius: 1.0,
                  spreadRadius: 1.0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Player info and timer
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Player info with timers
                      ChangeNotifierProvider.value(
                        value: timerManager,
                        child: const PlayPlayer(),
                      ),
                      const SizedBox(width: 10),

                      // Game steps
                      Expanded(
                        child: PlayStep(
                          decoration: decoration,
                          width: 180,
                        ),
                      ),
                    ],
                  ),
                ),

                // Bot recommendations and remarks
                const SizedBox(height: 10),
                Container(
                  height: 180,
                  decoration: decoration,
                  child: TabCard(
                    titleFit: FlexFit.tight,
                    titlePadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 30,
                    ),
                    titles: [
                      Text(context.l10n.recommendMove),
                      Text(context.l10n.remark),
                    ],
                    bodies: [
                      const PlayBot(),
                      Center(
                        child: Text(context.l10n.noRemark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
