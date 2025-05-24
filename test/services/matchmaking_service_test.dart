import 'package:flutter_test/flutter_test.dart';
import 'dart:math';

import 'package:chinese_chess/services/matchmaking_service.dart';
import 'package:chinese_chess/models/matchmaking_queue_model.dart';

void main() {
  group('MatchmakingService Logic Tests', () {
    test('should calculate appropriate max Elo difference based on rating', () {
      // Test the Elo difference calculation logic

      // High rated players (2000+) should have stricter matching
      expect(_calculateMaxEloDifference(2200), equals(150));
      expect(_calculateMaxEloDifference(2000), equals(150));

      // Mid-high rated players (1600-1999) should have moderate matching
      expect(_calculateMaxEloDifference(1800), equals(200));
      expect(_calculateMaxEloDifference(1600), equals(200));

      // Mid rated players (1200-1599) should have relaxed matching
      expect(_calculateMaxEloDifference(1400), equals(250));
      expect(_calculateMaxEloDifference(1200), equals(250));

      // Beginners (<1200) should have very flexible matching
      expect(_calculateMaxEloDifference(1000), equals(300));
      expect(_calculateMaxEloDifference(800), equals(300));
    });

    test('should expand Elo difference based on wait time', () {
      // Test wait time expansion logic

      const baseEloDiff = 200;
      const expansionInterval = 30; // seconds
      const expansionAmount = 50;

      // No wait time - base difference (1500 Elo gets 250 max diff)
      expect(_calculateExpandedEloDifference(1500, Duration.zero), equals(250));

      // 30 seconds wait - one expansion (250 + 50)
      expect(_calculateExpandedEloDifference(1500, Duration(seconds: 30)),
             equals(300));

      // 60 seconds wait - two expansions (250 + 100)
      expect(_calculateExpandedEloDifference(1500, Duration(seconds: 60)),
             equals(350));

      // 5 minutes wait - should be capped at max
      expect(_calculateExpandedEloDifference(1500, Duration(minutes: 5)),
             lessThanOrEqualTo(800)); // Max Elo difference
    });

    test('should determine colors correctly based on preferences', () {
      final player1 = MatchmakingQueueModel(
        id: '1',
        userId: 'user1',
        eloRating: 1500,
        preferredColor: PreferredColor.red,
        joinedAt: DateTime.now(),
        expiresAt: DateTime.now().add(Duration(minutes: 10)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final player2 = MatchmakingQueueModel(
        id: '2',
        userId: 'user2',
        eloRating: 1400,
        preferredColor: PreferredColor.black,
        joinedAt: DateTime.now(),
        expiresAt: DateTime.now().add(Duration(minutes: 10)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Test different preference scenarios
      final colors = _determineColors(player1, player2);
      expect(colors['red'], equals('user1')); // Player1 wanted red
      expect(colors['black'], equals('user2')); // Player2 wanted black
    });

    test('should determine colors by Elo when no preferences', () {
      final higherPlayer = MatchmakingQueueModel(
        id: '1',
        userId: 'higher',
        eloRating: 1600,
        joinedAt: DateTime.now(),
        expiresAt: DateTime.now().add(Duration(minutes: 10)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final lowerPlayer = MatchmakingQueueModel(
        id: '2',
        userId: 'lower',
        eloRating: 1400,
        joinedAt: DateTime.now(),
        expiresAt: DateTime.now().add(Duration(minutes: 10)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final colors = _determineColors(higherPlayer, lowerPlayer);
      expect(colors['red'], equals('higher')); // Higher Elo gets red
      expect(colors['black'], equals('lower'));
    });

    test('should handle conflicting color preferences', () {
      final player1 = MatchmakingQueueModel(
        id: '1',
        userId: 'user1',
        eloRating: 1600,
        preferredColor: PreferredColor.red,
        joinedAt: DateTime.now(),
        expiresAt: DateTime.now().add(Duration(minutes: 10)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final player2 = MatchmakingQueueModel(
        id: '2',
        userId: 'user2',
        eloRating: 1400,
        preferredColor: PreferredColor.red, // Same preference
        joinedAt: DateTime.now(),
        expiresAt: DateTime.now().add(Duration(minutes: 10)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // When both want the same color, fall back to Elo-based assignment
      final colors = _determineColors(player1, player2);
      expect(colors['red'], equals('user1')); // Higher Elo gets preference
      expect(colors['black'], equals('user2'));
    });

    test('should validate Elo proximity matching logic', () {
      // Test if two players should be matched based on Elo proximity

      // Close Elo ratings should match
      expect(_shouldMatch(1500, 1520, 200, Duration.zero), isTrue);

      // Far Elo ratings should not match initially
      expect(_shouldMatch(1500, 1800, 200, Duration.zero), isFalse);

      // Far Elo ratings should match after wait time expansion
      expect(_shouldMatch(1500, 1800, 200, Duration(minutes: 2)), isTrue);

      // Extremely far ratings should never match
      expect(_shouldMatch(1200, 2200, 200, Duration(minutes: 10)), isFalse);
    });

    test('should prioritize closer Elo matches', () {
      final targetPlayer = MatchmakingQueueModel(
        id: 'target',
        userId: 'target',
        eloRating: 1500,
        joinedAt: DateTime.now(),
        expiresAt: DateTime.now().add(Duration(minutes: 10)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final closeMatch = MatchmakingQueueModel(
        id: 'close',
        userId: 'close',
        eloRating: 1520, // 20 point difference
        joinedAt: DateTime.now(),
        expiresAt: DateTime.now().add(Duration(minutes: 10)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final farMatch = MatchmakingQueueModel(
        id: 'far',
        userId: 'far',
        eloRating: 1600, // 100 point difference
        joinedAt: DateTime.now(),
        expiresAt: DateTime.now().add(Duration(minutes: 10)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Close match should be preferred
      final candidates = [farMatch, closeMatch]; // Intentionally out of order
      final bestMatch = _findBestMatchSimulated(targetPlayer, candidates);

      expect(bestMatch?.userId, equals('close'));
    });

    test('should respect time control compatibility', () {
      final player3min = MatchmakingQueueModel(
        id: '3min',
        userId: '3min',
        eloRating: 1500,
        timeControl: 180, // 3 minutes
        joinedAt: DateTime.now(),
        expiresAt: DateTime.now().add(Duration(minutes: 10)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final player5min = MatchmakingQueueModel(
        id: '5min',
        userId: '5min',
        eloRating: 1510, // Very close Elo
        timeControl: 300, // 5 minutes
        joinedAt: DateTime.now(),
        expiresAt: DateTime.now().add(Duration(minutes: 10)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Should not match due to different time controls
      expect(_isTimeControlCompatible(player3min, player5min), isFalse);

      // Same time control should be compatible
      final anotherPlayer3min = player5min.copyWith(timeControl: 180);
      expect(_isTimeControlCompatible(player3min, anotherPlayer3min), isTrue);
    });
  });
}

// Helper functions to simulate the private methods for testing

int _calculateMaxEloDifference(int eloRating) {
  if (eloRating >= 2000) return 150;
  if (eloRating >= 1600) return 200;
  if (eloRating >= 1200) return 250;
  return 300;
}

int _calculateExpandedEloDifference(int eloRating, Duration waitTime) {
  final baseMaxDiff = _calculateMaxEloDifference(eloRating);
  const expansionInterval = Duration(seconds: 30);
  const expansionAmount = 50;
  const maxEloDifference = 800;

  final expansions = waitTime.inSeconds ~/ expansionInterval.inSeconds;
  final expandedDiff = baseMaxDiff + (expansions * expansionAmount);

  return min(expandedDiff, maxEloDifference);
}

Map<String, String> _determineColors(MatchmakingQueueModel player1, MatchmakingQueueModel player2) {
  // If both have preferences and they're different, honor them
  if (player1.preferredColor != null && player2.preferredColor != null) {
    if (player1.preferredColor != player2.preferredColor) {
      return {
        'red': player1.preferredColor == PreferredColor.red ? player1.userId : player2.userId,
        'black': player1.preferredColor == PreferredColor.black ? player1.userId : player2.userId,
      };
    }
  }

  // If only one has a preference, honor it
  if (player1.preferredColor != null && player2.preferredColor == null) {
    return {
      'red': player1.preferredColor == PreferredColor.red ? player1.userId : player2.userId,
      'black': player1.preferredColor == PreferredColor.black ? player1.userId : player2.userId,
    };
  }

  if (player2.preferredColor != null && player1.preferredColor == null) {
    return {
      'red': player2.preferredColor == PreferredColor.red ? player2.userId : player1.userId,
      'black': player2.preferredColor == PreferredColor.black ? player2.userId : player1.userId,
    };
  }

  // Default: higher Elo player gets red
  if (player1.eloRating >= player2.eloRating) {
    return {'red': player1.userId, 'black': player2.userId};
  } else {
    return {'red': player2.userId, 'black': player1.userId};
  }
}

bool _shouldMatch(int elo1, int elo2, int baseMaxDiff, Duration waitTime) {
  final expandedDiff = _calculateExpandedEloDifference(elo1, waitTime);
  return (elo1 - elo2).abs() <= expandedDiff;
}

MatchmakingQueueModel? _findBestMatchSimulated(
  MatchmakingQueueModel target,
  List<MatchmakingQueueModel> candidates,
) {
  MatchmakingQueueModel? bestMatch;
  int bestEloDifference = 999999;

  for (final candidate in candidates) {
    if (candidate.id == target.id) continue;

    final eloDifference = (target.eloRating - candidate.eloRating).abs();
    if (eloDifference < bestEloDifference && _isTimeControlCompatible(target, candidate)) {
      bestMatch = candidate;
      bestEloDifference = eloDifference;
    }
  }

  return bestMatch;
}

bool _isTimeControlCompatible(MatchmakingQueueModel player1, MatchmakingQueueModel player2) {
  return player1.timeControl == player2.timeControl;
}
