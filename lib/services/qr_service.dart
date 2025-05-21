import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../global.dart';
import '../models/match_invitation_model.dart';
import '../repositories/match_invitation_repository.dart';

/// Service for handling QR code operations
class QRService {
  // Singleton pattern
  static QRService? _instance;
  static QRService get instance => _instance ??= QRService._();

  QRService._();

  /// Generate a QR code data for a match invitation
  Future<String> generateInvitationQRData({
    required String creatorId,
    String? recipientId,
    Map<String, dynamic>? metadata,
    Duration validity = const Duration(hours: 24),
  }) async {
    try {
      // Create a match invitation
      final invitationId = await MatchInvitationRepository.instance.createInvitation(
        creatorId: creatorId,
        recipientId: recipientId,
        metadata: metadata,
        validity: validity,
      );
      
      // Get the invitation
      final invitation = await MatchInvitationRepository.instance.get(invitationId);
      
      if (invitation == null) {
        throw Exception('Failed to create invitation');
      }
      
      // Create QR code data
      final qrData = {
        'type': 'match_invitation',
        'code': invitation.invitationCode,
      };
      
      return jsonEncode(qrData);
    } catch (e) {
      logger.severe('Error generating invitation QR data: $e');
      rethrow;
    }
  }

  /// Parse QR code data for a match invitation
  Future<MatchInvitationModel?> parseInvitationQRData(String qrData) async {
    try {
      final data = jsonDecode(qrData) as Map<String, dynamic>;
      
      if (data['type'] != 'match_invitation') {
        throw Exception('Invalid QR code type');
      }
      
      final code = data['code'] as String;
      
      // Get the invitation by code
      return await MatchInvitationRepository.instance.getByCode(code);
    } catch (e) {
      logger.severe('Error parsing invitation QR data: $e');
      rethrow;
    }
  }

  /// Create a QR code widget
  Widget createQRCode(String data, {
    double size = 200.0,
    Color backgroundColor = Colors.white,
    Color foregroundColor = Colors.black,
    EdgeInsets padding = const EdgeInsets.all(10.0),
    Widget? embeddedImage,
    QrEmbeddedImageStyle? embeddedImageStyle,
  }) {
    return Container(
      color: backgroundColor,
      padding: padding,
      child: QrImageView(
        data: data,
        version: QrVersions.auto,
        size: size,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        embeddedImage: embeddedImage != null ? 
          NetworkImage('assets/images/app_icon.png') : null,
        embeddedImageStyle: embeddedImageStyle,
        errorStateBuilder: (context, error) => Center(
          child: Text(
            'Error generating QR code: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  /// Capture QR code as image
  Future<Uint8List?> captureQRCode(GlobalKey qrKey) async {
    try {
      final boundary = qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary == null) {
        throw Exception('Failed to find render object');
      }
      
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        throw Exception('Failed to convert image to bytes');
      }
      
      return byteData.buffer.asUint8List();
    } catch (e) {
      logger.severe('Error capturing QR code: $e');
      return null;
    }
  }
}
