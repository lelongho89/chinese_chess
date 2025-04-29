import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../global.dart';
import '../models/user_model.dart';
import 'base_repository.dart';

/// Repository for handling user data in Firestore
class UserRepository extends BaseRepository<UserModel> {
  // Singleton pattern
  static UserRepository? _instance;
  static UserRepository get instance => _instance ??= UserRepository._();

  UserRepository._() : super('users');

  @override
  UserModel fromFirestore(DocumentSnapshot doc) {
    return UserModel.fromFirestore(doc);
  }

  @override
  Map<String, dynamic> toFirestore(UserModel model) {
    return model.toMap();
  }

  // Create a new user in Firestore
  Future<void> createUser(User firebaseUser) async {
    try {
      final userModel = UserModel.fromFirebaseUser(
        firebaseUser.uid,
        firebaseUser.email ?? '',
        firebaseUser.displayName,
      );

      await set(firebaseUser.uid, userModel);
      logger.info('User created in Firestore: ${firebaseUser.uid}');
    } catch (e) {
      logger.severe('Error creating user in Firestore: $e');
      rethrow;
    }
  }

  // Update user's last login time
  Future<void> updateLastLogin(String uid) async {
    try {
      await update(uid, {
        'lastLoginAt': Timestamp.now(),
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
        'eloRating': newRating,
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
      final userDoc = await collection.doc(uid).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data() as Map<String, dynamic>;
      
      final updates = {
        'gamesPlayed': (userData['gamesPlayed'] ?? 0) + 1,
      };

      if (isDraw) {
        updates['gamesDraw'] = (userData['gamesDraw'] ?? 0) + 1;
      } else if (isWin) {
        updates['gamesWon'] = (userData['gamesWon'] ?? 0) + 1;
      } else {
        updates['gamesLost'] = (userData['gamesLost'] ?? 0) + 1;
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
      return await query((collection) => 
        collection.orderBy('eloRating', descending: true).limit(limit)
      );
    } catch (e) {
      logger.severe('Error getting top players: $e');
      rethrow;
    }
  }

  // Search users by display name
  Future<List<UserModel>> searchByDisplayName(String query, {int limit = 10}) async {
    try {
      // Use a compound query with startAt and endAt for prefix search
      final String endQuery = query + '\uf8ff'; // \uf8ff is a high code point
      
      return await this.query((collection) => 
        collection
          .orderBy('displayName')
          .startAt([query])
          .endAt([endQuery])
          .limit(limit)
      );
    } catch (e) {
      logger.severe('Error searching users by display name: $e');
      rethrow;
    }
  }

  // Get user's friends
  Future<List<UserModel>> getUserFriends(String uid) async {
    try {
      final userDoc = await collection.doc(uid).get();
      if (!userDoc.exists) return [];

      final userData = userDoc.data() as Map<String, dynamic>;
      final List<String> friendIds = List<String>.from(userData['friendIds'] ?? []);
      
      if (friendIds.isEmpty) return [];
      
      // Get all friends in a single batch
      final friendDocs = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendIds)
          .get();
      
      return friendDocs.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e) {
      logger.severe('Error getting user friends: $e');
      rethrow;
    }
  }

  // Add a friend
  Future<void> addFriend(String uid, String friendId) async {
    try {
      // Add friend to user's friend list
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final userDoc = await transaction.get(collection.doc(uid));
        
        if (!userDoc.exists) return;
        
        final userData = userDoc.data() as Map<String, dynamic>;
        final List<String> friendIds = List<String>.from(userData['friendIds'] ?? []);
        
        if (!friendIds.contains(friendId)) {
          friendIds.add(friendId);
          transaction.update(collection.doc(uid), {'friendIds': friendIds});
        }
      });
      
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
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final userDoc = await transaction.get(collection.doc(uid));
        
        if (!userDoc.exists) return;
        
        final userData = userDoc.data() as Map<String, dynamic>;
        final List<String> friendIds = List<String>.from(userData['friendIds'] ?? []);
        
        if (friendIds.contains(friendId)) {
          friendIds.remove(friendId);
          transaction.update(collection.doc(uid), {'friendIds': friendIds});
        }
      });
      
      logger.info('Friend removed: $uid -> $friendId');
    } catch (e) {
      logger.severe('Error removing friend: $e');
      rethrow;
    }
  }
}
