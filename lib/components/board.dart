import 'package:flutter/material.dart';

import '../global.dart';
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

    // Check if gamer is properly initialized before accessing skin
    if (!gamer.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SizedBox(
      width: gamer.skin.width,
      height: gamer.skin.height,
      child: Image.asset(
        gamer.skin.boardImage,
        errorBuilder: (context, error, stackTrace) {
          logger.warning('Failed to load board image: $error');
          return Container(
            width: gamer.skin.width,
            height: gamer.skin.height,
            decoration: BoxDecoration(
              color: Colors.brown.shade100,
              border: Border.all(color: Colors.brown.shade800, width: 2),
            ),
            child: CustomPaint(
              painter: _FallbackBoardPainter(),
            ),
          );
        },
      ),
    );
  }
}

/// Fallback board painter when board image fails to load
class _FallbackBoardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.shade800
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw grid lines
    const rows = 10;
    const cols = 9;

    for (int i = 0; i <= rows; i++) {
      final y = (size.height / rows) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    for (int i = 0; i <= cols; i++) {
      final x = (size.width / cols) * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw river text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '楚河 汉界',
        style: TextStyle(
          color: Colors.brown,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
