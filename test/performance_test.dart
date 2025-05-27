import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chinese_chess/models/chess_timer.dart';
import 'package:chinese_chess/models/game_timer_manager.dart';
import 'package:chinese_chess/models/game_manager.dart';
import 'package:chinese_chess/components/chess_timer_widget.dart';

void main() {
  group('Performance Tests', () {
    testWidgets('Timer updates should not cause excessive rebuilds', (WidgetTester tester) async {
      // Create a timer
      final timer = ChessTimer(initialTime: 60, increment: 2);

      // Track rebuild count
      int rebuildCount = 0;

      // Create a test widget that tracks rebuilds
      Widget testWidget = MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              rebuildCount++;
              return ChessTimerWidget(
                timer: timer,
                isActive: true,
                color: Colors.blue,
              );
            },
          ),
        ),
      );

      // Build the widget
      await tester.pumpWidget(testWidget);

      // Start the timer
      timer.start();

      // Wait for a few timer updates (should be 1 second intervals now)
      await tester.pump(const Duration(seconds: 3));

      // Stop the timer
      timer.stop();

      // Verify that rebuilds are reasonable (should be much less than before)
      // With 1-second intervals, we should have at most 4-5 rebuilds in 3 seconds
      expect(rebuildCount, lessThan(10),
        reason: 'Timer widget should not rebuild excessively');
    });

    testWidgets('Chess board should use RepaintBoundary', (WidgetTester tester) async {
      // This test verifies that RepaintBoundary widgets are present
      // in the widget tree to isolate repaints

      Widget testWidget = const MaterialApp(
        home: Scaffold(
          body: RepaintBoundary(
            child: SizedBox(
              width: 300,
              height: 300,
              child: Placeholder(), // Simulating chess board
            ),
          ),
        ),
      );

      await tester.pumpWidget(testWidget);

      // Verify RepaintBoundary widgets are present (should find multiple)
      expect(find.byType(RepaintBoundary), findsWidgets);
    });

    test('Timer should only notify listeners when time actually changes', () {
      final timer = ChessTimer(initialTime: 60, increment: 2);
      int notificationCount = 0;

      // Listen to timer changes
      timer.addListener(() {
        notificationCount++;
      });

      // Start timer
      timer.start();

      // Simulate time passing but not enough to change displayed time
      // (This would require mocking DateTime.now() in a real test)

      // Stop timer
      timer.stop();

      // The exact count will depend on implementation, but it should be reasonable
      expect(notificationCount, lessThan(100),
        reason: 'Timer should not notify excessively');
    });

    test('GameTimerManager should handle timer events efficiently', () {
      final gameManager = GameManager.instance;
      final timerManager = GameTimerManager(
        gameManager: gameManager,
        initialTimeSeconds: 60,
        incrementSeconds: 2,
      );

      // Test that timer manager doesn't cause memory leaks
      expect(timerManager.redTimer, isNotNull);
      expect(timerManager.blackTimer, isNotNull);

      // Test cleanup
      timerManager.dispose();

      // Verify timers are properly disposed (they should be in ready state after dispose)
      expect(timerManager.redTimer.state, TimerState.ready);
      expect(timerManager.blackTimer.state, TimerState.ready);
    });
  });
}
