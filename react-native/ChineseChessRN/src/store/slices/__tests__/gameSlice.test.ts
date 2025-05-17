import gameReducer, {
  setGameMode,
  setPieces,
  setSelectedPiece,
  setPossibleMoves,
  setCurrentPlayer,
  setGameActive,
  resetGame,
} from '../gameSlice';

describe('Game Slice', () => {
  // Initial state test
  it('should return the initial state', () => {
    const initialState = gameReducer(undefined, { type: undefined });
    
    expect(initialState.gameMode).toBeNull();
    expect(initialState.pieces).toEqual([]);
    expect(initialState.selectedPiece).toBeNull();
    expect(initialState.possibleMoves).toEqual([]);
    expect(initialState.currentPlayer).toBe('red');
    expect(initialState.isGameActive).toBe(false);
  });
  
  // Action tests
  it('should handle setGameMode', () => {
    const initialState = gameReducer(undefined, { type: undefined });
    const nextState = gameReducer(initialState, setGameMode('ai'));
    
    expect(nextState.gameMode).toBe('ai');
  });
  
  it('should handle setPieces', () => {
    const initialState = gameReducer(undefined, { type: undefined });
    const pieces = [
      {
        id: 'r1',
        type: 'rook',
        position: { row: 0, col: 0 },
        color: 'red',
      },
    ];
    
    const nextState = gameReducer(initialState, setPieces(pieces));
    
    expect(nextState.pieces).toEqual(pieces);
  });
  
  it('should handle setSelectedPiece', () => {
    const initialState = gameReducer(undefined, { type: undefined });
    const piece = {
      id: 'r1',
      type: 'rook',
      position: { row: 0, col: 0 },
      color: 'red',
    };
    
    const nextState = gameReducer(initialState, setSelectedPiece(piece));
    
    expect(nextState.selectedPiece).toEqual(piece);
  });
  
  it('should handle setPossibleMoves', () => {
    const initialState = gameReducer(undefined, { type: undefined });
    const moves = [
      { row: 1, col: 0 },
      { row: 2, col: 0 },
    ];
    
    const nextState = gameReducer(initialState, setPossibleMoves(moves));
    
    expect(nextState.possibleMoves).toEqual(moves);
  });
  
  it('should handle setCurrentPlayer', () => {
    const initialState = gameReducer(undefined, { type: undefined });
    const nextState = gameReducer(initialState, setCurrentPlayer('black'));
    
    expect(nextState.currentPlayer).toBe('black');
  });
  
  it('should handle setGameActive', () => {
    const initialState = gameReducer(undefined, { type: undefined });
    const nextState = gameReducer(initialState, setGameActive(true));
    
    expect(nextState.isGameActive).toBe(true);
  });
  
  it('should handle resetGame', () => {
    // Set up a non-default state
    let state = gameReducer(undefined, { type: undefined });
    state = gameReducer(state, setGameMode('ai'));
    state = gameReducer(state, setGameActive(true));
    state = gameReducer(state, setCurrentPlayer('black'));
    
    // Reset the game
    const nextState = gameReducer(state, resetGame());
    
    // Check that state is reset
    expect(nextState.pieces).toEqual([]);
    expect(nextState.selectedPiece).toBeNull();
    expect(nextState.possibleMoves).toEqual([]);
    expect(nextState.isGameActive).toBe(false);
    expect(nextState.currentPlayer).toBe('red');
    expect(nextState.history).toEqual([]);
  });
});
