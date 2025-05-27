import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

import '../global.dart';
import '../models/match_invitation_model.dart';
import '../services/qr_service.dart';

/// Screen for scanning QR codes
class QRScannerScreen extends StatefulWidget {
  final Function(MatchInvitationModel) onInvitationScanned;

  const QRScannerScreen({
    super.key,
    required this.onInvitationScanned,
  });

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> with WidgetsBindingObserver {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      controller.start();
    } else {
      controller.stop();
    }
  }

  Future<void> _processQRCode(String data) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Parse the QR code data
      final invitation = await QRService.instance.parseInvitationQRData(data);

      if (invitation == null) {
        if (mounted) {
          MyDialog.alert(
            context.l10n.invalidOrExpiredInvitation,
            title: context.l10n.error,
          );
        }
        return;
      }

      // Check if the invitation is valid
      if (invitation.status != MatchInvitationStatus.pending) {
        if (mounted) {
          MyDialog.alert(
            context.l10n.invitationAlreadyUsed,
            title: context.l10n.error,
          );
        }
        return;
      }

      // Check if the invitation has expired
      if (invitation.expirationTime.isBefore(DateTime.now())) {
        if (mounted) {
          MyDialog.alert(
            context.l10n.invitationExpired,
            title: context.l10n.error,
          );
        }
        return;
      }

      // Call the callback
      widget.onInvitationScanned(invitation);

      // Close the scanner
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      logger.severe('Error processing QR code: $e');
      if (mounted) {
        MyDialog.alert(
          '${context.l10n.errorProcessingQRCode}: $e',
          title: context.l10n.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.scanQRCode),
        actions: [
          IconButton(
            icon: ValueListenableBuilder<bool>(
              valueListenable: ValueNotifier<bool>(false),
              builder: (context, isOn, child) {
                return Icon(isOn ? Icons.flash_on : Icons.flash_off);
              },
            ),
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _processQRCode(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                context.l10n.scanQRCodeInstructions,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
