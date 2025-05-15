# Sample React Native Components for Chinese Chess

This document provides sample implementations of key components for the Chinese Chess game in React Native. These are starting points that will need to be expanded and integrated into the full application.

## Project Structure

```
src/
├── components/
│   ├── board/
│   │   ├── Board.js
│   │   ├── ChessBoard.js
│   │   └── index.js
│   ├── pieces/
│   │   ├── Piece.js
│   │   ├── PieceContainer.js
│   │   └── index.js
│   └── ui/
│       ├── GameBottomBar.js
│       ├── GameHeader.js
│       └── index.js
├── screens/
│   ├── GameScreen.js
│   ├── HomeScreen.js
│   ├── SettingsScreen.js
│   └── index.js
└── store/
    ├── actions/
    │   ├── gameActions.js
    │   └── index.js
    ├── reducers/
    │   ├── gameReducer.js
    │   └── index.js
    └── index.js
```

## Sample Components

### 1. Board Component

```javascript
// src/components/board/Board.js
import React from 'react';
import { View, Image, StyleSheet, Dimensions } from 'react-native';
import { useSelector } from 'react-redux';

const Board = () => {
  const { skin } = useSelector(state => state.game);
  
  return (
    <View style={[styles.boardContainer, { width: skin.width, height: skin.height }]}>
      <Image 
        source={skin.boardImage} 
        style={{ width: skin.width, height: skin.height }}
        resizeMode="contain"
      />
    </View>
  );
};

const styles = StyleSheet.create({
  boardContainer: {
    alignItems: 'center',
    justifyContent: 'center',
  },
});

export default Board;
```

### 2. Chess Piece Component

```javascript
// src/components/pieces/Piece.js
import React from 'react';
import { View, Image, StyleSheet } from 'react-native';
import { useSelector } from 'react-redux';

const Piece = ({ item, isActive = false, isAblePoint = false }) => {
  const { skin, scale } = useSelector(state => state.game);
  
  return (
    <View style={[
      styles.pieceContainer, 
      { width: skin.size, height: skin.size },
      isActive && styles.activePiece
    ]}>
      <Image 
        source={skin.getPieceImage(item.type)} 
        style={{ 
          width: skin.size * scale, 
          height: skin.size * scale 
        }}
        resizeMode="contain"
      />
    </View>
  );
};

const styles = StyleSheet.create({
  pieceContainer: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  activePiece: {
    // Add styling for active piece
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.8,
    shadowRadius: 2,
    elevation: 5,
  }
});

export default Piece;
```

### 3. Chess Board Component (with Pieces)

```javascript
// src/components/board/ChessBoard.js
import React, { useState, useEffect } from 'react';
import { View, StyleSheet, TouchableWithoutFeedback } from 'react-native';
import { useSelector, useDispatch } from 'react-redux';
import Board from './Board';
import Piece from '../pieces/Piece';
import PointMarker from '../pieces/PointMarker';
import { movePiece, selectPiece, highlightMoves } from '../../store/actions/gameActions';

const ChessBoard = () => {
  const dispatch = useDispatch();
  const { 
    pieces, 
    selectedPiece, 
    possibleMoves,
    skin,
    isLocked
  } = useSelector(state => state.game);
  
  const handleBoardPress = (event) => {
    if (isLocked) return;
    
    // Calculate board coordinates from touch position
    const { locationX, locationY } = event.nativeEvent;
    const position = calculateBoardPosition(locationX, locationY, skin);
    
    if (selectedPiece) {
      // If a piece is already selected, try to move it
      if (possibleMoves.some(move => move.position === position)) {
        dispatch(movePiece(selectedPiece, position));
      } else {
        // If clicked on another piece of same color, select it instead
        const pieceAtPosition = pieces.find(p => p.position === position);
        if (pieceAtPosition && pieceAtPosition.color === selectedPiece.color) {
          dispatch(selectPiece(pieceAtPosition));
          dispatch(highlightMoves(pieceAtPosition));
        } else {
          // Deselect if clicked elsewhere
          dispatch(selectPiece(null));
        }
      }
    } else {
      // If no piece is selected, try to select one
      const pieceAtPosition = pieces.find(p => p.position === position);
      if (pieceAtPosition && pieceAtPosition.color === currentPlayer) {
        dispatch(selectPiece(pieceAtPosition));
        dispatch(highlightMoves(pieceAtPosition));
      }
    }
  };
  
  // Helper function to calculate board position from screen coordinates
  const calculateBoardPosition = (x, y, skin) => {
    // Implementation depends on board layout and coordinates system
    // This is a placeholder
    const col = Math.floor(x / (skin.width / 9));
    const row = Math.floor(y / (skin.height / 10));
    return { row, col };
  };
  
  return (
    <TouchableWithoutFeedback onPress={handleBoardPress}>
      <View style={styles.container}>
        <Board />
        
        {/* Render possible move markers */}
        {possibleMoves.map((move, index) => (
          <View 
            key={`move-${index}`}
            style={[
              styles.absolutePosition,
              getPositionStyle(move.position, skin)
            ]}
          >
            <PointMarker size={skin.size * 0.5} />
          </View>
        ))}
        
        {/* Render all pieces */}
        {pieces.map((piece, index) => (
          <View 
            key={`piece-${piece.id}`}
            style={[
              styles.absolutePosition,
              getPositionStyle(piece.position, skin)
            ]}
          >
            <Piece 
              item={piece} 
              isActive={selectedPiece && selectedPiece.id === piece.id}
            />
          </View>
        ))}
      </View>
    </TouchableWithoutFeedback>
  );
};

// Helper function to convert board position to style position
const getPositionStyle = (position, skin) => {
  // Implementation depends on board layout
  // This is a placeholder
  const left = (position.col * (skin.width / 9));
  const top = (position.row * (skin.height / 10));
  
  return {
    left,
    top,
  };
};

const styles = StyleSheet.create({
  container: {
    position: 'relative',
  },
  absolutePosition: {
    position: 'absolute',
  },
});

export default ChessBoard;
```

### 4. Game Screen

```javascript
// src/screens/GameScreen.js
import React, { useEffect } from 'react';
import { View, StyleSheet, SafeAreaView } from 'react-native';
import { useSelector, useDispatch } from 'react-redux';
import ChessBoard from '../components/board/ChessBoard';
import GameHeader from '../components/ui/GameHeader';
import GameBottomBar from '../components/ui/GameBottomBar';
import { initGame } from '../store/actions/gameActions';

const GameScreen = ({ route }) => {
  const dispatch = useDispatch();
  const { gameMode } = route.params || { gameMode: 'ai' };
  const { isGameActive } = useSelector(state => state.game);
  
  useEffect(() => {
    // Initialize the game when the screen mounts
    dispatch(initGame(gameMode));
  }, [dispatch, gameMode]);
  
  return (
    <SafeAreaView style={styles.container}>
      <GameHeader />
      
      <View style={styles.boardContainer}>
        <ChessBoard />
      </View>
      
      <GameBottomBar mode={gameMode} />
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  boardContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
});

export default GameScreen;
```

### 5. Redux Store Setup

```javascript
// src/store/index.js
import { configureStore } from '@reduxjs/toolkit';
import rootReducer from './reducers';

const store = configureStore({
  reducer: rootReducer,
});

export default store;
```

```javascript
// src/store/reducers/index.js
import { combineReducers } from 'redux';
import gameReducer from './gameReducer';
import settingsReducer from './settingsReducer';
import authReducer from './authReducer';

const rootReducer = combineReducers({
  game: gameReducer,
  settings: settingsReducer,
  auth: authReducer,
});

export default rootReducer;
```

```javascript
// src/store/reducers/gameReducer.js
import { createSlice } from '@reduxjs/toolkit';
import { loadSkin } from '../../utils/skinLoader';

const initialState = {
  pieces: [],
  selectedPiece: null,
  possibleMoves: [],
  gameMode: null,
  isGameActive: false,
  isLocked: false,
  currentPlayer: 'red', // 'red' or 'black'
  skin: loadSkin('woods'), // Default skin
  scale: 1,
  history: [],
  fenString: 'rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w', // Default starting position
};

const gameSlice = createSlice({
  name: 'game',
  initialState,
  reducers: {
    setGameMode: (state, action) => {
      state.gameMode = action.payload;
    },
    setPieces: (state, action) => {
      state.pieces = action.payload;
    },
    setSelectedPiece: (state, action) => {
      state.selectedPiece = action.payload;
    },
    setPossibleMoves: (state, action) => {
      state.possibleMoves = action.payload;
    },
    setCurrentPlayer: (state, action) => {
      state.currentPlayer = action.payload;
    },
    setSkin: (state, action) => {
      state.skin = loadSkin(action.payload);
    },
    setScale: (state, action) => {
      state.scale = action.payload;
    },
    setLocked: (state, action) => {
      state.isLocked = action.payload;
    },
    setFenString: (state, action) => {
      state.fenString = action.payload;
    },
    addToHistory: (state, action) => {
      state.history.push(action.payload);
    },
    resetGame: (state) => {
      state.pieces = [];
      state.selectedPiece = null;
      state.possibleMoves = [];
      state.isGameActive = false;
      state.currentPlayer = 'red';
      state.history = [];
      state.fenString = 'rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w';
    },
  },
});

export const {
  setGameMode,
  setPieces,
  setSelectedPiece,
  setPossibleMoves,
  setCurrentPlayer,
  setSkin,
  setScale,
  setLocked,
  setFenString,
  addToHistory,
  resetGame,
} = gameSlice.actions;

export default gameSlice.reducer;
```

## Next Steps

These sample components provide a starting point for the React Native implementation. To complete the migration, you'll need to:

1. Implement the game logic service
2. Create the Firebase integration
3. Set up the navigation system
4. Implement the localization system
5. Create the timer functionality
6. Add the skin switching capability
7. Implement the AI opponent

Each of these components will need to be expanded and integrated into the full application according to the migration plan.
