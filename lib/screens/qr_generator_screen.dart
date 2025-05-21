import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

import '../global.dart';
import '../models/supabase_auth_service.dart';
import '../services/qr_service.dart';

/// Screen for generating QR codes for match invitations
class QRGeneratorScreen extends StatefulWidget {
  final Map<String, dynamic>? metadata;
  
  const QRGeneratorScreen({
    super.key,
    this.metadata,
  });

  @override
  State<QRGeneratorScreen> createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends State<QRGeneratorScreen> {
  final GlobalKey _qrKey = GlobalKey();
  String? _qrData;
  bool _isLoading = true;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _generateQRCode();
  }

  Future<void> _generateQRCode() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authService = await SupabaseAuthService.getInstance();
      final user = authService.user;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      // Generate QR code data
      final qrData = await QRService.instance.generateInvitationQRData(
        creatorId: user.id,
        metadata: widget.metadata,
      );
      
      setState(() {
        _qrData = qrData;
        _isLoading = false;
      });
    } catch (e) {
      logger.severe('Error generating QR code: $e');
      if (mounted) {
        MyDialog.alert(
          '${context.l10n.errorGeneratingQRCode}: $e',
          title: context.l10n.error,
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _shareQRCode() async {
    if (_qrData == null || _isSharing) return;
    
    setState(() {
      _isSharing = true;
    });
    
    try {
      // Capture the QR code as an image
      final imageBytes = await QRService.instance.captureQRCode(_qrKey);
      
      if (imageBytes == null) {
        throw Exception('Failed to capture QR code');
      }
      
      // Save the image to a temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/match_invitation_qr.png');
      await file.writeAsBytes(imageBytes);
      
      // Share the image
      final result = await SharePlus.instance.share(
        ShareParams(
          text: context.l10n.joinMyChineseChessMatch,
          files: [XFile(file.path)],
        ),
      );
      
      if (result.status == ShareResultStatus.success) {
        logger.info('QR code shared successfully');
      } else {
        logger.info('QR code sharing canceled or failed');
      }
    } catch (e) {
      logger.severe('Error sharing QR code: $e');
      if (mounted) {
        MyDialog.alert(
          '${context.l10n.errorSharingQRCode}: $e',
          title: context.l10n.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.inviteFriend),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.secondary,
                ),
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.l10n.scanQRCodeToJoinMatch,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Center(
                  child: RepaintBoundary(
                    key: _qrKey,
                    child: QRService.instance.createQRCode(
                      _qrData!,
                      size: 250,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    context.l10n.qrCodeValidFor24Hours,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _isSharing ? null : _shareQRCode,
                  icon: const Icon(Icons.share),
                  label: Text(_isSharing
                      ? context.l10n.sharing
                      : context.l10n.shareQRCode),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
