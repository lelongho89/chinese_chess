import 'package:chinese_chess/main.dart' as app;
import 'package:chinese_chess/screens/login_screen.dart';
import 'package:chinese_chess/widgets/social_login_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Social Login Integration Tests', () {
    testWidgets('Social login buttons are displayed on login screen',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to login screen if not already there
      // This depends on your app's navigation structure
      // You might need to tap on a login button first
      
      // Find login screen by looking for its widgets
      final loginButtonFinder = find.byType(ElevatedButton)
          .evaluate()
          .where((element) {
            final widget = element.widget as ElevatedButton;
            return widget.child is Text && 
                  (widget.child as Text).data?.contains('Login') == true;
          })
          .isEmpty ? null : find.byType(ElevatedButton).first;
          
      if (loginButtonFinder != null) {
        await tester.tap(loginButtonFinder);
        await tester.pumpAndSettle();
      }

      // Verify social login buttons are displayed
      expect(find.byType(SocialLoginButtons), findsOneWidget);
      
      // Take a screenshot of the login screen
      await IntegrationTestWidgetsFlutterBinding.instance
          .takeScreenshot('social_login_screen');
      
      // Find Google and Facebook buttons
      final googleButtonFinder = find.descendant(
        of: find.byType(SocialLoginButtons),
        matching: find.byWidgetPredicate((widget) => 
          widget is InkWell && 
          widget.toString().contains('google_logo')),
      );
      
      final facebookButtonFinder = find.descendant(
        of: find.byType(SocialLoginButtons),
        matching: find.byWidgetPredicate((widget) => 
          widget is InkWell && 
          widget.toString().contains('facebook_logo')),
      );
      
      // Verify both buttons are present
      expect(googleButtonFinder, findsOneWidget);
      expect(facebookButtonFinder, findsOneWidget);
    });
    
    // Note: We can't fully test the actual login process in integration tests
    // because it requires real Google/Facebook authentication
    // Instead, we're verifying the UI components are correctly displayed
  });
}
