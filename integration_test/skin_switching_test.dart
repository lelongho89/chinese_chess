import 'package:chinese_chess/main.dart' as app;
import 'package:chinese_chess/models/game_manager.dart';
import 'package:chinese_chess/models/game_setting.dart';
import 'package:chinese_chess/models/chess_skin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Skin Switching Integration Tests', () {
    testWidgets('App can switch between woods and stones skins',
        (WidgetTester tester) async {
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

      // Find and tap on chess skin selection
      final skinFinder = find.textContaining('Chess Skin');
      if (skinFinder.evaluate().isNotEmpty) {
        await tester.tap(skinFinder);
        await tester.pumpAndSettle();
      }

      // Take a screenshot of the skin selection dialog
      await IntegrationTestWidgetsFlutterBinding.instance
          .takeScreenshot('skin_selection_dialog');

      // Get the current skin
      final gameManager = GameManager.instance;
      final initialSkin = gameManager.skin.folder;
      
      // Select the other skin (if current is woods, select stones, and vice versa)
      final targetSkin = initialSkin == 'woods' ? 'Stones' : 'Woods';
      final skinOptionFinder = find.text(targetSkin);
      
      if (skinOptionFinder.evaluate().isNotEmpty) {
        await tester.tap(skinOptionFinder);
        await tester.pumpAndSettle();
      }

      // Go back to main screen
      final backButtonFinder = find.byType(BackButton);
      if (backButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(backButtonFinder);
        await tester.pumpAndSettle();
      }
      
      // Start a new game to see the skin change
      final newGameFinder = find.text('New Game');
      if (newGameFinder.evaluate().isNotEmpty) {
        await tester.tap(newGameFinder);
        await tester.pumpAndSettle();
      }
      
      // Take a screenshot of the game board with the new skin
      await IntegrationTestWidgetsFlutterBinding.instance
          .takeScreenshot('game_board_${targetSkin.toLowerCase()}_skin');
      
      // Verify that the skin has changed
      expect(gameManager.skin.folder, isNot(equals(initialSkin)));
      expect(gameManager.skin.folder, equals(targetSkin.toLowerCase()));
    });
  });
}
