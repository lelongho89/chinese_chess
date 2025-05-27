import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Chinese Chess'**
  String get appTitle;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @openMenu.
  ///
  /// In en, this message translates to:
  /// **'Open Menu'**
  String get openMenu;

  /// No description provided for @flipBoard.
  ///
  /// In en, this message translates to:
  /// **'Flip Board'**
  String get flipBoard;

  /// No description provided for @copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy Chess Code'**
  String get copyCode;

  /// No description provided for @parseCode.
  ///
  /// In en, this message translates to:
  /// **'Parse Chess Code'**
  String get parseCode;

  /// No description provided for @editCode.
  ///
  /// In en, this message translates to:
  /// **'Edit Chess'**
  String get editCode;

  /// No description provided for @newGame.
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get newGame;

  /// No description provided for @loadManual.
  ///
  /// In en, this message translates to:
  /// **'Load Chess Manual'**
  String get loadManual;

  /// No description provided for @saveManual.
  ///
  /// In en, this message translates to:
  /// **'Save Chess Manual'**
  String get saveManual;

  /// No description provided for @setting.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get setting;

  /// No description provided for @featureNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Feature is not available'**
  String get featureNotAvailable;

  /// No description provided for @modeRobot.
  ///
  /// In en, this message translates to:
  /// **'Robot Mode'**
  String get modeRobot;

  /// No description provided for @modeRobotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Play against AI opponent'**
  String get modeRobotSubtitle;

  /// No description provided for @modeOnline.
  ///
  /// In en, this message translates to:
  /// **'Online Mode'**
  String get modeOnline;

  /// No description provided for @modeOnlineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Play with friends online'**
  String get modeOnlineSubtitle;

  /// No description provided for @modeFree.
  ///
  /// In en, this message translates to:
  /// **'Free Mode'**
  String get modeFree;

  /// No description provided for @modeFreeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Local multiplayer on same device'**
  String get modeFreeSubtitle;

  /// No description provided for @chooseGameMode.
  ///
  /// In en, this message translates to:
  /// **'Choose your game mode'**
  String get chooseGameMode;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get save;

  /// No description provided for @trusteeshipToRobots.
  ///
  /// In en, this message translates to:
  /// **'Trusteeship to Robots'**
  String get trusteeshipToRobots;

  /// No description provided for @cancelRobots.
  ///
  /// In en, this message translates to:
  /// **'Cancel Trusteeship'**
  String get cancelRobots;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get thinking;

  /// No description provided for @currentInfo.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get currentInfo;

  /// No description provided for @manual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manual;

  /// No description provided for @theEvent.
  ///
  /// In en, this message translates to:
  /// **'Event: '**
  String get theEvent;

  /// No description provided for @theSite.
  ///
  /// In en, this message translates to:
  /// **'Site: '**
  String get theSite;

  /// No description provided for @theDate.
  ///
  /// In en, this message translates to:
  /// **'Date: '**
  String get theDate;

  /// No description provided for @theRound.
  ///
  /// In en, this message translates to:
  /// **'Round: '**
  String get theRound;

  /// No description provided for @theRed.
  ///
  /// In en, this message translates to:
  /// **'Red: '**
  String get theRed;

  /// No description provided for @theBlack.
  ///
  /// In en, this message translates to:
  /// **'Black: '**
  String get theBlack;

  /// No description provided for @stepStart.
  ///
  /// In en, this message translates to:
  /// **'==Start=='**
  String get stepStart;

  /// No description provided for @exitNow.
  ///
  /// In en, this message translates to:
  /// **'Exit Now ?'**
  String get exitNow;

  /// No description provided for @dontExit.
  ///
  /// In en, this message translates to:
  /// **'Wait a moment'**
  String get dontExit;

  /// No description provided for @yesExit.
  ///
  /// In en, this message translates to:
  /// **'Yes exit'**
  String get yesExit;

  /// No description provided for @clickAgainToExit.
  ///
  /// In en, this message translates to:
  /// **'Click again to Exit'**
  String get clickAgainToExit;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @situationCode.
  ///
  /// In en, this message translates to:
  /// **'Chess Code'**
  String get situationCode;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid Chess Code'**
  String get invalidCode;

  /// No description provided for @copySuccess.
  ///
  /// In en, this message translates to:
  /// **'Copy Success'**
  String get copySuccess;

  /// No description provided for @saveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Save Success'**
  String get saveSuccess;

  /// No description provided for @selectDirectorySave.
  ///
  /// In en, this message translates to:
  /// **'Select a Directory to Save'**
  String get selectDirectorySave;

  /// No description provided for @saveFilename.
  ///
  /// In en, this message translates to:
  /// **'Filename to Save'**
  String get saveFilename;

  /// No description provided for @selectPgnFile.
  ///
  /// In en, this message translates to:
  /// **'Select .PGN file'**
  String get selectPgnFile;

  /// No description provided for @recommendMove.
  ///
  /// In en, this message translates to:
  /// **'Recommend Move'**
  String get recommendMove;

  /// No description provided for @remark.
  ///
  /// In en, this message translates to:
  /// **'Remark'**
  String get remark;

  /// No description provided for @noRemark.
  ///
  /// In en, this message translates to:
  /// **'No remark'**
  String get noRemark;

  /// No description provided for @check.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get check;

  /// No description provided for @checkmate.
  ///
  /// In en, this message translates to:
  /// **'Checkmate'**
  String get checkmate;

  /// No description provided for @longRecheckLoose.
  ///
  /// In en, this message translates to:
  /// **'The same move 3 round to Lose'**
  String get longRecheckLoose;

  /// No description provided for @noEatToDraw.
  ///
  /// In en, this message translates to:
  /// **'60 round with no eat to Draw'**
  String get noEatToDraw;

  /// No description provided for @trapped.
  ///
  /// In en, this message translates to:
  /// **'Checkmate'**
  String get trapped;

  /// No description provided for @redLoose.
  ///
  /// In en, this message translates to:
  /// **'Loose'**
  String get redLoose;

  /// No description provided for @redWin.
  ///
  /// In en, this message translates to:
  /// **'Win'**
  String get redWin;

  /// No description provided for @redDraw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get redDraw;

  /// No description provided for @requestDraw.
  ///
  /// In en, this message translates to:
  /// **'Asked for a draw'**
  String get requestDraw;

  /// No description provided for @agreeToDraw.
  ///
  /// In en, this message translates to:
  /// **'Agree to draw'**
  String get agreeToDraw;

  /// No description provided for @requestRetract.
  ///
  /// In en, this message translates to:
  /// **'Asked for a Retract'**
  String get requestRetract;

  /// No description provided for @agreeRetract.
  ///
  /// In en, this message translates to:
  /// **'Agree to retract'**
  String get agreeRetract;

  /// No description provided for @disagreeRetract.
  ///
  /// In en, this message translates to:
  /// **'Disagree to retract'**
  String get disagreeRetract;

  /// No description provided for @cantSendCheck.
  ///
  /// In en, this message translates to:
  /// **'You can\'t send Check'**
  String get cantSendCheck;

  /// No description provided for @plsParryCheck.
  ///
  /// In en, this message translates to:
  /// **'Please parry the Check'**
  String get plsParryCheck;

  /// No description provided for @oneMoreGame.
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get oneMoreGame;

  /// No description provided for @letMeSee.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get letMeSee;

  /// No description provided for @settingTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingTitle;

  /// No description provided for @aiType.
  ///
  /// In en, this message translates to:
  /// **'AI Type'**
  String get aiType;

  /// No description provided for @builtInEngine.
  ///
  /// In en, this message translates to:
  /// **'Built-in Engine'**
  String get builtInEngine;

  /// No description provided for @aiLevel.
  ///
  /// In en, this message translates to:
  /// **'AI Level'**
  String get aiLevel;

  /// No description provided for @beginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginner;

  /// No description provided for @intermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get intermediate;

  /// No description provided for @master.
  ///
  /// In en, this message translates to:
  /// **'Master'**
  String get master;

  /// No description provided for @gameSound.
  ///
  /// In en, this message translates to:
  /// **'Game Sound'**
  String get gameSound;

  /// No description provided for @soundVolume.
  ///
  /// In en, this message translates to:
  /// **'Sound Volume'**
  String get soundVolume;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get languageChinese;

  /// No description provided for @languageVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get languageVietnamese;

  /// No description provided for @chessSkin.
  ///
  /// In en, this message translates to:
  /// **'Chess Skin'**
  String get chessSkin;

  /// No description provided for @skinWoods.
  ///
  /// In en, this message translates to:
  /// **'Woods'**
  String get skinWoods;

  /// No description provided for @skinStones.
  ///
  /// In en, this message translates to:
  /// **'Stones'**
  String get skinStones;

  /// No description provided for @quit.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get quit;

  /// No description provided for @quitGame.
  ///
  /// In en, this message translates to:
  /// **'Quit Game'**
  String get quitGame;

  /// No description provided for @inviteFriend.
  ///
  /// In en, this message translates to:
  /// **'Invite Friend'**
  String get inviteFriend;

  /// No description provided for @scanQRCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQRCode;

  /// No description provided for @scanQRCodeInstructions.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at a QR code to scan it'**
  String get scanQRCodeInstructions;

  /// No description provided for @scanQRCodeToJoinMatch.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code to Join Match'**
  String get scanQRCodeToJoinMatch;

  /// No description provided for @qrCodeValidFor24Hours.
  ///
  /// In en, this message translates to:
  /// **'QR code valid for 24 hours'**
  String get qrCodeValidFor24Hours;

  /// No description provided for @shareQRCode.
  ///
  /// In en, this message translates to:
  /// **'Share QR Code'**
  String get shareQRCode;

  /// No description provided for @sharing.
  ///
  /// In en, this message translates to:
  /// **'Sharing'**
  String get sharing;

  /// No description provided for @joinMyChineseChessMatch.
  ///
  /// In en, this message translates to:
  /// **'Join my Chinese Chess match!'**
  String get joinMyChineseChessMatch;

  /// No description provided for @joinMatch.
  ///
  /// In en, this message translates to:
  /// **'Join Match'**
  String get joinMatch;

  /// No description provided for @joinMatchConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Do you want to join {creatorName}\'s match?'**
  String joinMatchConfirmation(String creatorName);

  /// No description provided for @matchJoinedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Match joined successfully'**
  String get matchJoinedSuccessfully;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @invalidOrExpiredInvitation.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired invitation'**
  String get invalidOrExpiredInvitation;

  /// No description provided for @invitationAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'This invitation has already been used'**
  String get invitationAlreadyUsed;

  /// No description provided for @invitationExpired.
  ///
  /// In en, this message translates to:
  /// **'This invitation has expired'**
  String get invitationExpired;

  /// No description provided for @errorProcessingQRCode.
  ///
  /// In en, this message translates to:
  /// **'Error processing QR code'**
  String get errorProcessingQRCode;

  /// No description provided for @errorGeneratingQRCode.
  ///
  /// In en, this message translates to:
  /// **'Error generating QR code'**
  String get errorGeneratingQRCode;

  /// No description provided for @errorSharingQRCode.
  ///
  /// In en, this message translates to:
  /// **'Error sharing QR code'**
  String get errorSharingQRCode;

  /// No description provided for @errorShowingQRScanner.
  ///
  /// In en, this message translates to:
  /// **'Error showing QR scanner'**
  String get errorShowingQRScanner;

  /// No description provided for @errorShowingQRGenerator.
  ///
  /// In en, this message translates to:
  /// **'Error showing QR generator'**
  String get errorShowingQRGenerator;

  /// No description provided for @cannotJoinYourOwnInvitation.
  ///
  /// In en, this message translates to:
  /// **'Cannot join your own invitation'**
  String get cannotJoinYourOwnInvitation;

  /// No description provided for @errorJoiningMatch.
  ///
  /// In en, this message translates to:
  /// **'Error joining match'**
  String get errorJoiningMatch;

  /// No description provided for @emailVerification.
  ///
  /// In en, this message translates to:
  /// **'Email Verification'**
  String get emailVerification;

  /// No description provided for @verifyYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyYourEmail;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent'**
  String get verificationEmailSent;

  /// No description provided for @verificationEmailSentDescription.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a verification email to your address. Please check your inbox and click the verification link.'**
  String get verificationEmailSentDescription;

  /// No description provided for @resendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend Verification Email'**
  String get resendVerificationEmail;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in'**
  String get resendIn;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// No description provided for @failedToSendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Failed to send verification email'**
  String get failedToSendVerificationEmail;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign out failed'**
  String get signOutFailed;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a link to reset your password.'**
  String get resetPasswordDescription;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @sendingResetLink.
  ///
  /// In en, this message translates to:
  /// **'Sending reset link...'**
  String get sendingResetLink;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Reset Link Sent'**
  String get resetLinkSent;

  /// No description provided for @resetLinkSentDescription.
  ///
  /// In en, this message translates to:
  /// **'Check your email for a link to reset your password. If it doesn\'t appear within a few minutes, check your spam folder.'**
  String get resetLinkSentDescription;

  /// No description provided for @resetPasswordFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset link'**
  String get resetPasswordFailed;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @tooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please try again later.'**
  String get tooManyRequests;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get rememberMe;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @loggingIn.
  ///
  /// In en, this message translates to:
  /// **'Logging in...'**
  String get loggingIn;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @userDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled'**
  String get userDisabled;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get invalidCredentials;

  /// No description provided for @emailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email address before logging in. Check your inbox for a verification link.'**
  String get emailNotVerified;

  /// No description provided for @verificationRequired.
  ///
  /// In en, this message translates to:
  /// **'Verification Required'**
  String get verificationRequired;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @displayNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Display name is required'**
  String get displayNameRequired;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @iAgreeToThe.
  ///
  /// In en, this message translates to:
  /// **'I agree to the'**
  String get iAgreeToThe;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @termsAndConditionsText.
  ///
  /// In en, this message translates to:
  /// **'By using this app, you agree to our terms of service and privacy policy.'**
  String get termsAndConditionsText;

  /// No description provided for @mustAgreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'You must agree to the terms and conditions to register'**
  String get mustAgreeToTerms;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @creatingAccount.
  ///
  /// In en, this message translates to:
  /// **'Creating account...'**
  String get creatingAccount;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailed;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use'**
  String get emailAlreadyInUse;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @invalidCredential.
  ///
  /// In en, this message translates to:
  /// **'Invalid credential'**
  String get invalidCredential;

  /// No description provided for @accountExistsWithDifferentCredential.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with a different credential'**
  String get accountExistsWithDifferentCredential;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// No description provided for @guestMode.
  ///
  /// In en, this message translates to:
  /// **'Guest Mode'**
  String get guestMode;

  /// No description provided for @playAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Play as Guest'**
  String get playAsGuest;

  /// No description provided for @guestUser.
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get guestUser;

  /// No description provided for @anonymousUser.
  ///
  /// In en, this message translates to:
  /// **'Anonymous User'**
  String get anonymousUser;

  /// No description provided for @updateDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Update Display Name'**
  String get updateDisplayName;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfile;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get profileUpdateFailed;

  /// No description provided for @convertToAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get convertToAccount;

  /// No description provided for @convertToAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a permanent account to save your progress across devices'**
  String get convertToAccountDescription;

  /// No description provided for @currentlyPlayingAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Currently playing as guest'**
  String get currentlyPlayingAsGuest;

  /// No description provided for @timerEnabled.
  ///
  /// In en, this message translates to:
  /// **'Timer Enabled'**
  String get timerEnabled;

  /// No description provided for @timerDisabled.
  ///
  /// In en, this message translates to:
  /// **'Timer Disabled'**
  String get timerDisabled;

  /// No description provided for @resetTimer.
  ///
  /// In en, this message translates to:
  /// **'Reset Timer'**
  String get resetTimer;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @gamesPlayed.
  ///
  /// In en, this message translates to:
  /// **'Games Played'**
  String get gamesPlayed;

  /// No description provided for @gamesWon.
  ///
  /// In en, this message translates to:
  /// **'Games Won'**
  String get gamesWon;

  /// No description provided for @gamesLost.
  ///
  /// In en, this message translates to:
  /// **'Games Lost'**
  String get gamesLost;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @enablePushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable push notifications for game updates'**
  String get enablePushNotifications;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// No description provided for @enableSoundEffectsForMovesAndGames.
  ///
  /// In en, this message translates to:
  /// **'Enable sound effects for moves and games'**
  String get enableSoundEffectsForMovesAndGames;

  /// No description provided for @adjustTheVolumeOfSoundEffects.
  ///
  /// In en, this message translates to:
  /// **'Adjust the volume of sound effects'**
  String get adjustTheVolumeOfSoundEffects;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @pieceStyle.
  ///
  /// In en, this message translates to:
  /// **'Piece Style'**
  String get pieceStyle;

  /// No description provided for @chooseTheVisualStyleOfTheChessPieces.
  ///
  /// In en, this message translates to:
  /// **'Choose the visual style of the chess pieces'**
  String get chooseTheVisualStyleOfTheChessPieces;

  /// No description provided for @classic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get classic;

  /// No description provided for @boardStyle.
  ///
  /// In en, this message translates to:
  /// **'Board Style'**
  String get boardStyle;

  /// No description provided for @selectTheAppearanceOfTheChessboard.
  ///
  /// In en, this message translates to:
  /// **'Select the appearance of the chessboard'**
  String get selectTheAppearanceOfTheChessboard;

  /// No description provided for @wood.
  ///
  /// In en, this message translates to:
  /// **'Wood'**
  String get wood;

  /// No description provided for @gameTimer.
  ///
  /// In en, this message translates to:
  /// **'Game Timer'**
  String get gameTimer;

  /// No description provided for @turnTimeLimit.
  ///
  /// In en, this message translates to:
  /// **'Turn Time Limit'**
  String get turnTimeLimit;

  /// No description provided for @setTheTimeLimitForEachPlayersMove.
  ///
  /// In en, this message translates to:
  /// **'Set the time limit for each player\'s move'**
  String get setTheTimeLimitForEachPlayersMove;

  /// No description provided for @tenMinutes.
  ///
  /// In en, this message translates to:
  /// **'10 min'**
  String get tenMinutes;

  /// No description provided for @enableTimer.
  ///
  /// In en, this message translates to:
  /// **'Enable Timer'**
  String get enableTimer;

  /// No description provided for @enableOrDisableTheGameTimer.
  ///
  /// In en, this message translates to:
  /// **'Enable or disable the game timer'**
  String get enableOrDisableTheGameTimer;

  /// No description provided for @singlePlayer.
  ///
  /// In en, this message translates to:
  /// **'Single Player'**
  String get singlePlayer;

  /// No description provided for @playAgainstTheComputer.
  ///
  /// In en, this message translates to:
  /// **'Play against the computer'**
  String get playAgainstTheComputer;

  /// No description provided for @localMultiplayer.
  ///
  /// In en, this message translates to:
  /// **'Local Multiplayer'**
  String get localMultiplayer;

  /// No description provided for @playWithAFriendOnTheSameDevice.
  ///
  /// In en, this message translates to:
  /// **'Play with a friend on the same device'**
  String get playWithAFriendOnTheSameDevice;

  /// No description provided for @gameMode.
  ///
  /// In en, this message translates to:
  /// **'Game Mode'**
  String get gameMode;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @startGame.
  ///
  /// In en, this message translates to:
  /// **'Start Game'**
  String get startGame;

  /// No description provided for @gameSettings.
  ///
  /// In en, this message translates to:
  /// **'Game Settings'**
  String get gameSettings;

  /// No description provided for @aiDifficulty.
  ///
  /// In en, this message translates to:
  /// **'AI Difficulty'**
  String get aiDifficulty;

  /// No description provided for @setTheAIDifficultyLevel.
  ///
  /// In en, this message translates to:
  /// **'Set the AI difficulty level'**
  String get setTheAIDifficultyLevel;

  /// No description provided for @onlineMultiplayer.
  ///
  /// In en, this message translates to:
  /// **'Online Multiplayer'**
  String get onlineMultiplayer;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @joinedDate.
  ///
  /// In en, this message translates to:
  /// **'Joined {date}'**
  String joinedDate(Object date);

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @deleteProfile.
  ///
  /// In en, this message translates to:
  /// **'Delete Profile'**
  String get deleteProfile;

  /// No description provided for @deleteProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all stats and start fresh'**
  String get deleteProfileSubtitle;

  /// No description provided for @deleteProfileConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your profile? This will permanently delete all your stats, game history, and progress. You will start fresh with a new profile on your next login.'**
  String get deleteProfileConfirmation;

  /// No description provided for @matchmaking.
  ///
  /// In en, this message translates to:
  /// **'Matchmaking'**
  String get matchmaking;

  /// No description provided for @cancelSearch.
  ///
  /// In en, this message translates to:
  /// **'Cancel Search'**
  String get cancelSearch;

  /// No description provided for @findMatch.
  ///
  /// In en, this message translates to:
  /// **'Find Match'**
  String get findMatch;

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @eloRating.
  ///
  /// In en, this message translates to:
  /// **'ELO Rating'**
  String get eloRating;

  /// No description provided for @rankSoldier.
  ///
  /// In en, this message translates to:
  /// **'Soldier'**
  String get rankSoldier;

  /// No description provided for @rankApprentice.
  ///
  /// In en, this message translates to:
  /// **'Apprentice'**
  String get rankApprentice;

  /// No description provided for @rankScholar.
  ///
  /// In en, this message translates to:
  /// **'Scholar'**
  String get rankScholar;

  /// No description provided for @rankKnight.
  ///
  /// In en, this message translates to:
  /// **'Knight'**
  String get rankKnight;

  /// No description provided for @rankChariot.
  ///
  /// In en, this message translates to:
  /// **'Chariot'**
  String get rankChariot;

  /// No description provided for @rankCannon.
  ///
  /// In en, this message translates to:
  /// **'Cannon'**
  String get rankCannon;

  /// No description provided for @rankGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get rankGeneral;

  /// No description provided for @rankSoldierDesc.
  ///
  /// In en, this message translates to:
  /// **'Beginner players learning the game'**
  String get rankSoldierDesc;

  /// No description provided for @rankApprenticeDesc.
  ///
  /// In en, this message translates to:
  /// **'Players with basic rule understanding'**
  String get rankApprenticeDesc;

  /// No description provided for @rankScholarDesc.
  ///
  /// In en, this message translates to:
  /// **'Intermediate players with strategic skills'**
  String get rankScholarDesc;

  /// No description provided for @rankKnightDesc.
  ///
  /// In en, this message translates to:
  /// **'Skilled players mastering tactics'**
  String get rankKnightDesc;

  /// No description provided for @rankChariotDesc.
  ///
  /// In en, this message translates to:
  /// **'Advanced players with strong game sense'**
  String get rankChariotDesc;

  /// No description provided for @rankCannonDesc.
  ///
  /// In en, this message translates to:
  /// **'Expert players dominating opponents'**
  String get rankCannonDesc;

  /// No description provided for @rankGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'Elite players, masters of Xiangqi'**
  String get rankGeneralDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
