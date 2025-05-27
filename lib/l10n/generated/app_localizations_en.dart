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
  String get modeRobotSubtitle => 'Play against AI opponent';

  @override
  String get modeOnline => 'Online Mode';

  @override
  String get modeOnlineSubtitle => 'Play with friends online';

  @override
  String get modeFree => 'Free Mode';

  @override
  String get modeFreeSubtitle => 'Local multiplayer on same device';

  @override
  String get chooseGameMode => 'Choose your game mode';

  @override
  String get comingSoon => 'Coming Soon';

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
  String get scanQRCodeInstructions =>
      'Point the camera at a QR code to scan it';

  @override
  String get scanQRCodeToJoinMatch => 'Scan QR Code to Join Match';

  @override
  String get qrCodeValidFor24Hours => 'QR code valid for 24 hours';

  @override
  String get shareQRCode => 'Share QR Code';

  @override
  String get sharing => 'Sharing';

  @override
  String get joinMyChineseChessMatch => 'Join my Chinese Chess match!';

  @override
  String get joinMatch => 'Join Match';

  @override
  String joinMatchConfirmation(String creatorName) {
    return 'Do you want to join $creatorName\'s match?';
  }

  @override
  String get matchJoinedSuccessfully => 'Match joined successfully';

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
  String get cannotJoinYourOwnInvitation => 'Cannot join your own invitation';

  @override
  String get errorJoiningMatch => 'Error joining match';

  @override
  String get emailVerification => 'Email Verification';

  @override
  String get verifyYourEmail => 'Verify Your Email';

  @override
  String get verificationEmailSent => 'Verification email sent';

  @override
  String get verificationEmailSentDescription =>
      'We\'ve sent a verification email to your address. Please check your inbox and click the verification link.';

  @override
  String get resendVerificationEmail => 'Resend Verification Email';

  @override
  String get resendIn => 'Resend in';

  @override
  String get seconds => 'seconds';

  @override
  String get failedToSendVerificationEmail =>
      'Failed to send verification email';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutFailed => 'Sign out failed';

  @override
  String get forgotPassword => 'Forgot Password';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordDescription =>
      'Enter your email address and we\'ll send you a link to reset your password.';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get sendingResetLink => 'Sending reset link...';

  @override
  String get resetLinkSent => 'Reset Link Sent';

  @override
  String get resetLinkSentDescription =>
      'Check your email for a link to reset your password. If it doesn\'t appear within a few minutes, check your spam folder.';

  @override
  String get resetPasswordFailed => 'Failed to send reset link';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get email => 'Email';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get invalidEmail => 'Please enter a valid email address';

  @override
  String get userNotFound => 'User not found';

  @override
  String get tooManyRequests => 'Too many requests. Please try again later.';

  @override
  String get login => 'Login';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get password => 'Password';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get rememberMe => 'Remember Me';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get register => 'Register';

  @override
  String get loggingIn => 'Logging in...';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get userDisabled => 'This account has been disabled';

  @override
  String get invalidCredentials => 'Invalid email or password';

  @override
  String get emailNotVerified =>
      'Please verify your email address before logging in. Check your inbox for a verification link.';

  @override
  String get verificationRequired => 'Verification Required';

  @override
  String get createAccount => 'Create Account';

  @override
  String get displayName => 'Display Name';

  @override
  String get displayNameRequired => 'Display name is required';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get confirmPasswordRequired => 'Please confirm your password';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get iAgreeToThe => 'I agree to the';

  @override
  String get termsAndConditions => 'Terms and Conditions';

  @override
  String get termsAndConditionsText =>
      'By using this app, you agree to our terms of service and privacy policy.';

  @override
  String get mustAgreeToTerms =>
      'You must agree to the terms and conditions to register';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get creatingAccount => 'Creating account...';

  @override
  String get registrationFailed => 'Registration failed';

  @override
  String get emailAlreadyInUse => 'This email is already in use';

  @override
  String get orContinueWith => 'Or continue with';

  @override
  String get invalidCredential => 'Invalid credential';

  @override
  String get accountExistsWithDifferentCredential =>
      'An account already exists with a different credential';

  @override
  String get continueAsGuest => 'Continue as Guest';

  @override
  String get guestMode => 'Guest Mode';

  @override
  String get playAsGuest => 'Play as Guest';

  @override
  String get guestUser => 'Guest User';

  @override
  String get anonymousUser => 'Anonymous User';

  @override
  String get updateDisplayName => 'Update Display Name';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get saveProfile => 'Save Profile';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get profileUpdateFailed => 'Failed to update profile';

  @override
  String get convertToAccount => 'Create Account';

  @override
  String get convertToAccountDescription =>
      'Create a permanent account to save your progress across devices';

  @override
  String get currentlyPlayingAsGuest => 'Currently playing as guest';

  @override
  String get timerEnabled => 'Timer Enabled';

  @override
  String get timerDisabled => 'Timer Disabled';

  @override
  String get resetTimer => 'Reset Timer';

  @override
  String get account => 'Account';

  @override
  String get home => 'Home';

  @override
  String get play => 'Play';

  @override
  String get settings => 'Settings';

  @override
  String get gamesPlayed => 'Games Played';

  @override
  String get gamesWon => 'Games Won';

  @override
  String get gamesLost => 'Games Lost';

  @override
  String get notifications => 'Notifications';

  @override
  String get enablePushNotifications =>
      'Enable push notifications for game updates';

  @override
  String get sound => 'Sound';

  @override
  String get soundEffects => 'Sound Effects';

  @override
  String get enableSoundEffectsForMovesAndGames =>
      'Enable sound effects for moves and games';

  @override
  String get adjustTheVolumeOfSoundEffects =>
      'Adjust the volume of sound effects';

  @override
  String get appearance => 'Appearance';

  @override
  String get pieceStyle => 'Piece Style';

  @override
  String get chooseTheVisualStyleOfTheChessPieces =>
      'Choose the visual style of the chess pieces';

  @override
  String get classic => 'Classic';

  @override
  String get boardStyle => 'Board Style';

  @override
  String get selectTheAppearanceOfTheChessboard =>
      'Select the appearance of the chessboard';

  @override
  String get wood => 'Wood';

  @override
  String get gameTimer => 'Game Timer';

  @override
  String get turnTimeLimit => 'Turn Time Limit';

  @override
  String get setTheTimeLimitForEachPlayersMove =>
      'Set the time limit for each player\'s move';

  @override
  String get tenMinutes => '10 min';

  @override
  String get enableTimer => 'Enable Timer';

  @override
  String get enableOrDisableTheGameTimer => 'Enable or disable the game timer';

  @override
  String get singlePlayer => 'Single Player';

  @override
  String get playAgainstTheComputer => 'Play against the computer';

  @override
  String get localMultiplayer => 'Local Multiplayer';

  @override
  String get playWithAFriendOnTheSameDevice =>
      'Play with a friend on the same device';

  @override
  String get gameMode => 'Game Mode';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get easy => 'Easy';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Hard';

  @override
  String get startGame => 'Start Game';

  @override
  String get gameSettings => 'Game Settings';

  @override
  String get aiDifficulty => 'AI Difficulty';

  @override
  String get setTheAIDifficultyLevel => 'Set the AI difficulty level';

  @override
  String get onlineMultiplayer => 'Online Multiplayer';

  @override
  String get cancel => 'Cancel';

  @override
  String joinedDate(Object date) {
    return 'Joined $date';
  }

  @override
  String get changePassword => 'Change Password';

  @override
  String get logOut => 'Log Out';

  @override
  String get deleteProfile => 'Delete Profile';

  @override
  String get deleteProfileSubtitle => 'Delete all stats and start fresh';

  @override
  String get deleteProfileConfirmation =>
      'Are you sure you want to delete your profile? This will permanently delete all your stats, game history, and progress. You will start fresh with a new profile on your next login.';

  @override
  String get matchmaking => 'Matchmaking';

  @override
  String get cancelSearch => 'Cancel Search';

  @override
  String get findMatch => 'Find Match';

  @override
  String get rank => 'Rank';

  @override
  String get eloRating => 'ELO Rating';

  @override
  String get rankSoldier => 'Soldier';

  @override
  String get rankApprentice => 'Apprentice';

  @override
  String get rankScholar => 'Scholar';

  @override
  String get rankKnight => 'Knight';

  @override
  String get rankChariot => 'Chariot';

  @override
  String get rankCannon => 'Cannon';

  @override
  String get rankGeneral => 'General';

  @override
  String get rankSoldierDesc => 'Beginner players learning the game';

  @override
  String get rankApprenticeDesc => 'Players with basic rule understanding';

  @override
  String get rankScholarDesc => 'Intermediate players with strategic skills';

  @override
  String get rankKnightDesc => 'Skilled players mastering tactics';

  @override
  String get rankChariotDesc => 'Advanced players with strong game sense';

  @override
  String get rankCannonDesc => 'Expert players dominating opponents';

  @override
  String get rankGeneralDesc => 'Elite players, masters of Xiangqi';
}
