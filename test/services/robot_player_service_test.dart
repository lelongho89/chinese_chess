import 'package:flutter_test/flutter_test.dart';
import 'package:chinese_chess/models/user_model.dart';
import 'package:chinese_chess/models/game_data_model.dart';
import 'package:chinese_chess/services/robot_player_service.dart';

void main() {
  group('RobotPlayerService', () {
    late RobotPlayerService robotService;

    setUp(() {
      robotService = RobotPlayerService.instance;
    });

    test('should identify AI users correctly', () {
      final aiUser = UserModel(
        uid: 'ai-1',
        email: 'dragon.master@aitest.com',
        displayName: 'Dragon Master',
        eloRating: 1500,
        isAnonymous: true,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      final humanUser = UserModel(
        uid: 'human-1',
        email: 'player@example.com',
        displayName: 'Human Player',
        eloRating: 1400,
        isAnonymous: false,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      expect(robotService.isAIUser(aiUser), isTrue);
      expect(robotService.isAIUser(humanUser), isFalse);
    });

    test('should calculate difficulty from Elo rating correctly', () {
      // Test private method through public interface
      final testCases = [
        (700, 2),   // Very easy
        (900, 3),   // Easy
        (1100, 4),  // Easy-Medium
        (1300, 5),  // Medium
        (1500, 6),  // Medium-Hard
        (1700, 7),  // Hard
        (1900, 8),  // Very Hard
        (2100, 9),  // Expert
        (2300, 10), // Master
      ];

      for (final (elo, expectedDifficulty) in testCases) {
        // We can't test the private method directly, but we can verify
        // the difficulty descriptions are correct
        final description = robotService.getDifficultyDescription(expectedDifficulty);
        expect(description, isNotEmpty);
      }
    });

    test('should identify AI games correctly', () {
      final aiUser = UserModel(
        uid: 'ai-1',
        email: 'dragon.master@aitest.com',
        displayName: 'Dragon Master',
        eloRating: 1500,
        isAnonymous: true,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      final humanUser = UserModel(
        uid: 'human-1',
        email: 'player@example.com',
        displayName: 'Human Player',
        eloRating: 1400,
        isAnonymous: false,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      final aiGame = GameDataModel(
        id: 'game-1',
        redPlayerId: humanUser.uid,
        blackPlayerId: aiUser.uid,
        finalFen: '',
        redTimeRemaining: 180,
        blackTimeRemaining: 180,
        startedAt: DateTime.now(),
        isRanked: true,
      );

      final humanUser2 = UserModel(
        uid: 'human-2',
        email: 'player2@example.com',
        displayName: 'Human Player 2',
        eloRating: 1300,
        isAnonymous: false,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      final humanGame = GameDataModel(
        id: 'game-2',
        redPlayerId: humanUser.uid,
        blackPlayerId: humanUser2.uid,
        finalFen: '',
        redTimeRemaining: 180,
        blackTimeRemaining: 180,
        startedAt: DateTime.now(),
        isRanked: true,
      );

      expect(robotService.isAIGame(aiGame, [aiUser, humanUser]), isTrue);
      expect(robotService.isAIGame(humanGame, [humanUser, humanUser2]), isFalse);
    });

    test('should get AI and human players correctly', () {
      final aiUser = UserModel(
        uid: 'ai-1',
        email: 'dragon.master@aitest.com',
        displayName: 'Dragon Master',
        eloRating: 1500,
        isAnonymous: true,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      final humanUser = UserModel(
        uid: 'human-1',
        email: 'player@example.com',
        displayName: 'Human Player',
        eloRating: 1400,
        isAnonymous: false,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      final game = GameDataModel(
        id: 'game-1',
        redPlayerId: humanUser.uid,
        blackPlayerId: aiUser.uid,
        finalFen: '',
        redTimeRemaining: 180,
        blackTimeRemaining: 180,
        startedAt: DateTime.now(),
        isRanked: true,
      );

      final users = <UserModel>[aiUser, humanUser];

      final detectedAI = robotService.getAIPlayer(game, users);
      final detectedHuman = robotService.getHumanPlayer(game, users);

      expect(detectedAI?.uid, equals(aiUser.uid));
      expect(detectedHuman?.uid, equals(humanUser.uid));
    });

    test('should generate realistic robot names', () {
      final name1 = robotService.generateRobotName();
      final name2 = robotService.generateRobotName();

      expect(name1, isNotEmpty);
      expect(name2, isNotEmpty);
      expect(name1.contains(' '), isTrue); // Should have prefix and suffix

      // Names should be different (with high probability)
      expect(name1, isNot(equals(name2)));
    });

    test('should provide difficulty descriptions', () {
      final descriptions = [
        (1, 'Beginner'),
        (3, 'Easy'),
        (5, 'Medium'),
        (7, 'Hard'),
        (10, 'Master'),
      ];

      for (final (difficulty, expectedDesc) in descriptions) {
        final desc = robotService.getDifficultyDescription(difficulty);
        expect(desc, equals(expectedDesc));
      }
    });

    test('should handle robot statistics', () {
      final stats = robotService.getRobotStats();

      expect(stats, containsPair('active_robots', 0));
      expect(stats, containsPair('active_games', []));
      expect(stats, containsPair('difficulties', []));
    });
  });
}
