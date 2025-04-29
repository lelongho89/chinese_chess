import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for storing match data in Firestore
class MatchModel {
  final String id;
  final String? tournamentId;
  final String redPlayerId;
  final String blackPlayerId;
  final String? winnerId;
  final bool isDraw;
  final MatchStatus status;
  final Timestamp scheduledTime;
  final Timestamp? startTime;
  final Timestamp? endTime;
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

  // Create a MatchModel from a Firestore document
  factory MatchModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MatchModel(
      id: doc.id,
      tournamentId: data['tournamentId'],
      redPlayerId: data['redPlayerId'] ?? '',
      blackPlayerId: data['blackPlayerId'] ?? '',
      winnerId: data['winnerId'],
      isDraw: data['isDraw'] ?? false,
      status: MatchStatus.values[data['status'] ?? 0],
      scheduledTime: data['scheduledTime'] ?? Timestamp.now(),
      startTime: data['startTime'],
      endTime: data['endTime'],
      gameId: data['gameId'],
      round: data['round'] ?? 0,
      matchNumber: data['matchNumber'] ?? 0,
      metadata: data['metadata'],
    );
  }

  // Convert MatchModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'tournamentId': tournamentId,
      'redPlayerId': redPlayerId,
      'blackPlayerId': blackPlayerId,
      'winnerId': winnerId,
      'isDraw': isDraw,
      'status': status.index,
      'scheduledTime': scheduledTime,
      'startTime': startTime,
      'endTime': endTime,
      'gameId': gameId,
      'round': round,
      'matchNumber': matchNumber,
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
    Timestamp? scheduledTime,
    Timestamp? startTime,
    Timestamp? endTime,
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
