import 'package:flutter/material.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

import '../global.dart';
import '../game_board.dart';
import '../models/game_manager.dart';
import '../models/play_mode.dart';
import '../services/match_invitation_handler.dart';
import 'play_step.dart';

class GameBottomBar extends StatefulWidget {
  final PlayMode mode;

  const GameBottomBar(this.mode, {super.key});

  @override
  State<GameBottomBar> createState() => GameBottomBarState();
}

class GameBottomBarState extends State<GameBottomBar> {
  final GameManager gamer = GameManager.instance;

  @override
  Widget build(BuildContext context) {
    if (widget.mode == PlayMode.modeRobot) {
      return robotBottomBar();
    }
    if (widget.mode == PlayMode.modeOnline) {
      return onlineBottomBar();
    }

    return freeBottomBar();
  }

  void _showStepList() {
    final size = MediaQuery.of(context).size;
    MyDialog.popup(
      SizedBox(
        height: size.height * 0.75,
        child: Center(
          child: PlayStep(
            width: size.width * 0.8,
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showCode() {}

  void _doReply() {}

  void _showQRCodeGenerator() {
    MatchInvitationHandler.instance.showQRGenerator(context, metadata: {
      'isRanked': true,
      'gameType': 'standard',
    });
  }

  void _goPrev() {
    if (gamer.currentStep < 1) return;
    gamer.loadHistory(gamer.currentStep - 1);
    setState(() {});
  }

  void _goNext() {
    if (gamer.currentStep + 1 >= gamer.stepCount) return;
    gamer.loadHistory(gamer.currentStep + 1);
    setState(() {});
  }

  void _quitGame() {
    MyDialog.confirm(
      context.l10n.exitNow,
      buttonText: context.l10n.yesExit,
      cancelText: context.l10n.dontExit,
    ).then((confirmed) {
      if (confirmed ?? false) {
        // Stop the current game
        gamer.stop();

        // Navigate back to the main screen instead of showing mode selection
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }

  Widget freeBottomBar() {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(icon: const Icon(Icons.list), onPressed: _showStepList),
          IconButton(icon: const Icon(Icons.code), onPressed: _showCode),
          IconButton(
            icon: const Icon(Icons.navigate_before),
            onPressed: _goPrev,
          ),
          IconButton(icon: const Icon(Icons.navigate_next), onPressed: _goNext),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: context.l10n.quitGame,
            onPressed: _quitGame,
          ),
        ],
      ),
    );
  }

  Widget onlineBottomBar() {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(icon: const Icon(Icons.list), onPressed: _showStepList),
          IconButton(icon: const Icon(Icons.replay), onPressed: _doReply),
          IconButton(
            icon: const Icon(Icons.qr_code),
            tooltip: context.l10n.inviteFriend,
            onPressed: _showQRCodeGenerator,
          ),
          IconButton(
            icon: const Icon(Icons.navigate_before),
            onPressed: _goPrev,
          ),
          IconButton(icon: const Icon(Icons.navigate_next), onPressed: _goNext),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: context.l10n.quitGame,
            onPressed: _quitGame,
          ),
        ],
      ),
    );
  }

  Widget robotBottomBar() {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(icon: const Icon(Icons.list), onPressed: _showStepList),
          IconButton(icon: const Icon(Icons.replay), onPressed: _doReply),
          IconButton(
            icon: const Icon(Icons.navigate_before),
            onPressed: _goPrev,
          ),
          IconButton(icon: const Icon(Icons.navigate_next), onPressed: _goNext),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: context.l10n.quitGame,
            onPressed: _quitGame,
          ),
        ],
      ),
    );
  }
}
