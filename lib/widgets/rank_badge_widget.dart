import 'package:flutter/material.dart';
import '../services/ranking_service.dart';

/// Widget that displays a player's rank badge with stars
class RankBadgeWidget extends StatelessWidget {
  final int eloRating;
  final double size;
  final bool showStars;
  final bool showElo;
  final bool showDescription;

  const RankBadgeWidget({
    super.key,
    required this.eloRating,
    this.size = 120.0, // Increased default size
    this.showStars = true,
    this.showElo = false,
    this.showDescription = false,
  });

  @override
  Widget build(BuildContext context) {
    final ranking = RankingService.getPlayerRanking(eloRating);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Rank Badge
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: _getRankGradient(ranking.rank),
            border: Border.all(
              color: _getRankBorderColor(ranking.rank),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: _getRankBorderColor(ranking.rank).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(size * 0.1),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  ranking.rank.getDisplayCharacter(context),
                  style: TextStyle(
                    fontSize: size * 0.25, // Slightly smaller to fit better
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2, // Allow up to 2 lines for longer text
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Rank Name
        Text(
          ranking.rank.getLocalizedName(context),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: _getRankBorderColor(ranking.rank),
          ),
          textAlign: TextAlign.center,
        ),

        // Stars
        if (showStars) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(ranking.starLevel, (index) {
              return Icon(
                Icons.star,
                color: Colors.amber,
                size: size * 0.15,
              );
            }),
          ),
        ],

        // Elo Rating
        if (showElo) ...[
          const SizedBox(height: 4),
          Text(
            '$eloRating ELO',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],

        // Description
        if (showDescription) ...[
          const SizedBox(height: 4),
          Text(
            ranking.rank.getLocalizedDescription(context),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  /// Get gradient colors for rank badge
  LinearGradient _getRankGradient(Rank rank) {
    switch (rank.englishName) {
      case 'Soldier':
        return const LinearGradient(
          colors: [Color(0xFF8D6E63), Color(0xFF5D4037)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Apprentice':
        return const LinearGradient(
          colors: [Color(0xFF78909C), Color(0xFF455A64)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Scholar':
        return const LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Knight':
        return const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Chariot':
        return const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Cannon':
        return const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFE65100)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'General':
        return const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Colors.grey, Colors.blueGrey],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  /// Get border color for rank badge
  Color _getRankBorderColor(Rank rank) {
    switch (rank.englishName) {
      case 'Soldier':
        return const Color(0xFF3E2723);
      case 'Apprentice':
        return const Color(0xFF263238);
      case 'Scholar':
        return const Color(0xFF4A148C);
      case 'Knight':
        return const Color(0xFF0D47A1);
      case 'Chariot':
        return const Color(0xFF1B5E20);
      case 'Cannon':
        return const Color(0xFFBF360C);
      case 'General':
        return const Color(0xFF795548);
      default:
        return Colors.grey;
    }
  }
}

/// Compact version of rank badge for smaller spaces
class CompactRankBadge extends StatelessWidget {
  final int eloRating;
  final double size;

  const CompactRankBadge({
    super.key,
    required this.eloRating,
    this.size = 40.0, // Increased default size
  });

  @override
  Widget build(BuildContext context) {
    final ranking = RankingService.getPlayerRanking(eloRating);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getRankColor(ranking.rank),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(size * 0.1),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              ranking.rank.getDisplayCharacter(context),
              style: TextStyle(
                fontSize: size * 0.35, // Slightly smaller to fit better
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Color _getRankColor(Rank rank) {
    switch (rank.englishName) {
      case 'Soldier':
        return const Color(0xFF8D6E63);
      case 'Apprentice':
        return const Color(0xFF78909C);
      case 'Scholar':
        return const Color(0xFF9C27B0);
      case 'Knight':
        return const Color(0xFF2196F3);
      case 'Chariot':
        return const Color(0xFF4CAF50);
      case 'Cannon':
        return const Color(0xFFFF9800);
      case 'General':
        return const Color(0xFFFFD700);
      default:
        return Colors.grey;
    }
  }
}
