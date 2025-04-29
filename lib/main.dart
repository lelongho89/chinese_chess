import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

import 'global.dart';
import 'l10n/generated/app_localizations.dart';
import 'models/auth_service.dart';
import 'models/game_manager.dart';
import 'models/game_setting.dart';
import 'models/locale_provider.dart';
import 'screens/auth_wrapper.dart';
import 'widgets/game_wrapper.dart';
import 'game_board.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();

    // Configure Firestore for offline persistence
    await FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    logger.info('Firebase initialized successfully');
  } catch (e) {
    logger.severe('Failed to initialize Firebase: $e');
  }

  // Initialize game settings
  await GameSetting.getInstance();

  // Initialize locale provider
  final localeProvider = await LocaleProvider.getInstance();

  // Initialize auth service
  final authService = await AuthService.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: authService),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    // Get the current locale from the provider
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: '',
      onGenerateTitle: (BuildContext context) {
        return context.l10n.appTitle;
      },
      navigatorKey: MyDialog.navigatorKey,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ShirneDialogLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('zh', 'CN'),
        Locale('vi', ''),
      ],
      locale: localeProvider.locale,
      theme: AppTheme.createTheme(),
      highContrastTheme: AppTheme.createTheme(isHighContrast: true),
      darkTheme: AppTheme.createTheme(isDark: true),
      highContrastDarkTheme: AppTheme.createTheme(
        isDark: true,
        isHighContrast: true,
      ),
      // Material 3 specific configurations
      themeMode: ThemeMode.system, // Follow system theme
      debugShowCheckedModeBanner: false, // Remove debug banner
      home: AuthWrapper(
        child: GameWrapper(
          isMain: true,
          child: GameBoard(),
        ),
      ),
    );
  }
}


