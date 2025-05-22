// Widget tests for the Chinese Chess app UI components.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:chinese_chess/game_board.dart';
import 'package:chinese_chess/models/locale_provider.dart';
import 'package:chinese_chess/models/supabase_auth_service.dart';
import 'package:chinese_chess/l10n/generated/app_localizations.dart';

void main() {
  group('Game Mode Selection UI Tests', () {
    testWidgets('Should display game mode selection screen with proper cards', (WidgetTester tester) async {
      // Create mock providers
      final localeProvider = LocaleProvider();
      final authService = SupabaseAuthService();

      // Build the widget with necessary providers and localization
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: localeProvider),
            ChangeNotifierProvider.value(value: authService),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('zh', 'CN'),
              Locale('vi', ''),
            ],
            home: const GameBoard(),
          ),
        ),
      );

      // Wait for the widget to settle
      await tester.pumpAndSettle();

      // Verify that the main title is displayed
      expect(find.text('Chinese Chess'), findsOneWidget);

      // Verify that the subtitle is displayed
      expect(find.text('Choose your game mode'), findsOneWidget);

      // Verify that all three game mode cards are present
      expect(find.text('Robot Mode'), findsOneWidget);
      expect(find.text('Online Mode'), findsOneWidget);
      expect(find.text('Free Mode'), findsOneWidget);

      // Verify that subtitles are displayed
      expect(find.text('Play against AI opponent'), findsOneWidget);
      expect(find.text('Play with friends online'), findsOneWidget);
      expect(find.text('Local multiplayer on same device'), findsOneWidget);

      // Verify that "Coming Soon" badge is displayed for online mode
      expect(find.text('Coming Soon'), findsOneWidget);

      // Verify that the proper icons are displayed
      expect(find.byIcon(Icons.smart_toy), findsOneWidget);
      expect(find.byIcon(Icons.wifi), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
    });

    testWidgets('Should handle robot mode selection', (WidgetTester tester) async {
      // Create mock providers
      final localeProvider = LocaleProvider();
      final authService = SupabaseAuthService();

      // Build the widget
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: localeProvider),
            ChangeNotifierProvider.value(value: authService),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
            ],
            home: const GameBoard(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the Robot Mode card
      final robotModeCard = find.ancestor(
        of: find.text('Robot Mode'),
        matching: find.byType(InkWell),
      );

      expect(robotModeCard, findsOneWidget);
      await tester.tap(robotModeCard);
      await tester.pumpAndSettle();

      // After tapping, the game mode selection should be replaced with the game interface
      // The title should still be there but the mode selection cards should be gone
      expect(find.text('Choose your game mode'), findsNothing);
    });

    testWidgets('Should handle free mode selection', (WidgetTester tester) async {
      // Create mock providers
      final localeProvider = LocaleProvider();
      final authService = SupabaseAuthService();

      // Build the widget
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: localeProvider),
            ChangeNotifierProvider.value(value: authService),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
            ],
            home: const GameBoard(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the Free Mode card
      final freeModeCard = find.ancestor(
        of: find.text('Free Mode'),
        matching: find.byType(InkWell),
      );

      expect(freeModeCard, findsOneWidget);
      await tester.tap(freeModeCard);
      await tester.pumpAndSettle();

      // After tapping, the game mode selection should be replaced with the game interface
      expect(find.text('Choose your game mode'), findsNothing);
    });
  });
}
