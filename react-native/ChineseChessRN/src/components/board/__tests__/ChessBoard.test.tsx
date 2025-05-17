import React from 'react';
import { render, fireEvent } from '../../../utils/testing/test-utils';
import { ChessBoard } from '../ChessBoard';
import { Provider } from 'react-redux';
import { configureStore } from '@reduxjs/toolkit';
import gameReducer, {
  setPieces,
  setSelectedPiece,
  setPossibleMoves,
  setCurrentPlayer,
  setGameActive,
} from '../../../store/slices/gameSlice';
import { gameService } from '../../../services/game';

// Mock the game service
jest.mock('../../../services/game', () => ({
  gameService: {
    getBoardState: jest.fn(),
    getValidMoves: jest.fn(),
    makeMove: jest.fn(),
    getCurrentPlayer: jest.fn(),
    isGameActive: jest.fn(),
  },
}));

describe('ChessBoard Component', () => {
  // Set up test store and initial state
  const createTestStore = (initialState = {}) => {
    return configureStore({
      reducer: {
        game: gameReducer,
      },
      preloadedState: {
        game: {
          pieces: [],
          selectedPiece: null,
          possibleMoves: [],
          currentPlayer: 'red',
          isGameActive: true,
          ...initialState,
        },
      },
    });
  };
  
  // Reset mocks before each test
  beforeEach(() => {
    jest.clearAllMocks();
  });
  
  it('renders correctly with no pieces', () => {
    const store = createTestStore();
    
    const { getByTestId } = render(
      <Provider store={store}>
        <ChessBoard />
      </Provider>
    );
    
    // Check that the board is rendered
    const board = getByTestId('chess-board');
    expect(board).toBeTruthy();
  });
  
  it('renders pieces correctly', () => {
    // Create test pieces
    const pieces = [
      {
        id: 'r1',
        type: 'rook',
        position: { row: 0, col: 0 },
        color: 'red',
      },
      {
        id: 'R1',
        type: 'rook',
        position: { row: 9, col: 0 },
        color: 'black',
      },
    ];
    
    const store = createTestStore({ pieces });
    
    const { getAllByTestId } = render(
      <Provider store={store}>
        <ChessBoard />
      </Provider>
    );
    
    // Check that the pieces are rendered
    const renderedPieces = getAllByTestId(/chess-piece/);
    expect(renderedPieces.length).toBe(2);
  });
  
  it('handles piece selection correctly', () => {
    // Create test pieces
    const pieces = [
      {
        id: 'r1',
        type: 'rook',
        position: { row: 0, col: 0 },
        color: 'red',
      },
    ];
    
    // Mock valid moves
    const validMoves = [
      { row: 0, col: 1 },
      { row: 1, col: 0 },
    ];
    
    (gameService.getValidMoves as jest.Mock).mockReturnValue(validMoves);
    (gameService.getCurrentPlayer as jest.Mock).mockReturnValue('red');
    (gameService.isGameActive as jest.Mock).mockReturnValue(true);
    
    const store = createTestStore({ pieces });
    
    const { getByTestId } = render(
      <Provider store={store}>
        <ChessBoard />
      </Provider>
    );
    
    // Find and click the piece
    const piece = getByTestId('chess-piece-r1');
    fireEvent.press(piece);
    
    // Check that the piece was selected and possible moves were set
    const state = store.getState().game;
    expect(state.selectedPiece).toEqual(pieces[0]);
    expect(state.possibleMoves).toEqual(validMoves);
  });
  
  it('handles piece movement correctly', () => {
    // Create test pieces
    const pieces = [
      {
        id: 'r1',
        type: 'rook',
        position: { row: 0, col: 0 },
        color: 'red',
      },
    ];
    
    // Set up selected piece and possible moves
    const selectedPiece = pieces[0];
    const possibleMoves = [
      { row: 0, col: 1 },
      { row: 1, col: 0 },
    ];
    
    // Mock game service
    (gameService.makeMove as jest.Mock).mockReturnValue(true);
    (gameService.getCurrentPlayer as jest.Mock).mockReturnValue('red');
    (gameService.isGameActive as jest.Mock).mockReturnValue(true);
    
    const store = createTestStore({
      pieces,
      selectedPiece,
      possibleMoves,
    });
    
    const { getByTestId } = render(
      <Provider store={store}>
        <ChessBoard />
      </Provider>
    );
    
    // Find and click a valid move position
    const position = getByTestId('board-position-1-0');
    fireEvent.press(position);
    
    // Check that makeMove was called with the correct arguments
    expect(gameService.makeMove).toHaveBeenCalledWith(0, 0, 1, 0);
  });
  
  it('does not allow selecting opponent pieces', () => {
    // Create test pieces
    const pieces = [
      {
        id: 'R1',
        type: 'rook',
        position: { row: 9, col: 0 },
        color: 'black',
      },
    ];
    
    // Mock game service
    (gameService.getCurrentPlayer as jest.Mock).mockReturnValue('red');
    (gameService.isGameActive as jest.Mock).mockReturnValue(true);
    
    const store = createTestStore({ pieces });
    
    const { getByTestId } = render(
      <Provider store={store}>
        <ChessBoard />
      </Provider>
    );
    
    // Find and click the opponent's piece
    const piece = getByTestId('chess-piece-R1');
    fireEvent.press(piece);
    
    // Check that the piece was not selected
    const state = store.getState().game;
    expect(state.selectedPiece).toBeNull();
  });
  
  it('does not allow moves when game is not active', () => {
    // Create test pieces
    const pieces = [
      {
        id: 'r1',
        type: 'rook',
        position: { row: 0, col: 0 },
        color: 'red',
      },
    ];
    
    // Mock game service
    (gameService.getCurrentPlayer as jest.Mock).mockReturnValue('red');
    (gameService.isGameActive as jest.Mock).mockReturnValue(false);
    
    const store = createTestStore({
      pieces,
      isGameActive: false,
    });
    
    const { getByTestId } = render(
      <Provider store={store}>
        <ChessBoard />
      </Provider>
    );
    
    // Find and click the piece
    const piece = getByTestId('chess-piece-r1');
    fireEvent.press(piece);
    
    // Check that the piece was not selected
    const state = store.getState().game;
    expect(state.selectedPiece).toBeNull();
  });
});
