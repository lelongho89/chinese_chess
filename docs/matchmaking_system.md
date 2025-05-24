# Matchmaking System with Elo Proximity

## Overview

The Chinese Chess app implements a sophisticated matchmaking system that pairs players based on Elo rating proximity, ensuring fair and competitive matches. The system supports multiple queue types, time controls, and player preferences.

## Architecture

### Core Components

1. **MatchmakingQueueModel** - Data model for queue entries
2. **MatchmakingQueueRepository** - Database operations and queries
3. **MatchmakingService** - Business logic and matching algorithms
4. **MatchmakingScreen** - User interface for queue management

### Database Schema

```sql
-- Matchmaking queue table
CREATE TABLE matchmaking_queue (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  elo_rating INTEGER NOT NULL,
  queue_type TEXT DEFAULT 'ranked',
  time_control INTEGER DEFAULT 180,
  preferred_color TEXT,
  max_elo_difference INTEGER DEFAULT 200,
  status TEXT DEFAULT 'waiting',
  matched_with_user_id UUID,
  match_id UUID,
  joined_at TIMESTAMP,
  matched_at TIMESTAMP,
  expires_at TIMESTAMP,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  is_deleted BOOLEAN DEFAULT FALSE
);
```

## Matching Algorithm

### Elo Proximity Matching

The system uses a sophisticated algorithm that considers:

1. **Base Elo Difference**: Initial maximum rating difference
   - 2000+ Elo: 150 points max
   - 1600-1999 Elo: 200 points max
   - 1200-1599 Elo: 250 points max
   - <1200 Elo: 300 points max

2. **Wait Time Expansion**: Gradually increases search range
   - Every 30 seconds: +50 points to max difference
   - Maximum expansion: 800 points total
   - Prevents indefinite waiting

3. **Priority Factors**:
   - Closer Elo ratings preferred
   - Longer wait times get priority
   - Time control compatibility required

### Matching Process

```dart
// Periodic matching process (every 5 seconds)
1. Expire old queue entries (>10 minutes)
2. Get waiting players by queue type
3. Sort by join time (FIFO fairness)
4. For each player:
   - Calculate expanded Elo range
   - Find best match within range
   - Create game if match found
   - Mark both players as matched
```

## Queue Types

### Ranked Queue
- Affects player Elo ratings
- Stricter matching criteria
- Recorded in player statistics
- Contributes to leaderboard rankings

### Casual Queue
- No Elo rating changes
- More relaxed matching
- Practice and fun games
- Faster queue times

### Tournament Queue (Future)
- Special tournament events
- Bracket-style elimination
- Prize pools and rewards
- Scheduled competitions

## Features

### Player Preferences

1. **Color Preference**
   - Red (first player)
   - Black (second player)
   - No preference (automatic assignment)

2. **Time Control Options**
   - 1 minute (60 seconds)
   - 3 minutes (180 seconds) - default
   - 5 minutes (300 seconds)
   - 10 minutes (600 seconds)

3. **Custom Elo Range**
   - Override default max difference
   - Stricter or more relaxed matching
   - Advanced player option

### Queue Management

1. **Automatic Expiration**
   - 10-minute default timeout
   - Prevents stale queue entries
   - Configurable per queue type

2. **Status Tracking**
   - Waiting: Actively searching
   - Matched: Game created
   - Cancelled: User left queue
   - Expired: Timeout reached

3. **Real-time Updates**
   - Live wait time display
   - Queue position tracking
   - Match notification

## Color Assignment Logic

```dart
// Priority order for color assignment:
1. Honor different preferences (red vs black)
2. Honor single preference (one player has preference)
3. Resolve conflicts by Elo rating (higher gets preference)
4. Default: Higher Elo gets red (traditional advantage)
```

## Performance Optimizations

### Database Indexes

```sql
-- Efficient matchmaking queries
CREATE INDEX matchmaking_queue_matching_idx ON matchmaking_queue(
  status, queue_type, elo_rating, joined_at
) WHERE status = 'waiting' AND is_deleted = false;

-- User lookup
CREATE INDEX matchmaking_queue_user_id_idx ON matchmaking_queue(user_id);

-- Cleanup operations
CREATE INDEX matchmaking_queue_expires_at_idx ON matchmaking_queue(expires_at);
```

### Stored Procedures

```sql
-- Find potential matches efficiently
CREATE FUNCTION find_potential_matches(
  target_user_id UUID,
  target_elo INTEGER,
  target_queue_type TEXT,
  max_elo_diff INTEGER
) RETURNS TABLE(...);

-- Automatic cleanup
CREATE FUNCTION expire_old_queue_entries() RETURNS void;
CREATE FUNCTION cleanup_expired_queue_entries() RETURNS void;
```

## API Usage

### Joining Queue

```dart
final queueId = await MatchmakingService.instance.joinQueue(
  userId: currentUser.uid,
  queueType: QueueType.ranked,
  timeControl: 180, // 3 minutes
  preferredColor: PreferredColor.red,
  customMaxEloDifference: 150, // Optional
);
```

### Monitoring Queue Status

```dart
final queue = await MatchmakingService.instance.getUserActiveQueue(userId);
if (queue != null) {
  print('Wait time: ${queue.waitTimeSeconds} seconds');
  print('Status: ${queue.statusDescription}');
}
```

### Leaving Queue

```dart
await MatchmakingService.instance.leaveQueue(queueId);
// or cancel all user queues
await MatchmakingService.instance.cancelUserQueue(userId);
```

## Statistics and Monitoring

### Queue Statistics

```dart
final stats = await MatchmakingService.instance.getQueueStats();
// Returns:
// - total_waiting: Number of players in queue
// - ranked_waiting: Players in ranked queue
// - casual_waiting: Players in casual queue
// - average_wait_time_seconds: Average wait time
```

### Performance Metrics

- Average match time by Elo range
- Queue abandonment rates
- Match quality scores
- Peak usage times

## Error Handling

### Common Scenarios

1. **User Not Found**: Validate user exists before queuing
2. **Duplicate Queue**: Cancel existing entries automatically
3. **Network Issues**: Retry with exponential backoff
4. **Database Errors**: Graceful degradation and logging

### Recovery Mechanisms

1. **Automatic Cleanup**: Periodic removal of stale entries
2. **Queue Validation**: Check entry validity before matching
3. **Fallback Matching**: Relaxed criteria for long waits
4. **Manual Intervention**: Admin tools for queue management

## Testing

### Unit Tests

- Elo difference calculations
- Wait time expansion logic
- Color assignment algorithms
- Edge case handling

### Integration Tests

- Database operations
- Real-time matching
- Queue lifecycle management
- Performance under load

## Future Enhancements

### Planned Features

1. **Regional Matching**: Prefer players in same region
2. **Skill-based Matching**: Consider recent performance
3. **Friend Prioritization**: Match with friends when possible
4. **Tournament Integration**: Special tournament queues
5. **AI Fallback**: Match with AI if no players available

### Performance Improvements

1. **Caching**: Redis for hot queue data
2. **Sharding**: Distribute queues by region/skill
3. **Load Balancing**: Multiple matchmaking servers
4. **Real-time Sync**: WebSocket for instant updates

## Configuration

### Environment Variables

```env
MATCHMAKING_ENABLED=true
QUEUE_TIMEOUT_MINUTES=10
MATCHING_INTERVAL_SECONDS=5
MAX_ELO_DIFFERENCE=800
EXPANSION_INTERVAL_SECONDS=30
EXPANSION_AMOUNT=50
```

### Feature Flags

- Enable/disable queue types
- Adjust matching parameters
- A/B test different algorithms
- Emergency queue shutdown
