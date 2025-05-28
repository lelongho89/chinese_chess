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

  /// List of AI user names for testing - updated for more human/chess-like names
  static const List<String> _aiUserNames = [
    // Creative & Themed Names
    'TheGambitGuru', 'RookAndRoll', 'PawnProphet', 'EndgameEdison', 'ZugzwangZoe',
    'SilentAssassin', 'DeepThinker', 'BoardWarden', 'CheckmateCharlie', 'StrategicSue',
    'TacticalTom', 'CleverCatherine', 'KnightRider22', 'BishopOfBlitz', 'QueenOfSacrifice',
    'KingSlayer', 'FortressBuilder', 'AttackVector', 'CounterGambit', 'PositionalPlay',

    // More "Regular" Gamer Tags / Names
    'EmmaChess', 'AlexP_88', 'DeepBlueJr', 'ChessFanatic', 'TheGrandmasterG',
    'RookStar', 'PawnSlayerX', 'CheckmateMaster', 'StrategicMind', 'TacticalPlayer',
    'CatalanFan', 'SicilianPlayer', 'NimzoWizard', 'CaroKannKid', 'RetiOpening',
    'AlphaZeroFan', 'StockfishSim', 'LeelaLearner', 'NeuralNetNick', 'AI_Adversary',

    // Simple First Name + Chess Term
    'AnnaTheAnalyzer', 'BenTheBlockader', 'ChloeTheChecker', 'DavidTheDefender', 'EvaTheEvaluator',
    'FrankTheForker', 'GraceTheGrandmaster', 'HenryTheHunter', 'IslaTheInitiator', 'JackTheJumper',
    'KateTheKingpin', 'LeoTheLeverager', 'MiaTheManeuverer', 'NoahTheNeutralizer', 'OliviaTheOpener',

    // Names with numbers/suffixes
    'ChessNut_79', 'DeepMind_AI', 'Strategist_Pro', 'TacticMaster_X', 'GrandmasterBot_v2',
    'PawnStormer_01', 'RookRoller_EZ', 'KnightMoves_GG', 'BishopPair_WIN', 'QueenBee_AI',
  ];


  /// Generate a random Elo rating between 800-2000, biased towards 1000-1600.
  static int _generateRandomElo() {
    // Weights adjusted for 800-2000 range with bias towards 1000-1600
    final weights = [
      (800, 1000, 0.15),  // Beginner: 15%
      (1000, 1200, 0.25), // Novice: 25%
      (1200, 1400, 0.30), // Intermediate: 30%
      (1400, 1600, 0.20), // Advanced: 20%
      (1600, 1800, 0.05), // Expert: 5%
      (1800, 2000, 0.05), // Master: 5%
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
    final gamesPlayed = math.max(5, (eloRating - 750) ~/ 10 + _random.nextInt(50)); // Min 5 games, more for higher Elo

    // Win rate correlates with rating (roughly)
    // Simple model: Base 30% win rate, +1% for every 20 Elo points above 800
    double expectedWinRate = 0.30 + (math.max(0, eloRating - 800) / 20.0) * 0.01;
    expectedWinRate = math.min(0.85, math.max(0.15, expectedWinRate)); // Clamp between 15% and 85%

    // Add some randomness
    final actualWinRate = math.min(0.90, math.max(0.10, expectedWinRate + (_random.nextDouble() - 0.5) * 0.20)); // +/- 10% variation

    final gamesWon = (gamesPlayed * actualWinRate).round();
    
    // Draw rate: Higher for higher Elo, but generally less than wins/losses
    double drawRate = 0.05 + (math.max(0, eloRating - 1000) / 100.0) * 0.005; // Base 5%, +0.5% per 100 Elo over 1000
    drawRate = math.min(0.30, math.max(0.02, drawRate + (_random.nextDouble() - 0.5) * 0.10)); // Clamp 2%-30%, add variation
    
    final gamesDraw = (gamesPlayed * drawRate).round();
    
    final gamesLost = math.max(0, gamesPlayed - gamesWon - gamesDraw); // Ensure non-negative

    return {
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'gamesLost': gamesLost,
      'gamesDraw': gamesDraw,
    };
  }

  /// Create a single AI test user
  static UserModel _createAIUser(String name) {
    final uid = _uuid.v4();
    final eloRating = _generateRandomElo();
    final stats = _generateGameStats(eloRating);
    final now = DateTime.now();

    // Randomize creation date (within last year)
    final createdAt = now.subtract(Duration(days: _random.nextInt(365)));

    // Last login within last month for active users
    final lastLoginAt = now.subtract(Duration(days: _random.nextInt(30), hours: _random.nextInt(24)));
    
    // Determine a last played side randomly or based on game counts (if desired for more realism)
    final lastPlayedSide = _random.nextBool() ? 'red' : 'black';
    final redGames = (stats['gamesPlayed']! * (_random.nextDouble() * 0.4 + 0.3)).round(); // 30-70% red games
    final blackGames = stats['gamesPlayed']! - redGames;


    return UserModel(
      uid: uid,
      email: '${name.toLowerCase().replaceAll(' ', '_').replaceAll('.', '_')}@aitest.com', // Sanitize name for email
      displayName: name,
      eloRating: eloRating,
      gamesPlayed: stats['gamesPlayed']!,
      gamesWon: stats['gamesWon']!,
      gamesLost: stats['gamesLost']!,
      gamesDraw: stats['gamesDraw']!,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
      isAnonymous: false, // AI users are not anonymous in the sense of Supabase anonymous auth for this utility
      lastPlayedSide: lastPlayedSide,
      redGamesPlayed: redGames,
      blackGamesPlayed: blackGames,
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

      // Skip adding AI users to queue due to RLS policy restrictions
      // The matchmaking service will find AI users directly from the users table
      logger.info('🎯 AI users created but not added to queue (RLS restrictions)');

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
    // Simplified queue settings - no color preferences, single time control
    final queueTypes = [QueueType.ranked, QueueType.casual];

    final queueType = queueTypes[_random.nextInt(queueTypes.length)];

    // Use repository method to add AI user to queue (simplified)
    await UserRepository.instance.addAIUserToQueue(
      user.uid,
      user.eloRating,
      queueType.name,
      300, // Use standard 5-minute time control
      null, // No color preference in simplified mode
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
