import { createSlice, PayloadAction } from '@reduxjs/toolkit';

/**
 * User type definition
 */
export type User = {
  id: string;
  email: string;
  displayName: string;
  photoURL?: string;
  eloRating: number;
  gamesPlayed: number;
  gamesWon: number;
  gamesLost: number;
  gamesDraw: number;
};

/**
 * Authentication state type
 */
export type AuthState = {
  user: User | null;
  isLoading: boolean;
  error: string | null;
};

/**
 * Initial state for authentication
 */
const initialState: AuthState = {
  user: null,
  isLoading: false,
  error: null,
};

/**
 * Authentication slice for Redux
 */
const authSlice = createSlice({
  name: 'auth',
  initialState,
  reducers: {
    setUser: (state, action: PayloadAction<User | null>) => {
      state.user = action.payload;
      state.error = null;
    },
    setLoading: (state, action: PayloadAction<boolean>) => {
      state.isLoading = action.payload;
    },
    setError: (state, action: PayloadAction<string | null>) => {
      state.error = action.payload;
      state.isLoading = false;
    },
    updateUserStats: (state, action: PayloadAction<Partial<User>>) => {
      if (state.user) {
        state.user = { ...state.user, ...action.payload };
      }
    },
    logout: (state) => {
      state.user = null;
      state.error = null;
      state.isLoading = false;
    },
  },
});

export const { setUser, setLoading, setError, updateUserStats, logout } = authSlice.actions;

export default authSlice.reducer;
