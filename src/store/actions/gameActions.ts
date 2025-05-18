/**
 * Game actions for the Chinese Chess application
 */
import { createAsyncThunk } from '@reduxjs/toolkit';
import { gameService } from '../../services';
import { 
  setGameMode, 
  setPieces, 
  setSelectedPiece, 
  setPossibleMoves,
  setCurrentPlayer,
  setGameActive,
  addToHistory,
  setFenString,
  ChessPiece
} from '../slices/gameSlice';
import { AppDispatch, RootState } from '../rootReducer';

/**
 * Initialize a game
 */
export const initGame = createAsyncThunk<
  void,
  { gameMode: 'ai' | 'online' | 'free'; fen?: string },
  { dispatch: AppDispatch; state: RootState }
>(
  'game/initGame',
  async ({ gameMode, fen }, { dispatch }) => {
    // Initialize the game
    gameService.initGame(gameMode, fen);
    
    // Set up listener for game events
    gameService.addListener((event, data) => {
      switch (event) {
        case 'gameInit':
          dispatch(setGameMode(data.gameMode));
          dispatch(setPieces(data.board));
          dispatch(setCurrentPlayer(data.currentPlayer));
          dispatch(setGameActive(true));
          break;
        case 'moveMade':
          dispatch(setPieces(data.board));
          dispatch(setCurrentPlayer(data.currentPlayer));
          if (data.lastMove) {
            dispatch(addToHistory(data.lastMove));
          }
          break;
        case 'gameEnd':
          dispatch(setGameActive(false));
          break;
        case 'boardUpdated':
          dispatch(setPieces(data.board));
          dispatch(setCurrentPlayer(data.currentPlayer));
          break;
        default:
          break;
      }
    });
  }
);

/**
 * Select a piece
 */
export const selectPiece = (piece: ChessPiece | null) => (dispatch: AppDispatch) => {
  dispatch(setSelectedPiece(piece));
  
  if (!piece) {
    dispatch(setPossibleMoves([]));
    return;
  }
  
  // Get valid moves for the selected piece
  const { row, col } = piece.position;
  const validMoves = gameService.getValidMoves(row, col);
  
  dispatch(setPossibleMoves(validMoves));
};

/**
 * Move a piece
 */
export const movePiece = (
  fromPosition: { row: number; col: number },
  toPosition: { row: number; col: number }
) => (dispatch: AppDispatch) => {
  const { row: fromRow, col: fromCol } = fromPosition;
  const { row: toRow, col: toCol } = toPosition;
  
  // Make the move
  const success = gameService.makeMove(fromRow, fromCol, toRow, toCol);
  
  if (success) {
    // Deselect the piece
    dispatch(setSelectedPiece(null));
    dispatch(setPossibleMoves([]));
    
    // Update the FEN string
    dispatch(setFenString(gameService.getFen()));
  }
  
  return success;
};

/**
 * Load a game from a FEN string
 */
export const loadFromFen = (fen: string) => (dispatch: AppDispatch) => {
  gameService.loadFromFen(fen);
  dispatch(setFenString(fen));
};
