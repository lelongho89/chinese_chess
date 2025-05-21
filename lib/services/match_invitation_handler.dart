import 'package:flutter/material.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

import '../global.dart';
import '../models/match_invitation_model.dart';
import '../models/supabase_auth_service.dart';
import '../repositories/match_invitation_repository.dart';
import '../repositories/user_repository.dart';
import '../screens/qr_generator_screen.dart';
import '../screens/qr_scanner_screen.dart';
import '../services/game_service.dart';

/// Service for handling match invitations
class MatchInvitationHandler {
  // Singleton pattern
  static MatchInvitationHandler? _instance;
  static MatchInvitationHandler get instance => _instance ??= MatchInvitationHandler._();

  MatchInvitationHandler._();

  /// Show QR code scanner
  Future<void> showQRScanner(BuildContext context) async {
    try {
      final authService = await SupabaseAuthService.getInstance();
      final user = authService.user;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QRScannerScreen(
            onInvitationScanned: (invitation) => _handleScannedInvitation(context, invitation),
          ),
        ),
      );
    } catch (e) {
      logger.severe('Error showing QR scanner: $e');
      if (context.mounted) {
        MyDialog.alert(
          '${context.l10n.errorShowingQRScanner}: $e',
          title: context.l10n.error,
        );
      }
    }
  }

  /// Show QR code generator
  Future<void> showQRGenerator(BuildContext context, {Map<String, dynamic>? metadata}) async {
    try {
      final authService = await SupabaseAuthService.getInstance();
      final user = authService.user;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QRGeneratorScreen(
            metadata: metadata,
          ),
        ),
      );
    } catch (e) {
      logger.severe('Error showing QR generator: $e');
      if (context.mounted) {
        MyDialog.alert(
          '${context.l10n.errorShowingQRGenerator}: $e',
          title: context.l10n.error,
        );
      }
    }
  }

  /// Handle a scanned invitation
  Future<void> _handleScannedInvitation(BuildContext context, MatchInvitationModel invitation) async {
    try {
      final authService = await SupabaseAuthService.getInstance();
      final user = authService.user;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      // Check if the user is the creator of the invitation
      if (invitation.creatorId == user.id) {
        if (context.mounted) {
          MyDialog.alert(
            context.l10n.cannotJoinYourOwnInvitation,
            title: context.l10n.error,
          );
        }
        return;
      }
      
      // Get the creator's user info
      final creator = await UserRepository.instance.get(invitation.creatorId);
      
      if (creator == null) {
        throw Exception('Creator not found');
      }
      
      // Ask for confirmation
      final confirmed = await MyDialog.confirm(
        Text(
          context.l10n.joinMatchConfirmation(creator.displayName),
          style: const TextStyle(fontSize: 16),
        ),
        title: context.l10n.joinMatch,
      );
      
      if (confirmed != true || !context.mounted) {
        return;
      }
      
      // Accept the invitation
      await MatchInvitationRepository.instance.acceptInvitation(
        invitation.id,
        user.id,
      );
      
      // Start a game
      final gameId = await GameService.instance.startGame(
        redPlayerId: invitation.creatorId,
        blackPlayerId: user.id,
        isRanked: invitation.metadata?['isRanked'] ?? true,
        metadata: {
          ...?invitation.metadata,
          'invitationId': invitation.id,
        },
      );
      
      logger.info('Game started from invitation: $gameId');
      
      // Show success message
      if (context.mounted) {
        MyDialog.alert(
          context.l10n.matchJoinedSuccessfully,
          title: context.l10n.success,
        );
      }
    } catch (e) {
      logger.severe('Error handling scanned invitation: $e');
      if (context.mounted) {
        MyDialog.alert(
          '${context.l10n.errorJoiningMatch}: $e',
          title: context.l10n.error,
        );
      }
    }
  }
}
