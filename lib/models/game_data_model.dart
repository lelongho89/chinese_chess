import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for storing game data in Firestore
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
  final Timestamp startedAt;
  final Timestamp? endedAt;
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

  // Create a GameDataModel from a Firestore document
  factory GameDataModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GameDataModel(
      id: doc.id,
      redPlayerId: data['redPlayerId'] ?? '',
      blackPlayerId: data['blackPlayerId'] ?? '',
      winnerId: data['winnerId'],
      isDraw: data['isDraw'] ?? false,
      moveCount: data['moveCount'] ?? 0,
      moves: List<String>.from(data['moves'] ?? []),
      finalFen: data['finalFen'] ?? '',
      redTimeRemaining: data['redTimeRemaining'] ?? 0,
      blackTimeRemaining: data['blackTimeRemaining'] ?? 0,
      startedAt: data['startedAt'] ?? Timestamp.now(),
      endedAt: data['endedAt'],
      isRanked: data['isRanked'] ?? true,
      tournamentId: data['tournamentId'],
      metadata: data['metadata'],
    );
  }

  // Convert GameDataModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'redPlayerId': redPlayerId,
      'blackPlayerId': blackPlayerId,
      'winnerId': winnerId,
      'isDraw': isDraw,
      'moveCount': moveCount,
      'moves': moves,
      'finalFen': finalFen,
      'redTimeRemaining': redTimeRemaining,
      'blackTimeRemaining': blackTimeRemaining,
      'startedAt': startedAt,
      'endedAt': endedAt,
      'isRanked': isRanked,
      'tournamentId': tournamentId,
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
    Timestamp? startedAt,
    Timestamp? endedAt,
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
