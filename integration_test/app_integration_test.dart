import 'package:chinese_chess/main.dart' as app;
import 'package:chinese_chess/models/game_manager.dart';
import 'package:chinese_chess/widgets/social_login_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Chinese Chess App Integration Tests', () {
    testWidgets('Full app flow test - localization, skin, game, quit',
        (WidgetTester tester) async {
      // Set up SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Take a screenshot of the home screen
      await IntegrationTestWidgetsFlutterBinding.instance
          .takeScreenshot('01_home_screen');

      // 1. Test Localization - Navigate to settings
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

      // Take a screenshot of settings screen
      await IntegrationTestWidgetsFlutterBinding.instance
          .takeScreenshot('02_settings_screen');

      // Change language to Vietnamese
      final languageFinder = find.text('Language');
      if (languageFinder.evaluate().isNotEmpty) {
        await tester.tap(languageFinder);
        await tester.pumpAndSettle();
        
        final vietnameseFinder = find.text('Vietnamese');
        if (vietnameseFinder.evaluate().isNotEmpty) {
          await tester.tap(vietnameseFinder);
          await tester.pumpAndSettle();
        }
      }

      // Take a screenshot with Vietnamese language
      await IntegrationTestWidgetsFlutterBinding.instance
          .takeScreenshot('03_vietnamese_language');

      // 2. Test Skin Switching
      // Find and tap on chess skin selection
      final skinFinder = find.textContaining('Giao Diện Quân Cờ');
      if (skinFinder.evaluate().isNotEmpty) {
        await tester.tap(skinFinder);
        await tester.pumpAndSettle();
      }

      // Get the current skin
      final gameManager = GameManager.instance;
      final initialSkin = gameManager.skin.folder;
      
      // Select the other skin
      final targetSkin = initialSkin == 'woods' ? 'Đá' : 'Gỗ';
      final skinOptionFinder = find.text(targetSkin);
      
      if (skinOptionFinder.evaluate().isNotEmpty) {
        await tester.tap(skinOptionFinder);
        await tester.pumpAndSettle();
      }

      // Take a screenshot after skin change
      await IntegrationTestWidgetsFlutterBinding.instance
          .takeScreenshot('04_skin_changed');

      // Go back to main screen
      final backButtonFinder = find.byType(BackButton);
      if (backButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(backButtonFinder);
        await tester.pumpAndSettle();
      }

      // 3. Test Social Login UI (if available)
      // Look for login button
      final loginButtonFinder = find.byType(ElevatedButton)
          .evaluate()
          .where((element) {
            final widget = element.widget as ElevatedButton;
            return widget.child is Text && 
                  (widget.child as Text).data?.contains('Đăng nhập') == true;
          })
          .isEmpty ? null : find.byType(ElevatedButton).first;
          
      if (loginButtonFinder != null) {
        await tester.tap(loginButtonFinder);
        await tester.pumpAndSettle();
        
        // Verify social login buttons are displayed
        expect(find.byType(SocialLoginButtons), findsOneWidget);
        
        // Take a screenshot of login screen
        await IntegrationTestWidgetsFlutterBinding.instance
            .takeScreenshot('05_login_screen');
            
        // Go back to main screen
        final loginBackButtonFinder = find.byType(BackButton);
        if (loginBackButtonFinder.evaluate().isNotEmpty) {
          await tester.tap(loginBackButtonFinder);
          await tester.pumpAndSettle();
        }
      }

      // 4. Test Game Start and Quit
      // Start a new game
      final newGameFinder = find.text('Ván Mới');
      if (newGameFinder.evaluate().isNotEmpty) {
        await tester.tap(newGameFinder);
        await tester.pumpAndSettle();
      }

      // Take a screenshot of the game with the new skin
      await IntegrationTestWidgetsFlutterBinding.instance
          .takeScreenshot('06_game_screen_new_skin');

      // Open game menu
      final gameMenuButtonFinder = find.byIcon(Icons.menu);
      if (gameMenuButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(gameMenuButtonFinder);
        await tester.pumpAndSettle();
      }

      // Take a screenshot of game menu
      await IntegrationTestWidgetsFlutterBinding.instance
          .takeScreenshot('07_game_menu');

      // Find and tap on quit button
      final quitButtonFinder = find.text('Thoát');
      if (quitButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(quitButtonFinder);
        await tester.pumpAndSettle();
      }

      // If there's a confirmation dialog, confirm quit
      final confirmQuitFinder = find.text('Thoát');
      if (confirmQuitFinder.evaluate().isNotEmpty) {
        await tester.tap(confirmQuitFinder);
        await tester.pumpAndSettle();
      }

      // Take a screenshot after returning to home screen
      await IntegrationTestWidgetsFlutterBinding.instance
          .takeScreenshot('08_back_to_home');

      // Verify we're back at home screen
      expect(find.text('Ván Mới'), findsOneWidget);
    });
  });
}
