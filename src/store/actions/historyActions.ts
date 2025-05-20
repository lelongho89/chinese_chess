/**
 * Game history actions for the Chinese Chess application
 */
import { createAsyncThunk } from '@reduxjs/toolkit';
import { 
  GameHistoryService, 
  GameReplayService,
  GameHistoryEntry
} from '../../services/history';
import { 
  setGameHistory, 
  setCurrentGame,
  setLoading,
  setError
} from '../slices/gameSlice';
import { AppDispatch, RootState } from '../rootReducer';

/**
 * Save a game to history
 */
export const saveGameToHistory = createAsyncThunk<
  string,
  Omit<GameHistoryEntry, 'id'>,
  { dispatch: AppDispatch; state: RootState }
>(
  'history/saveGameToHistory',
  async (game, { dispatch, getState }) => {
    try {
      dispatch(setLoading(true));
      
      // Get the user ID from the auth state
      const { user } = getState().auth;
      
      // Save the game
      const gameId = await GameHistoryService.saveGame(game, user?.id);
      
      // Get the updated history
      const history = await GameHistoryService.getLocalHistory();
      
      // Update the Redux store
      dispatch(setGameHistory(history));
      
      dispatch(setLoading(false));
      
      return gameId;
    } catch (error) {
      dispatch(setLoading(false));
      
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to save game to history');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);

/**
 * Get game history
 */
export const getGameHistory = createAsyncThunk<
  void,
  void,
  { dispatch: AppDispatch; state: RootState }
>(
  'history/getGameHistory',
  async (_, { dispatch, getState }) => {
    try {
      dispatch(setLoading(true));
      
      // Get the user ID from the auth state
      const { user } = getState().auth;
      
      // Get the history
      let history: GameHistoryEntry[] = [];
      
      if (user) {
        // If user is logged in, get history from Firestore
        history = await GameHistoryService.getFirestoreHistory(user.id);
      } else {
        // Otherwise, get history from local storage
        history = await GameHistoryService.getLocalHistory();
      }
      
      // Update the Redux store
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

/**
 * Get a specific game from history
 */
export const getGameFromHistory = createAsyncThunk<
  GameHistoryEntry | null,
  { gameId: string },
  { dispatch: AppDispatch; state: RootState }
>(
  'history/getGameFromHistory',
  async ({ gameId }, { dispatch, getState }) => {
    try {
      dispatch(setLoading(true));
      
      // Get the user ID from the auth state
      const { user } = getState().auth;
      
      // Get the game
      const game = await GameHistoryService.getGame(gameId, user?.id);
      
      // Update the Redux store
      if (game) {
        dispatch(setCurrentGame(game));
      }
      
      dispatch(setLoading(false));
      
      return game;
    } catch (error) {
      dispatch(setLoading(false));
      
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to get game from history');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);

/**
 * Delete a game from history
 */
export const deleteGameFromHistory = createAsyncThunk<
  void,
  { gameId: string },
  { dispatch: AppDispatch; state: RootState }
>(
  'history/deleteGameFromHistory',
  async ({ gameId }, { dispatch, getState }) => {
    try {
      dispatch(setLoading(true));
      
      // Get the user ID from the auth state
      const { user } = getState().auth;
      
      // Delete the game
      await GameHistoryService.deleteGame(gameId, user?.id);
      
      // Get the updated history
      const history = await GameHistoryService.getLocalHistory();
      
      // Update the Redux store
      dispatch(setGameHistory(history));
      
      dispatch(setLoading(false));
    } catch (error) {
      dispatch(setLoading(false));
      
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to delete game from history');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);

/**
 * Clear all game history
 */
export const clearGameHistory = createAsyncThunk<
  void,
  void,
  { dispatch: AppDispatch; state: RootState }
>(
  'history/clearGameHistory',
  async (_, { dispatch, getState }) => {
    try {
      dispatch(setLoading(true));
      
      // Get the user ID from the auth state
      const { user } = getState().auth;
      
      // Clear the history
      await GameHistoryService.clearHistory(user?.id);
      
      // Update the Redux store
      dispatch(setGameHistory([]));
      
      dispatch(setLoading(false));
    } catch (error) {
      dispatch(setLoading(false));
      
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to clear game history');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);

/**
 * Export a game as PGN
 */
export const exportGameAsPGN = createAsyncThunk<
  string,
  { game: GameHistoryEntry },
  { dispatch: AppDispatch; state: RootState }
>(
  'history/exportGameAsPGN',
  async ({ game }, { dispatch }) => {
    try {
      // Export the game
      const pgn = GameHistoryService.exportAsPGN(game);
      
      return pgn;
    } catch (error) {
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to export game as PGN');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);

/**
 * Import a game from PGN
 */
export const importGameFromPGN = createAsyncThunk<
  GameHistoryEntry | null,
  { pgn: string },
  { dispatch: AppDispatch; state: RootState }
>(
  'history/importGameFromPGN',
  async ({ pgn }, { dispatch }) => {
    try {
      dispatch(setLoading(true));
      
      // Import the game
      const game = GameHistoryService.importFromPGN(pgn);
      
      // Update the Redux store
      if (game) {
        dispatch(setCurrentGame(game));
      }
      
      dispatch(setLoading(false));
      
      return game;
    } catch (error) {
      dispatch(setLoading(false));
      
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to import game from PGN');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);

/**
 * Load a game for replay
 */
export const loadGameForReplay = createAsyncThunk<
  void,
  { game: GameHistoryEntry },
  { dispatch: AppDispatch; state: RootState }
>(
  'history/loadGameForReplay',
  async ({ game }, { dispatch }) => {
    try {
      // Load the game for replay
      GameReplayService.loadGame(game);
      
      // Update the Redux store
      dispatch(setCurrentGame(game));
    } catch (error) {
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to load game for replay');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);
