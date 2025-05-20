import { createSlice, PayloadAction } from '@reduxjs/toolkit';
import { User } from './authSlice';
import { OnlineGame, Match } from '../../services/online';
import { GameHistoryEntry } from '../../services/history';

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

export type GameResult = {
  winner: 'red' | 'black' | 'draw' | null;
  reason: 'checkmate' | 'resignation' | 'timeout' | 'draw' | 'stalemate' | null;
};

export type ChatMessage = {
  id: string;
  senderId: string;
  senderName: string;
  message: string;
  timestamp: number;
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
  // Timer related state
  timerEnabled: boolean;
  initialTimeSeconds: number;
  incrementSeconds: number;
  gameResult: GameResult;
  // Online game state
  onlineGameId: string | null;
  opponent: User | null;
  availableGames: OnlineGame[];
  activeMatches: Match[];
  gameHistory: OnlineGame[];
  chatMessages: ChatMessage[];
  // Game history state
  savedGames: GameHistoryEntry[];
  currentGame: GameHistoryEntry | null;
  currentMoveIndex: number;
  isReplayMode: boolean;
  replaySpeed: number;
  isLoading: boolean;
  error: string | null;
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
  // Timer related state
  timerEnabled: false,
  initialTimeSeconds: 180, // 3 minutes
  incrementSeconds: 2,     // 2 seconds per move
  gameResult: {
    winner: null,
    reason: null
  },
  // Online game state
  onlineGameId: null,
  opponent: null,
  availableGames: [],
  activeMatches: [],
  gameHistory: [],
  chatMessages: [],
  // Game history state
  savedGames: [],
  currentGame: null,
  currentMoveIndex: -1,
  isReplayMode: false,
  replaySpeed: 1000, // 1 second per move
  isLoading: false,
  error: null
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
    // Timer related reducers
    setTimerEnabled: (state, action: PayloadAction<boolean>) => {
      state.timerEnabled = action.payload;
    },
    setInitialTime: (state, action: PayloadAction<number>) => {
      state.initialTimeSeconds = action.payload;
    },
    setIncrementTime: (state, action: PayloadAction<number>) => {
      state.incrementSeconds = action.payload;
    },
    setGameResult: (state, action: PayloadAction<GameResult>) => {
      state.gameResult = action.payload;
      state.isGameActive = false;
    },
    resetGame: (state) => {
      state.pieces = [];
      state.selectedPiece = null;
      state.possibleMoves = [];
      state.isGameActive = false;
      state.currentPlayer = 'red';
      state.history = [];
      state.fenString = 'rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w';
      state.gameResult = {
        winner: null,
        reason: null
      };
    },
    // Online game reducers
    setOnlineGameId: (state, action: PayloadAction<string | null>) => {
      state.onlineGameId = action.payload;
    },
    setOpponent: (state, action: PayloadAction<User | null>) => {
      state.opponent = action.payload;
    },
    setAvailableGames: (state, action: PayloadAction<OnlineGame[]>) => {
      state.availableGames = action.payload;
    },
    setActiveMatches: (state, action: PayloadAction<Match[]>) => {
      state.activeMatches = action.payload;
    },
    setGameHistory: (state, action: PayloadAction<OnlineGame[]>) => {
      state.gameHistory = action.payload;
    },
    addChatMessage: (state, action: PayloadAction<ChatMessage>) => {
      state.chatMessages.push(action.payload);
    },
    setChatMessages: (state, action: PayloadAction<ChatMessage[]>) => {
      state.chatMessages = action.payload;
    },
    setLoading: (state, action: PayloadAction<boolean>) => {
      state.isLoading = action.payload;
    },
    setError: (state, action: PayloadAction<string | null>) => {
      state.error = action.payload;
    },
    // Game history reducers
    setSavedGames: (state, action: PayloadAction<GameHistoryEntry[]>) => {
      state.savedGames = action.payload;
    },
    setCurrentGame: (state, action: PayloadAction<GameHistoryEntry | null>) => {
      state.currentGame = action.payload;
    },
    setCurrentMoveIndex: (state, action: PayloadAction<number>) => {
      state.currentMoveIndex = action.payload;
    },
    setReplayMode: (state, action: PayloadAction<boolean>) => {
      state.isReplayMode = action.payload;
    },
    setReplaySpeed: (state, action: PayloadAction<number>) => {
      state.replaySpeed = action.payload;
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
  // Timer related actions
  setTimerEnabled,
  setInitialTime,
  setIncrementTime,
  setGameResult,
  resetGame,
  // Online game actions
  setOnlineGameId,
  setOpponent,
  setAvailableGames,
  setActiveMatches,
  setGameHistory,
  addChatMessage,
  setChatMessages,
  setLoading,
  setError,
  // Game history actions
  setSavedGames,
  setCurrentGame,
  setCurrentMoveIndex,
  setReplayMode,
  setReplaySpeed,
} = gameSlice.actions;

export default gameSlice.reducer;
