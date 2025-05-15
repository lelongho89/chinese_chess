# Chinese Chess Game Logic Implementation in React Native

This document outlines how to implement the core game logic for Chinese Chess (Xiangqi) in React Native.

## Overview

The game logic implementation will be structured as a set of services and utilities that handle:

1. Board representation
2. Move validation
3. Game state management
4. FEN notation parsing and generation
5. AI opponent logic

## Board Representation

### Piece Types

```javascript
// src/constants/pieceTypes.js
export const PIECE_TYPES = {
  RED_GENERAL: 'K',
  RED_ADVISOR: 'A',
  RED_ELEPHANT: 'B',
  RED_HORSE: 'N',
  RED_CHARIOT: 'R',
  RED_CANNON: 'C',
  RED_PAWN: 'P',
  BLACK_GENERAL: 'k',
  BLACK_ADVISOR: 'a',
  BLACK_ELEPHANT: 'b',
  BLACK_HORSE: 'n',
  BLACK_CHARIOT: 'r',
  BLACK_CANNON: 'c',
  BLACK_PAWN: 'p',
  EMPTY: '0',
};

export const getPieceColor = (pieceType) => {
  if (!pieceType || pieceType === PIECE_TYPES.EMPTY) return null;
  return pieceType.toUpperCase() === pieceType ? 'red' : 'black';
};
```

### Board Class

```javascript
// src/services/game/Board.js
import { PIECE_TYPES, getPieceColor } from '../../constants/pieceTypes';

class Board {
  constructor(fen = 'rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w') {
    this.board = Array(10).fill().map(() => Array(9).fill(PIECE_TYPES.EMPTY));
    this.currentPlayer = 'red';
    this.loadFromFen(fen);
  }

  loadFromFen(fen) {
    const [boardPart, playerPart] = fen.split(' ');
    const rows = boardPart.split('/');
    
    // Parse board position
    for (let row = 0; row < 10; row++) {
      let col = 0;
      for (let i = 0; i < rows[row].length; i++) {
        const char = rows[row][i];
        if (/[0-9]/.test(char)) {
          // If it's a number, add that many empty spaces
          col += parseInt(char, 10);
        } else {
          // Otherwise, it's a piece
          this.board[row][col] = char;
          col++;
        }
      }
    }
    
    // Parse current player
    this.currentPlayer = playerPart === 'b' ? 'black' : 'red';
  }

  toFen() {
    let fen = '';
    
    // Convert board to FEN notation
    for (let row = 0; row < 10; row++) {
      let emptyCount = 0;
      
      for (let col = 0; col < 9; col++) {
        const piece = this.board[row][col];
        
        if (piece === PIECE_TYPES.EMPTY) {
          emptyCount++;
        } else {
          if (emptyCount > 0) {
            fen += emptyCount;
            emptyCount = 0;
          }
          fen += piece;
        }
      }
      
      if (emptyCount > 0) {
        fen += emptyCount;
      }
      
      if (row < 9) {
        fen += '/';
      }
    }
    
    // Add current player
    fen += ` ${this.currentPlayer === 'black' ? 'b' : 'w'}`;
    
    return fen;
  }

  getPieceAt(row, col) {
    if (row < 0 || row >= 10 || col < 0 || col >= 9) {
      return null;
    }
    return this.board[row][col];
  }

  movePiece(fromRow, fromCol, toRow, toCol) {
    const piece = this.board[fromRow][fromCol];
    
    // Make the move
    this.board[toRow][toCol] = piece;
    this.board[fromRow][fromCol] = PIECE_TYPES.EMPTY;
    
    // Switch player
    this.currentPlayer = this.currentPlayer === 'red' ? 'black' : 'red';
    
    return true;
  }

  isValidMove(fromRow, fromCol, toRow, toCol) {
    const piece = this.board[fromRow][fromCol];
    
    // Check if there's a piece at the starting position
    if (piece === PIECE_TYPES.EMPTY) {
      return false;
    }
    
    // Check if it's the current player's piece
    const pieceColor = getPieceColor(piece);
    if (pieceColor !== this.currentPlayer) {
      return false;
    }
    
    // Check if the destination has a piece of the same color
    const destPiece = this.board[toRow][toCol];
    if (destPiece !== PIECE_TYPES.EMPTY && getPieceColor(destPiece) === pieceColor) {
      return false;
    }
    
    // Delegate to piece-specific move validation
    return this.isValidPieceMove(piece, fromRow, fromCol, toRow, toCol);
  }

  isValidPieceMove(piece, fromRow, fromCol, toRow, toCol) {
    const pieceType = piece.toUpperCase();
    
    switch (pieceType) {
      case PIECE_TYPES.RED_GENERAL:
        return this.isValidGeneralMove(piece, fromRow, fromCol, toRow, toCol);
      case PIECE_TYPES.RED_ADVISOR:
        return this.isValidAdvisorMove(piece, fromRow, fromCol, toRow, toCol);
      case PIECE_TYPES.RED_ELEPHANT:
        return this.isValidElephantMove(piece, fromRow, fromCol, toRow, toCol);
      case PIECE_TYPES.RED_HORSE:
        return this.isValidHorseMove(piece, fromRow, fromCol, toRow, toCol);
      case PIECE_TYPES.RED_CHARIOT:
        return this.isValidChariotMove(piece, fromRow, fromCol, toRow, toCol);
      case PIECE_TYPES.RED_CANNON:
        return this.isValidCannonMove(piece, fromRow, fromCol, toRow, toCol);
      case PIECE_TYPES.RED_PAWN:
        return this.isValidPawnMove(piece, fromRow, fromCol, toRow, toCol);
      default:
        return false;
    }
  }

  // Implement piece-specific move validation methods
  isValidGeneralMove(piece, fromRow, fromCol, toRow, toCol) {
    const isRed = piece === PIECE_TYPES.RED_GENERAL;
    
    // Check if the move is within the palace
    if (isRed) {
      if (toRow < 7 || toRow > 9 || toCol < 3 || toCol > 5) {
        return false;
      }
    } else {
      if (toRow < 0 || toRow > 2 || toCol < 3 || toCol > 5) {
        return false;
      }
    }
    
    // Check if the move is orthogonal and one step
    const rowDiff = Math.abs(toRow - fromRow);
    const colDiff = Math.abs(toCol - fromCol);
    
    if ((rowDiff === 1 && colDiff === 0) || (rowDiff === 0 && colDiff === 1)) {
      return true;
    }
    
    // Check for flying general
    if (colDiff === 0 && rowDiff > 1) {
      // Check if there are pieces between the two generals
      let startRow = Math.min(fromRow, toRow) + 1;
      let endRow = Math.max(fromRow, toRow);
      
      for (let row = startRow; row < endRow; row++) {
        if (this.board[row][fromCol] !== PIECE_TYPES.EMPTY) {
          return false;
        }
      }
      
      // Check if the destination has the opponent's general
      const destPiece = this.board[toRow][toCol];
      return (isRed && destPiece === PIECE_TYPES.BLACK_GENERAL) || 
             (!isRed && destPiece === PIECE_TYPES.RED_GENERAL);
    }
    
    return false;
  }

  // Implement other piece-specific move validation methods...
  
  getValidMoves(row, col) {
    const piece = this.board[row][col];
    if (piece === PIECE_TYPES.EMPTY) {
      return [];
    }
    
    const validMoves = [];
    
    // Check all possible destinations
    for (let toRow = 0; toRow < 10; toRow++) {
      for (let toCol = 0; toCol < 9; toCol++) {
        if (this.isValidMove(row, col, toRow, toCol)) {
          validMoves.push({ row: toRow, col: toCol });
        }
      }
    }
    
    return validMoves;
  }
  
  isInCheck(player) {
    // Find the player's general
    const generalType = player === 'red' ? PIECE_TYPES.RED_GENERAL : PIECE_TYPES.BLACK_GENERAL;
    let generalRow = -1;
    let generalCol = -1;
    
    for (let row = 0; row < 10; row++) {
      for (let col = 0; col < 9; col++) {
        if (this.board[row][col] === generalType) {
          generalRow = row;
          generalCol = col;
          break;
        }
      }
      if (generalRow !== -1) break;
    }
    
    // Check if any opponent's piece can capture the general
    const opponentColor = player === 'red' ? 'black' : 'red';
    
    for (let row = 0; row < 10; row++) {
      for (let col = 0; col < 9; col++) {
        const piece = this.board[row][col];
        if (piece !== PIECE_TYPES.EMPTY && getPieceColor(piece) === opponentColor) {
          if (this.isValidMove(row, col, generalRow, generalCol)) {
            return true;
          }
        }
      }
    }
    
    return false;
  }
  
  isCheckmate(player) {
    if (!this.isInCheck(player)) {
      return false;
    }
    
    // Try all possible moves for all player's pieces
    for (let row = 0; row < 10; row++) {
      for (let col = 0; col < 9; col++) {
        const piece = this.board[row][col];
        if (piece !== PIECE_TYPES.EMPTY && getPieceColor(piece) === player) {
          const validMoves = this.getValidMoves(row, col);
          
          // For each valid move, check if it gets out of check
          for (const move of validMoves) {
            // Make a temporary move
            const originalDest = this.board[move.row][move.col];
            this.board[move.row][move.col] = piece;
            this.board[row][col] = PIECE_TYPES.EMPTY;
            
            // Check if still in check
            const stillInCheck = this.isInCheck(player);
            
            // Undo the move
            this.board[row][col] = piece;
            this.board[move.row][move.col] = originalDest;
            
            if (!stillInCheck) {
              return false; // Found a move that gets out of check
            }
          }
        }
      }
    }
    
    return true; // No move gets out of check
  }
}

export default Board;
```

## Game Service

```javascript
// src/services/game/GameService.js
import Board from './Board';
import { getPieceColor } from '../../constants/pieceTypes';

class GameService {
  constructor() {
    this.board = new Board();
    this.history = [];
    this.gameMode = null;
    this.isGameActive = false;
    this.listeners = [];
  }

  initGame(gameMode, fen = null) {
    this.gameMode = gameMode;
    this.board = new Board(fen || 'rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w');
    this.history = [];
    this.isGameActive = true;
    
    this.notifyListeners('gameInit', {
      gameMode,
      board: this.getBoardState(),
      currentPlayer: this.board.currentPlayer,
    });
  }

  getBoardState() {
    const pieces = [];
    
    for (let row = 0; row < 10; row++) {
      for (let col = 0; col < 9; col++) {
        const pieceType = this.board.getPieceAt(row, col);
        if (pieceType !== '0') {
          pieces.push({
            id: `${pieceType}-${row}-${col}`,
            type: pieceType,
            color: getPieceColor(pieceType),
            position: { row, col },
          });
        }
      }
    }
    
    return pieces;
  }

  getValidMoves(row, col) {
    return this.board.getValidMoves(row, col);
  }

  makeMove(fromRow, fromCol, toRow, toCol) {
    if (!this.isGameActive) {
      return false;
    }
    
    if (!this.board.isValidMove(fromRow, fromCol, toRow, toCol)) {
      return false;
    }
    
    // Record the move in history
    const piece = this.board.getPieceAt(fromRow, fromCol);
    const capturedPiece = this.board.getPieceAt(toRow, toCol);
    
    this.history.push({
      piece,
      from: { row: fromRow, col: fromCol },
      to: { row: toRow, col: toCol },
      capturedPiece,
    });
    
    // Make the move
    this.board.movePiece(fromRow, fromCol, toRow, toCol);
    
    // Check for game end conditions
    const previousPlayer = this.board.currentPlayer === 'red' ? 'black' : 'red';
    const isCheck = this.board.isInCheck(this.board.currentPlayer);
    const isCheckmate = isCheck && this.board.isCheckmate(this.board.currentPlayer);
    
    // Notify listeners
    this.notifyListeners('moveMade', {
      board: this.getBoardState(),
      currentPlayer: this.board.currentPlayer,
      isCheck,
      isCheckmate,
      lastMove: this.history[this.history.length - 1],
    });
    
    if (isCheckmate) {
      this.endGame(previousPlayer);
    } else if (this.gameMode === 'ai' && this.board.currentPlayer === 'black') {
      // If playing against AI and it's AI's turn, make AI move
      setTimeout(() => this.makeAIMove(), 500);
    }
    
    return true;
  }

  makeAIMove() {
    // Implement AI move logic
    // For now, just make a random valid move
    const pieces = this.getBoardState().filter(p => p.color === 'black');
    
    if (pieces.length === 0) return;
    
    // Try to find a valid move
    for (const piece of pieces) {
      const { row, col } = piece.position;
      const validMoves = this.getValidMoves(row, col);
      
      if (validMoves.length > 0) {
        const randomMove = validMoves[Math.floor(Math.random() * validMoves.length)];
        this.makeMove(row, col, randomMove.row, randomMove.col);
        return;
      }
    }
  }

  endGame(winner) {
    this.isGameActive = false;
    
    this.notifyListeners('gameEnd', {
      winner,
      history: this.history,
    });
  }

  getFen() {
    return this.board.toFen();
  }

  loadFromFen(fen) {
    this.board.loadFromFen(fen);
    this.history = [];
    
    this.notifyListeners('boardUpdated', {
      board: this.getBoardState(),
      currentPlayer: this.board.currentPlayer,
    });
  }

  addListener(listener) {
    this.listeners.push(listener);
    return () => {
      this.listeners = this.listeners.filter(l => l !== listener);
    };
  }

  notifyListeners(event, data) {
    this.listeners.forEach(listener => {
      if (typeof listener === 'function') {
        listener(event, data);
      }
    });
  }
}

export default new GameService();
```

## Integration with Redux

```javascript
// src/store/actions/gameActions.js
import gameService from '../../services/game/GameService';

export const initGame = (gameMode, fen = null) => (dispatch) => {
  gameService.initGame(gameMode, fen);
  
  // Set up listener for game events
  gameService.addListener((event, data) => {
    switch (event) {
      case 'gameInit':
        dispatch(setGameMode(data.gameMode));
        dispatch(setPieces(data.board));
        dispatch(setCurrentPlayer(data.currentPlayer));
        break;
      case 'moveMade':
        dispatch(setPieces(data.board));
        dispatch(setCurrentPlayer(data.currentPlayer));
        if (data.lastMove) {
          dispatch(addToHistory(data.lastMove));
        }
        break;
      case 'gameEnd':
        dispatch(setGameOver(data.winner));
        break;
      case 'boardUpdated':
        dispatch(setPieces(data.board));
        dispatch(setCurrentPlayer(data.currentPlayer));
        break;
      default:
        break;
    }
  });
};

export const selectPiece = (piece) => ({
  type: 'game/setSelectedPiece',
  payload: piece,
});

export const highlightMoves = (piece) => (dispatch) => {
  if (!piece) {
    dispatch(setPossibleMoves([]));
    return;
  }
  
  const { row, col } = piece.position;
  const validMoves = gameService.getValidMoves(row, col);
  
  dispatch(setPossibleMoves(validMoves));
};

export const movePiece = (piece, toPosition) => (dispatch) => {
  const { row: fromRow, col: fromCol } = piece.position;
  const { row: toRow, col: toCol } = toPosition;
  
  const success = gameService.makeMove(fromRow, fromCol, toRow, toCol);
  
  if (success) {
    dispatch(selectPiece(null));
    dispatch(setPossibleMoves([]));
  }
};

// Other action creators...
```

## Conclusion

This implementation provides a solid foundation for the Chinese Chess game logic in React Native. The `Board` class handles the core game rules and state, while the `GameService` provides a higher-level API for the application to interact with. The Redux integration ensures that the UI stays in sync with the game state.

To complete the implementation, you would need to:

1. Implement the remaining piece-specific move validation methods
2. Enhance the AI opponent with more sophisticated algorithms
3. Add support for game history navigation
4. Implement network play functionality
5. Add sound effects and animations

The modular design allows for easy extension and maintenance as the application grows.
