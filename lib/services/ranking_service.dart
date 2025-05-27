import 'package:flutter/material.dart';
import '../global.dart';

/// Service for handling player ranking system based on Elo ratings
/// Uses Xiangqi piece names for culturally resonant badges
class RankingService {
  // Singleton pattern
  static RankingService? _instance;
  static RankingService get instance => _instance ??= RankingService._();

  RankingService._();

  /// Get rank from Elo rating using the exact logic provided
  static Rank getRankFromElo(int elo) {
    if (elo >= 2500) return Rank(
      englishName: 'General', chineseName: '将', vietnameseName: 'Tướng',
      minElo: 2500, maxElo: 9999, stars: ((elo - 2500) ~/ 1000) + 1);
    if (elo >= 2200) return Rank(
      englishName: 'Cannon', chineseName: '炮', vietnameseName: 'Pháo',
      minElo: 2200, maxElo: 2499, stars: ((elo - 2200) ~/ 100) + 1);
    if (elo >= 1900) return Rank(
      englishName: 'Chariot', chineseName: '车', vietnameseName: 'Xe',
      minElo: 1900, maxElo: 2199, stars: ((elo - 1900) ~/ 100) + 1);
    if (elo >= 1600) return Rank(
      englishName: 'Knight', chineseName: '马', vietnameseName: 'Mã',
      minElo: 1600, maxElo: 1899, stars: ((elo - 1600) ~/ 100) + 1);
    if (elo >= 1300) return Rank(
      englishName: 'Scholar', chineseName: '象', vietnameseName: 'Tượng',
      minElo: 1300, maxElo: 1599, stars: ((elo - 1300) ~/ 100) + 1);
    if (elo >= 1000) return Rank(
      englishName: 'Apprentice', chineseName: '士', vietnameseName: 'Cố Vấn',
      minElo: 1000, maxElo: 1299, stars: ((elo - 1000) ~/ 100) + 1);
    return Rank(
      englishName: 'Soldier', chineseName: '兵', vietnameseName: 'Lính',
      minElo: 0, maxElo: 999, stars: ((elo - 0) ~/ 333) + 1);
  }

  /// Get complete ranking information for a player
  static PlayerRanking getPlayerRanking(int eloRating) {
    final rank = getRankFromElo(eloRating);
    return PlayerRanking(
      rank: rank,
      eloRating: eloRating,
    );
  }

  /// Get all available ranks (for UI display)
  static List<Rank> getAllRanks() {
    return [
      getRankFromElo(0),    // Soldier
      getRankFromElo(1000), // Apprentice
      getRankFromElo(1300), // Scholar
      getRankFromElo(1600), // Knight
      getRankFromElo(1900), // Chariot
      getRankFromElo(2200), // Cannon
      getRankFromElo(2500), // General
    ];
  }

  /// Get rank index (0-based) for sorting purposes
  static int getRankIndex(int eloRating) {
    final rank = getRankFromElo(eloRating);
    if (rank.minElo >= 2500) return 6; // General
    if (rank.minElo >= 2200) return 5; // Cannon
    if (rank.minElo >= 1900) return 4; // Chariot
    if (rank.minElo >= 1600) return 3; // Knight
    if (rank.minElo >= 1300) return 2; // Scholar
    if (rank.minElo >= 1000) return 1; // Apprentice
    return 0; // Soldier
  }

  /// Calculate Elo needed for next star or rank
  static EloProgress getEloProgress(int eloRating) {
    final currentRank = getRankFromElo(eloRating);
    final currentStars = currentRank.stars;

    // Calculate points needed for next star
    int? nextStarElo;
    int? nextRankElo;

    if (currentRank.englishName == 'General') {
      // For General, next star is every 1000 points
      nextStarElo = 2500 + (currentStars * 1000);
    } else if (currentRank.englishName == 'Soldier') {
      // For Soldier, next star is every 333 points
      if (currentStars < 3) {
        nextStarElo = (currentStars * 333) + 1;
      }
      nextRankElo = 1000; // Next rank is Apprentice
    } else {
      // For other ranks, next star is every 100 points
      if (currentStars < 3) {
        nextStarElo = currentRank.minElo + (currentStars * 100);
      }
      // Calculate next rank Elo
      if (currentRank.minElo < 2500) {
        nextRankElo = currentRank.maxElo + 1;
      }
    }

    return EloProgress(
      currentElo: eloRating,
      nextStarElo: nextStarElo,
      nextRankElo: nextRankElo,
      currentRank: currentRank,
    );
  }
}

/// Rank class with localization support
class Rank {
  final String englishName;
  final String chineseName;
  final String vietnameseName;
  final int minElo;
  final int maxElo;
  final int stars;

  const Rank({
    required this.englishName,
    required this.chineseName,
    required this.vietnameseName,
    required this.minElo,
    required this.maxElo,
    required this.stars,
  });

  /// Get localized name based on context
  String getLocalizedName(BuildContext context) {
    switch (englishName) {
      case 'Soldier':
        return context.l10n.rankSoldier;
      case 'Apprentice':
        return context.l10n.rankApprentice;
      case 'Scholar':
        return context.l10n.rankScholar;
      case 'Knight':
        return context.l10n.rankKnight;
      case 'Chariot':
        return context.l10n.rankChariot;
      case 'Cannon':
        return context.l10n.rankCannon;
      case 'General':
        return context.l10n.rankGeneral;
      default:
        return englishName;
    }
  }

  /// Get localized description based on context
  String getLocalizedDescription(BuildContext context) {
    switch (englishName) {
      case 'Soldier':
        return context.l10n.rankSoldierDesc;
      case 'Apprentice':
        return context.l10n.rankApprenticeDesc;
      case 'Scholar':
        return context.l10n.rankScholarDesc;
      case 'Knight':
        return context.l10n.rankKnightDesc;
      case 'Chariot':
        return context.l10n.rankChariotDesc;
      case 'Cannon':
        return context.l10n.rankCannonDesc;
      case 'General':
        return context.l10n.rankGeneralDesc;
      default:
        return '';
    }
  }

  /// Get the appropriate character based on locale
  String getDisplayCharacter(BuildContext context) {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'vi':
        return vietnameseName;
      case 'zh':
        return chineseName;
      default:
        return chineseName; // Default to Chinese characters
    }
  }

  @override
  String toString() => '$chineseName ($englishName)';
}

/// Complete ranking information for a player
class PlayerRanking {
  final Rank rank;
  final int eloRating;

  const PlayerRanking({
    required this.rank,
    required this.eloRating,
  });

  /// Get localized display name
  String getDisplayName(BuildContext context) =>
      '${rank.getDisplayCharacter(context)} ${rank.getLocalizedName(context)}';

  /// Get short display name (just the character)
  String getShortDisplayName(BuildContext context) => rank.getDisplayCharacter(context);

  /// Get star level
  int get starLevel => rank.stars;

  @override
  String toString() => '${rank.chineseName} ${rank.englishName} (${rank.stars} ⭐)';
}

/// Progress information for Elo advancement
class EloProgress {
  final int currentElo;
  final int? nextStarElo;
  final int? nextRankElo;
  final Rank currentRank;

  const EloProgress({
    required this.currentElo,
    this.nextStarElo,
    this.nextRankElo,
    required this.currentRank,
  });

  int? get pointsToNextStar => nextStarElo != null ? nextStarElo! - currentElo : null;
  int? get pointsToNextRank => nextRankElo != null ? nextRankElo! - currentElo : null;
}
