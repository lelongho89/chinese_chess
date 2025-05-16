import { createSlice, PayloadAction } from '@reduxjs/toolkit';

/**
 * Game state types
 */
export type GameMode = 'ai' | 'online' | 'free';

export type ChessPiece = {
  id: string;
  type: string;
  position: { row: number; col: number };
  color: 'red' | 'black';
};

export type GameState = {
  gameMode: GameMode | null;
  pieces: ChessPiece[];
  selectedPiece: ChessPiece | null;
  possibleMoves: { row: number; col: number }[];
  currentPlayer: 'red' | 'black';
  isGameActive: boolean;
  isLocked: boolean;
  fenString: string;
  history: any[];
  skin: string;
  scale: number;
};

/**
 * Initial state for the game
 */
const initialState: GameState = {
  gameMode: null,
  pieces: [],
  selectedPiece: null,
  possibleMoves: [],
  currentPlayer: 'red',
  isGameActive: false,
  isLocked: false,
  fenString: 'rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w',
  history: [],
  skin: 'woods',
  scale: 1,
};

/**
 * Game slice for Redux
 */
const gameSlice = createSlice({
  name: 'game',
  initialState,
  reducers: {
    setGameMode: (state, action: PayloadAction<GameMode>) => {
      state.gameMode = action.payload;
    },
    setPieces: (state, action: PayloadAction<ChessPiece[]>) => {
      state.pieces = action.payload;
    },
    setSelectedPiece: (state, action: PayloadAction<ChessPiece | null>) => {
      state.selectedPiece = action.payload;
    },
    setPossibleMoves: (state, action: PayloadAction<{ row: number; col: number }[]>) => {
      state.possibleMoves = action.payload;
    },
    setCurrentPlayer: (state, action: PayloadAction<'red' | 'black'>) => {
      state.currentPlayer = action.payload;
    },
    setGameActive: (state, action: PayloadAction<boolean>) => {
      state.isGameActive = action.payload;
    },
    setLocked: (state, action: PayloadAction<boolean>) => {
      state.isLocked = action.payload;
    },
    setSkin: (state, action: PayloadAction<string>) => {
      state.skin = action.payload;
    },
    setScale: (state, action: PayloadAction<number>) => {
      state.scale = action.payload;
    },
    setFenString: (state, action: PayloadAction<string>) => {
      state.fenString = action.payload;
    },
    addToHistory: (state, action: PayloadAction<any>) => {
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
  setGameActive,
  setLocked,
  setSkin,
  setScale,
  setFenString,
  addToHistory,
  resetGame,
} = gameSlice.actions;

export default gameSlice.reducer;
