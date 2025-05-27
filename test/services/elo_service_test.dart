import 'package:flutter_test/flutter_test.dart';
import 'dart:math';

import 'package:chinese_chess/services/elo_service.dart';

void main() {
  group('EloService Mathematical Tests', () {
    test('should use K-factor of 32', () {
      expect(EloService.kFactor, equals(32));
    });

    test('should calculate expected score correctly for equal ratings', () {
      // Test the mathematical formula directly
      // Expected score = 1 / (1 + 10^((opponent_rating - player_rating) / 400))

      // For equal ratings (1500 vs 1500)
      final expectedScore = 1.0 / (1.0 + pow(10, (1500 - 1500) / 400));
      expect(expectedScore, equals(0.5));

      // For 200 point difference (1600 vs 1400)
      final expectedScoreHigher = 1.0 / (1.0 + pow(10, (1400 - 1600) / 400));
      expect(expectedScoreHigher, closeTo(0.76, 0.01));

      final expectedScoreLower = 1.0 / (1.0 + pow(10, (1600 - 1400) / 400));
      expect(expectedScoreLower, closeTo(0.24, 0.01));
    });

    test('should calculate new rating correctly for equal players', () {
      // Test the rating calculation formula directly
      // New rating = old_rating + K * (actual_score - expected_score)

      final oldRating = 1500;
      final expectedScore = 0.5; // Equal players
      final actualScoreWin = 1.0; // Winner
      final actualScoreLoss = 0.0; // Loser

      final newRatingWinner = (oldRating + EloService.kFactor * (actualScoreWin - expectedScore)).round();
      final newRatingLoser = (oldRating + EloService.kFactor * (actualScoreLoss - expectedScore)).round();

      expect(newRatingWinner, equals(1516)); // 1500 + 32 * (1.0 - 0.5) = 1516
      expect(newRatingLoser, equals(1484)); // 1500 + 32 * (0.0 - 0.5) = 1484
    });

    test('should preserve total rating points (zero-sum)', () {
      // Test that the total rating points are preserved
      final rating1 = 1600;
      final rating2 = 1400;
      final initialTotal = rating1 + rating2;

      // Calculate expected scores
      final expectedScore1 = 1.0 / (1.0 + pow(10, (rating2 - rating1) / 400));
      final expectedScore2 = 1.0 / (1.0 + pow(10, (rating1 - rating2) / 400));

      // Player 1 wins
      final actualScore1 = 1.0;
      final actualScore2 = 0.0;

      // Calculate new ratings
      final newRating1 = (rating1 + EloService.kFactor * (actualScore1 - expectedScore1)).round();
      final newRating2 = (rating2 + EloService.kFactor * (actualScore2 - expectedScore2)).round();

      final finalTotal = newRating1 + newRating2;

      // Total should be preserved (within rounding error)
      expect((finalTotal - initialTotal).abs(), lessThanOrEqualTo(1));
    });

    test('should handle extreme rating differences correctly', () {
      final highRating = 2000;
      final lowRating = 1200;

      // Calculate expected scores
      final expectedScoreHigh = 1.0 / (1.0 + pow(10, (lowRating - highRating) / 400));
      final expectedScoreLow = 1.0 / (1.0 + pow(10, (highRating - lowRating) / 400));

      // Lower rated player wins (major upset)
      final actualScoreHigh = 0.0;
      final actualScoreLow = 1.0;

      // Calculate new ratings
      final newRatingHigh = (highRating + EloService.kFactor * (actualScoreHigh - expectedScoreHigh)).round();
      final newRatingLow = (lowRating + EloService.kFactor * (actualScoreLow - expectedScoreLow)).round();

      // High rated player should lose close to 32 points
      expect(newRatingHigh, lessThan(highRating - 30));
      // Low rated player should gain close to 32 points
      expect(newRatingLow, greaterThan(lowRating + 30));
    });

    test('should handle draw correctly for equal players', () {
      final rating = 1500;
      final expectedScore = 0.5; // Equal players
      final actualScore = 0.5; // Draw

      final newRating = (rating + EloService.kFactor * (actualScore - expectedScore)).round();

      // No rating change for draw between equal players
      expect(newRating, equals(rating));
    });

    test('should handle draw correctly for unequal players', () {
      final highRating = 1600;
      final lowRating = 1400;

      // Calculate expected scores
      final expectedScoreHigh = 1.0 / (1.0 + pow(10, (lowRating - highRating) / 400));
      final expectedScoreLow = 1.0 / (1.0 + pow(10, (highRating - lowRating) / 400));

      // Draw
      final actualScore = 0.5;

      // Calculate new ratings
      final newRatingHigh = (highRating + EloService.kFactor * (actualScore - expectedScoreHigh)).round();
      final newRatingLow = (lowRating + EloService.kFactor * (actualScore - expectedScoreLow)).round();

      // Higher rated player should lose points in a draw
      expect(newRatingHigh, lessThan(highRating));
      // Lower rated player should gain points in a draw
      expect(newRatingLow, greaterThan(lowRating));
    });

    test('should handle minimum and maximum rating values', () {
      // Test with very low ratings
      final lowRating1 = 100;
      final lowRating2 = 100;

      final expectedScore = 0.5;
      final actualScoreWin = 1.0;
      final actualScoreLoss = 0.0;

      final newRatingWinner = (lowRating1 + EloService.kFactor * (actualScoreWin - expectedScore)).round();
      final newRatingLoser = (lowRating2 + EloService.kFactor * (actualScoreLoss - expectedScore)).round();

      expect(newRatingWinner, equals(116));
      expect(newRatingLoser, equals(84));

      // Test with very high ratings
      final highRating1 = 3000;
      final highRating2 = 3000;

      final newRatingWinnerHigh = (highRating1 + EloService.kFactor * (actualScoreWin - expectedScore)).round();
      final newRatingLoserHigh = (highRating2 + EloService.kFactor * (actualScoreLoss - expectedScore)).round();

      expect(newRatingWinnerHigh, equals(3016));
      expect(newRatingLoserHigh, equals(2984));
    });
  });

}
