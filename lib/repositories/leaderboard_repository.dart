import '../global.dart';
import '../models/leaderboard_entry_model.dart';
import 'supabase_base_repository.dart';

/// Repository for handling leaderboard data in Supabase
class LeaderboardRepository extends SupabaseBaseRepository<LeaderboardEntryModel> {
  // Singleton pattern
  static LeaderboardRepository? _instance;
  static LeaderboardRepository get instance => _instance ??= LeaderboardRepository._();

  LeaderboardRepository._() : super('leaderboard');

  @override
  LeaderboardEntryModel fromSupabase(Map<String, dynamic> data, String id) {
    return LeaderboardEntryModel.fromSupabase(data, id);
  }

  @override
  Map<String, dynamic> toSupabase(LeaderboardEntryModel model) {
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
        lastUpdated: DateTime.now(),
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
      final response = await table
          .select()
          .order('elo_rating', ascending: false)
          .limit(limit);

      return response.map((record) {
        final id = record['id'] as String;
        return fromSupabase(record, id);
      }).toList();
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
      final response = await table
          .select()
          .order('elo_rating', ascending: false);

      final players = response.map((record) {
        final id = record['id'] as String;
        return fromSupabase(record, id);
      }).toList();

      // Update ranks one by one
      for (int i = 0; i < players.length; i++) {
        final player = players[i];
        final rank = i + 1; // Ranks start at 1

        await update(player.id, {'rank': rank});
      }

      logger.info('Ranks recalculated for ${players.length} players');
    } catch (e) {
      logger.severe('Error recalculating ranks: $e');
      rethrow;
    }
  }

  // Get players by rank range
  Future<List<LeaderboardEntryModel>> getPlayersByRankRange(int startRank, int endRank) async {
    try {
      final response = await table
          .select()
          .gte('rank', startRank)
          .lte('rank', endRank)
          .order('rank');

      return response.map((record) {
        final id = record['id'] as String;
        return fromSupabase(record, id);
      }).toList();
    } catch (e) {
      logger.severe('Error getting players by rank range: $e');
      rethrow;
    }
  }

  // Listen to leaderboard changes
  Stream<List<LeaderboardEntryModel>> listenToTopPlayers({int limit = 10}) {
    try {
      return table
          .select()
          .order('elo_rating', ascending: false)
          .limit(limit)
          .stream()
          .map((response) {
            return response.map((record) {
              final id = record['id'] as String;
              return fromSupabase(record, id);
            }).toList();
          });
    } catch (e) {
      logger.severe('Error listening to top players: $e');
      rethrow;
    }
  }
}
