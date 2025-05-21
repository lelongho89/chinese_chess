/// Model for storing match data in Supabase
class MatchModel {
  final String id;
  final String? tournamentId;
  final String redPlayerId;
  final String blackPlayerId;
  final String? winnerId;
  final bool isDraw;
  final MatchStatus status;
  final DateTime scheduledTime;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? gameId;
  final int round;
  final int matchNumber;
  final Map<String, dynamic>? metadata;

  MatchModel({
    required this.id,
    this.tournamentId,
    required this.redPlayerId,
    required this.blackPlayerId,
    this.winnerId,
    this.isDraw = false,
    this.status = MatchStatus.scheduled,
    required this.scheduledTime,
    this.startTime,
    this.endTime,
    this.gameId,
    required this.round,
    required this.matchNumber,
    this.metadata,
  });

  // Create a MatchModel from a Supabase record
  factory MatchModel.fromSupabase(Map<String, dynamic> data, String id) {
    return MatchModel(
      id: id,
      tournamentId: data['tournament_id'],
      redPlayerId: data['red_player_id'] ?? '',
      blackPlayerId: data['black_player_id'] ?? '',
      winnerId: data['winner_id'],
      isDraw: data['is_draw'] ?? false,
      status: MatchStatus.values[data['status'] ?? 0],
      scheduledTime: DateTime.parse(data['scheduled_time'] ?? DateTime.now().toIso8601String()),
      startTime: data['start_time'] != null ? DateTime.parse(data['start_time']) : null,
      endTime: data['end_time'] != null ? DateTime.parse(data['end_time']) : null,
      gameId: data['game_id'],
      round: data['round'] ?? 0,
      matchNumber: data['match_number'] ?? 0,
      metadata: data['metadata'],
    );
  }

  // Convert MatchModel to a Map for Supabase
  Map<String, dynamic> toMap() {
    return {
      'tournament_id': tournamentId,
      'red_player_id': redPlayerId,
      'black_player_id': blackPlayerId,
      'winner_id': winnerId,
      'is_draw': isDraw,
      'status': status.index,
      'scheduled_time': scheduledTime.toIso8601String(),
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'game_id': gameId,
      'round': round,
      'match_number': matchNumber,
      'metadata': metadata,
    };
  }

  // Create a copy of MatchModel with updated fields
  MatchModel copyWith({
    String? tournamentId,
    String? redPlayerId,
    String? blackPlayerId,
    String? winnerId,
    bool? isDraw,
    MatchStatus? status,
    DateTime? scheduledTime,
    DateTime? startTime,
    DateTime? endTime,
    String? gameId,
    int? round,
    int? matchNumber,
    Map<String, dynamic>? metadata,
  }) {
    return MatchModel(
      id: id,
      tournamentId: tournamentId ?? this.tournamentId,
      redPlayerId: redPlayerId ?? this.redPlayerId,
      blackPlayerId: blackPlayerId ?? this.blackPlayerId,
      winnerId: winnerId ?? this.winnerId,
      isDraw: isDraw ?? this.isDraw,
      status: status ?? this.status,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      gameId: gameId ?? this.gameId,
      round: round ?? this.round,
      matchNumber: matchNumber ?? this.matchNumber,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum MatchStatus {
  scheduled,
  inProgress,
  completed,
  cancelled
}
