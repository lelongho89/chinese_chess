import 'package:cloud_firestore/cloud_firestore.dart';

/// User model for storing user data in Firestore
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final int eloRating;
  final int gamesPlayed;
  final int gamesWon;
  final int gamesLost;
  final int gamesDraw;
  final Timestamp createdAt;
  final Timestamp lastLoginAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.eloRating = 1200, // Default Elo rating
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.gamesLost = 0,
    this.gamesDraw = 0,
    required this.createdAt,
    required this.lastLoginAt,
  });

  // Create a UserModel from a Firebase User
  factory UserModel.fromFirebaseUser(String uid, String email, String? displayName) {
    final now = Timestamp.now();
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? email.split('@').first, // Use part of email if no display name
      createdAt: now,
      lastLoginAt: now,
    );
  }

  // Create a UserModel from a Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      eloRating: data['eloRating'] ?? 1200,
      gamesPlayed: data['gamesPlayed'] ?? 0,
      gamesWon: data['gamesWon'] ?? 0,
      gamesLost: data['gamesLost'] ?? 0,
      gamesDraw: data['gamesDraw'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      lastLoginAt: data['lastLoginAt'] ?? Timestamp.now(),
    );
  }

  // Convert UserModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'eloRating': eloRating,
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'gamesLost': gamesLost,
      'gamesDraw': gamesDraw,
      'createdAt': createdAt,
      'lastLoginAt': lastLoginAt,
    };
  }

  // Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? displayName,
    int? eloRating,
    int? gamesPlayed,
    int? gamesWon,
    int? gamesLost,
    int? gamesDraw,
    Timestamp? lastLoginAt,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      eloRating: eloRating ?? this.eloRating,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      gamesLost: gamesLost ?? this.gamesLost,
      gamesDraw: gamesDraw ?? this.gamesDraw,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
