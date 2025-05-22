import 'package:supabase_flutter/supabase_flutter.dart';

/// User model for storing user data in Supabase
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final int eloRating;
  final int gamesPlayed;
  final int gamesWon;
  final int gamesLost;
  final int gamesDraw;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isAnonymous;

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
    this.isAnonymous = false,
  });

  // Create a UserModel from a Supabase User
  factory UserModel.fromSupabaseUser(User user) {
    final now = DateTime.now();
    return UserModel(
      uid: user.id,
      email: user.email ?? '',
      displayName: user.userMetadata?['name'] ?? user.email?.split('@').first ?? 'User',
      createdAt: now,
      lastLoginAt: now,
      isAnonymous: user.isAnonymous,
    );
  }

  // Create a UserModel from a Supabase User with custom display name (for anonymous users)
  factory UserModel.fromSupabaseUserWithDisplayName(User user, String displayName) {
    final now = DateTime.now();
    return UserModel(
      uid: user.id,
      email: user.email ?? '',
      displayName: displayName,
      createdAt: now,
      lastLoginAt: now,
      isAnonymous: user.isAnonymous,
    );
  }

  // Create a UserModel from a Supabase record
  factory UserModel.fromSupabase(Map<String, dynamic> data, String id) {
    return UserModel(
      uid: id,
      email: data['email'] ?? '',
      displayName: data['display_name'] ?? '',
      eloRating: data['elo_rating'] ?? 1200,
      gamesPlayed: data['games_played'] ?? 0,
      gamesWon: data['games_won'] ?? 0,
      gamesLost: data['games_lost'] ?? 0,
      gamesDraw: data['games_draw'] ?? 0,
      createdAt: DateTime.parse(data['created_at'] ?? DateTime.now().toIso8601String()),
      lastLoginAt: DateTime.parse(data['last_login_at'] ?? DateTime.now().toIso8601String()),
      isAnonymous: data['is_anonymous'] ?? false,
    );
  }

  // Convert UserModel to a Map for Supabase
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'display_name': displayName,
      'elo_rating': eloRating,
      'games_played': gamesPlayed,
      'games_won': gamesWon,
      'games_lost': gamesLost,
      'games_draw': gamesDraw,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt.toIso8601String(),
      'is_anonymous': isAnonymous,
    };
  }

  // Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? displayName,
    String? email,
    int? eloRating,
    int? gamesPlayed,
    int? gamesWon,
    int? gamesLost,
    int? gamesDraw,
    DateTime? lastLoginAt,
    bool? isAnonymous,
  }) {
    return UserModel(
      uid: uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      eloRating: eloRating ?? this.eloRating,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      gamesLost: gamesLost ?? this.gamesLost,
      gamesDraw: gamesDraw ?? this.gamesDraw,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }
}
