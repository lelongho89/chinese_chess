import 'package:flutter/foundation.dart';

/// Status of a match invitation
enum MatchInvitationStatus {
  pending,
  accepted,
  rejected,
  expired,
}

/// Model for storing match invitation data in Supabase
class MatchInvitationModel {
  final String id;
  final String creatorId;
  final String? recipientId;
  final MatchInvitationStatus status;
  final String invitationCode;
  final DateTime expirationTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final Map<String, dynamic>? metadata;

  MatchInvitationModel({
    required this.id,
    required this.creatorId,
    this.recipientId,
    this.status = MatchInvitationStatus.pending,
    required this.invitationCode,
    required this.expirationTime,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.metadata,
  });

  /// Create a MatchInvitationModel from a Supabase record
  factory MatchInvitationModel.fromSupabase(Map<String, dynamic> data, String id) {
    return MatchInvitationModel(
      id: id,
      creatorId: data['creator_id'] ?? '',
      recipientId: data['recipient_id'],
      status: MatchInvitationStatus.values[data['status'] ?? 0],
      invitationCode: data['invitation_code'] ?? '',
      expirationTime: DateTime.parse(data['expiration_time']),
      createdAt: DateTime.parse(data['created_at']),
      updatedAt: DateTime.parse(data['updated_at']),
      isDeleted: data['is_deleted'] ?? false,
      metadata: data['metadata'],
    );
  }

  /// Convert the model to a Supabase record
  Map<String, dynamic> toMap() {
    return {
      'creator_id': creatorId,
      'recipient_id': recipientId,
      'status': status.index,
      'invitation_code': invitationCode,
      'expiration_time': expirationTime.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_deleted': isDeleted,
      'metadata': metadata,
    };
  }

  /// Create a copy of this model with the given fields replaced
  MatchInvitationModel copyWith({
    String? id,
    String? creatorId,
    String? recipientId,
    MatchInvitationStatus? status,
    String? invitationCode,
    DateTime? expirationTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    Map<String, dynamic>? metadata,
  }) {
    return MatchInvitationModel(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      recipientId: recipientId ?? this.recipientId,
      status: status ?? this.status,
      invitationCode: invitationCode ?? this.invitationCode,
      expirationTime: expirationTime ?? this.expirationTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MatchInvitationModel &&
        other.id == id &&
        other.creatorId == creatorId &&
        other.recipientId == recipientId &&
        other.status == status &&
        other.invitationCode == invitationCode &&
        other.expirationTime == expirationTime &&
        other.isDeleted == isDeleted;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        creatorId.hashCode ^
        recipientId.hashCode ^
        status.hashCode ^
        invitationCode.hashCode ^
        expirationTime.hashCode ^
        isDeleted.hashCode;
  }
}
