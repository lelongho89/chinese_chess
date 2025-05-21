# Chinese Chess Supabase Integration

## Overview

The Chinese Chess game uses Supabase for storing and synchronizing game data. This document describes the Supabase data model, security rules, and integration with the Flutter app.

## Data Model

The Supabase database is organized into the following tables:

### Users Table

Stores user profile data and game statistics.

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  email TEXT NOT NULL,
  display_name TEXT,
  elo_rating INTEGER DEFAULT 1200,
  games_played INTEGER DEFAULT 0,
  games_won INTEGER DEFAULT 0,
  games_lost INTEGER DEFAULT 0,
  games_draw INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_login_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Games Table

Stores game data.

```sql
CREATE TABLE games (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  red_player_id UUID REFERENCES users(id),
  black_player_id UUID REFERENCES users(id),
  winner_id UUID REFERENCES users(id),
  is_draw BOOLEAN DEFAULT FALSE,
  move_count INTEGER DEFAULT 0,
  moves JSONB DEFAULT '[]'::JSONB,
  final_fen TEXT,
  red_time_remaining INTEGER,
  black_time_remaining INTEGER,
  started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  ended_at TIMESTAMP WITH TIME ZONE,
  is_ranked BOOLEAN DEFAULT TRUE,
  tournament_id UUID REFERENCES tournaments(id),
  metadata JSONB
);
```

### Tournaments Table

Stores tournament data.

```sql
CREATE TABLE tournaments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  creator_id UUID REFERENCES users(id),
  participant_ids UUID[] DEFAULT '{}'::UUID[],
  max_participants INTEGER DEFAULT 8,
  status INTEGER DEFAULT 0,
  type INTEGER DEFAULT 0,
  start_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  end_time TIMESTAMP WITH TIME ZONE,
  brackets JSONB DEFAULT '{}'::JSONB,
  settings JSONB,
  metadata JSONB
);
```

### Matches Table

Stores tournament matches.

```sql
CREATE TABLE matches (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tournament_id UUID REFERENCES tournaments(id),
  red_player_id UUID REFERENCES users(id),
  black_player_id UUID REFERENCES users(id),
  winner_id UUID REFERENCES users(id),
  is_draw BOOLEAN DEFAULT FALSE,
  status INTEGER DEFAULT 0,
  scheduled_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  start_time TIMESTAMP WITH TIME ZONE,
  end_time TIMESTAMP WITH TIME ZONE,
  game_id UUID REFERENCES games(id),
  round INTEGER DEFAULT 0,
  match_number INTEGER DEFAULT 0,
  metadata JSONB
);
```

### Leaderboard Table

Stores leaderboard entries.

```sql
CREATE TABLE leaderboard (
  id UUID PRIMARY KEY REFERENCES users(id),
  user_id UUID REFERENCES users(id),
  display_name TEXT,
  elo_rating INTEGER DEFAULT 1200,
  rank INTEGER DEFAULT 0,
  games_played INTEGER DEFAULT 0,
  games_won INTEGER DEFAULT 0,
  games_lost INTEGER DEFAULT 0,
  games_draw INTEGER DEFAULT 0,
  win_rate REAL DEFAULT 0,
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  metadata JSONB
);
```

## Row Level Security (RLS)

Supabase uses Row Level Security (RLS) to control access to data. The following policies are implemented:

### Users Table

```sql
-- Allow users to read their own data
CREATE POLICY "Users can read their own data" ON users
  FOR SELECT USING (auth.uid() = id);

-- Allow users to update their own data
CREATE POLICY "Users can update their own data" ON users
  FOR UPDATE USING (auth.uid() = id);
```

### Games Table

```sql
-- Allow players to read their own games
CREATE POLICY "Players can read their own games" ON games
  FOR SELECT USING (auth.uid() = red_player_id OR auth.uid() = black_player_id);

-- Allow players to update their own games
CREATE POLICY "Players can update their own games" ON games
  FOR UPDATE USING (auth.uid() = red_player_id OR auth.uid() = black_player_id);
```

## Data Models

The app uses the following data models to interact with Supabase:

1. **UserModel**: Represents a user profile
2. **GameDataModel**: Represents a game
3. **TournamentModel**: Represents a tournament
4. **MatchModel**: Represents a match
5. **LeaderboardEntryModel**: Represents a leaderboard entry

## Repositories

The app uses repository classes to abstract Supabase operations:

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

Supabase is initialized in the `main.dart` file:

```dart
// Initialize Supabase
await SupabaseClient.initialize();
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

Supabase streams are used for real-time updates:

```dart
// Example: Listen to a game
final gameStream = GameRepository.instance.listenToActiveGame(gameId);

// Example: Listen to leaderboard changes
final leaderboardStream = LeaderboardRepository.instance.listenToTopPlayers();
```
