import { combineReducers } from '@reduxjs/toolkit';
import gameReducer from './slices/gameSlice';
import settingsReducer from './slices/settingsSlice';
import authReducer from './slices/authSlice';
import ratingReducer from './slices/ratingSlice';

/**
 * Root reducer combining all slice reducers
 */
const rootReducer = combineReducers({
  game: gameReducer,
  settings: settingsReducer,
  auth: authReducer,
  rating: ratingReducer,
});

export type RootState = ReturnType<typeof rootReducer>;

export default rootReducer;
