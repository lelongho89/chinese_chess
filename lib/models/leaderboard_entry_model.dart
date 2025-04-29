import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for storing leaderboard entry data in Firestore
class LeaderboardEntryModel {
  final String id;
  final String userId;
  final String displayName;
  final int eloRating;
  final int rank;
  final int gamesPlayed;
  final int gamesWon;
  final int gamesLost;
  final int gamesDraw;
  final double winRate;
  final Timestamp lastUpdated;
  final Map<String, dynamic>? metadata;

  LeaderboardEntryModel({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.eloRating,
    required this.rank,
    required this.gamesPlayed,
    required this.gamesWon,
    required this.gamesLost,
    required this.gamesDraw,
    required this.winRate,
    required this.lastUpdated,
    this.metadata,
  });

  // Create a LeaderboardEntryModel from a Firestore document
  factory LeaderboardEntryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Calculate win rate
    final gamesPlayed = data['gamesPlayed'] ?? 0;
    final gamesWon = data['gamesWon'] ?? 0;
    final winRate = gamesPlayed > 0 ? gamesWon / gamesPlayed : 0.0;
    
    return LeaderboardEntryModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      displayName: data['displayName'] ?? '',
      eloRating: data['eloRating'] ?? 1200,
      rank: data['rank'] ?? 0,
      gamesPlayed: gamesPlayed,
      gamesWon: gamesWon,
      gamesLost: data['gamesLost'] ?? 0,
      gamesDraw: data['gamesDraw'] ?? 0,
      winRate: winRate,
      lastUpdated: data['lastUpdated'] ?? Timestamp.now(),
      metadata: data['metadata'],
    );
  }

  // Convert LeaderboardEntryModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'displayName': displayName,
      'eloRating': eloRating,
      'rank': rank,
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'gamesLost': gamesLost,
      'gamesDraw': gamesDraw,
      'winRate': winRate,
      'lastUpdated': lastUpdated,
      'metadata': metadata,
    };
  }

  // Create a copy of LeaderboardEntryModel with updated fields
  LeaderboardEntryModel copyWith({
    String? userId,
    String? displayName,
    int? eloRating,
    int? rank,
    int? gamesPlayed,
    int? gamesWon,
    int? gamesLost,
    int? gamesDraw,
    double? winRate,
    Timestamp? lastUpdated,
    Map<String, dynamic>? metadata,
  }) {
    return LeaderboardEntryModel(
      id: id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      eloRating: eloRating ?? this.eloRating,
      rank: rank ?? this.rank,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      gamesLost: gamesLost ?? this.gamesLost,
      gamesDraw: gamesDraw ?? this.gamesDraw,
      winRate: winRate ?? this.winRate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      metadata: metadata ?? this.metadata,
    );
  }
}
