import 'package:flutter_test/flutter_test.dart';
import 'package:chinese_chess/config/app_config.dart';
import 'package:chinese_chess/models/matchmaking_queue_model.dart';
import 'package:chinese_chess/models/user_model.dart';
import 'package:chinese_chess/services/matchmaking_service.dart';
import 'package:chinese_chess/services/side_alternation_service.dart';

void main() {
  group('Simplified Matchmaking', () {
    late AppConfig appConfig;
    late SideAlternationService sideService;

    setUp(() {
      appConfig = AppConfig.instance;
      sideService = SideAlternationService.instance;
    });

    group('App Configuration', () {
      test('should provide default time control', () {
        expect(appConfig.matchTimeControl, equals(300)); // 5 minutes
        expect(appConfig.matchTimeControlFormatted, equals('5min'));
      });

      test('should provide matchmaking configuration', () {
        expect(appConfig.enableAIMatching, isTrue);
        expect(appConfig.aiSpawnDelaySeconds, equals(10));
        expect(appConfig.maxEloDifference, equals(200));
        expect(appConfig.enforceSideAlternation, isTrue);
      });

      test('should provide queue timeout configuration', () {
        expect(appConfig.queueTimeout, equals(const Duration(minutes: 10)));
      });

      test('should provide debug configuration', () {
        expect(appConfig.showDebugTools, isNotNull);
        expect(appConfig.testAIUserCount, equals(15));
      });

      test('should provide configuration as map', () {
        final config = appConfig.toMap();
        expect(config['matchTimeControl'], equals(300));
        expect(config['enableAIMatching'], isTrue);
        expect(config['maxEloDifference'], equals(200));
        expect(config['enforceSideAlternation'], isTrue);
      });
    });

    group('Simplified Queue Model', () {
      test('should create queue model without side preferences', () {
        final now = DateTime.now();
        final queue = MatchmakingQueueModel(
          id: 'test_id',
          userId: 'user_123',
          eloRating: 1500,
          queueType: QueueType.ranked,
          timeControl: appConfig.matchTimeControl,
          maxEloDifference: appConfig.maxEloDifference,
          joinedAt: now,
          expiresAt: now.add(appConfig.queueTimeout),
          createdAt: now,
          updatedAt: now,
        );

        expect(queue.timeControl, equals(300));
        expect(queue.maxEloDifference, equals(200));
        expect(queue.queueType, equals(QueueType.ranked));
        expect(queue.status, equals(MatchmakingStatus.waiting));
      });

      test('should convert to map without preferred color', () {
        final now = DateTime.now();
        final queue = MatchmakingQueueModel(
          id: 'test_id',
          userId: 'user_123',
          eloRating: 1500,
          queueType: QueueType.ranked,
          timeControl: 300,
          joinedAt: now,
          expiresAt: now.add(const Duration(minutes: 10)),
          createdAt: now,
          updatedAt: now,
        );

        final map = queue.toMap();
        expect(map.containsKey('preferred_color'), isFalse);
        expect(map['time_control'], equals(300));
        expect(map['queue_type'], equals('ranked'));
      });

      test('should create from Supabase data without preferred color', () {
        final now = DateTime.now();
        final data = {
          'user_id': 'user_123',
          'elo_rating': 1500,
          'queue_type': 'ranked',
          'time_control': 300,
          'max_elo_difference': 200,
          'status': 'waiting',
          'joined_at': now.toIso8601String(),
          'expires_at': now.add(const Duration(minutes: 10)).toIso8601String(),
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
          'is_deleted': false,
        };

        final queue = MatchmakingQueueModel.fromSupabase(data, 'test_id');
        expect(queue.userId, equals('user_123'));
        expect(queue.timeControl, equals(300));
        expect(queue.queueType, equals(QueueType.ranked));
      });
    });

    group('Side Assignment Without Preferences', () {
      test('should assign sides without preferences', () async {
        // Create test players
        final player1 = UserModel(
          uid: 'player1',
          email: 'player1@test.com',
          displayName: 'Player 1',
          eloRating: 1500,
          gamesPlayed: 5,
          redGamesPlayed: 3,
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
          gamesPlayed: 4,
          redGamesPlayed: 1,
          blackGamesPlayed: 3,
          lastPlayedSide: 'black',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        // Test side assignment logic without preferences
        final stats1 = sideService.getPlayerSideStats(player1);
        final stats2 = sideService.getPlayerSideStats(player2);

        // Player 1 last played Red, should prefer Black
        expect(stats1['preferred_next_side'], equals('black'));
        
        // Player 2 last played Black, should prefer Red
        expect(stats2['preferred_next_side'], equals('red'));
      });

      test('should handle AI match side assignment without preferences', () async {
        final humanPlayer = UserModel(
          uid: 'human',
          email: 'human@test.com',
          displayName: 'Human',
          eloRating: 1500,
          gamesPlayed: 8,
          redGamesPlayed: 6, // Strong Red bias
          blackGamesPlayed: 2,
          lastPlayedSide: 'red',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        final stats = sideService.getPlayerSideStats(humanPlayer);
        
        // Human should prefer Black to balance their Red bias
        expect(stats['should_alternate'], isTrue);
        expect(stats['preferred_next_side'], equals('black'));
        expect(stats['red_ratio'], equals(0.75)); // 6/8 = 0.75
      });
    });

    group('Simplified Matchmaking Logic', () {
      test('should use configured time control for all matches', () {
        // All matches should use the same time control from AppConfig
        expect(appConfig.matchTimeControl, equals(300));
        expect(appConfig.isSimplifiedMode, isTrue);
      });

      test('should provide available time control options for admin', () {
        final options = AppConfig.availableTimeControls;
        expect(options, contains(180)); // 3 minutes
        expect(options, contains(300)); // 5 minutes
        expect(options, contains(600)); // 10 minutes

        final names = AppConfig.timeControlNames;
        expect(names[300], equals('5 minutes (Standard)'));
        expect(names[600], equals('10 minutes (Extended)'));
      });

      test('should handle environment variable configuration', () {
        // Test that configuration can be overridden via environment
        // In a real test environment, you would set environment variables
        expect(appConfig.matchTimeControl, isPositive);
        expect(appConfig.maxEloDifference, isPositive);
        expect(appConfig.aiSpawnDelaySeconds, isNonNegative);
      });
    });

    group('Queue Compatibility', () {
      test('should match players with same queue type only', () {
        final now = DateTime.now();
        
        final rankedPlayer = MatchmakingQueueModel(
          id: 'ranked_id',
          userId: 'ranked_user',
          eloRating: 1500,
          queueType: QueueType.ranked,
          timeControl: 300,
          joinedAt: now,
          expiresAt: now.add(const Duration(minutes: 10)),
          createdAt: now,
          updatedAt: now,
        );

        final casualPlayer = MatchmakingQueueModel(
          id: 'casual_id',
          userId: 'casual_user',
          eloRating: 1500,
          queueType: QueueType.casual,
          timeControl: 300,
          joinedAt: now,
          expiresAt: now.add(const Duration(minutes: 10)),
          createdAt: now,
          updatedAt: now,
        );

        // Players with different queue types should not be compatible
        expect(rankedPlayer.queueType, isNot(equals(casualPlayer.queueType)));
      });

      test('should use standard time control for all players', () {
        final now = DateTime.now();
        
        final player1 = MatchmakingQueueModel(
          id: 'player1_id',
          userId: 'player1',
          eloRating: 1500,
          queueType: QueueType.ranked,
          timeControl: appConfig.matchTimeControl,
          joinedAt: now,
          expiresAt: now.add(appConfig.queueTimeout),
          createdAt: now,
          updatedAt: now,
        );

        final player2 = MatchmakingQueueModel(
          id: 'player2_id',
          userId: 'player2',
          eloRating: 1400,
          queueType: QueueType.ranked,
          timeControl: appConfig.matchTimeControl,
          joinedAt: now,
          expiresAt: now.add(appConfig.queueTimeout),
          createdAt: now,
          updatedAt: now,
        );

        // All players should have the same time control
        expect(player1.timeControl, equals(player2.timeControl));
        expect(player1.timeControl, equals(appConfig.matchTimeControl));
      });
    });

    group('Configuration Display', () {
      test('should format time control for display', () {
        expect(appConfig.matchTimeControlFormatted, equals('5min'));
        expect(appConfig.timeDisplayText, equals('5min'));
      });

      test('should provide debug configuration', () {
        final config = appConfig.toMap();
        expect(config, containsPair('showDebugTools', appConfig.showDebugTools));
        expect(config, containsPair('testAIUserCount', 15));
      });
    });
  });
}
