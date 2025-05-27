# Online Multiplayer Usage Guide

## Overview

This guide explains how to integrate and use the online multiplayer system in the Chinese Chess application. The system provides real-time gameplay between players using Supabase real-time subscriptions.

## Quick Start

### 1. Database Setup

First, run the database migration to set up the required tables:

```bash
# Apply the migration to your Supabase database
supabase db push
```

This creates:
- Enhanced `games` table with real-time fields
- `game_moves` table for move tracking
- Database triggers for automatic state updates
- Row-level security policies

### 2. Starting an Online Game

```dart
import 'package:chinese_chess/services/online_game_manager.dart';
import 'package:chinese_chess/models/game_data_model.dart';
import 'package:chinese_chess/models/game_manager.dart';

// Initialize an online game
final gameManager = GameManager.instance;
final gameData = GameDataModel(
  id: 'game-123',
  redPlayerId: 'player-1',
  blackPlayerId: 'player-2',
  // ... other game data
);

await OnlineGameManager.instance.initializeOnlineGame(
  gameData: gameData,
  currentUserId: 'player-1', // Current user's ID
  gameManager: gameManager,
);
```

### 3. Making Moves

The system automatically handles move synchronization:

```dart
// When a player makes a move, it's automatically sent to the opponent
// The DriverOnline class handles this transparently

// For manual move sending (if needed):
await OnlineGameManager.instance.makeMove('e2e4');
```

### 4. Handling Game Events

```dart
// Subscribe to game state changes
OnlineMultiplayerService.instance
  .subscribeToGame(gameId)
  .listen((gameData) {
    // Handle game state updates
    if (gameData.gameStatus == GameStatus.ended) {
      showGameEndDialog(gameData);
    }
  });

// Subscribe to opponent moves
OnlineMultiplayerService.instance
  .subscribeToMoves(gameId)
  .listen((move) {
    // Handle opponent's move
    updateGameBoard(move.moveNotation);
  });
```

## Integration with Existing Game Flow

### Matchmaking to Online Game

```dart
// After successful matchmaking
final matchResult = await MatchmakingService.instance.findMatch(userId);
if (matchResult != null) {
  // Create game from match
  final gameData = await GameRepository.instance.createGameFromMatch(matchResult);
  
  // Initialize online game
  await OnlineGameManager.instance.initializeOnlineGame(
    gameData: gameData,
    currentUserId: userId,
    gameManager: GameManager.instance,
  );
  
  // Navigate to game screen
  Navigator.pushNamed(context, '/online-game');
}
```

### Game Screen Setup

```dart
class OnlineGameScreen extends StatefulWidget {
  final String gameId;
  
  @override
  _OnlineGameScreenState createState() => _OnlineGameScreenState();
}

class _OnlineGameScreenState extends State<OnlineGameScreen> {
  late StreamSubscription<GameDataModel> _gameSubscription;
  late StreamSubscription<GameMoveModel> _moveSubscription;
  
  @override
  void initState() {
    super.initState();
    _setupSubscriptions();
  }
  
  void _setupSubscriptions() {
    // Subscribe to game updates
    _gameSubscription = OnlineMultiplayerService.instance
      .subscribeToGame(widget.gameId)
      .listen(_handleGameUpdate);
    
    // Subscribe to move updates
    _moveSubscription = OnlineMultiplayerService.instance
      .subscribeToMoves(widget.gameId)
      .listen(_handleMoveUpdate);
  }
  
  void _handleGameUpdate(GameDataModel game) {
    setState(() {
      // Update UI based on game state
    });
  }
  
  void _handleMoveUpdate(GameMoveModel move) {
    // Update game board with opponent's move
    GameManager.instance.addMove(PlayerAction(move: move.moveNotation));
  }
  
  @override
  void dispose() {
    _gameSubscription.cancel();
    _moveSubscription.cancel();
    OnlineGameManager.instance.dispose();
    super.dispose();
  }
}
```

## Connection Management

### Handling Disconnections

```dart
// Monitor connection status
OnlineMultiplayerService.instance
  .subscribeToConnectionStatus(gameId)
  .listen((status) {
    if (status.anyDisconnected) {
      showDisconnectionDialog();
    } else if (status.bothConnected) {
      hideDisconnectionDialog();
    }
  });

// Handle network errors
try {
  await OnlineMultiplayerService.instance.makeMove(/* ... */);
} catch (e) {
  if (e is NetworkException) {
    showNetworkErrorDialog();
  }
}
```

### Manual Connection Management

```dart
// Update connection status manually
await OnlineMultiplayerService.instance.updateConnectionStatus(
  gameId,
  userId,
  ConnectionStatus.reconnecting,
);

// Pause game due to connection issues
await OnlineMultiplayerService.instance.pauseGame(
  gameId,
  'Player disconnected',
);

// Resume game when connection restored
await OnlineMultiplayerService.instance.resumeGame(gameId);
```

## Error Handling

### Common Error Scenarios

```dart
// Game not found
try {
  await OnlineGameManager.instance.initializeOnlineGame(/* ... */);
} catch (e) {
  if (e.toString().contains('Game not found')) {
    showErrorDialog('Game no longer exists');
    Navigator.pop(context);
  }
}

// Not player's turn
try {
  await OnlineGameManager.instance.makeMove('e2e4');
} catch (e) {
  if (e.toString().contains('Not your turn')) {
    showErrorDialog('Wait for your turn');
  }
}

// Network timeout
try {
  await OnlineMultiplayerService.instance.makeMove(/* ... */);
} on TimeoutException {
  showErrorDialog('Move failed - please try again');
}
```

## Testing

### Unit Tests

Run the comprehensive test suite:

```bash
flutter test test/services/online_multiplayer_service_test.dart
```

### Integration Testing

```dart
// Test online game flow
testWidgets('should handle online game flow', (tester) async {
  // Set up mock game data
  final gameData = GameDataModel(/* ... */);
  
  // Initialize online game
  await OnlineGameManager.instance.initializeOnlineGame(
    gameData: gameData,
    currentUserId: 'test-user',
    gameManager: GameManager.instance,
  );
  
  // Verify game state
  expect(OnlineGameManager.instance.isInOnlineGame, isTrue);
  
  // Test move making
  await OnlineGameManager.instance.makeMove('e2e4');
  
  // Verify move was processed
  // ... assertions
});
```

## Performance Considerations

### Optimizing Real-time Updates

```dart
// Limit subscription scope
OnlineMultiplayerService.instance
  .subscribeToMoves(gameId)
  .where((move) => move.playerId != currentUserId) // Only opponent moves
  .listen(_handleOpponentMove);

// Batch UI updates
Timer? _updateTimer;
void _scheduleUIUpdate() {
  _updateTimer?.cancel();
  _updateTimer = Timer(Duration(milliseconds: 16), () {
    setState(() {
      // Update UI
    });
  });
}
```

### Memory Management

```dart
// Always dispose of subscriptions
@override
void dispose() {
  OnlineMultiplayerService.instance.cleanupGame(gameId);
  OnlineGameManager.instance.dispose();
  super.dispose();
}
```

## Security Best Practices

### Row-Level Security

The system automatically enforces that:
- Players can only access their own games
- Players can only make moves in games they're part of
- Move validation is performed server-side

### Input Validation

```dart
// Validate moves before sending
bool isValidMove(String moveNotation) {
  return ChessManual.isPosMove(moveNotation) &&
         GameManager.instance.rule.isValidMove(moveNotation);
}

// Only send valid moves
if (isValidMove(moveNotation)) {
  await OnlineGameManager.instance.makeMove(moveNotation);
}
```

## Troubleshooting

### Common Issues

1. **Moves not syncing**: Check network connection and Supabase real-time status
2. **Game state out of sync**: Verify database triggers are working
3. **Connection timeouts**: Implement retry logic with exponential backoff
4. **Memory leaks**: Ensure all subscriptions are properly disposed

### Debug Logging

```dart
// Enable debug logging
Logger.root.level = Level.ALL;
Logger.root.onRecord.listen((record) {
  print('${record.level.name}: ${record.time}: ${record.message}');
});
```

The online multiplayer system provides a robust foundation for real-time Chinese Chess gameplay with automatic synchronization, connection management, and error recovery.
