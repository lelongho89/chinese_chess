import 'package:chinese_chess/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Quit Game Integration Tests', () {
    testWidgets('Quit button returns to home screen without exiting app',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Take a screenshot of the home screen
      await IntegrationTestWidgetsFlutterBinding.instance
          .takeScreenshot('home_screen');

      // Start a new game
      final newGameFinder = find.text('New Game');
      if (newGameFinder.evaluate().isNotEmpty) {
        await tester.tap(newGameFinder);
        await tester.pumpAndSettle();
      }

      // Take a screenshot of the game screen
      await IntegrationTestWidgetsFlutterBinding.instance
          .takeScreenshot('game_screen');

      // Find and tap on the menu button
      final menuButtonFinder = find.byIcon(Icons.menu);
      if (menuButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(menuButtonFinder);
        await tester.pumpAndSettle();
      }

      // Take a screenshot of the game menu
      await IntegrationTestWidgetsFlutterBinding.instance
          .takeScreenshot('game_menu');

      // Find and tap on the quit button
      final quitButtonFinder = find.text('Quit');
      if (quitButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(quitButtonFinder);
        await tester.pumpAndSettle();
      }

      // If there's a confirmation dialog, confirm the quit action
      final confirmQuitFinder = find.text('Yes');
      if (confirmQuitFinder.evaluate().isNotEmpty) {
        await tester.tap(confirmQuitFinder);
        await tester.pumpAndSettle();
      }

      // Take a screenshot after quitting
      await IntegrationTestWidgetsFlutterBinding.instance
          .takeScreenshot('after_quit_game');

      // Verify that we're back at the home screen
      expect(find.text('New Game'), findsOneWidget);
      
      // Verify that the app is still running (not exited)
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
