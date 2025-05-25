import 'dart:math' as math;
import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/matchmaking_queue_model.dart';
import '../repositories/user_repository.dart';
import '../services/matchmaking_service.dart';
import '../global.dart';

/// Utility class to populate the database with AI test users for matchmaking testing
class PopulateTestUsers {
  static const _uuid = Uuid();
  static final _random = Random();

  /// List of AI user names for testing
  static const List<String> _aiUserNames = [
    'ChessBot Alpha',
    'Dragon Master',
    'Phoenix Player',
    'Tiger Strategist',
    'Eagle Eye',
    'Lightning Strike',
    'Thunder King',
    'Storm Warrior',
    'Fire General',
    'Ice Commander',
    'Wind Dancer',
    'Earth Guardian',
    'Golden Knight',
    'Silver Sage',
    'Bronze Fighter',
    'Diamond Mind',
    'Ruby Tactician',
    'Emerald Scholar',
    'Sapphire Genius',
    'Pearl Wisdom',
  ];

  /// Generate a random Elo rating between 800-2400 (realistic chess rating range)
  static int _generateRandomElo() {
    // Weight towards middle ratings (1000-1600) for better matchmaking
    final weights = [
      (800, 1000, 0.1),   // Beginner: 10%
      (1000, 1200, 0.2),  // Novice: 20%
      (1200, 1400, 0.3),  // Intermediate: 30%
      (1400, 1600, 0.2),  // Advanced: 20%
      (1600, 1800, 0.1),  // Expert: 10%
      (1800, 2000, 0.05), // Master: 5%
      (2000, 2400, 0.05), // Grandmaster: 5%
    ];

    final rand = _random.nextDouble();
    double cumulative = 0.0;

    for (final (min, max, weight) in weights) {
      cumulative += weight;
      if (rand <= cumulative) {
        return min + _random.nextInt(max - min);
      }
    }

    return 1200; // Default fallback
  }

  /// Generate realistic game statistics based on Elo rating
  static Map<String, int> _generateGameStats(int eloRating) {
    // Higher rated players tend to have more games
    final baseGames = (eloRating - 800) ~/ 50 + _random.nextInt(20);
    final gamesPlayed = math.max(10, baseGames + _random.nextInt(50));

    // Win rate correlates with rating (roughly)
    final expectedWinRate = math.min(0.8, math.max(0.2, (eloRating - 800) / 1600 * 0.6 + 0.2));
    final winRateVariation = 0.1 + _random.nextDouble() * 0.2; // ±10-20% variation
    final actualWinRate = math.min(0.9, math.max(0.1, expectedWinRate + (_random.nextDouble() - 0.5) * winRateVariation));

    final gamesWon = (gamesPlayed * actualWinRate).round();
    final drawRate = 0.05 + _random.nextDouble() * 0.15; // 5-20% draws
    final gamesDraw = (gamesPlayed * drawRate).round();
    final gamesLost = gamesPlayed - gamesWon - gamesDraw;

    return {
      'gamesPlayed': gamesPlayed,
      'gamesWon': math.max(0, gamesWon),
      'gamesLost': math.max(0, gamesLost),
      'gamesDraw': math.max(0, gamesDraw),
    };
  }

  /// Create a single AI test user
  static UserModel _createAIUser(String name) {
    final uid = _uuid.v4();
    final eloRating = _generateRandomElo();
    final stats = _generateGameStats(eloRating);
    final now = DateTime.now();

    // Randomize creation date (within last 6 months)
    final createdAt = now.subtract(Duration(days: _random.nextInt(180)));

    // Last login within last week for active users
    final lastLoginAt = now.subtract(Duration(hours: _random.nextInt(168)));

    return UserModel(
      uid: uid,
      email: '${name.toLowerCase().replaceAll(' ', '.')}@aitest.com',
      displayName: name,
      eloRating: eloRating,
      gamesPlayed: stats['gamesPlayed']!,
      gamesWon: stats['gamesWon']!,
      gamesLost: stats['gamesLost']!,
      gamesDraw: stats['gamesDraw']!,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
      isAnonymous: false,
    );
  }

  /// Populate database with AI test users
  static Future<void> populateAIUsers({int count = 15}) async {
    try {
      logger.info('🤖 Starting to populate $count AI test users...');

      // Check if AI users already exist
      final existingUsers = await UserRepository.instance.getAll();
      final aiUsers = existingUsers.where((user) =>
        user.email.endsWith('@aitest.com')).toList();

      if (aiUsers.isNotEmpty) {
        logger.info('⚠️ Found ${aiUsers.length} existing AI users. Clearing them first...');
        await clearAIUsers();
      }

      final usersToCreate = <UserModel>[];
      final shuffledNames = List<String>.from(_aiUserNames)..shuffle(_random);

      for (int i = 0; i < math.min(count, shuffledNames.length); i++) {
        final aiUser = _createAIUser(shuffledNames[i]);
        usersToCreate.add(aiUser);
      }

      // Create AI users through Supabase auth (anonymous users)
      final supabase = Supabase.instance.client;

      for (final user in usersToCreate) {
        try {
          print('🤖 Creating AI user: ${user.displayName} (Elo: ${user.eloRating})'); // Debug log

          // Create anonymous user through Supabase auth
          final authResponse = await supabase.auth.signInAnonymously();

          if (authResponse.user != null) {
            // Create a new user model with the auth user's ID
            final updatedUser = UserModel(
              uid: authResponse.user!.id,
              email: user.email,
              displayName: user.displayName,
              eloRating: user.eloRating,
              gamesPlayed: user.gamesPlayed,
              gamesWon: user.gamesWon,
              gamesLost: user.gamesLost,
              gamesDraw: user.gamesDraw,
              createdAt: user.createdAt,
              lastLoginAt: user.lastLoginAt,
              isAnonymous: true, // Mark as anonymous
            );
            await UserRepository.instance.set(authResponse.user!.id, updatedUser);

            print('✅ Created AI user: ${user.displayName} (Elo: ${user.eloRating})'); // Debug log
            logger.info('✅ Created AI user: ${user.displayName} (Elo: ${user.eloRating})');
          }

          // Sign out the anonymous user
          await supabase.auth.signOut();

        } catch (e) {
          print('❌ Failed to create AI user ${user.displayName}: $e');
          logger.severe('❌ Failed to create AI user ${user.displayName}: $e');
        }
      }

      logger.info('🎉 Successfully created ${usersToCreate.length} AI test users!');

      // Add some AI users to the matchmaking queue for testing
      await _addAIUsersToQueue(usersToCreate);

      // Log summary statistics
      final avgElo = usersToCreate.map((u) => u.eloRating).reduce((a, b) => a + b) / usersToCreate.length;
      final minElo = usersToCreate.map((u) => u.eloRating).reduce(math.min);
      final maxElo = usersToCreate.map((u) => u.eloRating).reduce(math.max);

      logger.info('📊 AI Users Summary:');
      logger.info('   Average Elo: ${avgElo.round()}');
      logger.info('   Elo Range: $minElo - $maxElo');

    } catch (e) {
      logger.severe('❌ Error populating AI users: $e');
      rethrow;
    }
  }

  /// Add some AI users to the matchmaking queue for testing
  static Future<void> _addAIUsersToQueue(List<UserModel> aiUsers) async {
    try {
      // Add about 30% of AI users to the queue (4-5 users)
      final usersToQueue = aiUsers.take((aiUsers.length * 0.3).round()).toList();

      for (final user in usersToQueue) {
        try {
          print('🎯 Adding AI user to queue: ${user.displayName}'); // Debug log

          // Create a queue entry directly in the database
          await _addAIUserToQueueDirectly(user);

          print('✅ AI user added to queue: ${user.displayName}'); // Debug log
        } catch (e) {
          print('❌ Failed to add AI user to queue ${user.displayName}: $e');
          logger.severe('❌ Failed to add AI user to queue ${user.displayName}: $e');
        }
      }

      logger.info('🎯 Added ${usersToQueue.length} AI users to matchmaking queue');
    } catch (e) {
      logger.severe('❌ Error adding AI users to queue: $e');
    }
  }

  /// Add AI user to queue using repository method
  static Future<void> _addAIUserToQueueDirectly(UserModel user) async {
    // Random queue settings for variety
    final queueTypes = [QueueType.ranked, QueueType.casual];
    final timeControls = [60, 180, 300, 600]; // 1, 3, 5, 10 minutes
    final colors = [PreferredColor.red, PreferredColor.black, null];

    final queueType = queueTypes[_random.nextInt(queueTypes.length)];
    final timeControl = timeControls[_random.nextInt(timeControls.length)];
    final preferredColor = colors[_random.nextInt(colors.length)];

    // Use repository method to add AI user to queue
    await UserRepository.instance.addAIUserToQueue(
      user.uid,
      user.eloRating,
      queueType.name,
      timeControl,
      preferredColor?.name,
    );
  }

  /// Remove all AI test users from database
  static Future<void> clearAIUsers() async {
    try {
      logger.info('🧹 Clearing AI test users...');

      // Use the special method to remove all AI users
      await UserRepository.instance.removeAllAIUsers();

      logger.info('✅ Cleared all AI test users');
    } catch (e) {
      logger.severe('❌ Error clearing AI users: $e');
      rethrow;
    }
  }

  /// Get all AI test users
  static Future<List<UserModel>> getAIUsers() async {
    try {
      final allUsers = await UserRepository.instance.getAll();
      return allUsers.where((user) =>
        user.email.endsWith('@aitest.com')).toList();
    } catch (e) {
      logger.severe('❌ Error getting AI users: $e');
      return [];
    }
  }
}
