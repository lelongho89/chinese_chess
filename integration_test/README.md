# Integration Tests for Chinese Chess

This directory contains integration tests for the Chinese Chess app, testing the following features:

1. **Social Login** - Verifies that Google and Facebook login buttons are displayed correctly
2. **Localization** - Tests switching between languages (English and Vietnamese)
3. **Skin Switching** - Tests changing between the "Woods" and "Stones" skins
4. **Quit Game** - Verifies that the quit button returns to the home screen without exiting the app
5. **Full App Flow** - A comprehensive test that combines all the above features

## Running the Tests

### Android and iOS

To run the integration tests on a connected device or emulator:

```bash
flutter test integration_test/app_integration_test.dart
```

To run a specific test:

```bash
flutter test integration_test/social_login_test.dart
flutter test integration_test/localization_test.dart
flutter test integration_test/skin_switching_test.dart
flutter test integration_test/quit_game_test.dart
```

### Taking Screenshots

The tests are configured to take screenshots at key points. Screenshots will be saved in the project root directory.

## Test Structure

Each test follows this general structure:

1. Initialize the integration test binding
2. Start the app
3. Navigate to the relevant screen
4. Perform actions to test the feature
5. Take screenshots at key points
6. Verify the expected behavior using assertions

## Notes

- The social login test only verifies the UI components, as actual authentication requires real Google/Facebook credentials
- Some tests may need adjustments based on the exact UI structure of your app
- The tests use `SharedPreferences.setMockInitialValues({})` to ensure a clean state for each test
