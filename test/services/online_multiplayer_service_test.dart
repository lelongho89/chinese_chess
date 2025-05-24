import 'package:flutter_test/flutter_test.dart';

import 'package:chinese_chess/models/game_move_model.dart';
import 'package:chinese_chess/models/game_data_model.dart';

void main() {
  group('OnlineMultiplayerService Logic Tests', () {
    group('GameMoveModel', () {
      test('should create GameMoveModel with correct properties', () {
        final move = GameMoveModel(
          id: 'move1',
          gameId: 'game1',
          playerId: 'player1',
          moveNumber: 1,
          moveNotation: 'e2e4',
          fenAfterMove: 'rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR',
          timeRemaining: 180,
          moveTime: 5000,
          isCheck: false,
          isCheckmate: false,
          createdAt: DateTime.now(),
        );

        expect(move.id, equals('move1'));
        expect(move.gameId, equals('game1'));
        expect(move.playerId, equals('player1'));
        expect(move.moveNumber, equals(1));
        expect(move.moveNotation, equals('e2e4'));
        expect(move.timeRemaining, equals(180));
        expect(move.moveTime, equals(5000));
        expect(move.isCheck, isFalse);
        expect(move.isCheckmate, isFalse);
      });

      test('should determine player color correctly', () {
        final redMove = GameMoveModel(
          id: 'move1',
          gameId: 'game1',
          playerId: 'player1',
          moveNumber: 1, // Odd move number = red player
          moveNotation: 'e2e4',
          fenAfterMove: 'test',
          timeRemaining: 180,
          moveTime: 5000,
          createdAt: DateTime.now(),
        );

        final blackMove = GameMoveModel(
          id: 'move2',
          gameId: 'game1',
          playerId: 'player2',
          moveNumber: 2, // Even move number = black player
          moveNotation: 'e7e5',
          fenAfterMove: 'test',
          timeRemaining: 175,
          moveTime: 3000,
          createdAt: DateTime.now(),
        );

        expect(redMove.isRedMove, isTrue);
        expect(redMove.isBlackMove, isFalse);
        expect(redMove.playerColor, equals(0));

        expect(blackMove.isRedMove, isFalse);
        expect(blackMove.isBlackMove, isTrue);
        expect(blackMove.playerColor, equals(1));
      });

      test('should format time correctly', () {
        final move = GameMoveModel(
          id: 'move1',
          gameId: 'game1',
          playerId: 'player1',
          moveNumber: 1,
          moveNotation: 'e2e4',
          fenAfterMove: 'test',
          timeRemaining: 125, // 2:05
          moveTime: 5500, // 5.5 seconds
          createdAt: DateTime.now(),
        );

        expect(move.formattedTimeRemaining, equals('2:05'));
        expect(move.formattedMoveTime, equals('5.5s'));
      });

      test('should format move time for different durations', () {
        final fastMove = GameMoveModel(
          id: 'move1',
          gameId: 'game1',
          playerId: 'player1',
          moveNumber: 1,
          moveNotation: 'e2e4',
          fenAfterMove: 'test',
          timeRemaining: 180,
          moveTime: 500, // 500ms
          createdAt: DateTime.now(),
        );

        final slowMove = GameMoveModel(
          id: 'move2',
          gameId: 'game1',
          playerId: 'player1',
          moveNumber: 2,
          moveNotation: 'e7e5',
          fenAfterMove: 'test',
          timeRemaining: 180,
          moveTime: 65000, // 1m 5s
          createdAt: DateTime.now(),
        );

        expect(fastMove.formattedMoveTime, equals('500ms'));
        expect(slowMove.formattedMoveTime, equals('1m 5.0s'));
      });

      test('should create description correctly', () {
        final redMove = GameMoveModel(
          id: 'move1',
          gameId: 'game1',
          playerId: 'player1',
          moveNumber: 1,
          moveNotation: 'e2e4',
          fenAfterMove: 'test',
          timeRemaining: 180,
          moveTime: 5000,
          isCheck: true,
          createdAt: DateTime.now(),
        );

        final blackCheckmateMove = GameMoveModel(
          id: 'move2',
          gameId: 'game1',
          playerId: 'player2',
          moveNumber: 2,
          moveNotation: 'h8h1',
          fenAfterMove: 'test',
          timeRemaining: 175,
          moveTime: 3000,
          isCheckmate: true,
          createdAt: DateTime.now(),
        );

        expect(redMove.description, equals('Red: e2e4 (Check)'));
        expect(blackCheckmateMove.description, equals('Black: h8h1 (Checkmate)'));
      });
    });

    group('PlayerConnectionStatus', () {
      test('should create with default connected status', () {
        final status = PlayerConnectionStatus();

        expect(status.red, equals(ConnectionStatus.connected));
        expect(status.black, equals(ConnectionStatus.connected));
        expect(status.bothConnected, isTrue);
        expect(status.anyDisconnected, isFalse);
        expect(status.anyReconnecting, isFalse);
      });

      test('should detect disconnected players', () {
        final status = PlayerConnectionStatus(
          red: ConnectionStatus.disconnected,
          black: ConnectionStatus.connected,
        );

        expect(status.bothConnected, isFalse);
        expect(status.anyDisconnected, isTrue);
        expect(status.anyReconnecting, isFalse);
      });

      test('should detect reconnecting players', () {
        final status = PlayerConnectionStatus(
          red: ConnectionStatus.connected,
          black: ConnectionStatus.reconnecting,
        );

        expect(status.bothConnected, isFalse);
        expect(status.anyDisconnected, isFalse);
        expect(status.anyReconnecting, isTrue);
      });

      test('should serialize to and from JSON correctly', () {
        final originalStatus = PlayerConnectionStatus(
          red: ConnectionStatus.disconnected,
          black: ConnectionStatus.reconnecting,
        );

        final json = originalStatus.toJson();
        final deserializedStatus = PlayerConnectionStatus.fromJson(json);

        expect(deserializedStatus.red, equals(ConnectionStatus.disconnected));
        expect(deserializedStatus.black, equals(ConnectionStatus.reconnecting));
      });

      test('should copy with new values', () {
        final originalStatus = PlayerConnectionStatus(
          red: ConnectionStatus.connected,
          black: ConnectionStatus.connected,
        );

        final updatedStatus = originalStatus.copyWith(
          red: ConnectionStatus.disconnected,
        );

        expect(updatedStatus.red, equals(ConnectionStatus.disconnected));
        expect(updatedStatus.black, equals(ConnectionStatus.connected));
        expect(originalStatus.red, equals(ConnectionStatus.connected)); // Original unchanged
      });
    });

    group('GameStatus', () {
      test('should have correct display names', () {
        expect(GameStatus.active.displayName, equals('Active'));
        expect(GameStatus.paused.displayName, equals('Paused'));
        expect(GameStatus.ended.displayName, equals('Ended'));
        expect(GameStatus.abandoned.displayName, equals('Abandoned'));
      });

      test('should have correct state checks', () {
        expect(GameStatus.active.isActive, isTrue);
        expect(GameStatus.active.isEnded, isFalse);
        expect(GameStatus.active.isFinished, isFalse);

        expect(GameStatus.paused.isPaused, isTrue);
        expect(GameStatus.paused.isFinished, isFalse);

        expect(GameStatus.ended.isEnded, isTrue);
        expect(GameStatus.ended.isFinished, isTrue);

        expect(GameStatus.abandoned.isAbandoned, isTrue);
        expect(GameStatus.abandoned.isFinished, isTrue);
      });

      test('should parse from string correctly', () {
        expect(parseGameStatus('active'), equals(GameStatus.active));
        expect(parseGameStatus('paused'), equals(GameStatus.paused));
        expect(parseGameStatus('ended'), equals(GameStatus.ended));
        expect(parseGameStatus('abandoned'), equals(GameStatus.abandoned));
        expect(parseGameStatus('invalid'), equals(GameStatus.active)); // Default
        expect(parseGameStatus(null), equals(GameStatus.active)); // Default
      });
    });

    group('GameDataModel Real-time Extensions', () {
      test('should determine current player correctly', () {
        final game = GameDataModel(
          id: 'game1',
          redPlayerId: 'player1',
          blackPlayerId: 'player2',
          finalFen: 'test',
          redTimeRemaining: 180,
          blackTimeRemaining: 180,
          startedAt: DateTime.now(),
          currentPlayer: 0, // Red's turn
        );

        expect(game.isRedTurn, isTrue);
        expect(game.isBlackTurn, isFalse);
        expect(game.currentPlayerName, equals('Red'));
        expect(game.isPlayerTurn('player1'), isTrue);
        expect(game.isPlayerTurn('player2'), isFalse);
      });

      test('should get opponent ID correctly', () {
        final game = GameDataModel(
          id: 'game1',
          redPlayerId: 'player1',
          blackPlayerId: 'player2',
          finalFen: 'test',
          redTimeRemaining: 180,
          blackTimeRemaining: 180,
          startedAt: DateTime.now(),
        );

        expect(game.getOpponentId('player1'), equals('player2'));
        expect(game.getOpponentId('player2'), equals('player1'));
        expect(game.getOpponentId('player3'), isNull);
      });

      test('should check connection status correctly', () {
        final connectedGame = GameDataModel(
          id: 'game1',
          redPlayerId: 'player1',
          blackPlayerId: 'player2',
          finalFen: 'test',
          redTimeRemaining: 180,
          blackTimeRemaining: 180,
          startedAt: DateTime.now(),
          connectionStatus: PlayerConnectionStatus(
            red: ConnectionStatus.connected,
            black: ConnectionStatus.connected,
          ),
        );

        final disconnectedGame = GameDataModel(
          id: 'game2',
          redPlayerId: 'player1',
          blackPlayerId: 'player2',
          finalFen: 'test',
          redTimeRemaining: 180,
          blackTimeRemaining: 180,
          startedAt: DateTime.now(),
          connectionStatus: PlayerConnectionStatus(
            red: ConnectionStatus.disconnected,
            black: ConnectionStatus.connected,
          ),
        );

        expect(connectedGame.bothPlayersConnected, isTrue);
        expect(connectedGame.anyPlayerDisconnected, isFalse);

        expect(disconnectedGame.bothPlayersConnected, isFalse);
        expect(disconnectedGame.anyPlayerDisconnected, isTrue);
      });

      test('should check game status correctly', () {
        final activeGame = GameDataModel(
          id: 'game1',
          redPlayerId: 'player1',
          blackPlayerId: 'player2',
          finalFen: 'test',
          redTimeRemaining: 180,
          blackTimeRemaining: 180,
          startedAt: DateTime.now(),
          gameStatus: GameStatus.active,
        );

        final endedGame = GameDataModel(
          id: 'game2',
          redPlayerId: 'player1',
          blackPlayerId: 'player2',
          finalFen: 'test',
          redTimeRemaining: 180,
          blackTimeRemaining: 180,
          startedAt: DateTime.now(),
          gameStatus: GameStatus.ended,
        );

        expect(activeGame.isActive, isTrue);
        expect(activeGame.isEnded, isFalse);

        expect(endedGame.isActive, isFalse);
        expect(endedGame.isEnded, isTrue);
      });
    });
  });
}
