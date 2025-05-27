// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '中国象棋';

  @override
  String get menu => '菜单';

  @override
  String get openMenu => '打开菜单';

  @override
  String get flipBoard => '翻转棋盘';

  @override
  String get copyCode => '复制局面代码';

  @override
  String get parseCode => '粘贴局面代码';

  @override
  String get editCode => '编辑局面';

  @override
  String get newGame => '新对局';

  @override
  String get loadManual => '加载棋谱';

  @override
  String get saveManual => '保存棋谱';

  @override
  String get setting => '设置';

  @override
  String get featureNotAvailable => '功能暂未实现';

  @override
  String get modeRobot => '人机模式';

  @override
  String get modeRobotSubtitle => '与AI对手对战';

  @override
  String get modeOnline => '联网模式';

  @override
  String get modeOnlineSubtitle => '与朋友在线对战';

  @override
  String get modeFree => '自由模式';

  @override
  String get modeFreeSubtitle => '同设备本地多人游戏';

  @override
  String get chooseGameMode => '选择游戏模式';

  @override
  String get comingSoon => '即将推出';

  @override
  String get clearAll => '清除全部';

  @override
  String get save => '确定';

  @override
  String get trusteeshipToRobots => '托管给机器人';

  @override
  String get cancelRobots => '取消托管';

  @override
  String get thinking => '思考中...';

  @override
  String get currentInfo => '当前信息';

  @override
  String get manual => '棋局信息';

  @override
  String get theEvent => '赛事：';

  @override
  String get theSite => '地点：';

  @override
  String get theDate => '日期：';

  @override
  String get theRound => '轮次：';

  @override
  String get theRed => '红方：';

  @override
  String get theBlack => '黑方：';

  @override
  String get stepStart => '==开始==';

  @override
  String get exitNow => '确定退出？';

  @override
  String get dontExit => '暂不退出';

  @override
  String get yesExit => '立即退出';

  @override
  String get clickAgainToExit => '再次点击退出';

  @override
  String get apply => '应用';

  @override
  String get situationCode => '局面代码';

  @override
  String get invalidCode => '无效代码';

  @override
  String get copySuccess => '复制成功';

  @override
  String get saveSuccess => '保存成功';

  @override
  String get selectDirectorySave => '选择保存位置';

  @override
  String get saveFilename => '保存文件名';

  @override
  String get selectPgnFile => '选择棋谱文件';

  @override
  String get recommendMove => '推荐招法';

  @override
  String get remark => '注解';

  @override
  String get noRemark => '暂无注解';

  @override
  String get check => '将军';

  @override
  String get checkmate => '绝杀';

  @override
  String get longRecheckLoose => '不变招长将作负';

  @override
  String get noEatToDraw => '60回合无吃子判和';

  @override
  String get trapped => '困毙';

  @override
  String get redLoose => '先负';

  @override
  String get redWin => '先胜';

  @override
  String get redDraw => '先和';

  @override
  String get requestDraw => '对方请求和棋';

  @override
  String get agreeToDraw => '同意和棋';

  @override
  String get requestRetract => '对方请求悔棋';

  @override
  String get agreeRetract => '同意悔棋';

  @override
  String get disagreeRetract => '拒绝悔棋';

  @override
  String get cantSendCheck => '不能送将';

  @override
  String get plsParryCheck => '请应将';

  @override
  String get oneMoreGame => '再来一局';

  @override
  String get letMeSee => '再看看';

  @override
  String get settingTitle => '系统设置';

  @override
  String get aiType => 'AI类型';

  @override
  String get builtInEngine => '内置引擎';

  @override
  String get aiLevel => 'AI级别';

  @override
  String get beginner => '初级';

  @override
  String get intermediate => '中级';

  @override
  String get master => '大师';

  @override
  String get gameSound => '游戏音效';

  @override
  String get soundVolume => '音量';

  @override
  String get language => '语言';

  @override
  String get languageEnglish => '英语';

  @override
  String get languageChinese => '中文';

  @override
  String get languageVietnamese => '越南语';

  @override
  String get chessSkin => '棋子皮肤';

  @override
  String get skinWoods => '木质';

  @override
  String get skinStones => '石质';

  @override
  String get quit => '退出';

  @override
  String get quitGame => '退出游戏';

  @override
  String get inviteFriend => 'Invite Friend';

  @override
  String get scanQRCode => '扫描二维码';

  @override
  String get scanQRCodeInstructions => '将相机对准二维码进行扫描';

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
  String get error => '错误';

  @override
  String get invalidOrExpiredInvitation => '无效或已过期的邀请';

  @override
  String get invitationAlreadyUsed => '此邀请已被使用';

  @override
  String get invitationExpired => '此邀请已过期';

  @override
  String get errorProcessingQRCode => '处理二维码时出错';

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

  @override
  String get emailVerification => '邮箱验证';

  @override
  String get verifyYourEmail => '验证您的邮箱';

  @override
  String get verificationEmailSent => '验证邮件已发送';

  @override
  String get verificationEmailSentDescription => '我们已向您的邮箱发送了验证邮件。请检查您的收件箱并点击验证链接。';

  @override
  String get resendVerificationEmail => '重新发送验证邮件';

  @override
  String get resendIn => '重新发送倒计时';

  @override
  String get seconds => '秒';

  @override
  String get failedToSendVerificationEmail => '发送验证邮件失败';

  @override
  String get signOut => '退出登录';

  @override
  String get signOutFailed => '退出登录失败';

  @override
  String get forgotPassword => '忘记密码';

  @override
  String get resetPassword => '重置密码';

  @override
  String get resetPasswordDescription => '输入您的电子邮件地址，我们将向您发送重置密码的链接。';

  @override
  String get sendResetLink => '发送重置链接';

  @override
  String get sendingResetLink => '正在发送重置链接...';

  @override
  String get resetLinkSent => '重置链接已发送';

  @override
  String get resetLinkSentDescription => '请检查您的电子邮件以获取重置密码的链接。如果几分钟内没有收到，请检查您的垃圾邮件文件夹。';

  @override
  String get resetPasswordFailed => '发送重置链接失败';

  @override
  String get backToLogin => '返回登录';

  @override
  String get email => '电子邮件';

  @override
  String get emailRequired => '电子邮件是必填项';

  @override
  String get invalidEmail => '请输入有效的电子邮件地址';

  @override
  String get userNotFound => '用户不存在';

  @override
  String get tooManyRequests => '请求过多。请稍后再试。';

  @override
  String get login => '登录';

  @override
  String get welcomeBack => '欢迎回来';

  @override
  String get password => '密码';

  @override
  String get passwordRequired => '密码是必填项';

  @override
  String get rememberMe => '记住我';

  @override
  String get dontHaveAccount => '没有账号？';

  @override
  String get register => '注册';

  @override
  String get loggingIn => '正在登录...';

  @override
  String get loginFailed => '登录失败';

  @override
  String get userDisabled => '此账号已被禁用';

  @override
  String get invalidCredentials => '邮箱或密码无效';

  @override
  String get emailNotVerified => '请在登录前验证您的电子邮件地址。检查您的收件箱以获取验证链接。';

  @override
  String get verificationRequired => '需要验证';

  @override
  String get createAccount => '创建账号';

  @override
  String get displayName => '显示名称';

  @override
  String get displayNameRequired => '显示名称是必填项';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get confirmPasswordRequired => '请确认您的密码';

  @override
  String get passwordTooShort => '密码必须至少6个字符';

  @override
  String get passwordsDoNotMatch => '密码不匹配';

  @override
  String get iAgreeToThe => '我同意';

  @override
  String get termsAndConditions => '条款和条件';

  @override
  String get termsAndConditionsText => '使用本应用程序，即表示您同意我们的服务条款和隐私政策。';

  @override
  String get mustAgreeToTerms => '您必须同意条款和条件才能注册';

  @override
  String get alreadyHaveAccount => '已有账号？';

  @override
  String get creatingAccount => '正在创建账号...';

  @override
  String get registrationFailed => '注册失败';

  @override
  String get emailAlreadyInUse => '此电子邮件已被使用';

  @override
  String get orContinueWith => '或继续使用';

  @override
  String get invalidCredential => '无效的凭证';

  @override
  String get accountExistsWithDifferentCredential => '已存在使用不同凭证的账号';

  @override
  String get continueAsGuest => '以游客身份继续';

  @override
  String get guestMode => '游客模式';

  @override
  String get playAsGuest => '以游客身份游戏';

  @override
  String get guestUser => '游客用户';

  @override
  String get anonymousUser => '匿名用户';

  @override
  String get updateDisplayName => '更新显示名称';

  @override
  String get profile => '个人资料';

  @override
  String get editProfile => '编辑个人资料';

  @override
  String get saveProfile => '保存个人资料';

  @override
  String get profileUpdated => '个人资料更新成功';

  @override
  String get profileUpdateFailed => '个人资料更新失败';

  @override
  String get convertToAccount => '创建账号';

  @override
  String get convertToAccountDescription => '创建永久账号以在设备间保存您的进度';

  @override
  String get currentlyPlayingAsGuest => '当前以游客身份游戏';

  @override
  String get timerEnabled => '计时器已启用';

  @override
  String get timerDisabled => '计时器已禁用';

  @override
  String get resetTimer => '重置计时器';

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
  String get sound => 'Sound';

  @override
  String get soundEffects => 'Sound Effects';

  @override
  String get enableSoundEffectsForMovesAndGames => 'Enable sound effects for moves and games';

  @override
  String get adjustTheVolumeOfSoundEffects => 'Adjust the volume of sound effects';

  @override
  String get appearance => 'Appearance';

  @override
  String get pieceStyle => 'Piece Style';

  @override
  String get chooseTheVisualStyleOfTheChessPieces => 'Choose the visual style of the chess pieces';

  @override
  String get classic => 'Classic';

  @override
  String get boardStyle => 'Board Style';

  @override
  String get selectTheAppearanceOfTheChessboard => 'Select the appearance of the chessboard';

  @override
  String get wood => 'Wood';

  @override
  String get gameTimer => 'Game Timer';

  @override
  String get turnTimeLimit => 'Turn Time Limit';

  @override
  String get setTheTimeLimitForEachPlayersMove => 'Set the time limit for each player\'s move';

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
  String get playWithAFriendOnTheSameDevice => 'Play with a friend on the same device';

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
  String get matchmaking => 'Matchmaking';

  @override
  String get cancelSearch => 'Cancel Search';

  @override
  String get findMatch => 'Find Match';
}
