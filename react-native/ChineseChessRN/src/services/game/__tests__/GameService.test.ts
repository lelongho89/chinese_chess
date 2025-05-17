import { gameService } from '../index';

describe('GameService', () => {
  // Reset the game service before each test
  beforeEach(() => {
    gameService.resetGame();
  });
  
  // Test game initialization
  it('should initialize the game correctly', () => {
    // Initialize the game
    gameService.initGame('ai');
    
    // Check that the board has the correct number of pieces
    const pieces = gameService.getBoardState();
    expect(pieces.length).toBe(32); // 16 pieces per side
    
    // Check that the current player is red
    expect(gameService.getCurrentPlayer()).toBe('red');
    
    // Check that the game is active
    expect(gameService.isGameActive()).toBe(true);
  });
  
  // Test making a valid move
  it('should make a valid move correctly', () => {
    // Initialize the game
    gameService.initGame('ai');
    
    // Get the initial state
    const initialPieces = gameService.getBoardState();
    const initialPlayer = gameService.getCurrentPlayer();
    
    // Find a red pawn
    const redPawn = initialPieces.find(piece => piece.type === 'pawn' && piece.color === 'red');
    expect(redPawn).toBeTruthy();
    
    if (redPawn) {
      // Make a valid move with the pawn
      const result = gameService.makeMove(redPawn.position.row, redPawn.position.col, redPawn.position.row - 1, redPawn.position.col);
      
      // Check that the move was successful
      expect(result).toBe(true);
      
      // Check that the player has changed
      expect(gameService.getCurrentPlayer()).not.toBe(initialPlayer);
      
      // Check that the pawn has moved
      const updatedPieces = gameService.getBoardState();
      const movedPawn = updatedPieces.find(piece => piece.id === redPawn.id);
      expect(movedPawn).toBeTruthy();
      
      if (movedPawn) {
        expect(movedPawn.position.row).toBe(redPawn.position.row - 1);
        expect(movedPawn.position.col).toBe(redPawn.position.col);
      }
    }
  });
  
  // Test making an invalid move
  it('should reject an invalid move', () => {
    // Initialize the game
    gameService.initGame('ai');
    
    // Get the initial state
    const initialPieces = gameService.getBoardState();
    const initialPlayer = gameService.getCurrentPlayer();
    
    // Find a red rook
    const redRook = initialPieces.find(piece => piece.type === 'rook' && piece.color === 'red');
    expect(redRook).toBeTruthy();
    
    if (redRook) {
      // Try to make an invalid move with the rook (diagonal)
      const result = gameService.makeMove(redRook.position.row, redRook.position.col, redRook.position.row - 1, redRook.position.col - 1);
      
      // Check that the move was rejected
      expect(result).toBe(false);
      
      // Check that the player has not changed
      expect(gameService.getCurrentPlayer()).toBe(initialPlayer);
      
      // Check that the rook has not moved
      const updatedPieces = gameService.getBoardState();
      const unmoved = updatedPieces.find(piece => piece.id === redRook.id);
      expect(unmoved).toBeTruthy();
      
      if (unmoved) {
        expect(unmoved.position.row).toBe(redRook.position.row);
        expect(unmoved.position.col).toBe(redRook.position.col);
      }
    }
  });
  
  // Test getting valid moves
  it('should return valid moves for a piece', () => {
    // Initialize the game
    gameService.initGame('ai');
    
    // Get the initial state
    const initialPieces = gameService.getBoardState();
    
    // Find a red pawn
    const redPawn = initialPieces.find(piece => piece.type === 'pawn' && piece.color === 'red');
    expect(redPawn).toBeTruthy();
    
    if (redPawn) {
      // Get valid moves for the pawn
      const validMoves = gameService.getValidMoves(redPawn.position.row, redPawn.position.col);
      
      // A pawn at the starting position should have at least one valid move
      expect(validMoves.length).toBeGreaterThan(0);
      
      // Check that the valid moves are correct
      const expectedMove = { row: redPawn.position.row - 1, col: redPawn.position.col };
      expect(validMoves).toContainEqual(expectedMove);
    }
  });
  
  // Test capturing a piece
  it('should handle piece capture correctly', () => {
    // Initialize a custom board for testing captures
    gameService.resetGame();
    
    // Load a custom FEN with a red rook that can capture a black pawn
    const customFEN = '4k4/9/9/9/9/9/9/9/1p7/R3K4 w - - 0 1';
    gameService.loadFromFen(customFEN);
    
    // Get the initial state
    const initialPieces = gameService.getBoardState();
    
    // Find the red rook and black pawn
    const redRook = initialPieces.find(piece => piece.type === 'rook' && piece.color === 'red');
    const blackPawn = initialPieces.find(piece => piece.type === 'pawn' && piece.color === 'black');
    
    expect(redRook).toBeTruthy();
    expect(blackPawn).toBeTruthy();
    
    if (redRook && blackPawn) {
      // Capture the black pawn with the red rook
      const result = gameService.makeMove(redRook.position.row, redRook.position.col, blackPawn.position.row, blackPawn.position.col);
      
      // Check that the move was successful
      expect(result).toBe(true);
      
      // Check that the black pawn has been captured (removed from the board)
      const updatedPieces = gameService.getBoardState();
      const capturedPawn = updatedPieces.find(piece => piece.id === blackPawn.id);
      expect(capturedPawn).toBeUndefined();
      
      // Check that the red rook is now at the pawn's position
      const movedRook = updatedPieces.find(piece => piece.id === redRook.id);
      expect(movedRook).toBeTruthy();
      
      if (movedRook) {
        expect(movedRook.position.row).toBe(blackPawn.position.row);
        expect(movedRook.position.col).toBe(blackPawn.position.col);
      }
    }
  });
  
  // Test FEN conversion
  it('should correctly convert to and from FEN notation', () => {
    // Initialize the game
    gameService.initGame('ai');
    
    // Get the FEN string for the starting position
    const startingFen = gameService.getFen();
    
    // Make a move
    const pieces = gameService.getBoardState();
    const redPawn = pieces.find(piece => piece.type === 'pawn' && piece.color === 'red');
    
    if (redPawn) {
      gameService.makeMove(redPawn.position.row, redPawn.position.col, redPawn.position.row - 1, redPawn.position.col);
    }
    
    // Get the FEN string after the move
    const afterMoveFen = gameService.getFen();
    
    // The FEN strings should be different
    expect(afterMoveFen).not.toBe(startingFen);
    
    // Reset the game
    gameService.resetGame();
    
    // Load the FEN string from after the move
    gameService.loadFromFen(afterMoveFen);
    
    // The FEN string should be the same as before
    expect(gameService.getFen()).toBe(afterMoveFen);
  });
  
  // Test game result detection
  it('should detect checkmate correctly', () => {
    // Load a custom FEN with a checkmate position
    const checkmateFEN = '4k4/9/9/9/9/9/9/9/9/R3K1R2 b - - 0 1';
    gameService.loadFromFen(checkmateFEN);
    
    // Check that the game is in checkmate
    expect(gameService.isCheckmate()).toBe(true);
    
    // Check that the game result is correct
    const result = gameService.getGameResult();
    expect(result.winner).toBe('red');
    expect(result.reason).toBe('checkmate');
  });
});
