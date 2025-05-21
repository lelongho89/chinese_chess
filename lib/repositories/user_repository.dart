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
}
