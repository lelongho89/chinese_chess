// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Chinese Chess';

  @override
  String get menu => 'Menu';

  @override
  String get openMenu => 'Open Menu';

  @override
  String get flipBoard => 'Flip Board';

  @override
  String get copyCode => 'Copy Chess Code';

  @override
  String get parseCode => 'Parse Chess Code';

  @override
  String get editCode => 'Edit Chess';

  @override
  String get newGame => 'New Game';

  @override
  String get loadManual => 'Load Chess Manual';

  @override
  String get saveManual => 'Save Chess Manual';

  @override
  String get setting => 'Setting';

  @override
  String get featureNotAvailable => 'Feature is not available';

  @override
  String get modeRobot => 'Robot Mode';

  @override
  String get modeOnline => 'Online Mode';

  @override
  String get modeFree => 'Free Mode';

  @override
  String get clearAll => 'Clear All';

  @override
  String get save => 'Apply';

  @override
  String get trusteeshipToRobots => 'Trusteeship to Robots';

  @override
  String get cancelRobots => 'Cancel Trusteeship';

  @override
  String get thinking => 'Thinking...';

  @override
  String get currentInfo => 'Current';

  @override
  String get manual => 'Manual';

  @override
  String get theEvent => 'Event: ';

  @override
  String get theSite => 'Site: ';

  @override
  String get theDate => 'Date: ';

  @override
  String get theRound => 'Round: ';

  @override
  String get theRed => 'Red: ';

  @override
  String get theBlack => 'Black: ';

  @override
  String get stepStart => '==Start==';

  @override
  String get exitNow => 'Exit Now ?';

  @override
  String get dontExit => 'Wait a moment';

  @override
  String get yesExit => 'Yes exit';

  @override
  String get clickAgainToExit => 'Click again to Exit';

  @override
  String get apply => 'Apply';

  @override
  String get situationCode => 'Chess Code';

  @override
  String get invalidCode => 'Invalid Chess Code';

  @override
  String get copySuccess => 'Copy Success';

  @override
  String get saveSuccess => 'Save Success';

  @override
  String get selectDirectorySave => 'Select a Directory to Save';

  @override
  String get saveFilename => 'Filename to Save';

  @override
  String get selectPgnFile => 'Select .PGN file';

  @override
  String get recommendMove => 'Recommend Move';

  @override
  String get remark => 'Remark';

  @override
  String get noRemark => 'No remark';

  @override
  String get check => 'Check';

  @override
  String get checkmate => 'Checkmate';

  @override
  String get longRecheckLoose => 'The same move 3 round to Lose';

  @override
  String get noEatToDraw => '60 round with no eat to Draw';

  @override
  String get trapped => 'Checkmate';

  @override
  String get redLoose => 'Loose';

  @override
  String get redWin => 'Win';

  @override
  String get redDraw => 'Draw';

  @override
  String get requestDraw => 'Asked for a draw';

  @override
  String get agreeToDraw => 'Agree to draw';

  @override
  String get requestRetract => 'Asked for a Retract';

  @override
  String get agreeRetract => 'Agree to retract';

  @override
  String get disagreeRetract => 'Disagree to retract';

  @override
  String get cantSendCheck => 'You can\'t send Check';

  @override
  String get plsParryCheck => 'Please parry the Check';

  @override
  String get oneMoreGame => 'New Game';

  @override
  String get letMeSee => 'Not now';

  @override
  String get settingTitle => 'Settings';

  @override
  String get aiType => 'AI Type';

  @override
  String get builtInEngine => 'Built-in Engine';

  @override
  String get aiLevel => 'AI Level';

  @override
  String get beginner => 'Beginner';

  @override
  String get intermediate => 'Intermediate';

  @override
  String get master => 'Master';

  @override
  String get gameSound => 'Game Sound';

  @override
  String get soundVolume => 'Sound Volume';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => 'Chinese';

  @override
  String get languageVietnamese => 'Vietnamese';

  @override
  String get chessSkin => 'Chess Skin';

  @override
  String get skinWoods => 'Woods';

  @override
  String get skinStones => 'Stones';

  @override
  String get quit => 'Quit';

  @override
  String get quitGame => 'Quit Game';

  @override
  String get inviteFriend => 'Invite Friend';

  @override
  String get scanQRCode => 'Scan QR Code';

  @override
  String get scanQRCodeInstructions => 'Point the camera at a QR code';

  @override
  String get scanQRCodeToJoinMatch => 'Scan this QR code to join the match';

  @override
  String get qrCodeValidFor24Hours => 'This QR code is valid for 24 hours';

  @override
  String get shareQRCode => 'Share QR Code';

  @override
  String get sharing => 'Sharing...';

  @override
  String get joinMyChineseChessMatch => 'Join my Chinese Chess match!';

  @override
  String get joinMatch => 'Join Match';

  @override
  String joinMatchConfirmation(Object name) {
    return 'Do you want to join $name\'s match?';
  }

  @override
  String get matchJoinedSuccessfully => 'Match joined successfully!';

  @override
  String get success => 'Success';

  @override
  String get error => 'Error';

  @override
  String get invalidOrExpiredInvitation => 'Invalid or expired invitation';

  @override
  String get invitationAlreadyUsed => 'This invitation has already been used';

  @override
  String get invitationExpired => 'This invitation has expired';

  @override
  String get errorProcessingQRCode => 'Error processing QR code';

  @override
  String get errorGeneratingQRCode => 'Error generating QR code';

  @override
  String get errorSharingQRCode => 'Error sharing QR code';

  @override
  String get errorShowingQRScanner => 'Error showing QR scanner';

  @override
  String get errorShowingQRGenerator => 'Error showing QR generator';

  @override
  String get cannotJoinYourOwnInvitation => 'You cannot join your own invitation';

  @override
  String get errorJoiningMatch => 'Error joining match';
}
