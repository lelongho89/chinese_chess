import 'package:chinese_chess/main.dart' as app;
import 'package:chinese_chess/l10n/generated/app_localizations.dart';
import 'package:chinese_chess/models/game_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Localization Integration Tests', () {
    testWidgets('App can switch between languages', (WidgetTester tester) async {
      // Set up SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings screen
      final settingsButtonFinder = find.byIcon(Icons.settings);
      if (settingsButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(settingsButtonFinder);
        await tester.pumpAndSettle();
      } else {
        // If settings icon not found, look for menu button first
        final menuButtonFinder = find.byIcon(Icons.menu);
        if (menuButtonFinder.evaluate().isNotEmpty) {
          await tester.tap(menuButtonFinder);
          await tester.pumpAndSettle();
          
          // Now look for settings in the menu
          final settingsInMenuFinder = find.text('Settings').first;
          await tester.tap(settingsInMenuFinder);
          await tester.pumpAndSettle();
        }
      }

      // Take a screenshot of the settings screen with default language
      await IntegrationTestWidgetsFlutterBinding.instance
          .takeScreenshot('settings_default_language');

      // Find and tap on language selection
      final languageFinder = find.text('Language');
      if (languageFinder.evaluate().isNotEmpty) {
        await tester.tap(languageFinder);
        await tester.pumpAndSettle();
      }

      // Select Vietnamese language
      final vietnameseFinder = find.text('Vietnamese');
      if (vietnameseFinder.evaluate().isNotEmpty) {
        await tester.tap(vietnameseFinder);
        await tester.pumpAndSettle();
      }

      // Take a screenshot after language change
      await IntegrationTestWidgetsFlutterBinding.instance
          .takeScreenshot('settings_vietnamese_language');

      // Verify that text has changed to Vietnamese
      // Look for Vietnamese text that should now be displayed
      expect(find.text('Cài Đặt'), findsWidgets);
      
      // Go back to main screen
      final backButtonFinder = find.byType(BackButton);
      if (backButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(backButtonFinder);
        await tester.pumpAndSettle();
      }
      
      // Take a screenshot of main screen with Vietnamese language
      await IntegrationTestWidgetsFlutterBinding.instance
          .takeScreenshot('main_vietnamese_language');
      
      // Verify main screen elements are in Vietnamese
      expect(find.text('Ván Mới'), findsWidgets);
    });
  });
}
