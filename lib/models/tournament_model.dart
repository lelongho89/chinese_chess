import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for storing tournament data in Firestore
class TournamentModel {
  final String id;
  final String name;
  final String description;
  final String creatorId;
  final List<String> participantIds;
  final int maxParticipants;
  final TournamentStatus status;
  final TournamentType type;
  final Timestamp startTime;
  final Timestamp? endTime;
  final Map<String, List<String>> brackets; // Round -> List of match IDs
  final Map<String, dynamic>? settings;
  final Map<String, dynamic>? metadata;

  TournamentModel({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorId,
    this.participantIds = const [],
    required this.maxParticipants,
    this.status = TournamentStatus.upcoming,
    this.type = TournamentType.singleElimination,
    required this.startTime,
    this.endTime,
    this.brackets = const {},
    this.settings,
    this.metadata,
  });

  // Create a TournamentModel from a Firestore document
  factory TournamentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Convert brackets data from Firestore
    Map<String, List<String>> brackets = {};
    if (data['brackets'] != null) {
      final Map<String, dynamic> bracketsData = data['brackets'];
      bracketsData.forEach((key, value) {
        brackets[key] = List<String>.from(value);
      });
    }
    
    return TournamentModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      creatorId: data['creatorId'] ?? '',
      participantIds: List<String>.from(data['participantIds'] ?? []),
      maxParticipants: data['maxParticipants'] ?? 8,
      status: TournamentStatus.values[data['status'] ?? 0],
      type: TournamentType.values[data['type'] ?? 0],
      startTime: data['startTime'] ?? Timestamp.now(),
      endTime: data['endTime'],
      brackets: brackets,
      settings: data['settings'],
      metadata: data['metadata'],
    );
  }

  // Convert TournamentModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'creatorId': creatorId,
      'participantIds': participantIds,
      'maxParticipants': maxParticipants,
      'status': status.index,
      'type': type.index,
      'startTime': startTime,
      'endTime': endTime,
      'brackets': brackets,
      'settings': settings,
      'metadata': metadata,
    };
  }

  // Create a copy of TournamentModel with updated fields
  TournamentModel copyWith({
    String? name,
    String? description,
    String? creatorId,
    List<String>? participantIds,
    int? maxParticipants,
    TournamentStatus? status,
    TournamentType? type,
    Timestamp? startTime,
    Timestamp? endTime,
    Map<String, List<String>>? brackets,
    Map<String, dynamic>? settings,
    Map<String, dynamic>? metadata,
  }) {
    return TournamentModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      participantIds: participantIds ?? this.participantIds,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      status: status ?? this.status,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      brackets: brackets ?? this.brackets,
      settings: settings ?? this.settings,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum TournamentStatus {
  upcoming,
  inProgress,
  completed,
  cancelled
}

enum TournamentType {
  singleElimination,
  doubleElimination,
  roundRobin,
  swiss
}
