import 'dart:math' as math;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../global.dart';
import '../models/user_model.dart';
import '../supabase_client.dart' as client;
import 'supabase_base_repository.dart';

/// Repository for handling user data in Supabase
class UserRepository extends SupabaseBaseRepository<UserModel> {
  // Singleton pattern
  static UserRepository? _instance;
  static UserRepository get instance => _instance ??= UserRepository._();

  UserRepository._() : super('users');

  @override
  UserModel fromSupabase(Map<String, dynamic> data, String id) {
    return UserModel.fromSupabase(data, id);
  }

  @override
  Map<String, dynamic> toSupabase(UserModel model) {
    return model.toMap();
  }

  // Create a new user in Supabase
  Future<void> createUser(User supabaseUser) async {
    try {
      final userModel = UserModel.fromSupabaseUser(supabaseUser);
      await set(supabaseUser.id, userModel);
      logger.info('User created in Supabase: ${supabaseUser.id}');
    } catch (e) {
      logger.severe('Error creating user in Supabase: $e');
      rethrow;
    }
  }

  // Create or update a user in Supabase
  Future<void> createOrUpdateUser(User supabaseUser) async {
    try {
      final existingUser = await get(supabaseUser.id);
      if (existingUser == null) {
        await createUser(supabaseUser);
      } else {
        await updateLastLogin(supabaseUser.id);
      }
    } catch (e) {
      logger.severe('Error creating or updating user in Supabase: $e');
      rethrow;
    }
  }

  // Update user's last login time
  Future<void> updateLastLogin(String uid) async {
    try {
      await update(uid, {
        'last_login_at': DateTime.now().toIso8601String(),
      });
      logger.info('User last login updated: $uid');
    } catch (e) {
      logger.severe('Error updating user last login: $e');
      rethrow;
    }
  }

  // Update user's Elo rating
  Future<void> updateEloRating(String uid, int newRating) async {
    try {
      await update(uid, {
        'elo_rating': newRating,
      });
      logger.info('User Elo rating updated: $uid, $newRating');
    } catch (e) {
      logger.severe('Error updating user Elo rating: $e');
      rethrow;
    }
  }

  // Update user's game statistics
  Future<void> updateGameStats(String uid, bool isWin, bool isDraw) async {
    try {
      final user = await get(uid);
      if (user == null) return;

      final updates = {
        'games_played': user.gamesPlayed + 1,
      };

      if (isDraw) {
        updates['games_draw'] = user.gamesDraw + 1;
      } else if (isWin) {
        updates['games_won'] = user.gamesWon + 1;
      } else {
        updates['games_lost'] = user.gamesLost + 1;
      }

      await update(uid, updates);
      logger.info('User game stats updated: $uid, Win: $isWin, Draw: $isDraw');
    } catch (e) {
      logger.severe('Error updating user game stats: $e');
      rethrow;
    }
  }

  // Update user's game statistics with side information
  Future<void> updateGameStatsWithSide(String uid, bool isWin, bool isDraw, String side) async {
    try {
      final user = await get(uid);
      if (user == null) return;

      final updates = {
        'games_played': user.gamesPlayed + 1,
        'last_played_side': side,
      };

      // Update side-specific counters
      if (side == 'red') {
        updates['red_games_played'] = user.redGamesPlayed + 1;
      } else if (side == 'black') {
        updates['black_games_played'] = user.blackGamesPlayed + 1;
      }

      if (isDraw) {
        updates['games_draw'] = user.gamesDraw + 1;
      } else if (isWin) {
        updates['games_won'] = user.gamesWon + 1;
      } else {
        updates['games_lost'] = user.gamesLost + 1;
      }

      await update(uid, updates);
      logger.info('User game stats updated with side: $uid, Win: $isWin, Draw: $isDraw, Side: $side');
    } catch (e) {
      logger.severe('Error updating user game stats with side: $e');
      rethrow;
    }
  }

  // Get top players by Elo rating
  Future<List<UserModel>> getTopPlayers({int limit = 10}) async {
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

  // Search users by display name
  Future<List<UserModel>> searchByDisplayName(String query, {int limit = 10}) async {
    try {
      // Use ilike for case-insensitive search with Supabase
      final response = await table
          .select()
          .ilike('display_name', '%$query%')
          .order('display_name')
          .limit(limit);

      return response.map((record) {
        final id = record['id'] as String;
        return fromSupabase(record, id);
      }).toList();
    } catch (e) {
      logger.severe('Error searching users by display name: $e');
      rethrow;
    }
  }

  // Get user's friends
  Future<List<UserModel>> getUserFriends(String uid) async {
    try {
      final user = await get(uid);
      if (user == null) return [];

      // Get the user's friends from the friends table
      final response = await client.SupabaseClientWrapper.instance.database
          .from('friends')
          .select('friend_id')
          .eq('user_id', uid);

      final List<String> friendIds = response
          .map((record) => record['friend_id'] as String)
          .toList();

      if (friendIds.isEmpty) return [];

      // Get all friends in a single batch
      final friendsResponse = await table
          .select()
          .filter('id', 'in', friendIds);

      return friendsResponse.map((record) {
        final id = record['id'] as String;
        return fromSupabase(record, id);
      }).toList();
    } catch (e) {
      logger.severe('Error getting user friends: $e');
      rethrow;
    }
  }

  // Add a friend
  Future<void> addFriend(String uid, String friendId) async {
    try {
      // Check if the friendship already exists
      final existingFriendship = await client.SupabaseClientWrapper.instance.database
          .from('friends')
          .select()
          .eq('user_id', uid)
          .eq('friend_id', friendId)
          .maybeSingle();

      if (existingFriendship == null) {
        // Add friend to user's friend list
        await client.SupabaseClientWrapper.instance.database
            .from('friends')
            .insert({
              'user_id': uid,
              'friend_id': friendId,
              'created_at': DateTime.now().toIso8601String(),
            });
      }

      logger.info('Friend added: $uid -> $friendId');
    } catch (e) {
      logger.severe('Error adding friend: $e');
      rethrow;
    }
  }

  // Remove a friend
  Future<void> removeFriend(String uid, String friendId) async {
    try {
      // Remove friend from user's friend list
      await client.SupabaseClientWrapper.instance.database
          .from('friends')
          .delete()
          .eq('user_id', uid)
          .eq('friend_id', friendId);

      logger.info('Friend removed: $uid -> $friendId');
    } catch (e) {
      logger.severe('Error removing friend: $e');
      rethrow;
    }
  }

  // Add AI user using database function (bypasses RLS for testing)
  Future<void> addAIUser(UserModel aiUser) async {
    try {
      // First ensure we have the necessary policies for AI users
      await _ensureAIUserPolicies();

      // Try direct insert first (should work with the new policy)
      final data = aiUser.toMap();
      data['id'] = aiUser.uid; // Ensure ID is set

      await client.SupabaseClientWrapper.instance.database
          .from('users')
          .insert(data);

      logger.info('AI user added: ${aiUser.displayName} (${aiUser.uid})');
    } catch (e) {
      logger.severe('Error adding AI user: $e');
      rethrow;
    }
  }

  // Ensure the AI user policies exist in the database
  Future<void> _ensureAIUserPolicies() async {
    try {
      // For now, we'll skip policy creation since we can't execute SQL directly
      // The AI users are created through anonymous auth which should work
      logger.info('AI user policies check skipped (using anonymous auth approach)');
    } catch (e) {
      logger.info('Could not create AI user policies: $e');
    }
  }

  // Add AI user to matchmaking queue (for testing)
  Future<void> addAIUserToQueue(String userId, int eloRating, String queueType, int timeControl, String? preferredColor) async {
    try {
      // Create queue entry data
      final queueData = {
        'id': _generateUUID(),
        'user_id': userId,
        'elo_rating': eloRating,
        'queue_type': queueType,
        'time_control': timeControl,
        'preferred_color': preferredColor,
        'max_elo_difference': 200,
        'status': 'waiting',
        'joined_at': DateTime.now().toIso8601String(),
        'expires_at': DateTime.now().add(const Duration(minutes: 10)).toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_deleted': false,
      };

      // Try direct insert (might work if RLS allows it)
      await client.SupabaseClientWrapper.instance.database
          .from('matchmaking_queue')
          .insert(queueData);

      logger.info('AI user added to queue: $userId');
    } catch (e) {
      logger.severe('Error adding AI user to queue: $e');
      rethrow;
    }
  }

  // Generate a simple UUID (basic implementation)
  String _generateUUID() {
    final random = math.Random();
    final chars = '0123456789abcdef';
    final uuid = List.generate(32, (index) => chars[random.nextInt(16)]).join();
    return '${uuid.substring(0, 8)}-${uuid.substring(8, 12)}-${uuid.substring(12, 16)}-${uuid.substring(16, 20)}-${uuid.substring(20, 32)}';
  }

  // Remove all AI users (for cleanup)
  Future<void> removeAllAIUsers() async {
    try {
      // Ensure we have the necessary policies for AI users
      await _ensureAIUserPolicies();

      // Delete all AI users directly
      await client.SupabaseClientWrapper.instance.database
          .from('users')
          .delete()
          .like('email', '%@aitest.com');

      logger.info('All AI users removed');
    } catch (e) {
      logger.severe('Error removing AI users: $e');
      rethrow;
    }
  }
}
