import '../global.dart';
import '../models/matchmaking_queue_model.dart';
import '../supabase_client.dart' as supabase;
import 'supabase_base_repository.dart';

/// Model for potential match results
class PotentialMatch {
  final String queueId;
  final String userId;
  final int eloRating;
  final int eloDifference;
  final int waitTimeSeconds;

  PotentialMatch({
    required this.queueId,
    required this.userId,
    required this.eloRating,
    required this.eloDifference,
    required this.waitTimeSeconds,
  });

  factory PotentialMatch.fromMap(Map<String, dynamic> data) {
    return PotentialMatch(
      queueId: data['queue_id'],
      userId: data['user_id'],
      eloRating: data['elo_rating'],
      eloDifference: data['elo_difference'],
      waitTimeSeconds: data['wait_time_seconds'],
    );
  }

  @override
  String toString() {
    return 'PotentialMatch(userId: $userId, elo: $eloRating, diff: $eloDifference, wait: ${waitTimeSeconds}s)';
  }
}

/// Repository for handling matchmaking queue data in Supabase
class MatchmakingQueueRepository extends SupabaseBaseRepository<MatchmakingQueueModel> {
  // Singleton pattern
  static MatchmakingQueueRepository? _instance;
  static MatchmakingQueueRepository get instance => _instance ??= MatchmakingQueueRepository._();

  MatchmakingQueueRepository._() : super('matchmaking_queue');

  @override
  MatchmakingQueueModel fromSupabase(Map<String, dynamic> data, String id) {
    return MatchmakingQueueModel.fromSupabase(data, id);
  }

  @override
  Map<String, dynamic> toSupabase(MatchmakingQueueModel model) {
    return model.toMap();
  }

  /// Join the matchmaking queue
  Future<String> joinQueue({
    required String userId,
    required int eloRating,
    QueueType queueType = QueueType.ranked,
    int timeControl = 180,
    PreferredColor? preferredColor,
    int maxEloDifference = 200,
    Duration queueTimeout = const Duration(minutes: 10),
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Cancel any existing queue entries for this user
      await cancelUserQueue(userId);

      final now = DateTime.now();
      final queueModel = MatchmakingQueueModel(
        id: '', // Will be set by Supabase
        userId: userId,
        eloRating: eloRating,
        queueType: queueType,
        timeControl: timeControl,
        preferredColor: preferredColor,
        maxEloDifference: maxEloDifference,
        status: MatchmakingStatus.waiting,
        joinedAt: now,
        expiresAt: now.add(queueTimeout),
        createdAt: now,
        updatedAt: now,
        metadata: metadata,
      );

      final queueId = await add(queueModel);
      logger.info('User $userId joined matchmaking queue: $queueId');
      return queueId;
    } catch (e) {
      logger.severe('Error joining matchmaking queue: $e');
      rethrow;
    }
  }

  /// Leave the matchmaking queue
  Future<void> leaveQueue(String queueId) async {
    try {
      await update(queueId, {
        'status': MatchmakingStatus.cancelled.name,
        'updated_at': DateTime.now().toIso8601String(),
      });
      logger.info('Left matchmaking queue: $queueId');
    } catch (e) {
      logger.severe('Error leaving matchmaking queue: $e');
      rethrow;
    }
  }

  /// Cancel all queue entries for a user
  Future<void> cancelUserQueue(String userId) async {
    try {
      final response = await table
          .update({
            'status': MatchmakingStatus.cancelled.name,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('status', MatchmakingStatus.waiting.name);

      logger.info('Cancelled queue entries for user: $userId');
    } catch (e) {
      logger.severe('Error cancelling user queue: $e');
      rethrow;
    }
  }

  /// Find potential matches for a user
  Future<List<PotentialMatch>> findPotentialMatches({
    required String userId,
    required int eloRating,
    required QueueType queueType,
    int maxEloDifference = 200,
  }) async {
    try {
      final client = supabase.SupabaseClientWrapper.instance.database;
      final response = await client.rpc('find_potential_matches', params: {
        'target_user_id': userId,
        'target_elo': eloRating,
        'target_queue_type': queueType.name,
        'max_elo_diff': maxEloDifference,
      });

      return (response as List)
          .map((data) => PotentialMatch.fromMap(data))
          .toList();
    } catch (e) {
      logger.severe('Error finding potential matches: $e');
      rethrow;
    }
  }

  /// Mark two queue entries as matched
  Future<void> markAsMatched({
    required String queueId1,
    required String queueId2,
    required String matchId,
  }) async {
    try {
      final now = DateTime.now();
      final updates = {
        'status': MatchmakingStatus.matched.name,
        'match_id': matchId,
        'matched_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      // Get the queue entries to cross-reference matched users
      final queue1 = await get(queueId1);
      final queue2 = await get(queueId2);

      if (queue1 == null || queue2 == null) {
        throw Exception('Queue entries not found');
      }

      // Update first queue entry
      await update(queueId1, {
        ...updates,
        'matched_with_user_id': queue2.userId,
      });

      // Update second queue entry
      await update(queueId2, {
        ...updates,
        'matched_with_user_id': queue1.userId,
      });

      logger.info('Marked queue entries as matched: $queueId1 <-> $queueId2');
    } catch (e) {
      logger.severe('Error marking queue entries as matched: $e');
      rethrow;
    }
  }

  /// Get active queue entry for a user
  Future<MatchmakingQueueModel?> getUserActiveQueue(String userId) async {
    try {
      final response = await table
          .select()
          .eq('user_id', userId)
          .eq('status', MatchmakingStatus.waiting.name)
          .eq('is_deleted', false)
          .order('created_at', ascending: false)
          .limit(1);

      if (response.isEmpty) return null;

      final data = response.first;
      final id = data['id'] as String;
      return fromSupabase(data, id);
    } catch (e) {
      logger.severe('Error getting user active queue: $e');
      rethrow;
    }
  }

  /// Get queue statistics
  Future<Map<String, dynamic>> getQueueStats() async {
    try {
      final response = await table
          .select()
          .eq('status', MatchmakingStatus.waiting.name)
          .eq('is_deleted', false);

      final totalWaiting = response.length;
      final rankedWaiting = response.where((r) => r['queue_type'] == 'ranked').length;
      final casualWaiting = response.where((r) => r['queue_type'] == 'casual').length;

      // Calculate average wait time
      final now = DateTime.now();
      final waitTimes = response.map((r) {
        final joinedAt = DateTime.parse(r['joined_at']);
        return now.difference(joinedAt).inSeconds;
      }).toList();

      final avgWaitTime = waitTimes.isEmpty ? 0 : waitTimes.reduce((a, b) => a + b) / waitTimes.length;

      return {
        'total_waiting': totalWaiting,
        'ranked_waiting': rankedWaiting,
        'casual_waiting': casualWaiting,
        'average_wait_time_seconds': avgWaitTime.round(),
      };
    } catch (e) {
      logger.severe('Error getting queue stats: $e');
      rethrow;
    }
  }

  /// Expire old queue entries
  Future<void> expireOldEntries() async {
    try {
      final client = supabase.SupabaseClientWrapper.instance.database;
      await client.rpc('expire_old_queue_entries');
      logger.info('Expired old queue entries');
    } catch (e) {
      logger.severe('Error expiring old queue entries: $e');
      rethrow;
    }
  }

  /// Clean up expired entries
  Future<void> cleanupExpiredEntries() async {
    try {
      final client = supabase.SupabaseClientWrapper.instance.database;
      await client.rpc('cleanup_expired_queue_entries');
      logger.info('Cleaned up expired queue entries');
    } catch (e) {
      logger.severe('Error cleaning up expired queue entries: $e');
      rethrow;
    }
  }

  /// Get waiting players by Elo range
  Future<List<MatchmakingQueueModel>> getWaitingPlayersByEloRange({
    required int minElo,
    required int maxElo,
    QueueType? queueType,
    int limit = 50,
  }) async {
    try {
      var queryBuilder = table
          .select()
          .eq('status', MatchmakingStatus.waiting.name)
          .eq('is_deleted', false)
          .gte('elo_rating', minElo)
          .lte('elo_rating', maxElo);

      if (queueType != null) {
        queryBuilder = queryBuilder.eq('queue_type', queueType.name);
      }

      final response = await queryBuilder
          .order('joined_at')
          .limit(limit);

      return response.map((record) {
        final id = record['id'] as String;
        return fromSupabase(record, id);
      }).toList();
    } catch (e) {
      logger.severe('Error getting waiting players by Elo range: $e');
      rethrow;
    }
  }
}
