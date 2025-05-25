# AI Matching System

## Overview

The AI Matching System automatically pairs human players with AI opponents when no other human players are available in the matchmaking queue. This ensures players always find matches and can test the online multiplayer system even during low-traffic periods.

## How It Works

### 1. Primary Matching (Human vs Human)
- The system first attempts to match players with other human players
- Uses Elo-based proximity matching with expanding search ranges over time
- Honors color preferences and time control requirements

### 2. Fallback AI Matching
When no suitable human opponent is found:
- **Wait Time**: Player must wait at least 30 seconds before AI matching
- **AI Selection**: System finds AI users within acceptable Elo range
- **Randomization**: Picks from top 3 closest AI opponents to add variety
- **Color Preference**: Human player's color preference is honored

## Configuration

### Constants (in `MatchmakingService`)
```dart
static const Duration _minWaitTimeForAI = Duration(seconds: 30);
static const bool _enableAIMatching = true;
static const int _maxAICandidates = 3;
```

### Elo Matching Rules
- Uses same expanding Elo difference as human matching
- Starts with base difference (150-300 based on player rating)
- Expands by 50 points every 30 seconds of waiting
- Maximum difference capped at 800 points

## AI User Requirements

### AI User Identification
- AI users have emails ending with `@aitest.com`
- Created through anonymous authentication system
- Stored in same `users` table as human players

### AI User Pool
- 15 AI users with realistic Elo distribution (800-2400)
- Weighted towards intermediate levels (1200-1600)
- Unique names like "Dragon Master", "Phoenix Player", etc.

## Match Creation Process

### Human vs AI Match
1. **Validation**: Check wait time and AI availability
2. **Selection**: Find suitable AI opponent by Elo proximity
3. **Color Assignment**: Honor human player's preference
4. **Game Creation**: Create game with special AI metadata
5. **Queue Update**: Mark human player's queue entry as matched

### Special Metadata for AI Matches
```dart
metadata: {
  'matchmaking': true,
  'ai_match': true,
  'queue_type': 'ranked',
  'time_control': 180,
  'player_wait_time': 45,
  'elo_difference': 120,
  'ai_opponent_id': 'uuid',
  'ai_opponent_name': 'Dragon Master',
}
```

## Benefits

### For Development
- **Always Available**: Developers can test matchmaking anytime
- **Realistic Testing**: AI users have varied Elo ratings
- **No Setup Required**: AI users are automatically created
- **Clean Testing**: Easy to add/remove AI users

### For Users
- **Reduced Wait Times**: No more empty queues
- **Skill-Appropriate Matches**: AI opponents match player skill level
- **Preference Respect**: Color choices are honored
- **Seamless Experience**: AI matches feel like human matches

## Implementation Details

### Key Files Modified
- `lib/services/matchmaking_service.dart` - Core AI matching logic
- `lib/repositories/matchmaking_queue_repository.dart` - AI match handling
- `lib/utils/populate_test_users.dart` - AI user creation

### Database Changes
- Modified `markAsMatched` to handle null `queueId2` for AI matches
- AI users stored in same `users` table with special email pattern
- Queue entries marked differently for AI vs human matches

## Future Enhancements

### Potential Improvements
- **AI Difficulty Levels**: Different AI personalities/styles
- **Learning AI**: AI that adapts to player patterns
- **AI Availability**: Time-based AI user availability
- **Custom AI**: Players can create custom AI opponents
- **AI Statistics**: Track performance against different AI types

### Configuration Options
- Adjustable wait time before AI matching
- Enable/disable AI matching per queue type
- Custom Elo ranges for AI matching
- Player preference for AI vs human-only matching
