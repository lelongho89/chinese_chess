import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../global.dart';
import 'user_model.dart';

/// Repository for handling user data in Firestore
class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _usersCollection;

  // Singleton pattern
  static UserRepository? _instance;
  static UserRepository get instance => _instance ??= UserRepository._();

  UserRepository._() : _usersCollection = FirebaseFirestore.instance.collection('users');

  // Create a new user in Firestore
  Future<void> createUser(User firebaseUser) async {
    try {
      final userModel = UserModel.fromFirebaseUser(
        firebaseUser.uid,
        firebaseUser.email ?? '',
        firebaseUser.displayName,
      );

      await _usersCollection.doc(firebaseUser.uid).set(userModel.toMap());
      logger.info('User created in Firestore: ${firebaseUser.uid}');
    } catch (e) {
      logger.severe('Error creating user in Firestore: $e');
      rethrow;
    }
  }

  // Get a user from Firestore
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      logger.severe('Error getting user from Firestore: $e');
      rethrow;
    }
  }

  // Update a user in Firestore
  Future<void> updateUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).update(user.toMap());
      logger.info('User updated in Firestore: ${user.uid}');
    } catch (e) {
      logger.severe('Error updating user in Firestore: $e');
      rethrow;
    }
  }

  // Update user's last login time
  Future<void> updateLastLogin(String uid) async {
    try {
      await _usersCollection.doc(uid).update({
        'lastLoginAt': Timestamp.now(),
      });
      logger.info('User last login updated: $uid');
    } catch (e) {
      logger.severe('Error updating user last login: $e');
      rethrow;
    }
  }

  // Delete a user from Firestore
  Future<void> deleteUser(String uid) async {
    try {
      await _usersCollection.doc(uid).delete();
      logger.info('User deleted from Firestore: $uid');
    } catch (e) {
      logger.severe('Error deleting user from Firestore: $e');
      rethrow;
    }
  }

  // Update user's Elo rating
  Future<void> updateEloRating(String uid, int newRating) async {
    try {
      await _usersCollection.doc(uid).update({
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
      final userDoc = await _usersCollection.doc(uid).get();
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

      await _usersCollection.doc(uid).update(updates);
      logger.info('User game stats updated: $uid, Win: $isWin, Draw: $isDraw');
    } catch (e) {
      logger.severe('Error updating user game stats: $e');
      rethrow;
    }
  }

  // Get top players by Elo rating
  Future<List<UserModel>> getTopPlayers({int limit = 10}) async {
    try {
      final querySnapshot = await _usersCollection
          .orderBy('eloRating', descending: true)
          .limit(limit)
          .get();
      
      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      logger.severe('Error getting top players: $e');
      rethrow;
    }
  }
}
