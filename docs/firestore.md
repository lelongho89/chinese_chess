# Chinese Chess Firestore Integration

## Overview

The Chinese Chess game uses Firebase Firestore for storing and synchronizing game data. This document describes the Firestore data model, security rules, and integration with the Flutter app.

## Data Model

The Firestore database is organized into the following collections:

### Users Collection

Stores user profile data and game statistics.

```
users/{userId}
  - email: string
  - displayName: string
  - eloRating: number (default: 1200)
  - gamesPlayed: number
  - gamesWon: number
  - gamesLost: number
  - gamesDraw: number
  - createdAt: timestamp
  - lastLoginAt: timestamp
  - friendIds: array<string>
```

### Games Collection

Stores game data including moves, time remaining, and results.

```
games/{gameId}
  - redPlayerId: string
  - blackPlayerId: string
  - winnerId: string (optional)
  - isDraw: boolean
  - moveCount: number
  - moves: array<string>
  - finalFen: string
  - redTimeRemaining: number (in seconds)
  - blackTimeRemaining: number (in seconds)
  - startedAt: timestamp
  - endedAt: timestamp (optional)
  - isRanked: boolean
  - tournamentId: number (optional)
  - metadata: map (optional)
```

### Tournaments Collection

Stores tournament data including participants, brackets, and results.

```
tournaments/{tournamentId}
  - name: string
  - description: string
  - creatorId: string
  - participantIds: array<string>
  - maxParticipants: number
  - status: number (0: upcoming, 1: inProgress, 2: completed, 3: cancelled)
  - type: number (0: singleElimination, 1: doubleElimination, 2: roundRobin, 3: swiss)
  - startTime: timestamp
  - endTime: timestamp (optional)
  - brackets: map<string, array<string>> (round -> list of match IDs)
  - settings: map (optional)
  - metadata: map (optional)
```

### Matches Collection

Stores match data for tournaments.

```
matches/{matchId}
  - tournamentId: string (optional)
  - redPlayerId: string
  - blackPlayerId: string
  - winnerId: string (optional)
  - isDraw: boolean
  - status: number (0: scheduled, 1: inProgress, 2: completed, 3: cancelled)
  - scheduledTime: timestamp
  - startTime: timestamp (optional)
  - endTime: timestamp (optional)
  - gameId: string (optional)
  - round: number
  - matchNumber: number
  - metadata: map (optional)
```

### Leaderboard Collection

Stores leaderboard data for ranking players.

```
leaderboard/{userId}
  - userId: string
  - displayName: string
  - eloRating: number
  - rank: number
  - gamesPlayed: number
  - gamesWon: number
  - gamesLost: number
  - gamesDraw: number
  - winRate: number
  - lastUpdated: timestamp
  - metadata: map (optional)
```

## Security Rules

Firestore security rules are defined in `firestore.rules` and enforce the following access controls:

1. **Users Collection**:
   - Users can read and update their own data
   - Admins can read and update all user data
   - Only admins can delete user data

2. **Games Collection**:
   - Anyone can read game data
   - Only authenticated users can create games
   - Only players in the game or admins can update game data
   - Only admins can delete games

3. **Tournaments Collection**:
   - Anyone can read tournament data
   - Only authenticated users can create tournaments
   - Only tournament creator or admins can update tournament data
   - Only admins can delete tournaments

4. **Matches Collection**:
   - Anyone can read match data
   - Only authenticated users can create matches
   - Only players in the match or admins can update match data
   - Only admins can delete matches

5. **Leaderboard Collection**:
   - Anyone can read leaderboard data
   - Only the system or admins can write leaderboard data

## Offline Support

Firestore is configured for offline persistence with unlimited cache size, allowing the app to function without an internet connection. When the device comes back online, Firestore automatically synchronizes any changes.

## Data Models

The app uses the following data models to interact with Firestore:

1. **UserModel**: Represents a user profile
2. **GameDataModel**: Represents a game
3. **TournamentModel**: Represents a tournament
4. **MatchModel**: Represents a match
5. **LeaderboardEntryModel**: Represents a leaderboard entry

## Repositories

The app uses repository classes to abstract Firestore operations:

1. **UserRepository**: Handles user data operations
2. **GameRepository**: Handles game data operations
3. **TournamentRepository**: Handles tournament data operations
4. **MatchRepository**: Handles match data operations
5. **LeaderboardRepository**: Handles leaderboard data operations

## Services

The app uses service classes to handle higher-level operations:

1. **EloService**: Handles Elo rating calculations
2. **GameService**: Handles game operations
3. **TournamentService**: Handles tournament operations

## Implementation Details

### Initialization

Firestore is initialized in the `main.dart` file with offline persistence enabled:

```dart
await Firebase.initializeApp();

// Configure Firestore for offline persistence
await FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

### Data Access

Data is accessed through repository classes that provide methods for CRUD operations:

```dart
// Example: Get a user
final user = await UserRepository.instance.get(userId);

// Example: Create a game
final gameId = await GameRepository.instance.createGame(redPlayerId, blackPlayerId);

// Example: Update a tournament
await TournamentRepository.instance.update(tournamentId, {'status': TournamentStatus.inProgress.index});
```

### Real-time Updates

Firestore streams are used for real-time updates:

```dart
// Example: Listen to a game
final gameStream = GameRepository.instance.listenToActiveGame(gameId);

// Example: Listen to leaderboard changes
final leaderboardStream = LeaderboardRepository.instance.listenToTopPlayers();
```

## Indexes

Firestore indexes are required for complex queries. The following indexes should be created:

1. **Games Collection**:
   - Composite index on `redPlayerId` and `startedAt` (descending)
   - Composite index on `blackPlayerId` and `startedAt` (descending)
   - Composite index on `tournamentId` and `startedAt` (descending)

2. **Tournaments Collection**:
   - Composite index on `status` and `startTime`

3. **Matches Collection**:
   - Composite index on `tournamentId`, `round`, and `matchNumber`
   - Composite index on `redPlayerId` and `scheduledTime` (descending)
   - Composite index on `blackPlayerId` and `scheduledTime` (descending)

## Error Handling

All Firestore operations are wrapped in try-catch blocks to handle errors gracefully. Errors are logged using the app's logging system.
