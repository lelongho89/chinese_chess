import 'package:flutter_test/flutter_test.dart';
import 'package:chinese_chess/models/chess_timer.dart';

void main() {
  group('ChessTimer', () {
    late ChessTimer timer;
    
    setUp(() {
      timer = ChessTimer(initialTime: 180, increment: 2);
    });
    
    test('initial state is correct', () {
      expect(timer.timeRemaining, equals(180));
      expect(timer.state, equals(TimerState.ready));
      expect(timer.isRunning, equals(false));
      expect(timer.isExpired, equals(false));
      expect(timer.formattedTime, equals('03:00'));
    });
    
    test('start changes state to running', () {
      timer.start();
      expect(timer.state, equals(TimerState.running));
      expect(timer.isRunning, equals(true));
    });
    
    test('pause changes state to paused', () {
      timer.start();
      timer.pause();
      expect(timer.state, equals(TimerState.paused));
      expect(timer.isRunning, equals(false));
    });
    
    test('resume changes state back to running', () {
      timer.start();
      timer.pause();
      timer.resume();
      expect(timer.state, equals(TimerState.running));
      expect(timer.isRunning, equals(true));
    });
    
    test('stop changes state to stopped', () {
      timer.start();
      timer.stop();
      expect(timer.state, equals(TimerState.stopped));
      expect(timer.isRunning, equals(false));
    });
    
    test('reset changes state to ready and resets time', () {
      timer.start();
      // Manually set time to simulate elapsed time
      timer.setTimeRemaining(100);
      timer.reset();
      expect(timer.state, equals(TimerState.ready));
      expect(timer.timeRemaining, equals(180));
      expect(timer.formattedTime, equals('03:00'));
    });
    
    test('addIncrement adds increment to time remaining', () {
      timer.start();
      // Manually set time to simulate elapsed time
      timer.setTimeRemaining(100);
      timer.addIncrement();
      expect(timer.timeRemaining, equals(102));
      expect(timer.formattedTime, equals('01:42'));
    });
    
    test('setTimeRemaining updates time correctly', () {
      timer.setTimeRemaining(90);
      expect(timer.timeRemaining, equals(90));
      expect(timer.formattedTime, equals('01:30'));
    });
    
    test('setTimeRemaining to zero changes state to expired', () {
      timer.setTimeRemaining(0);
      expect(timer.state, equals(TimerState.expired));
      expect(timer.isExpired, equals(true));
      expect(timer.timeRemaining, equals(0));
      expect(timer.formattedTime, equals('00:00'));
    });
    
    test('formattedTime formats time correctly', () {
      timer.setTimeRemaining(65);
      expect(timer.formattedTime, equals('01:05'));
      
      timer.setTimeRemaining(9);
      expect(timer.formattedTime, equals('00:09'));
      
      timer.setTimeRemaining(0);
      expect(timer.formattedTime, equals('00:00'));
    });
  });
}
