/// Model for storing individual game moves in real-time
class GameMoveModel {
  final String id;
  final String gameId;
  final String playerId;
  final int moveNumber;
  final String moveNotation; // e.g., "e2e4", "h7h5"
  final String fenAfterMove;
  final int timeRemaining; // seconds remaining for the player
  final int moveTime; // time taken for this move in milliseconds
  final bool isCheck;
  final bool isCheckmate;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  GameMoveModel({
    required this.id,
    required this.gameId,
    required this.playerId,
    required this.moveNumber,
    required this.moveNotation,
    required this.fenAfterMove,
    required this.timeRemaining,
    required this.moveTime,
    this.isCheck = false,
    this.isCheckmate = false,
    required this.createdAt,
    this.metadata,
  });

  /// Create a GameMoveModel from a Supabase record
  factory GameMoveModel.fromSupabase(Map<String, dynamic> data, String id) {
    return GameMoveModel(
      id: id,
      gameId: data['game_id'] ?? '',
      playerId: data['player_id'] ?? '',
      moveNumber: data['move_number'] ?? 0,
      moveNotation: data['move_notation'] ?? '',
      fenAfterMove: data['fen_after_move'] ?? '',
      timeRemaining: data['time_remaining'] ?? 0,
      moveTime: data['move_time'] ?? 0,
      isCheck: data['is_check'] ?? false,
      isCheckmate: data['is_checkmate'] ?? false,
      createdAt: DateTime.parse(data['created_at'] ?? DateTime.now().toIso8601String()),
      metadata: data['metadata'],
    );
  }

  /// Convert the model to a Supabase record
  Map<String, dynamic> toMap() {
    return {
      'game_id': gameId,
      'player_id': playerId,
      'move_number': moveNumber,
      'move_notation': moveNotation,
      'fen_after_move': fenAfterMove,
      'time_remaining': timeRemaining,
      'move_time': moveTime,
      'is_check': isCheck,
      'is_checkmate': isCheckmate,
      'created_at': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create a copy of this model with the given fields replaced
  GameMoveModel copyWith({
    String? id,
    String? gameId,
    String? playerId,
    int? moveNumber,
    String? moveNotation,
    String? fenAfterMove,
    int? timeRemaining,
    int? moveTime,
    bool? isCheck,
    bool? isCheckmate,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return GameMoveModel(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      playerId: playerId ?? this.playerId,
      moveNumber: moveNumber ?? this.moveNumber,
      moveNotation: moveNotation ?? this.moveNotation,
      fenAfterMove: fenAfterMove ?? this.fenAfterMove,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      moveTime: moveTime ?? this.moveTime,
      isCheck: isCheck ?? this.isCheck,
      isCheckmate: isCheckmate ?? this.isCheckmate,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert move notation to Chinese chess format
  String get chineseNotation {
    // This would convert algebraic notation to Chinese chess notation
    // For now, return the raw notation
    return moveNotation;
  }

  /// Get the player color (0 for red, 1 for black)
  int get playerColor {
    return (moveNumber - 1) % 2;
  }

  /// Check if this move is by the red player
  bool get isRedMove {
    return playerColor == 0;
  }

  /// Check if this move is by the black player
  bool get isBlackMove {
    return playerColor == 1;
  }

  /// Get a human-readable description of the move
  String get description {
    final color = isRedMove ? 'Red' : 'Black';
    final status = isCheckmate ? ' (Checkmate)' : isCheck ? ' (Check)' : '';
    return '$color: $moveNotation$status';
  }

  /// Get the time taken for this move in a human-readable format
  String get formattedMoveTime {
    if (moveTime < 1000) {
      return '${moveTime}ms';
    } else if (moveTime < 60000) {
      return '${(moveTime / 1000).toStringAsFixed(1)}s';
    } else {
      final minutes = moveTime ~/ 60000;
      final seconds = (moveTime % 60000) / 1000;
      return '${minutes}m ${seconds.toStringAsFixed(1)}s';
    }
  }

  /// Get the remaining time in a human-readable format
  String get formattedTimeRemaining {
    final minutes = timeRemaining ~/ 60;
    final seconds = timeRemaining % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'GameMoveModel(id: $id, gameId: $gameId, moveNumber: $moveNumber, move: $moveNotation)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameMoveModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Enum for game connection status
enum ConnectionStatus {
  connected,
  disconnected,
  reconnecting,
}

/// Model for tracking player connection status
class PlayerConnectionStatus {
  final ConnectionStatus red;
  final ConnectionStatus black;

  const PlayerConnectionStatus({
    this.red = ConnectionStatus.connected,
    this.black = ConnectionStatus.connected,
  });

  factory PlayerConnectionStatus.fromJson(Map<String, dynamic> json) {
    return PlayerConnectionStatus(
      red: _parseConnectionStatus(json['red']),
      black: _parseConnectionStatus(json['black']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'red': red.name,
      'black': black.name,
    };
  }

  static ConnectionStatus _parseConnectionStatus(String? value) {
    switch (value) {
      case 'connected':
        return ConnectionStatus.connected;
      case 'disconnected':
        return ConnectionStatus.disconnected;
      case 'reconnecting':
        return ConnectionStatus.reconnecting;
      default:
        return ConnectionStatus.connected;
    }
  }

  PlayerConnectionStatus copyWith({
    ConnectionStatus? red,
    ConnectionStatus? black,
  }) {
    return PlayerConnectionStatus(
      red: red ?? this.red,
      black: black ?? this.black,
    );
  }

  bool get bothConnected => red == ConnectionStatus.connected && black == ConnectionStatus.connected;
  bool get anyDisconnected => red == ConnectionStatus.disconnected || black == ConnectionStatus.disconnected;
  bool get anyReconnecting => red == ConnectionStatus.reconnecting || black == ConnectionStatus.reconnecting;

  @override
  String toString() {
    return 'PlayerConnectionStatus(red: ${red.name}, black: ${black.name})';
  }
}

/// Enum for game status
enum GameStatus {
  active,
  paused,
  ended,
  abandoned,
}

/// Extension for GameStatus
extension GameStatusExtension on GameStatus {
  String get displayName {
    switch (this) {
      case GameStatus.active:
        return 'Active';
      case GameStatus.paused:
        return 'Paused';
      case GameStatus.ended:
        return 'Ended';
      case GameStatus.abandoned:
        return 'Abandoned';
    }
  }

  bool get isActive => this == GameStatus.active;
  bool get isPaused => this == GameStatus.paused;
  bool get isEnded => this == GameStatus.ended;
  bool get isAbandoned => this == GameStatus.abandoned;
  bool get isFinished => isEnded || isAbandoned;

}

/// Helper function to parse GameStatus from string
GameStatus parseGameStatus(String? value) {
  switch (value) {
    case 'active':
      return GameStatus.active;
    case 'paused':
      return GameStatus.paused;
    case 'ended':
      return GameStatus.ended;
    case 'abandoned':
      return GameStatus.abandoned;
    default:
      return GameStatus.active;
  }
}
