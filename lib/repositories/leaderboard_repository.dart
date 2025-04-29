import 'package:cloud_firestore/cloud_firestore.dart';

import '../global.dart';
import '../models/leaderboard_entry_model.dart';
import 'base_repository.dart';

/// Repository for handling leaderboard data in Firestore
class LeaderboardRepository extends BaseRepository<LeaderboardEntryModel> {
  // Singleton pattern
  static LeaderboardRepository? _instance;
  static LeaderboardRepository get instance => _instance ??= LeaderboardRepository._();

  LeaderboardRepository._() : super('leaderboard');

  @override
  LeaderboardEntryModel fromFirestore(DocumentSnapshot doc) {
    return LeaderboardEntryModel.fromFirestore(doc);
  }

  @override
  Map<String, dynamic> toFirestore(LeaderboardEntryModel model) {
    return model.toMap();
  }

  // Create or update a leaderboard entry
  Future<void> updateLeaderboardEntry({
    required String userId,
    required String displayName,
    required int eloRating,
    required int rank,
    required int gamesPlayed,
    required int gamesWon,
    required int gamesLost,
    required int gamesDraw,
  }) async {
    try {
      // Calculate win rate
      final winRate = gamesPlayed > 0 ? gamesWon / gamesPlayed : 0.0;
      
      final leaderboardEntry = LeaderboardEntryModel(
        id: userId, // Use userId as the document ID
        userId: userId,
        displayName: displayName,
        eloRating: eloRating,
        rank: rank,
        gamesPlayed: gamesPlayed,
        gamesWon: gamesWon,
        gamesLost: gamesLost,
        gamesDraw: gamesDraw,
        winRate: winRate,
        lastUpdated: Timestamp.now(),
        metadata: null,
      );

      await set(userId, leaderboardEntry);
      logger.info('Leaderboard entry updated: $userId');
    } catch (e) {
      logger.severe('Error updating leaderboard entry: $e');
      rethrow;
    }
  }

  // Get top players
  Future<List<LeaderboardEntryModel>> getTopPlayers({int limit = 10}) async {
    try {
      return await query((collection) => 
        collection
          .orderBy('eloRating', descending: true)
          .limit(limit)
      );
    } catch (e) {
      logger.severe('Error getting top players: $e');
      rethrow;
    }
  }

  // Get player rank
  Future<int> getPlayerRank(String userId) async {
    try {
      final leaderboardEntry = await get(userId);
      return leaderboardEntry?.rank ?? 0;
    } catch (e) {
      logger.severe('Error getting player rank: $e');
      rethrow;
    }
  }

  // Recalculate ranks for all players
  Future<void> recalculateRanks() async {
    try {
      // Get all players sorted by Elo rating
      final players = await query((collection) => 
        collection.orderBy('eloRating', descending: true)
      );
      
      // Update ranks in batches
      final batch = FirebaseFirestore.instance.batch();
      
      for (int i = 0; i < players.length; i++) {
        final player = players[i];
        final rank = i + 1; // Ranks start at 1
        
        batch.update(collection.doc(player.id), {'rank': rank});
      }
      
      await batch.commit();
      logger.info('Ranks recalculated for ${players.length} players');
    } catch (e) {
      logger.severe('Error recalculating ranks: $e');
      rethrow;
    }
  }

  // Get players by rank range
  Future<List<LeaderboardEntryModel>> getPlayersByRankRange(int startRank, int endRank) async {
    try {
      return await query((collection) => 
        collection
          .where('rank', isGreaterThanOrEqualTo: startRank)
          .where('rank', isLessThanOrEqualTo: endRank)
          .orderBy('rank')
      );
    } catch (e) {
      logger.severe('Error getting players by rank range: $e');
      rethrow;
    }
  }

  // Listen to leaderboard changes
  Stream<List<LeaderboardEntryModel>> listenToTopPlayers({int limit = 10}) {
    return listenToQuery((collection) => 
      collection
        .orderBy('eloRating', descending: true)
        .limit(limit)
    );
  }
}
