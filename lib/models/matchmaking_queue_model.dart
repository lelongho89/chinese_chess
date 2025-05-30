/// Status of a matchmaking queue entry
enum MatchmakingStatus {
  waiting,
  pending_confirmation,
  matched,
  cancelled,
  expired,
}

/// Queue type for matchmaking
enum QueueType {
  ranked,
  casual,
  tournament,
}

/// Model for storing matchmaking queue data in Supabase
class MatchmakingQueueModel {
  final String id;
  final String userId;
  final int eloRating;
  final QueueType queueType;
  final int timeControl; // Base time in seconds (5 minutes)
  final int incrementSeconds; // Time increment in seconds (3 seconds)
  final int maxEloDifference;
  final MatchmakingStatus status;
  final String? matchedWithUserId;
  final String? matchId;
  final DateTime joinedAt;
  final DateTime? matchedAt;
  final DateTime expiresAt;
  final DateTime? confirmationExpiresAt;
  final bool isConfirmed;
  final DateTime? confirmationTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final Map<String, dynamic>? metadata;

  MatchmakingQueueModel({
    required this.id,
    required this.userId,
    required this.eloRating,
    this.queueType = QueueType.ranked,
    this.timeControl = 300, // 5 minutes default
    this.incrementSeconds = 3, // +3 seconds default
    this.maxEloDifference = 200,
    this.status = MatchmakingStatus.waiting,
    this.matchedWithUserId,
    this.matchId,
    required this.joinedAt,
    this.matchedAt,
    required this.expiresAt,
    this.confirmationExpiresAt,
    this.isConfirmed = false,
    this.confirmationTime,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.metadata,
  });

  /// Create a MatchmakingQueueModel from a Supabase record
  factory MatchmakingQueueModel.fromSupabase(Map<String, dynamic> data, String id) {
    return MatchmakingQueueModel(
      id: id,
      userId: data['user_id'] ?? '',
      eloRating: data['elo_rating'] ?? 1200,
      queueType: _parseQueueType(data['queue_type']),
      timeControl: data['time_control'] ?? 300, // Default to 5 minutes if not specified
      incrementSeconds: data['increment_seconds'] ?? 3, // Default to 3 seconds if not specified
      maxEloDifference: data['max_elo_difference'] ?? 200,
      status: _parseStatus(data['status']),
      matchedWithUserId: data['matched_with_user_id'],
      matchId: data['match_id'],
      joinedAt: DateTime.parse(data['joined_at']),
      matchedAt: data['matched_at'] != null ? DateTime.parse(data['matched_at']) : null,
      expiresAt: DateTime.parse(data['expires_at']),
      confirmationExpiresAt: data['confirmation_expires_at'] != null ? DateTime.parse(data['confirmation_expires_at']) : null,
      isConfirmed: data['is_confirmed'] ?? false,
      confirmationTime: data['confirmation_time'] != null ? DateTime.parse(data['confirmation_time']) : null,
      createdAt: DateTime.parse(data['created_at']),
      updatedAt: DateTime.parse(data['updated_at']),
      isDeleted: data['is_deleted'] ?? false,
      metadata: data['metadata'],
    );
  }

  /// Convert the model to a Supabase record
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'elo_rating': eloRating,
      'queue_type': queueType.name,
      'time_control': timeControl,
      'increment_seconds': incrementSeconds,
      'max_elo_difference': maxEloDifference,
      'status': status.name,
      'matched_with_user_id': matchedWithUserId,
      'match_id': matchId,
      'joined_at': joinedAt.toIso8601String(),
      'matched_at': matchedAt?.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'confirmation_expires_at': confirmationExpiresAt?.toIso8601String(),
      'is_confirmed': isConfirmed,
      'confirmation_time': confirmationTime?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_deleted': isDeleted,
      'metadata': metadata,
    };
  }

  /// Create a copy of this model with the given fields replaced
  MatchmakingQueueModel copyWith({
    String? id,
    String? userId,
    int? eloRating,
    QueueType? queueType,
    int? timeControl,
    int? incrementSeconds,
    int? maxEloDifference,
    MatchmakingStatus? status,
    String? matchedWithUserId,
    String? matchId,
    DateTime? joinedAt,
    DateTime? matchedAt,
    DateTime? expiresAt,
    DateTime? confirmationExpiresAt,
    bool? isConfirmed,
    DateTime? confirmationTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    Map<String, dynamic>? metadata,
  }) {
    return MatchmakingQueueModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eloRating: eloRating ?? this.eloRating,
      queueType: queueType ?? this.queueType,
      timeControl: timeControl ?? this.timeControl,
      incrementSeconds: incrementSeconds ?? this.incrementSeconds,
      maxEloDifference: maxEloDifference ?? this.maxEloDifference,
      status: status ?? this.status,
      matchedWithUserId: matchedWithUserId ?? this.matchedWithUserId,
      matchId: matchId ?? this.matchId,
      joinedAt: joinedAt ?? this.joinedAt,
      matchedAt: matchedAt ?? this.matchedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      confirmationExpiresAt: confirmationExpiresAt ?? this.confirmationExpiresAt,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      confirmationTime: confirmationTime ?? this.confirmationTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get the wait time in seconds
  int get waitTimeSeconds {
    if (status != MatchmakingStatus.waiting) return 0;
    return DateTime.now().difference(joinedAt).inSeconds;
  }

  /// Check if the queue entry is expired
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  /// Get a human-readable status description
  String getStatusDescription(BuildContext context) {
    switch (status) {
      case MatchmakingStatus.waiting:
        return context.l10n.searchingForOpponent;
      case MatchmakingStatus.pending_confirmation:
        return context.l10n.waitingForConfirmation;
      case MatchmakingStatus.matched:
        return context.l10n.matchFoundExclamation;
      case MatchmakingStatus.cancelled:
        return context.l10n.searchCancelled;
      case MatchmakingStatus.expired:
        return context.l10n.searchExpired;
    }
  }

  /// Parse queue type from string
  static QueueType _parseQueueType(String? value) {
    switch (value) {
      case 'ranked':
        return QueueType.ranked;
      case 'casual':
        return QueueType.casual;
      case 'tournament':
        return QueueType.tournament;
      default:
        return QueueType.ranked;
    }
  }

  /// Parse status from string
  static MatchmakingStatus _parseStatus(String? value) {
    switch (value) {
      case 'waiting':
        return MatchmakingStatus.waiting;
      case 'pending_confirmation':
        return MatchmakingStatus.pending_confirmation;
      case 'matched':
        return MatchmakingStatus.matched;
      case 'cancelled':
        return MatchmakingStatus.cancelled;
      case 'expired':
        return MatchmakingStatus.expired;
      default:
        return MatchmakingStatus.waiting;
    }
  }

  @override
  String toString() {
    return 'MatchmakingQueueModel(id: $id, userId: $userId, eloRating: $eloRating, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MatchmakingQueueModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
