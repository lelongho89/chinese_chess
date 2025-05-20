/**
 * Online game actions for the Chinese Chess application
 */
import { createAsyncThunk } from '@reduxjs/toolkit';
import { 
  GameSyncService, 
  MatchmakingService, 
  WebSocketService,
  OnlineGame,
  Match,
  MatchmakingEvent
} from '../../services/online';
import { 
  setOnlineGameId, 
  setOpponent, 
  setGameMode, 
  setGameActive,
  setError,
  setLoading,
  setAvailableGames,
  setActiveMatches,
  setGameHistory
} from '../slices/gameSlice';
import { Move } from '../../services/game/Board';
import { AppDispatch, RootState } from '../rootReducer';

/**
 * Initialize online services
 */
export const initializeOnlineServices = createAsyncThunk<
  void,
  { userId: string; token: string },
  { dispatch: AppDispatch; state: RootState }
>(
  'online/initializeOnlineServices',
  async ({ userId, token }, { dispatch }) => {
    try {
      dispatch(setLoading(true));
      
      // Initialize game synchronization service
      GameSyncService.initialize(userId, token);
      
      dispatch(setLoading(false));
    } catch (error) {
      dispatch(setLoading(false));
      
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to initialize online services');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);

/**
 * Clean up online services
 */
export const cleanupOnlineServices = createAsyncThunk<
  void,
  void,
  { dispatch: AppDispatch; state: RootState }
>(
  'online/cleanupOnlineServices',
  async (_, { dispatch }) => {
    try {
      // Clean up game synchronization service
      GameSyncService.cleanup();
    } catch (error) {
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to clean up online services');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);

/**
 * Create an online game
 */
export const createOnlineGame = createAsyncThunk<
  void,
  { timeControl?: number; increment?: number },
  { dispatch: AppDispatch; state: RootState }
>(
  'online/createOnlineGame',
  async ({ timeControl, increment }, { dispatch }) => {
    try {
      dispatch(setLoading(true));
      
      // Create game
      GameSyncService.createGame(timeControl, increment);
      
      // Set game mode
      dispatch(setGameMode('online'));
      
      dispatch(setLoading(false));
    } catch (error) {
      dispatch(setLoading(false));
      
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to create online game');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);

/**
 * Join an online game
 */
export const joinOnlineGame = createAsyncThunk<
  void,
  { gameId: string },
  { dispatch: AppDispatch; state: RootState }
>(
  'online/joinOnlineGame',
  async ({ gameId }, { dispatch }) => {
    try {
      dispatch(setLoading(true));
      
      // Join game
      GameSyncService.joinGame(gameId);
      
      // Set game ID
      dispatch(setOnlineGameId(gameId));
      
      // Set game mode
      dispatch(setGameMode('online'));
      
      dispatch(setLoading(false));
    } catch (error) {
      dispatch(setLoading(false));
      
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to join online game');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);

/**
 * Make a move in an online game
 */
export const makeOnlineMove = createAsyncThunk<
  void,
  { move: Move },
  { dispatch: AppDispatch; state: RootState }
>(
  'online/makeOnlineMove',
  async ({ move }, { dispatch }) => {
    try {
      // Make move
      GameSyncService.makeMove(move);
    } catch (error) {
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to make move');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);

/**
 * Leave an online game
 */
export const leaveOnlineGame = createAsyncThunk<
  void,
  void,
  { dispatch: AppDispatch; state: RootState }
>(
  'online/leaveOnlineGame',
  async (_, { dispatch }) => {
    try {
      // Leave game
      GameSyncService.leaveGame();
      
      // Reset game state
      dispatch(setOnlineGameId(null));
      dispatch(setOpponent(null));
      dispatch(setGameMode('ai'));
    } catch (error) {
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to leave online game');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);

/**
 * Send a chat message in an online game
 */
export const sendChatMessage = createAsyncThunk<
  void,
  { message: string },
  { dispatch: AppDispatch; state: RootState }
>(
  'online/sendChatMessage',
  async ({ message }, { dispatch }) => {
    try {
      // Send chat message
      GameSyncService.sendChatMessage(message);
    } catch (error) {
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to send chat message');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);

/**
 * Get available online games
 */
export const getAvailableGames = createAsyncThunk<
  void,
  void,
  { dispatch: AppDispatch; state: RootState }
>(
  'online/getAvailableGames',
  async (_, { dispatch }) => {
    try {
      dispatch(setLoading(true));
      
      // Get available games
      const games = await GameSyncService.getAvailableGames();
      
      // Set available games
      dispatch(setAvailableGames(games));
      
      dispatch(setLoading(false));
    } catch (error) {
      dispatch(setLoading(false));
      
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to get available games');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);

/**
 * Join the matchmaking queue
 */
export const joinMatchmakingQueue = createAsyncThunk<
  void,
  { 
    userId: string; 
    displayName: string; 
    rating: number; 
    timeControl?: number; 
    increment?: number 
  },
  { dispatch: AppDispatch; state: RootState }
>(
  'online/joinMatchmakingQueue',
  async ({ userId, displayName, rating, timeControl, increment }, { dispatch }) => {
    try {
      dispatch(setLoading(true));
      
      // Join queue
      await MatchmakingService.joinQueue(
        userId,
        displayName,
        rating,
        timeControl,
        increment
      );
      
      dispatch(setLoading(false));
    } catch (error) {
      dispatch(setLoading(false));
      
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to join matchmaking queue');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);

/**
 * Leave the matchmaking queue
 */
export const leaveMatchmakingQueue = createAsyncThunk<
  void,
  void,
  { dispatch: AppDispatch; state: RootState }
>(
  'online/leaveMatchmakingQueue',
  async (_, { dispatch }) => {
    try {
      // Leave queue
      await MatchmakingService.leaveQueue();
    } catch (error) {
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to leave matchmaking queue');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);

/**
 * Accept a match
 */
export const acceptMatch = createAsyncThunk<
  void,
  { matchId: string },
  { dispatch: AppDispatch; state: RootState }
>(
  'online/acceptMatch',
  async ({ matchId }, { dispatch }) => {
    try {
      // Accept match
      await MatchmakingService.acceptMatch(matchId);
    } catch (error) {
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to accept match');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);

/**
 * Decline a match
 */
export const declineMatch = createAsyncThunk<
  void,
  { matchId: string },
  { dispatch: AppDispatch; state: RootState }
>(
  'online/declineMatch',
  async ({ matchId }, { dispatch }) => {
    try {
      // Decline match
      await MatchmakingService.declineMatch(matchId);
    } catch (error) {
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to decline match');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);

/**
 * Get active matches
 */
export const getActiveMatches = createAsyncThunk<
  void,
  { userId: string },
  { dispatch: AppDispatch; state: RootState }
>(
  'online/getActiveMatches',
  async ({ userId }, { dispatch }) => {
    try {
      dispatch(setLoading(true));
      
      // Get active matches
      const matches = await MatchmakingService.getActiveMatches(userId);
      
      // Set active matches
      dispatch(setActiveMatches(matches));
      
      dispatch(setLoading(false));
    } catch (error) {
      dispatch(setLoading(false));
      
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to get active matches');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);

/**
 * Get user game history
 */
export const getUserGameHistory = createAsyncThunk<
  void,
  { userId: string; limit?: number },
  { dispatch: AppDispatch; state: RootState }
>(
  'online/getUserGameHistory',
  async ({ userId, limit }, { dispatch }) => {
    try {
      dispatch(setLoading(true));
      
      // Get game history
      const history = await GameSyncService.getUserGameHistory(userId, limit);
      
      // Set game history
      dispatch(setGameHistory(history));
      
      dispatch(setLoading(false));
    } catch (error) {
      dispatch(setLoading(false));
      
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to get game history');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);
