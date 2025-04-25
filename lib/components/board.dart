import 'package:flutter/material.dart';

import '../models/game_manager.dart';
import '../models/game_event.dart';
import '../widgets/game_wrapper.dart';

/// 棋盘
class Board extends StatefulWidget {
  const Board({super.key});

  @override
  State<Board> createState() => BoardState();
}

class BoardState extends State<Board> {
  late GameManager gamer;
  bool isInit = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, initGamer);
  }

  void initGamer() {
    if (isInit) return;
    isInit = true;

    GameWrapperState? gameWrapper = context.findAncestorStateOfType<GameWrapperState>();
    if (gameWrapper == null) return;

    gamer = gameWrapper.gamer;
    // Listen for game load events which are triggered when skin changes
    gamer.on<GameLoadEvent>(_onGameLoad);
  }

  void _onGameLoad(GameEvent event) {
    // Refresh the board when the game is loaded (including skin changes)
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    if (isInit) {
      gamer.off<GameLoadEvent>(_onGameLoad);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInit) {
      GameWrapperState? gameWrapper = context.findAncestorStateOfType<GameWrapperState>();
      if (gameWrapper != null) {
        gamer = gameWrapper.gamer;
      } else {
        return const SizedBox();
      }
    }

    return SizedBox(
      width: gamer.skin.width,
      height: gamer.skin.height,
      child: Image.asset(gamer.skin.boardImage),
    );
  }
}
