import { RootState } from './rootReducer';

/**
 * Game selectors
 */
export const selectGameMode = (state: RootState) => state.game.gameMode;
export const selectPieces = (state: RootState) => state.game.pieces;
export const selectSelectedPiece = (state: RootState) => state.game.selectedPiece;
export const selectPossibleMoves = (state: RootState) => state.game.possibleMoves;
export const selectCurrentPlayer = (state: RootState) => state.game.currentPlayer;
export const selectIsGameActive = (state: RootState) => state.game.isGameActive;
export const selectIsLocked = (state: RootState) => state.game.isLocked;
export const selectSkin = (state: RootState) => state.game.skin;
export const selectScale = (state: RootState) => state.game.scale;
export const selectFenString = (state: RootState) => state.game.fenString;
export const selectHistory = (state: RootState) => state.game.history;

/**
 * Settings selectors
 */
export const selectSoundEnabled = (state: RootState) => state.settings.soundEnabled;
export const selectMusicEnabled = (state: RootState) => state.settings.musicEnabled;
export const selectNotificationsEnabled = (state: RootState) => state.settings.notificationsEnabled;
export const selectLanguage = (state: RootState) => state.settings.language;
export const selectBoardOrientation = (state: RootState) => state.settings.boardOrientation;

/**
 * Auth selectors
 */
export const selectUser = (state: RootState) => state.auth.user;
export const selectIsAuthenticated = (state: RootState) => !!state.auth.user;
export const selectAuthLoading = (state: RootState) => state.auth.isLoading;
export const selectAuthError = (state: RootState) => state.auth.error;
