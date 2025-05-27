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
  final String? deviceId; // Device ID for anonymous users
  final String? lastPlayedSide; // 'red' or 'black' - tracks last side played for alternation
  final int redGamesPlayed; // Count of games played as Red
  final int blackGamesPlayed; // Count of games played as Black

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
    this.deviceId,
    this.lastPlayedSide,
    this.redGamesPlayed = 0,
    this.blackGamesPlayed = 0,
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
  factory UserModel.fromSupabaseUserWithDisplayName(User user, String displayName, {String? deviceId}) {
    final now = DateTime.now();
    return UserModel(
      uid: user.id,
      email: user.email ?? '',
      displayName: displayName,
      createdAt: now,
      lastLoginAt: now,
      isAnonymous: user.isAnonymous,
      deviceId: deviceId,
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
      deviceId: data['device_id'],
      lastPlayedSide: data['last_played_side'],
      redGamesPlayed: data['red_games_played'] ?? 0,
      blackGamesPlayed: data['black_games_played'] ?? 0,
    );
  }

  // Convert UserModel to a Map for Supabase
  Map<String, dynamic> toMap() {
    final map = {
      'email': email,
      'display_name': displayName,
      'elo_rating': eloRating,
      'games_played': gamesPlayed,
      'games_won': gamesWon,
      'games_lost': gamesLost,
      'games_draw': gamesDraw,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt.toIso8601String(),
      'red_games_played': redGamesPlayed,
      'black_games_played': blackGamesPlayed,
    };

    // Only include is_anonymous if the database supports it
    // This prevents errors if the column doesn't exist yet
    if (isAnonymous) {
      map['is_anonymous'] = isAnonymous;
    }

    // Include device_id for anonymous users
    if (deviceId != null) {
      map['device_id'] = deviceId!;
    }

    // Include last played side for alternation tracking
    if (lastPlayedSide != null) {
      map['last_played_side'] = lastPlayedSide!;
    }

    return map;
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
    String? deviceId,
    String? lastPlayedSide,
    int? redGamesPlayed,
    int? blackGamesPlayed,
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
      deviceId: deviceId ?? this.deviceId,
      lastPlayedSide: lastPlayedSide ?? this.lastPlayedSide,
      redGamesPlayed: redGamesPlayed ?? this.redGamesPlayed,
      blackGamesPlayed: blackGamesPlayed ?? this.blackGamesPlayed,
    );
  }
}
