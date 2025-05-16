/**
 * Rating actions for the Chinese Chess application
 */
import { createAsyncThunk } from '@reduxjs/toolkit';
import { 
  RatingService, 
  PlayerRating, 
  LeaderboardEntry 
} from '../../services/rating';
import { 
  setLoading, 
  setError,
  setPlayerRating,
  setLeaderboard,
  setRatingHistory,
  setPlayerRank,
  updateUserStats
} from '../slices/ratingSlice';
import { AppDispatch, RootState } from '../rootReducer';

/**
 * Get player rating
 */
export const getPlayerRating = createAsyncThunk<
  PlayerRating,
  { userId: string },
  { dispatch: AppDispatch; state: RootState }
>(
  'rating/getPlayerRating',
  async ({ userId }, { dispatch }) => {
    try {
      dispatch(setLoading(true));
      
      // Get player rating
      const rating = await RatingService.getPlayerRating(userId);
      
      // Update Redux store
      dispatch(setPlayerRating(rating));
      
      // Update user stats in auth slice
      dispatch(updateUserStats({
        rating: rating.rating,
        gamesPlayed: rating.gamesPlayed,
        gamesWon: rating.gamesWon,
        gamesLost: rating.gamesLost,
        gamesDraw: rating.gamesDraw,
      }));
      
      dispatch(setLoading(false));
      
      return rating;
    } catch (error) {
      dispatch(setLoading(false));
      
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to get player rating');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);

/**
 * Get leaderboard
 */
export const getLeaderboard = createAsyncThunk<
  LeaderboardEntry[],
  { limit?: number },
  { dispatch: AppDispatch; state: RootState }
>(
  'rating/getLeaderboard',
  async ({ limit }, { dispatch }) => {
    try {
      dispatch(setLoading(true));
      
      // Get leaderboard
      const leaderboard = await RatingService.getLeaderboard(limit);
      
      // Update Redux store
      dispatch(setLeaderboard(leaderboard));
      
      dispatch(setLoading(false));
      
      return leaderboard;
    } catch (error) {
      dispatch(setLoading(false));
      
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to get leaderboard');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);

/**
 * Get rating history
 */
export const getRatingHistory = createAsyncThunk<
  PlayerRating['ratingHistory'],
  { userId: string },
  { dispatch: AppDispatch; state: RootState }
>(
  'rating/getRatingHistory',
  async ({ userId }, { dispatch }) => {
    try {
      dispatch(setLoading(true));
      
      // Get rating history
      const history = await RatingService.getRatingHistory(userId);
      
      // Update Redux store
      dispatch(setRatingHistory(history));
      
      dispatch(setLoading(false));
      
      return history;
    } catch (error) {
      dispatch(setLoading(false));
      
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to get rating history');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);

/**
 * Get player rank
 */
export const getPlayerRank = createAsyncThunk<
  number,
  { userId: string },
  { dispatch: AppDispatch; state: RootState }
>(
  'rating/getPlayerRank',
  async ({ userId }, { dispatch }) => {
    try {
      dispatch(setLoading(true));
      
      // Get player rank
      const rank = await RatingService.getPlayerRank(userId);
      
      // Update Redux store
      dispatch(setPlayerRank(rank));
      
      dispatch(setLoading(false));
      
      return rank;
    } catch (error) {
      dispatch(setLoading(false));
      
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to get player rank');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);

/**
 * Update ratings after a game
 */
export const updateRatings = createAsyncThunk<
  { player1NewRating: number; player2NewRating: number },
  { player1Id: string; player2Id: string; winnerId: string | null },
  { dispatch: AppDispatch; state: RootState }
>(
  'rating/updateRatings',
  async ({ player1Id, player2Id, winnerId }, { dispatch, getState }) => {
    try {
      dispatch(setLoading(true));
      
      // Update ratings
      const result = await RatingService.updateRatings(player1Id, player2Id, winnerId);
      
      // If current user is one of the players, update their rating
      const { user } = getState().auth;
      
      if (user) {
        if (user.id === player1Id) {
          // Get updated player rating
          await dispatch(getPlayerRating({ userId: player1Id }));
        } else if (user.id === player2Id) {
          // Get updated player rating
          await dispatch(getPlayerRating({ userId: player2Id }));
        }
      }
      
      dispatch(setLoading(false));
      
      return result;
    } catch (error) {
      dispatch(setLoading(false));
      
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to update ratings');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);
