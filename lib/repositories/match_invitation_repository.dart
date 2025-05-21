import 'dart:math';

import '../global.dart';
import '../models/match_invitation_model.dart';
import '../supabase_client.dart';
import 'supabase_base_repository.dart';

/// Repository for handling match invitation data in Supabase
class MatchInvitationRepository extends SupabaseBaseRepository<MatchInvitationModel> {
  // Singleton pattern
  static MatchInvitationRepository? _instance;
  static MatchInvitationRepository get instance => _instance ??= MatchInvitationRepository._();

  MatchInvitationRepository._() : super('match_invitations');

  @override
  MatchInvitationModel fromSupabase(Map<String, dynamic> data, String id) {
    return MatchInvitationModel.fromSupabase(data, id);
  }

  @override
  Map<String, dynamic> toSupabase(MatchInvitationModel model) {
    return model.toMap();
  }

  /// Generate a unique invitation code
  String _generateInvitationCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Create a new match invitation
  Future<String> createInvitation({
    required String creatorId,
    String? recipientId,
    Map<String, dynamic>? metadata,
    Duration validity = const Duration(hours: 24),
  }) async {
    try {
      final invitationCode = _generateInvitationCode();
      final expirationTime = DateTime.now().add(validity);
      
      final invitationModel = MatchInvitationModel(
        id: '', // Will be set by Supabase
        creatorId: creatorId,
        recipientId: recipientId,
        invitationCode: invitationCode,
        expirationTime: expirationTime,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: metadata,
      );

      final invitationId = await add(invitationModel);
      logger.info('Match invitation created: $invitationId with code $invitationCode');
      return invitationId;
    } catch (e) {
      logger.severe('Error creating match invitation: $e');
      rethrow;
    }
  }

  /// Get invitation by code
  Future<MatchInvitationModel?> getByCode(String code) async {
    try {
      final response = await table
          .select()
          .eq('invitation_code', code)
          .eq('is_deleted', false)
          .maybeSingle();
      
      if (response != null) {
        final id = response['id'] as String;
        return fromSupabase(response, id);
      }
      return null;
    } catch (e) {
      logger.severe('Error getting invitation by code: $e');
      rethrow;
    }
  }

  /// Accept an invitation
  Future<void> acceptInvitation(String invitationId, String recipientId) async {
    try {
      await update(invitationId, {
        'status': MatchInvitationStatus.accepted.index,
        'recipient_id': recipientId,
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      logger.info('Match invitation accepted: $invitationId by $recipientId');
    } catch (e) {
      logger.severe('Error accepting match invitation: $e');
      rethrow;
    }
  }

  /// Reject an invitation
  Future<void> rejectInvitation(String invitationId) async {
    try {
      await update(invitationId, {
        'status': MatchInvitationStatus.rejected.index,
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      logger.info('Match invitation rejected: $invitationId');
    } catch (e) {
      logger.severe('Error rejecting match invitation: $e');
      rethrow;
    }
  }

  /// Get active invitations created by a user
  Future<List<MatchInvitationModel>> getActiveInvitationsByCreator(String creatorId) async {
    try {
      final now = DateTime.now().toIso8601String();
      
      final response = await table
          .select()
          .eq('creator_id', creatorId)
          .eq('is_deleted', false)
          .eq('status', MatchInvitationStatus.pending.index)
          .gt('expiration_time', now)
          .order('created_at', ascending: false);
      
      return response.map((record) {
        final id = record['id'] as String;
        return fromSupabase(record, id);
      }).toList();
    } catch (e) {
      logger.severe('Error getting active invitations by creator: $e');
      rethrow;
    }
  }

  /// Get active invitations for a recipient
  Future<List<MatchInvitationModel>> getActiveInvitationsForRecipient(String recipientId) async {
    try {
      final now = DateTime.now().toIso8601String();
      
      final response = await table
          .select()
          .eq('recipient_id', recipientId)
          .eq('is_deleted', false)
          .eq('status', MatchInvitationStatus.pending.index)
          .gt('expiration_time', now)
          .order('created_at', ascending: false);
      
      return response.map((record) {
        final id = record['id'] as String;
        return fromSupabase(record, id);
      }).toList();
    } catch (e) {
      logger.severe('Error getting active invitations for recipient: $e');
      rethrow;
    }
  }
}
