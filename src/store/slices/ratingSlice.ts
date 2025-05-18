import { createSlice, PayloadAction } from '@reduxjs/toolkit';
import { PlayerRating, LeaderboardEntry } from '../../services/rating';

/**
 * Rating state type
 */
export type RatingState = {
  playerRating: PlayerRating | null;
  leaderboard: LeaderboardEntry[];
  ratingHistory: PlayerRating['ratingHistory'];
  playerRank: number;
  isLoading: boolean;
  error: string | null;
};

/**
 * Initial state for rating
 */
const initialState: RatingState = {
  playerRating: null,
  leaderboard: [],
  ratingHistory: [],
  playerRank: 0,
  isLoading: false,
  error: null,
};

/**
 * Rating slice for Redux
 */
const ratingSlice = createSlice({
  name: 'rating',
  initialState,
  reducers: {
    setPlayerRating: (state, action: PayloadAction<PlayerRating>) => {
      state.playerRating = action.payload;
    },
    setLeaderboard: (state, action: PayloadAction<LeaderboardEntry[]>) => {
      state.leaderboard = action.payload;
    },
    setRatingHistory: (state, action: PayloadAction<PlayerRating['ratingHistory']>) => {
      state.ratingHistory = action.payload;
    },
    setPlayerRank: (state, action: PayloadAction<number>) => {
      state.playerRank = action.payload;
    },
    updateUserStats: (state, action: PayloadAction<{
      rating: number;
      gamesPlayed: number;
      gamesWon: number;
      gamesLost: number;
      gamesDraw: number;
    }>) => {
      if (state.playerRating) {
        state.playerRating = {
          ...state.playerRating,
          ...action.payload,
        };
      }
    },
    setLoading: (state, action: PayloadAction<boolean>) => {
      state.isLoading = action.payload;
    },
    setError: (state, action: PayloadAction<string | null>) => {
      state.error = action.payload;
      state.isLoading = false;
    },
    resetRating: (state) => {
      state.playerRating = null;
      state.leaderboard = [];
      state.ratingHistory = [];
      state.playerRank = 0;
      state.error = null;
      state.isLoading = false;
    },
  },
});

export const {
  setPlayerRating,
  setLeaderboard,
  setRatingHistory,
  setPlayerRank,
  updateUserStats,
  setLoading,
  setError,
  resetRating,
} = ratingSlice.actions;

export default ratingSlice.reducer;
