import 'package:flutter_test/flutter_test.dart';
import 'package:chinese_chess/services/ranking_service.dart';

void main() {
  group('RankingService Tests', () {
    test('should return correct rank for different Elo ratings', () {
      // Test Soldier rank (0-999)
      var ranking = RankingService.getPlayerRanking(500);
      expect(ranking.rank.englishName, 'Soldier');
      expect(ranking.rank.chineseName, '兵');
      expect(ranking.rank.vietnameseName, 'Lính');

      // Test Apprentice rank (1000-1299)
      ranking = RankingService.getPlayerRanking(1200);
      expect(ranking.rank.englishName, 'Apprentice');
      expect(ranking.rank.chineseName, '士');
      expect(ranking.rank.vietnameseName, 'Cố Vấn');

      // Test Scholar rank (1300-1599)
      ranking = RankingService.getPlayerRanking(1450);
      expect(ranking.rank.englishName, 'Scholar');
      expect(ranking.rank.chineseName, '象');
      expect(ranking.rank.vietnameseName, 'Tượng');

      // Test Knight rank (1600-1899)
      ranking = RankingService.getPlayerRanking(1750);
      expect(ranking.rank.englishName, 'Knight');
      expect(ranking.rank.chineseName, '马');
      expect(ranking.rank.vietnameseName, 'Mã');

      // Test Chariot rank (1900-2199)
      ranking = RankingService.getPlayerRanking(2050);
      expect(ranking.rank.englishName, 'Chariot');
      expect(ranking.rank.chineseName, '车');
      expect(ranking.rank.vietnameseName, 'Xe');

      // Test Cannon rank (2200-2499)
      ranking = RankingService.getPlayerRanking(2350);
      expect(ranking.rank.englishName, 'Cannon');
      expect(ranking.rank.chineseName, '炮');
      expect(ranking.rank.vietnameseName, 'Pháo');

      // Test General rank (2500+)
      ranking = RankingService.getPlayerRanking(2600);
      expect(ranking.rank.englishName, 'General');
      expect(ranking.rank.chineseName, '将');
      expect(ranking.rank.vietnameseName, 'Tướng');
    });

    test('should calculate correct star levels', () {
      // Test Apprentice rank star levels (1000-1299)
      // 1 star: 1000-1099
      var ranking = RankingService.getPlayerRanking(1050);
      expect(ranking.starLevel, 1);

      // 2 stars: 1100-1199
      ranking = RankingService.getPlayerRanking(1150);
      expect(ranking.starLevel, 2);

      // 3 stars: 1200-1299
      ranking = RankingService.getPlayerRanking(1250);
      expect(ranking.starLevel, 3);

      // Test Soldier rank star levels (0-999) - every 333 points
      ranking = RankingService.getPlayerRanking(100);
      expect(ranking.starLevel, 1);

      ranking = RankingService.getPlayerRanking(400);
      expect(ranking.starLevel, 2);

      ranking = RankingService.getPlayerRanking(700);
      expect(ranking.starLevel, 3);

      // Test General rank star levels (2500+) - every 1000 points
      ranking = RankingService.getPlayerRanking(2600);
      expect(ranking.starLevel, 1);

      ranking = RankingService.getPlayerRanking(3600);
      expect(ranking.starLevel, 2);
    });

    test('should handle edge cases correctly', () {
      // Test minimum Elo (should be Soldier)
      var ranking = RankingService.getPlayerRanking(0);
      expect(ranking.rank.englishName, 'Soldier');
      expect(ranking.starLevel, 1);

      // Test very high Elo (should be General)
      ranking = RankingService.getPlayerRanking(3000);
      expect(ranking.rank.englishName, 'General');

      // Test boundary values
      ranking = RankingService.getPlayerRanking(999);
      expect(ranking.rank.englishName, 'Soldier');

      ranking = RankingService.getPlayerRanking(1000);
      expect(ranking.rank.englishName, 'Apprentice');
    });

    test('should return all ranks', () {
      var allRanks = RankingService.getAllRanks();
      expect(allRanks.length, 7);
      expect(allRanks[0].englishName, 'Soldier');
      expect(allRanks[6].englishName, 'General');
    });

    test('should calculate rank index correctly', () {
      expect(RankingService.getRankIndex(500), 0); // Soldier
      expect(RankingService.getRankIndex(1200), 1); // Apprentice
      expect(RankingService.getRankIndex(2600), 6); // General
    });
  });
}
