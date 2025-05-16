import { createSlice, PayloadAction } from '@reduxjs/toolkit';

/**
 * Settings state types
 */
export type SettingsState = {
  soundEnabled: boolean;
  musicEnabled: boolean;
  notificationsEnabled: boolean;
  language: 'english' | 'chinese' | 'vietnamese';
  boardOrientation: 'normal' | 'flipped';
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
    resetSettings: (state) => {
      state.soundEnabled = true;
      state.musicEnabled = true;
      state.notificationsEnabled = true;
      state.language = 'english';
      state.boardOrientation = 'normal';
    },
  },
});

export const {
  setSoundEnabled,
  setMusicEnabled,
  setNotificationsEnabled,
  setLanguage,
  setBoardOrientation,
  resetSettings,
} = settingsSlice.actions;

export default settingsSlice.reducer;
