/// Model for storing leaderboard entry data in Supabase
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
  final DateTime lastUpdated;
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

  // Create a LeaderboardEntryModel from a Supabase record
  factory LeaderboardEntryModel.fromSupabase(Map<String, dynamic> data, String id) {
    // Calculate win rate
    final gamesPlayed = data['games_played'] ?? 0;
    final gamesWon = data['games_won'] ?? 0;
    final winRate = gamesPlayed > 0 ? gamesWon / gamesPlayed : 0.0;

    return LeaderboardEntryModel(
      id: id,
      userId: data['user_id'] ?? '',
      displayName: data['display_name'] ?? '',
      eloRating: data['elo_rating'] ?? 1200,
      rank: data['rank'] ?? 0,
      gamesPlayed: gamesPlayed,
      gamesWon: gamesWon,
      gamesLost: data['games_lost'] ?? 0,
      gamesDraw: data['games_draw'] ?? 0,
      winRate: winRate,
      lastUpdated: DateTime.parse(data['last_updated'] ?? DateTime.now().toIso8601String()),
      metadata: data['metadata'],
    );
  }

  // Convert LeaderboardEntryModel to a Map for Supabase
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'display_name': displayName,
      'elo_rating': eloRating,
      'rank': rank,
      'games_played': gamesPlayed,
      'games_won': gamesWon,
      'games_lost': gamesLost,
      'games_draw': gamesDraw,
      'win_rate': winRate,
      'last_updated': lastUpdated.toIso8601String(),
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
    DateTime? lastUpdated,
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
