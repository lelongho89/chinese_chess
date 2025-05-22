import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

import 'global.dart';
import 'l10n/generated/app_localizations.dart';
import 'models/supabase_auth_service.dart';
import 'models/game_manager.dart';
import 'models/game_setting.dart';
import 'models/locale_provider.dart';
import 'screens/auth_wrapper.dart';
import 'screens/main_screen.dart';
import 'supabase_client.dart' as client;
import 'widgets/game_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable hierarchical logging for engine interface
  Logger.root.level = Level.ALL;
  hierarchicalLoggingEnabled = true;

  // Load environment variables
  await dotenv.load();

  // Initialize Supabase
  try {
    await client.SupabaseClientWrapper.initialize();
    logger.info('Supabase initialized successfully');
  } catch (e) {
    logger.severe('Failed to initialize Supabase: $e');
  }

  // Initialize game settings
  await GameSetting.getInstance();

  // Initialize locale provider
  final localeProvider = await LocaleProvider.getInstance();

  // Initialize auth service
  final authService = await SupabaseAuthService.getInstance();

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
      localizationsDelegates: [
        AppLocalizations.delegate,
        _FallbackShirneDialogDelegate(),
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
      localeResolutionCallback: (locale, supportedLocales) {
        // Handle locale resolution for third-party packages that may not support all locales
        if (locale != null) {
          for (final supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
        }
        // Fallback to English if locale is not supported
        return const Locale('en', '');
      },
      theme: AppTheme.createTheme(),
      highContrastTheme: AppTheme.createTheme(isHighContrast: true),
      darkTheme: AppTheme.createTheme(isDark: true),
      highContrastDarkTheme: AppTheme.createTheme(
        isDark: true,
        isHighContrast: true,
      ),
      // Material 3 specific configurations
      themeMode: ThemeMode.dark, // Use dark theme to match design
      debugShowCheckedModeBanner: false, // Remove debug banner
      home: AuthWrapper(
        child: GameWrapper(
          isMain: true,
          child: const MainScreen(),
        ),
      ),
    );
  }
}

/// Custom delegate that wraps ShirneDialogLocalizations.delegate
/// and provides fallback for unsupported locales
class _FallbackShirneDialogDelegate extends LocalizationsDelegate<ShirneDialogLocalizations> {
  const _FallbackShirneDialogDelegate();

  @override
  bool isSupported(Locale locale) {
    // Always return true since we handle fallback internally
    return true;
  }

  @override
  Future<ShirneDialogLocalizations> load(Locale locale) async {
    // Check if ShirneDialogLocalizations supports this locale
    if (ShirneDialogLocalizations.delegate.isSupported(locale)) {
      return await ShirneDialogLocalizations.delegate.load(locale);
    } else {
      // Fallback to English for unsupported locales
      return await ShirneDialogLocalizations.delegate.load(const Locale('en'));
    }
  }

  @override
  bool shouldReload(_FallbackShirneDialogDelegate old) => false;
}


