# Elo Rating System

## Overview

The Chinese Chess app implements a basic Elo rating system with K=32 to track player skill levels and maintain competitive balance in ranked games.

## Implementation Details

### Core Components

1. **EloService** (`lib/services/elo_service.dart`)
   - Singleton service handling all Elo calculations
   - K-factor of 32 for moderate rating volatility
   - Integrates with user and leaderboard repositories

2. **User Model** (`lib/models/user_model.dart`)
   - Stores player Elo rating (default: 1200)
   - Tracks game statistics (played, won, lost, draw)

3. **Leaderboard System** (`lib/repositories/leaderboard_repository.dart`)
   - Maintains player rankings
   - Automatic rank recalculation after rating updates

### Mathematical Formula

The Elo rating system uses the standard formula:

```
Expected Score = 1 / (1 + 10^((Opponent Rating - Player Rating) / 400))
New Rating = Old Rating + K * (Actual Score - Expected Score)
```

Where:
- **K-factor = 32**: Determines rating volatility
- **Actual Score**: 1.0 for win, 0.5 for draw, 0.0 for loss
- **Expected Score**: Probability of winning based on rating difference

### Integration

The Elo system is automatically triggered when:
1. A ranked game ends (`GameService.endGame()`)
2. Players have valid user records
3. Game result is determined (win/loss/draw)

### Key Features

- **Zero-sum system**: Total rating points are preserved
- **Upset handling**: Lower-rated players gain more points for wins
- **Draw mechanics**: Rating adjustments based on expected outcomes
- **Automatic leaderboard updates**: Rankings recalculated after each game

### Test Coverage

Comprehensive unit tests verify:
- Mathematical accuracy of calculations
- Edge cases (extreme ratings, draws)
- Zero-sum property preservation
- K-factor validation
- Rating boundary handling

### Usage Example

```dart
// Automatically called when a ranked game ends
final newRatings = await EloService.instance.calculateNewRatings(
  redPlayerId: 'player1',
  blackPlayerId: 'player2', 
  winnerId: 'player1', // or null for draw
  isDraw: false,
);

// Returns: {'player1': 1516, 'player2': 1484}
```

### Database Schema

**Users Table:**
- `elo_rating`: Integer (default 1200)
- `games_played`: Integer
- `games_won`: Integer  
- `games_lost`: Integer
- `games_draw`: Integer

**Leaderboard Table:**
- `user_id`: String (FK to users)
- `elo_rating`: Integer
- `rank`: Integer
- `win_rate`: Double
- `last_updated`: Timestamp

### Performance Considerations

- Batch updates for multiple rating changes
- Efficient rank recalculation using database sorting
- Minimal database queries per game completion

### Future Enhancements

Potential improvements for the rating system:
- Dynamic K-factor based on player experience
- Provisional ratings for new players
- Rating floors to prevent excessive drops
- Seasonal rating resets
- Tournament-specific rating pools
