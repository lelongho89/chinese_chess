import 'game_move_model.dart';

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

  // Real-time game state fields
  final String currentFen;
  final int currentPlayer; // 0 for red, 1 for black
  final GameStatus gameStatus;
  final String? lastMove;
  final DateTime? lastMoveAt;
  final PlayerConnectionStatus connectionStatus;

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
    // Real-time fields with defaults
    this.currentFen = 'rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR',
    this.currentPlayer = 0,
    this.gameStatus = GameStatus.active,
    this.lastMove,
    this.lastMoveAt,
    this.connectionStatus = const PlayerConnectionStatus(),
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
      // Real-time fields
      currentFen: data['current_fen'] ?? 'rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR',
      currentPlayer: data['current_player'] ?? 0,
      gameStatus: parseGameStatus(data['game_status']),
      lastMove: data['last_move'],
      lastMoveAt: data['last_move_at'] != null ? DateTime.parse(data['last_move_at']) : null,
      connectionStatus: data['connection_status'] != null
          ? PlayerConnectionStatus.fromJson(data['connection_status'])
          : const PlayerConnectionStatus(),
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
      // Real-time fields
      'current_fen': currentFen,
      'current_player': currentPlayer,
      'game_status': gameStatus.name,
      'last_move': lastMove,
      'last_move_at': lastMoveAt?.toIso8601String(),
      'connection_status': connectionStatus.toJson(),
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
    // Real-time fields
    String? currentFen,
    int? currentPlayer,
    GameStatus? gameStatus,
    String? lastMove,
    DateTime? lastMoveAt,
    PlayerConnectionStatus? connectionStatus,
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
      // Real-time fields
      currentFen: currentFen ?? this.currentFen,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      gameStatus: gameStatus ?? this.gameStatus,
      lastMove: lastMove ?? this.lastMove,
      lastMoveAt: lastMoveAt ?? this.lastMoveAt,
      connectionStatus: connectionStatus ?? this.connectionStatus,
    );
  }

  // Helper methods for game state
  bool get isRedTurn => currentPlayer == 0;
  bool get isBlackTurn => currentPlayer == 1;
  bool get isActive => gameStatus.isActive;
  bool get isEnded => gameStatus.isEnded;
  bool get isPaused => gameStatus.isPaused;

  String get currentPlayerName => isRedTurn ? 'Red' : 'Black';

  /// Check if a specific player is the current player
  bool isPlayerTurn(String playerId) {
    return (isRedTurn && playerId == redPlayerId) ||
           (isBlackTurn && playerId == blackPlayerId);
  }

  /// Get the opponent's player ID for a given player
  String? getOpponentId(String playerId) {
    if (playerId == redPlayerId) return blackPlayerId;
    if (playerId == blackPlayerId) return redPlayerId;
    return null;
  }

  /// Check if both players are connected
  bool get bothPlayersConnected => connectionStatus.bothConnected;

  /// Check if any player is disconnected
  bool get anyPlayerDisconnected => connectionStatus.anyDisconnected;
}
