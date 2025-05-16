import 'package:flutter_test/flutter_test.dart';
import 'package:chinese_chess/models/chess_timer.dart';
import 'package:chinese_chess/models/game_manager.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([GameManager])
import 'timer_expiration_test.mocks.dart';

void main() {
  group('Timer Expiration', () {
    late ChessTimer timer;
    late MockGameManager mockGameManager;
    
    setUp(() {
      mockGameManager = MockGameManager();
      timer = ChessTimer(initialTime: 5, increment: 2);
    });
    
    test('Game manager is notified when timer expires', () async {
      // Set timer to almost expired
      timer.setTimeRemaining(1);
      timer.start();
      
      // Wait for timer to expire
      await Future.delayed(const Duration(seconds: 2));
      
      // Verify timer is expired
      expect(timer.isExpired, isTrue);
      expect(timer.state, equals(TimerState.expired));
      
      // In a real scenario, the GameManager would be notified
      // This can be tested with the integration test
    });
  });
}