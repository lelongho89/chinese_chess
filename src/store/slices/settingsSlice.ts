import { createSlice, PayloadAction } from '@reduxjs/toolkit';

/**
 * AI difficulty levels
 */
export type AIDifficulty = 'easy' | 'medium' | 'hard';

/**
 * Settings state types
 */
export type SettingsState = {
  soundEnabled: boolean;
  musicEnabled: boolean;
  notificationsEnabled: boolean;
  language: 'english' | 'chinese' | 'vietnamese';
  boardOrientation: 'normal' | 'flipped';
  aiDifficulty: AIDifficulty;
};

/**
 * Initial state for settings
 */
const initialState: SettingsState = {
  soundEnabled: true,
  musicEnabled: true,
  notificationsEnabled: true,
  language: 'english',
  boardOrientation: 'normal',
  aiDifficulty: 'medium',
};

/**
 * Settings slice for Redux
 */
const settingsSlice = createSlice({
  name: 'settings',
  initialState,
  reducers: {
    setSoundEnabled: (state, action: PayloadAction<boolean>) => {
      state.soundEnabled = action.payload;
    },
    setMusicEnabled: (state, action: PayloadAction<boolean>) => {
      state.musicEnabled = action.payload;
    },
    setNotificationsEnabled: (state, action: PayloadAction<boolean>) => {
      state.notificationsEnabled = action.payload;
    },
    setLanguage: (state, action: PayloadAction<'english' | 'chinese' | 'vietnamese'>) => {
      state.language = action.payload;
    },
    setBoardOrientation: (state, action: PayloadAction<'normal' | 'flipped'>) => {
      state.boardOrientation = action.payload;
    },
    setAIDifficulty: (state, action: PayloadAction<AIDifficulty>) => {
      state.aiDifficulty = action.payload;
    },
    resetSettings: (state) => {
      state.soundEnabled = true;
      state.musicEnabled = true;
      state.notificationsEnabled = true;
      state.language = 'english';
      state.boardOrientation = 'normal';
      state.aiDifficulty = 'medium';
    },
  },
});

export const {
  setSoundEnabled,
  setMusicEnabled,
  setNotificationsEnabled,
  setLanguage,
  setBoardOrientation,
  setAIDifficulty,
  resetSettings,
} = settingsSlice.actions;

export default settingsSlice.reducer;
