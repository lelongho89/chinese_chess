import 'package:cchess/cchess.dart';
import 'package:flutter/material.dart';

import '../global.dart';
import '../models/game_manager.dart';
import '../widgets/game_wrapper.dart';

/// 棋子
class Piece extends StatelessWidget {
  final ChessItem item;
  final bool isActive;
  final bool isAblePoint;
  final bool isHover;

  const Piece({
    super.key,
    required this.item,
    this.isActive = false,
    this.isHover = false,
    this.isAblePoint = false,
  });

  Widget blankWidget(GameManager gamer) {
    double size = gamer.skin.size;

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: Colors.transparent),
    );
  }

  @override
  Widget build(BuildContext context) {
    GameWrapperState? gameWrapper = context.findAncestorStateOfType<GameWrapperState>();
    GameManager gamer = gameWrapper?.gamer ?? GameManager.instance;
    String team = item.team == 0 ? 'r' : 'b';

    return item.isBlank
        ? blankWidget(gamer)
        : AnimatedContainer(
            width: gamer.skin.size * gamer.scale,
            height: gamer.skin.size * gamer.scale,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutQuint,
            transform: isHover
                ? (Matrix4.translationValues(-4, -4, -4))
                : (Matrix4.translationValues(0, 0, 0)),
            transformAlignment: Alignment.topCenter,
            decoration: (isHover)
                ? BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, .1),
                        offset: Offset(2, 3),
                        blurRadius: 1,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, .1),
                        offset: Offset(4, 6),
                        blurRadius: 2,
                        spreadRadius: 2,
                      ),
                    ],
                    //border: Border.all(color: Color.fromRGBO(255, 255, 255, .7), width: 2),
                    borderRadius: BorderRadius.all(
                      Radius.circular(gamer.skin.size / 2),
                    ),
                  )
                : BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, .2),
                        offset: Offset(2, 2),
                        blurRadius: 1,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, .1),
                        offset: Offset(3, 3),
                        blurRadius: 1,
                        spreadRadius: 1,
                      ),
                    ],
                    border: isActive
                        ? Border.all(
                            color: Colors.white54,
                            width: 2,
                            style: BorderStyle.solid,
                          )
                        : null,
                    borderRadius: BorderRadius.all(
                      Radius.circular(gamer.skin.size / 2),
                    ),
                  ),
            child: Stack(
              children: [
                Image.asset(
                  team == 'r'
                      ? gamer.skin.getRedChess(item.code)
                      : gamer.skin.getBlackChess(item.code),
                  errorBuilder: (context, error, stackTrace) {
                    logger.warning('Failed to load chess piece image: $error');
                    return Container(
                      width: gamer.skin.size,
                      height: gamer.skin.size,
                      decoration: BoxDecoration(
                        color: team == 'r' ? Colors.red.shade100 : Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(gamer.skin.size / 2),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: Center(
                        child: Text(
                          item.code.toUpperCase(),
                          style: TextStyle(
                            color: team == 'r' ? Colors.red.shade800 : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: gamer.skin.size * 0.3,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
  }
}
