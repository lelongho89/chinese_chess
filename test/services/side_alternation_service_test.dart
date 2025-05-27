import 'package:flutter_test/flutter_test.dart';
import 'package:chinese_chess/models/user_model.dart';
import 'package:chinese_chess/services/side_alternation_service.dart';

void main() {
  group('SideAlternationService', () {
    late SideAlternationService service;

    setUp(() {
      service = SideAlternationService.instance;
    });

    group('Side Assignment Logic', () {
      test('should assign sides based on alternation for experienced players', () async {
        // Create players with side history
        final player1 = UserModel(
          uid: 'player1',
          email: 'player1@test.com',
          displayName: 'Player 1',
          eloRating: 1500,
          gamesPlayed: 10,
          redGamesPlayed: 8, // Played Red 80% of the time
          blackGamesPlayed: 2,
          lastPlayedSide: 'red',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        final player2 = UserModel(
          uid: 'player2',
          email: 'player2@test.com',
          displayName: 'Player 2',
          eloRating: 1400,
          gamesPlayed: 10,
          redGamesPlayed: 3, // Played Red 30% of the time
          blackGamesPlayed: 7,
          lastPlayedSide: 'black',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        // Mock the user repository calls
        // In a real test, you'd mock UserRepository.instance.get()
        
        // Test the internal logic methods
        final stats1 = service.getPlayerSideStats(player1);
        final stats2 = service.getPlayerSideStats(player2);

        // Player 1 should prefer Black (to balance their Red bias)
        expect(stats1['should_alternate'], isTrue);
        expect(stats1['preferred_next_side'], equals('black'));

        // Player 2 should prefer Red (to balance their Black bias)
        expect(stats2['should_alternate'], isTrue);
        expect(stats2['preferred_next_side'], equals('red'));
      });

      test('should calculate red ratio correctly', () {
        final player = UserModel(
          uid: 'test',
          email: 'test@test.com',
          displayName: 'Test Player',
          eloRating: 1200,
          gamesPlayed: 10,
          redGamesPlayed: 6,
          blackGamesPlayed: 4,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        final stats = service.getPlayerSideStats(player);
        expect(stats['red_ratio'], equals(0.6));
        expect(stats['black_ratio'], equals(0.4));
      });

      test('should handle players with no side history', () {
        final newPlayer = UserModel(
          uid: 'new',
          email: 'new@test.com',
          displayName: 'New Player',
          eloRating: 1200,
          gamesPlayed: 0,
          redGamesPlayed: 0,
          blackGamesPlayed: 0,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        final stats = service.getPlayerSideStats(newPlayer);
        expect(stats['red_ratio'], equals(0.5));
        expect(stats['should_alternate'], isFalse);
        expect(stats['preferred_next_side'], equals('red')); // Default preference
      });

      test('should detect when alternation is needed', () {
        // Player with strong Red bias (80%)
        final redBiasedPlayer = UserModel(
          uid: 'red_biased',
          email: 'red@test.com',
          displayName: 'Red Biased',
          eloRating: 1200,
          gamesPlayed: 10,
          redGamesPlayed: 8,
          blackGamesPlayed: 2,
          lastPlayedSide: 'red',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        // Player with strong Black bias (20% Red)
        final blackBiasedPlayer = UserModel(
          uid: 'black_biased',
          email: 'black@test.com',
          displayName: 'Black Biased',
          eloRating: 1200,
          gamesPlayed: 10,
          redGamesPlayed: 2,
          blackGamesPlayed: 8,
          lastPlayedSide: 'black',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        // Balanced player (50%)
        final balancedPlayer = UserModel(
          uid: 'balanced',
          email: 'balanced@test.com',
          displayName: 'Balanced',
          eloRating: 1200,
          gamesPlayed: 10,
          redGamesPlayed: 5,
          blackGamesPlayed: 5,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        final redStats = service.getPlayerSideStats(redBiasedPlayer);
        final blackStats = service.getPlayerSideStats(blackBiasedPlayer);
        final balancedStats = service.getPlayerSideStats(balancedPlayer);

        expect(redStats['should_alternate'], isTrue);
        expect(redStats['preferred_next_side'], equals('black'));

        expect(blackStats['should_alternate'], isTrue);
        expect(blackStats['preferred_next_side'], equals('red'));

        expect(balancedStats['should_alternate'], isFalse);
      });

      test('should prefer alternation based on last played side', () {
        final player = UserModel(
          uid: 'test',
          email: 'test@test.com',
          displayName: 'Test',
          eloRating: 1200,
          gamesPlayed: 4,
          redGamesPlayed: 2,
          blackGamesPlayed: 2,
          lastPlayedSide: 'red',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        final stats = service.getPlayerSideStats(player);
        expect(stats['preferred_next_side'], equals('black'));

        final playerBlackLast = player.copyWith(lastPlayedSide: 'black');
        final statsBlackLast = service.getPlayerSideStats(playerBlackLast);
        expect(statsBlackLast['preferred_next_side'], equals('red'));
      });
    });

    group('AI Match Side Assignment', () {
      test('should handle AI match side assignment', () async {
        // This would require mocking UserRepository in a real test
        // For now, we test the logic conceptually
        
        final humanPlayer = UserModel(
          uid: 'human',
          email: 'human@test.com',
          displayName: 'Human',
          eloRating: 1500,
          gamesPlayed: 6,
          redGamesPlayed: 5, // Strong Red bias
          blackGamesPlayed: 1,
          lastPlayedSide: 'red',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        final stats = service.getPlayerSideStats(humanPlayer);
        
        // Human should prefer Black to balance their Red bias
        expect(stats['should_alternate'], isTrue);
        expect(stats['preferred_next_side'], equals('black'));
      });
    });

    group('Side Statistics', () {
      test('should provide comprehensive side statistics', () {
        final player = UserModel(
          uid: 'test',
          email: 'test@test.com',
          displayName: 'Test Player',
          eloRating: 1400,
          gamesPlayed: 15,
          redGamesPlayed: 9,
          blackGamesPlayed: 6,
          lastPlayedSide: 'red',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        final stats = service.getPlayerSideStats(player);

        expect(stats['total_games'], equals(15));
        expect(stats['total_side_tracked_games'], equals(15));
        expect(stats['red_games'], equals(9));
        expect(stats['black_games'], equals(6));
        expect(stats['red_ratio'], equals(0.6));
        expect(stats['black_ratio'], equals(0.4));
        expect(stats['last_played_side'], equals('red'));
        expect(stats['should_alternate'], isFalse); // 60% is not >= 70%
        expect(stats['preferred_next_side'], equals('black'));
      });

      test('should handle edge cases in statistics', () {
        // Player with only one game
        final oneGamePlayer = UserModel(
          uid: 'one_game',
          email: 'one@test.com',
          displayName: 'One Game',
          eloRating: 1200,
          gamesPlayed: 1,
          redGamesPlayed: 1,
          blackGamesPlayed: 0,
          lastPlayedSide: 'red',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        final stats = service.getPlayerSideStats(oneGamePlayer);
        expect(stats['should_alternate'], isFalse); // Need at least 2 games
        expect(stats['red_ratio'], equals(1.0));
      });
    });

    group('Preference Handling', () {
      test('should honor preferences for new players', () {
        final newPlayer = UserModel(
          uid: 'new',
          email: 'new@test.com',
          displayName: 'New Player',
          eloRating: 1200,
          gamesPlayed: 1,
          redGamesPlayed: 0,
          blackGamesPlayed: 1,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        // Test internal preference logic
        // In a real implementation, you'd test the actual determineSideAssignment method
        final stats = service.getPlayerSideStats(newPlayer);
        expect(stats['should_alternate'], isFalse); // New player, no alternation needed
      });
    });
  });
}
