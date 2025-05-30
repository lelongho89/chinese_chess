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

  // Create an anonymous user in Supabase
  Future<void> createAnonymousUser(User supabaseUser, String displayName) async {
    try {
      final userModel = UserModel.fromSupabaseUserWithDisplayName(supabaseUser, displayName);

      // Try to create the user, but handle database schema issues gracefully
      try {
        await set(supabaseUser.id, userModel);
        logger.info('Anonymous user created in Supabase: ${supabaseUser.id}');
      } catch (dbError) {
        // If there's a database schema issue, try with minimal data
        logger.warning('Failed to create full user record, trying minimal data: $dbError');

        final minimalData = {
          'email': supabaseUser.email ?? '',
          'display_name': displayName,
          'created_at': DateTime.now().toIso8601String(),
          'last_login_at': DateTime.now().toIso8601String(),
        };

        await table.upsert(minimalData.map((key, value) => MapEntry(key, value))..['id'] = supabaseUser.id);
        logger.info('Anonymous user created with minimal data: ${supabaseUser.id}');
      }
    } catch (e) {
      logger.severe('Error creating anonymous user in Supabase: $e');
      rethrow;
    }
  }

  // Create anonymous user with device ID
  Future<void> createAnonymousUserWithDevice(User supabaseUser, String displayName, String deviceId) async {
    try {
      final userModel = UserModel.fromSupabaseUserWithDisplayName(supabaseUser, displayName, deviceId: deviceId);

      // Try to create the user, but handle database schema issues gracefully
      try {
        await set(supabaseUser.id, userModel);
        logger.info('Anonymous user created with device ID: ${supabaseUser.id}');
      } catch (dbError) {
        // If there's a database schema issue, try with minimal data
        logger.warning('Failed to create full user record, trying minimal data: $dbError');

        final minimalData = {
          'email': supabaseUser.email ?? '',
          'display_name': displayName,
          'device_id': deviceId,
          'is_anonymous': true,
          'created_at': DateTime.now().toIso8601String(),
          'last_login_at': DateTime.now().toIso8601String(),
        };

        await table.upsert(minimalData.map((key, value) => MapEntry(key, value))..['id'] = supabaseUser.id);
        logger.info('Anonymous user created with minimal data and device ID: ${supabaseUser.id}');
      }
    } catch (e) {
      logger.severe('Error creating anonymous user with device ID: $e');
      rethrow;
    }
  }

  // Get user by device ID
  Future<UserModel?> getUserByDeviceId(String deviceId) async {
    try {
      final response = await table
          .select()
          .eq('device_id', deviceId)
          .eq('is_anonymous', true)
          .maybeSingle();

      if (response != null) {
        final userModel = fromSupabase(response, response['id']);
        logger.info('Found user by device ID: ${userModel.uid}');
        return userModel;
      }

      return null;
    } catch (e) {
      logger.severe('Error getting user by device ID: $e');
      return null;
    }
  }

  // Link device to existing user (for session restoration)
  Future<void> linkDeviceToUser(String newUserId, String deviceId, UserModel existingUser) async {
    try {
      // Create a new user record with the new Supabase user ID but existing stats
      final updatedUser = existingUser.copyWith();
      final userData = updatedUser.toMap();
      userData['id'] = newUserId;
      userData['device_id'] = deviceId;
      userData['last_login_at'] = DateTime.now().toIso8601String();

      await table.upsert(userData);

      // Optionally, clean up the old user record if it's different
      if (existingUser.uid != newUserId) {
        try {
          await delete(existingUser.uid);
          logger.info('Cleaned up old user record: ${existingUser.uid}');
        } catch (e) {
          logger.warning('Could not clean up old user record: $e');
        }
      }

      logger.info('Linked device to user: $newUserId');
    } catch (e) {
      logger.severe('Error linking device to user: $e');
      rethrow;
    }
  }

  // Convert anonymous user to permanent account
  Future<void> convertAnonymousUser(User supabaseUser) async {
    try {
      await update(supabaseUser.id, {
        'email': supabaseUser.email ?? '',
        'is_anonymous': false,
        'last_login_at': DateTime.now().toIso8601String(),
      });
      logger.info('Anonymous user converted to permanent account: ${supabaseUser.id}');
    } catch (e) {
      logger.severe('Error converting anonymous user: $e');
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

  // Delete anonymous user data completely (for profile deletion)
  Future<void> deleteAnonymousUserData(String uid) async {
    try {
      // First verify this is an anonymous user
      final user = await get(uid);
      if (user == null) {
        logger.warning('User not found for deletion: $uid');
        return;
      }

      if (!user.isAnonymous) {
        throw Exception('Cannot delete non-anonymous user data');
      }

      // Delete user record
      await delete(uid);

      // TODO: Delete related data (games, matchmaking entries, etc.)
      // This would be expanded based on your data model

      logger.info('Anonymous user data deleted: $uid');
    } catch (e) {
      logger.severe('Error deleting anonymous user data: $e');
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
  
    /// Get all AI users (display name contains 'AI', case-insensitive)
    Future<List<UserModel>> getAIUsers() async {
      try {
        final response = await table
            .select()
            .ilike('display_name', '%ai%');
        return response.map((record) {
          final id = record['id'] as String;
          return fromSupabase(record, id);
        }).toList();
      } catch (e) {
        logger.severe('Error getting AI users: $e');
        return [];
      }
    }
  }
/// Get all AI users (display name contains 'AI', case-insensitive)
  Future<List<UserModel>> getAIUsers() async {
    try {
      final response = await table
          .select()
          .ilike('display_name', '%ai%');
      return response.map((record) {
        final id = record['id'] as String;
        return fromSupabase(record, id);
      }).toList();
    } catch (e) {
      logger.severe('Error getting AI users: $e');
      return [];
    }
  }
}
