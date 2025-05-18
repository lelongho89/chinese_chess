# Chinese Chess Technical Documentation

## Architecture Overview

This document outlines the technical architecture and implementation details for the Chinese Chess application in React Native. It provides a comprehensive guide for developers to understand the codebase structure, key components, and technical decisions.

## Project Structure

```
src/
├── assets/                 # Static assets (images, sounds, etc.)
│   ├── images/            # UI images
│   ├── sounds/            # Game sounds
│   └── skins/             # Board and piece skins
├── components/            # Reusable UI components
│   ├── board/             # Chess board components
│   ├── pieces/            # Chess piece components
│   └── ui/                # General UI components
├── screens/               # Screen components
├── navigation/            # Navigation configuration
├── hooks/                 # Custom React hooks
├── utils/                 # Utility functions
├── services/              # Business logic services
│   ├── firebase/          # Firebase integration
│   ├── game/              # Game logic
│   └── audio/             # Audio management
├── store/                 # State management
│   ├── actions/           # Redux actions
│   ├── reducers/          # Redux reducers
│   └── slices/            # Redux Toolkit slices
└── localization/          # Internationalization
```

## Core Technologies

### Frontend Framework
- **React Native**: Cross-platform mobile framework
- **TypeScript**: Type-safe JavaScript
- **React Navigation**: Navigation library for React Native

### State Management
- **Redux**: Centralized state management
- **Redux Toolkit**: Simplified Redux development
- **Redux Persist**: State persistence

### Backend and Services
- **Firebase**: Backend-as-a-Service
  - Authentication
  - Firestore (database)
  - Storage
  - Analytics
  - Cloud Functions (optional)

### UI Components
- **React Native Gesture Handler**: Touch handling
- **React Native Reanimated**: Advanced animations
- **React Native SVG**: Vector graphics
- **React Native Safe Area Context**: Safe area management

### Testing
- **Jest**: Unit testing
- **React Native Testing Library**: Component testing
- **Detox**: End-to-end testing

## Technical Implementation Details

### Game Logic Implementation

#### Board Representation
The game board is represented as a 10×9 grid (rows × columns) using a 2D array. Each cell contains a string representing the piece type or an empty space.

```typescript
// Board representation
private board: string[][];

// Initialize the board
this.board = Array(BOARD_ROWS).fill(null).map(() => Array(BOARD_COLS).fill(PIECE_TYPES.EMPTY));
```

#### FEN Notation
The game state is stored using Forsyth-Edwards Notation (FEN), a standard for describing chess positions:

```typescript
// Example FEN string for the initial position
const INITIAL_FEN = 'rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w';

// Parse FEN string to get piece positions
export const parseFen = (fen: string) => {
  const [boardPart] = fen.split(' ');
  const rows = boardPart.split('/');
  // Implementation details...
};
```

#### Move Validation
Each piece type has specific movement rules implemented as validation functions:

```typescript
// Example: General/King move validation
export const isValidGeneralMove = (
  piece: string,
  fromRow: number,
  fromCol: number,
  toRow: number,
  toCol: number,
  board: string[][]
): boolean => {
  // Implementation details...
};
```

#### Game State Management
The game state is managed through a dedicated service that handles:
- Turn management
- Move execution
- Check/checkmate detection
- Game history

```typescript
class GameService {
  // Game state properties
  private board: Board;
  private gameMode: GameMode;
  private listeners: GameEventListener[];
  
  // Methods for game interaction
  initGame(gameMode: GameMode, fen?: string): void { /* ... */ }
  makeMove(fromRow: number, fromCol: number, toRow: number, toCol: number): boolean { /* ... */ }
  isInCheck(): boolean { /* ... */ }
  isCheckmate(): boolean { /* ... */ }
  // ...
}
```

### State Management Architecture

The application uses Redux for state management with the following structure:

#### Store Configuration
```typescript
// Store setup with Redux Toolkit
export const store = configureStore({
  reducer: rootReducer,
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      serializableCheck: {
        ignoredActions: [FLUSH, REHYDRATE, PAUSE, PERSIST, PURGE, REGISTER],
      },
    }),
});

// Persist configuration
export const persistor = persistStore(store);
```

#### Game State Slice
```typescript
// Game state slice with Redux Toolkit
export const gameSlice = createSlice({
  name: 'game',
  initialState,
  reducers: {
    setGameMode: (state, action: PayloadAction<GameMode>) => {
      state.gameMode = action.payload;
    },
    setPieces: (state, action: PayloadAction<ChessPiece[]>) => {
      state.pieces = action.payload;
    },
    // Other reducers...
  },
  extraReducers: (builder) => {
    // Handle async actions...
  },
});
```

### Firebase Integration

#### Authentication
```typescript
// Firebase authentication service
export class AuthService {
  // Sign in with email and password
  async signInWithEmailAndPassword(email: string, password: string): Promise<User> {
    try {
      const userCredential = await auth().signInWithEmailAndPassword(email, password);
      return userCredential.user;
    } catch (error) {
      throw error;
    }
  }
  
  // Other authentication methods...
}
```

#### Firestore Data Structure
```typescript
// Game data type for Firestore
export type GameData = {
  id?: string;
  players: string[];
  playerData: {
    [userId: string]: {
      color: 'red' | 'black';
      rating: number;
    };
  };
  status: 'active' | 'completed' | 'abandoned';
  winner?: string;
  startPosition: string;
  currentPosition: string;
  moves: {
    from: { row: number; col: number };
    to: { row: number; col: number };
    piece: string;
    capturedPiece?: string;
    timestamp: any;
  }[];
  // Other properties...
};
```

### UI Components

#### Chess Board Component
```typescript
// Chess board component
export const ChessBoard: React.FC<ChessBoardProps> = ({
  onCellPress,
  onPiecePress,
  onMovePress,
}) => {
  // Component implementation...
  return (
    <View style={styles.board}>
      {/* Board grid */}
      {/* Pieces */}
      {/* Highlight for selected piece */}
      {/* Possible move indicators */}
    </View>
  );
};
```

#### Game Screen
```typescript
// Game screen component
const GameScreen: React.FC = () => {
  // State and hooks...
  
  return (
    <SafeAreaView style={styles.container}>
      <GameHeader onSettingsPress={handleSettingsPress} />
      <PlayerInfo
        color="black"
        name="Black Player"
        isCurrentPlayer={currentPlayer === 'black'}
        capturedPieces={[]}
      />
      <GameTimerDisplay />
      <GameStatus />
      <AIThinkingIndicator isThinking={aiThinking} difficulty={aiDifficulty} />
      <ChessBoard
        onCellPress={handleCellPress}
        onPiecePress={handlePiecePress}
        onMovePress={handleMovePress}
      />
      {/* Other UI elements */}
    </SafeAreaView>
  );
};
```

## Performance Considerations

### Rendering Optimization
- Use `React.memo` for pure components
- Implement `useCallback` for event handlers
- Utilize `useMemo` for expensive calculations
- Employ virtualization for long lists

### Animation Performance
- Use native driver for animations when possible
- Implement gesture responders efficiently
- Optimize SVG rendering for piece movements

### Network Optimization
- Implement offline support with local storage
- Use Firebase offline persistence
- Implement debouncing for frequent updates

## Testing Strategy

### Unit Testing
- Test game logic functions in isolation
- Validate move rules for all piece types
- Verify game state transitions

### Component Testing
- Test UI components with React Native Testing Library
- Verify component rendering and interactions
- Mock services and state for predictable tests

### Integration Testing
- Test the interaction between components and services
- Verify game flow from start to finish
- Test online multiplayer functionality

## Deployment Considerations

### App Store Preparation
- Configure proper app icons and splash screens
- Implement app review guidelines compliance
- Set up proper versioning and build numbers

### Google Play Store Preparation
- Configure Android-specific settings
- Implement proper permissions handling
- Set up Play Store listing assets

### CI/CD Pipeline
- Implement automated testing in CI
- Configure build automation
- Set up deployment workflows
