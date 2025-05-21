/// Model for storing game data in Supabase
class GameDataModel {
  final String id;
  final String redPlayerId;
  final String blackPlayerId;
  final String? winnerId;
  final bool isDraw;
  final int moveCount;
  final List<String> moves;
  final String finalFen;
  final int redTimeRemaining; // in seconds
  final int blackTimeRemaining; // in seconds
  final DateTime startedAt;
  final DateTime? endedAt;
  final bool isRanked;
  final int? tournamentId;
  final Map<String, dynamic>? metadata;

  GameDataModel({
    required this.id,
    required this.redPlayerId,
    required this.blackPlayerId,
    this.winnerId,
    this.isDraw = false,
    this.moveCount = 0,
    this.moves = const [],
    required this.finalFen,
    required this.redTimeRemaining,
    required this.blackTimeRemaining,
    required this.startedAt,
    this.endedAt,
    this.isRanked = true,
    this.tournamentId,
    this.metadata,
  });

  // Create a GameDataModel from a Supabase record
  factory GameDataModel.fromSupabase(Map<String, dynamic> data, String id) {
    return GameDataModel(
      id: id,
      redPlayerId: data['red_player_id'] ?? '',
      blackPlayerId: data['black_player_id'] ?? '',
      winnerId: data['winner_id'],
      isDraw: data['is_draw'] ?? false,
      moveCount: data['move_count'] ?? 0,
      moves: List<String>.from(data['moves'] ?? []),
      finalFen: data['final_fen'] ?? '',
      redTimeRemaining: data['red_time_remaining'] ?? 0,
      blackTimeRemaining: data['black_time_remaining'] ?? 0,
      startedAt: DateTime.parse(data['started_at'] ?? DateTime.now().toIso8601String()),
      endedAt: data['ended_at'] != null ? DateTime.parse(data['ended_at']) : null,
      isRanked: data['is_ranked'] ?? true,
      tournamentId: data['tournament_id'],
      metadata: data['metadata'],
    );
  }

  // Convert GameDataModel to a Map for Supabase
  Map<String, dynamic> toMap() {
    return {
      'red_player_id': redPlayerId,
      'black_player_id': blackPlayerId,
      'winner_id': winnerId,
      'is_draw': isDraw,
      'move_count': moveCount,
      'moves': moves,
      'final_fen': finalFen,
      'red_time_remaining': redTimeRemaining,
      'black_time_remaining': blackTimeRemaining,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'is_ranked': isRanked,
      'tournament_id': tournamentId,
      'metadata': metadata,
    };
  }

  // Create a copy of GameDataModel with updated fields
  GameDataModel copyWith({
    String? redPlayerId,
    String? blackPlayerId,
    String? winnerId,
    bool? isDraw,
    int? moveCount,
    List<String>? moves,
    String? finalFen,
    int? redTimeRemaining,
    int? blackTimeRemaining,
    DateTime? startedAt,
    DateTime? endedAt,
    bool? isRanked,
    int? tournamentId,
    Map<String, dynamic>? metadata,
  }) {
    return GameDataModel(
      id: id,
      redPlayerId: redPlayerId ?? this.redPlayerId,
      blackPlayerId: blackPlayerId ?? this.blackPlayerId,
      winnerId: winnerId ?? this.winnerId,
      isDraw: isDraw ?? this.isDraw,
      moveCount: moveCount ?? this.moveCount,
      moves: moves ?? this.moves,
      finalFen: finalFen ?? this.finalFen,
      redTimeRemaining: redTimeRemaining ?? this.redTimeRemaining,
      blackTimeRemaining: blackTimeRemaining ?? this.blackTimeRemaining,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      isRanked: isRanked ?? this.isRanked,
      tournamentId: tournamentId ?? this.tournamentId,
      metadata: metadata ?? this.metadata,
    );
  }
}
