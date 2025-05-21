import 'package:supabase_flutter/supabase_flutter.dart';

import '../global.dart';
import '../repositories/supabase_base_repository.dart';
import '../supabase_client.dart';
import 'user_model.dart';

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
  Future<void> createOrUpdateUser(User supabaseUser, {String? displayName}) async {
    try {
      final existingUser = await get(supabaseUser.id);
      if (existingUser == null) {
        // Create new user
        final userModel = UserModel.fromSupabaseUser(supabaseUser);
        await set(supabaseUser.id, userModel);
        logger.info('User created in Supabase: ${supabaseUser.id}');
      } else {
        // Update existing user
        await updateLastLogin(supabaseUser.id);

        // Update display name if provided
        if (displayName != null) {
          await update(supabaseUser.id, {'display_name': displayName});
        }
      }
    } catch (e) {
      logger.severe('Error creating or updating user in Supabase: $e');
      rethrow;
    }
  }

  // Get a user from Supabase
  Future<UserModel?> getUser(String uid) async {
    return get(uid);
  }

  // Update a user in Supabase
  Future<void> updateUser(UserModel user) async {
    try {
      await update(user.uid, user.toMap());
      logger.info('User updated in Supabase: ${user.uid}');
    } catch (e) {
      logger.severe('Error updating user in Supabase: $e');
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

  // Delete a user from Supabase
  Future<void> deleteUser(String uid) async {
    try {
      await delete(uid);
      logger.info('User deleted from Supabase: $uid');
    } catch (e) {
      logger.severe('Error deleting user from Supabase: $e');
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
}
