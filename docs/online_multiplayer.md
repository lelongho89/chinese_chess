# Online Multiplayer System

## Overview

The Chinese Chess app now features a complete online multiplayer system that enables real-time gameplay between players across the internet. The system uses Supabase real-time subscriptions for instant move synchronization and provides robust connection management.

## Architecture

### Core Components

1. **OnlineMultiplayerService** - Central service for real-time game coordination
2. **DriverOnline** - Player driver for handling network moves
3. **GameMoveRepository** - Database operations for move tracking
4. **Real-time Models** - Enhanced data models for live gameplay

### Technology Stack

- **Supabase Real-time**: WebSocket-based live data synchronization
- **PostgreSQL**: Persistent game state and move history
- **Flutter Streams**: Reactive UI updates
- **Database Triggers**: Automatic game state updates

## Database Schema

### Enhanced Games Table

```sql
-- Real-time game state fields
ALTER TABLE games ADD COLUMN current_fen TEXT;
ALTER TABLE games ADD COLUMN current_player INTEGER; -- 0=red, 1=black
ALTER TABLE games ADD COLUMN game_status TEXT; -- 'active', 'paused', 'ended'
ALTER TABLE games ADD COLUMN last_move TEXT;
ALTER TABLE games ADD COLUMN last_move_at TIMESTAMP;
ALTER TABLE games ADD COLUMN connection_status JSONB;
```

### Game Moves Table

```sql
CREATE TABLE game_moves (
  id UUID PRIMARY KEY,
  game_id UUID REFERENCES games(id),
  player_id UUID REFERENCES users(id),
  move_number INTEGER NOT NULL,
  move_notation TEXT NOT NULL,
  fen_after_move TEXT NOT NULL,
  time_remaining INTEGER NOT NULL,
  move_time INTEGER NOT NULL,
  is_check BOOLEAN DEFAULT FALSE,
  is_checkmate BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### Automatic State Updates

```sql
-- Trigger to update game state when moves are added
CREATE TRIGGER trigger_update_game_state_on_move
  AFTER INSERT ON game_moves
  FOR EACH ROW
  EXECUTE FUNCTION update_game_state_on_move();
```

## Real-time Synchronization

### Move Broadcasting

```dart
// Player makes a move
await OnlineMultiplayerService.instance.makeMove(
  gameId: gameId,
  playerId: playerId,
  moveNotation: 'e2e4',
  fenAfterMove: newFen,
  timeRemaining: 175,
  moveTime: 5000,
);

// Opponent receives move instantly via WebSocket
OnlineMultiplayerService.instance
  .subscribeToMoves(gameId)
  .listen((move) {
    // Update game board with opponent's move
    gameBoard.applyMove(move.moveNotation);
  });
```

### Game State Synchronization

```dart
// Subscribe to game state changes
OnlineMultiplayerService.instance
  .subscribeToGame(gameId)
  .listen((game) {
    // Update UI based on game state
    if (game.gameStatus == GameStatus.paused) {
      showPausedDialog();
    }
    
    // Update connection indicators
    updateConnectionStatus(game.connectionStatus);
  });
```

## Player Driver Integration

### Online Driver Implementation

The `DriverOnline` class handles network-based player interactions:

```dart
class DriverOnline extends PlayerDriver {
  @override
  Future<PlayerAction?> move() {
    // Wait for opponent's move via real-time subscription
    return _waitForNetworkMove();
  }
  
  @override
  void completeMove(PlayerAction move) {
    // Send local player's move to opponent
    _broadcastMove(move);
  }
}
```

### Seamless Integration

- **Local Player**: Uses `DriverUser` for touch input
- **Remote Player**: Uses `DriverOnline` for network moves
- **AI Player**: Uses `DriverRobot` for computer moves

## Connection Management

### Connection Status Tracking

```dart
enum ConnectionStatus {
  connected,    // Player is online and responsive
  disconnected, // Player has lost connection
  reconnecting, // Player is attempting to reconnect
}

class PlayerConnectionStatus {
  final ConnectionStatus red;
  final ConnectionStatus black;
  
  bool get bothConnected => red == connected && black == connected;
  bool get anyDisconnected => red == disconnected || black == disconnected;
}
```

### Automatic Handling

- **Disconnection Detection**: Monitors WebSocket connection status
- **Game Pausing**: Automatically pauses when player disconnects
- **Reconnection**: Seamlessly resumes when player reconnects
- **Timeout Handling**: Abandons game after extended disconnection

## Game Flow

### Starting an Online Game

1. **Matchmaking**: Players join queue and get matched
2. **Game Creation**: System creates game with both players
3. **Driver Setup**: Each player gets appropriate driver type
4. **Real-time Setup**: Subscribe to game and move streams
5. **Game Start**: First player (red) makes opening move

### During Gameplay

1. **Local Move**: Player makes move via touch input
2. **Move Validation**: Client validates move legality
3. **Database Update**: Move stored in `game_moves` table
4. **Trigger Execution**: Database updates game state
5. **Real-time Broadcast**: Supabase sends move to opponent
6. **Opponent Update**: Opponent's UI updates instantly
7. **Turn Switch**: Game switches to opponent's turn

### Game Ending

1. **End Condition**: Checkmate, resignation, or timeout
2. **State Update**: Game status set to 'ended'
3. **Elo Calculation**: Rating changes calculated
4. **Cleanup**: Real-time subscriptions closed
5. **Results**: Players see final game results

## Error Handling

### Network Errors

```dart
// Automatic retry with exponential backoff
try {
  await makeMove(...);
} catch (e) {
  if (e is NetworkException) {
    await retryWithBackoff(() => makeMove(...));
  }
}
```

### Connection Recovery

```dart
// Handle disconnection
void onDisconnected() {
  updateConnectionStatus(ConnectionStatus.disconnected);
  pauseGame('Player disconnected');
  showReconnectingDialog();
}

// Handle reconnection
void onReconnected() {
  updateConnectionStatus(ConnectionStatus.connected);
  resumeGame();
  hideReconnectingDialog();
}
```

### Data Consistency

- **Move Validation**: Server-side validation prevents invalid moves
- **Sequence Checking**: Move numbers ensure proper ordering
- **State Reconciliation**: Sync game state on reconnection
- **Conflict Resolution**: Handle simultaneous move attempts

## Performance Optimizations

### Efficient Subscriptions

- **Targeted Channels**: Subscribe only to relevant game data
- **Automatic Cleanup**: Unsubscribe when leaving game
- **Connection Pooling**: Reuse WebSocket connections
- **Selective Updates**: Only sync changed fields

### Database Optimizations

```sql
-- Indexes for fast real-time queries
CREATE INDEX game_moves_game_id_idx ON game_moves(game_id);
CREATE INDEX game_moves_created_at_idx ON game_moves(created_at);
CREATE INDEX games_status_idx ON games(game_status);
```

### Memory Management

- **Stream Controllers**: Properly dispose of streams
- **Subscription Cleanup**: Cancel subscriptions on dispose
- **Model Caching**: Cache frequently accessed game data
- **Garbage Collection**: Regular cleanup of old data

## Security Considerations

### Row Level Security (RLS)

```sql
-- Players can only access their own games
CREATE POLICY "Players can read their games" ON games
  FOR SELECT USING (
    red_player_id = auth.uid() OR black_player_id = auth.uid()
  );

-- Players can only add moves to their games
CREATE POLICY "Players can add moves" ON game_moves
  FOR INSERT WITH CHECK (
    player_id = auth.uid() AND
    game_id IN (SELECT id FROM games WHERE 
      red_player_id = auth.uid() OR black_player_id = auth.uid())
  );
```

### Move Validation

- **Server-side Validation**: All moves validated on server
- **Turn Verification**: Ensure player can make move
- **Game State Checks**: Verify game is active
- **Rate Limiting**: Prevent move spam

## Testing

### Unit Tests

```dart
// Test move model functionality
test('should create GameMoveModel with correct properties', () {
  final move = GameMoveModel(...);
  expect(move.moveNotation, equals('e2e4'));
  expect(move.isRedMove, isTrue);
});

// Test connection status handling
test('should detect disconnected players', () {
  final status = PlayerConnectionStatus(red: ConnectionStatus.disconnected);
  expect(status.anyDisconnected, isTrue);
});
```

### Integration Tests

- **Real-time Sync**: Test move broadcasting
- **Connection Handling**: Test disconnect/reconnect
- **Game State**: Test state synchronization
- **Error Recovery**: Test network error handling

## Monitoring and Analytics

### Real-time Metrics

- **Active Games**: Number of ongoing games
- **Move Latency**: Time from move to opponent update
- **Connection Quality**: Disconnect/reconnect rates
- **Error Rates**: Network and validation errors

### Performance Monitoring

```dart
// Track move latency
final startTime = DateTime.now();
await makeMove(...);
final latency = DateTime.now().difference(startTime);
analytics.trackMoveLatency(latency.inMilliseconds);
```

## Future Enhancements

### Planned Features

1. **Spectator Mode**: Allow watching live games
2. **Game Recording**: Save and replay games
3. **Voice Chat**: Real-time voice communication
4. **Tournament Mode**: Multi-player tournaments
5. **Mobile Notifications**: Push notifications for moves

### Technical Improvements

1. **WebRTC**: Direct peer-to-peer connections
2. **Compression**: Optimize data transfer
3. **Caching**: Intelligent client-side caching
4. **Load Balancing**: Distribute real-time load
5. **Regional Servers**: Reduce latency globally

## Configuration

### Environment Variables

```env
SUPABASE_REALTIME_ENABLED=true
MOVE_TIMEOUT_SECONDS=30
RECONNECT_ATTEMPTS=5
HEARTBEAT_INTERVAL_SECONDS=10
```

### Feature Flags

- **Real-time Sync**: Enable/disable live updates
- **Auto Reconnect**: Automatic reconnection attempts
- **Move Validation**: Server-side move checking
- **Connection Monitoring**: Track connection quality

The online multiplayer system provides a robust, scalable foundation for real-time Chinese Chess gameplay with excellent user experience and reliable performance.
