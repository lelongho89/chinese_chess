import { Board } from '../Board';

describe('Board', () => {
  let board: Board;
  
  beforeEach(() => {
    // Create a new board instance before each test
    board = new Board();
  });
  
  it('should initialize with the correct starting position', () => {
    // Initialize the board
    board.initBoard();
    
    // Check that the board has the correct number of pieces
    const pieces = board.getPieces();
    expect(pieces.length).toBe(32); // 16 pieces per side
    
    // Check that there are the correct number of each piece type
    const redPieces = pieces.filter(piece => piece.color === 'red');
    const blackPieces = pieces.filter(piece => piece.color === 'black');
    
    expect(redPieces.length).toBe(16);
    expect(blackPieces.length).toBe(16);
    
    // Check specific pieces
    const redRooks = redPieces.filter(piece => piece.type === 'rook');
    const blackRooks = blackPieces.filter(piece => piece.type === 'rook');
    
    expect(redRooks.length).toBe(2);
    expect(blackRooks.length).toBe(2);
  });
  
  it('should correctly identify valid moves for a rook', () => {
    // Initialize the board
    board.initBoard();
    
    // Find a rook
    const pieces = board.getPieces();
    const redRook = pieces.find(piece => piece.type === 'rook' && piece.color === 'red');
    
    // Ensure we found a rook
    expect(redRook).toBeTruthy();
    
    if (redRook) {
      // Get valid moves for the rook
      const validMoves = board.getValidMoves(redRook.position.row, redRook.position.col);
      
      // A rook at the starting position should have no valid moves (blocked by other pieces)
      expect(validMoves.length).toBe(0);
      
      // Move the rook to an open position
      board.movePiece(redRook.position.row, redRook.position.col, 4, 4);
      
      // Get valid moves for the rook at the new position
      const newValidMoves = board.getValidMoves(4, 4);
      
      // A rook in the middle of the board should have multiple valid moves
      expect(newValidMoves.length).toBeGreaterThan(0);
    }
  });
  
  it('should correctly handle piece capture', () => {
    // Initialize the board
    board.initBoard();
    
    // Find a red rook and a black pawn
    const pieces = board.getPieces();
    const redRook = pieces.find(piece => piece.type === 'rook' && piece.color === 'red');
    const blackPawn = pieces.find(piece => piece.type === 'pawn' && piece.color === 'black');
    
    // Ensure we found the pieces
    expect(redRook).toBeTruthy();
    expect(blackPawn).toBeTruthy();
    
    if (redRook && blackPawn) {
      // Move the rook to a position where it can capture the pawn
      board.movePiece(redRook.position.row, redRook.position.col, blackPawn.position.row, blackPawn.position.col);
      
      // Get the updated pieces
      const updatedPieces = board.getPieces();
      
      // The black pawn should be captured (removed from the board)
      const capturedPawn = updatedPieces.find(piece => 
        piece.id === blackPawn.id && 
        piece.position.row === blackPawn.position.row && 
        piece.position.col === blackPawn.position.col
      );
      
      expect(capturedPawn).toBeUndefined();
      
      // The red rook should be at the pawn's position
      const movedRook = updatedPieces.find(piece => 
        piece.id === redRook.id && 
        piece.position.row === blackPawn.position.row && 
        piece.position.col === blackPawn.position.col
      );
      
      expect(movedRook).toBeTruthy();
    }
  });
  
  it('should correctly convert to and from FEN notation', () => {
    // Initialize the board
    board.initBoard();
    
    // Get the FEN string for the starting position
    const fen = board.toFEN();
    
    // Create a new board
    const newBoard = new Board();
    
    // Load the FEN string
    newBoard.fromFEN(fen);
    
    // Get the pieces from both boards
    const originalPieces = board.getPieces();
    const newPieces = newBoard.getPieces();
    
    // Both boards should have the same number of pieces
    expect(newPieces.length).toBe(originalPieces.length);
    
    // Check that the pieces are in the same positions
    for (const originalPiece of originalPieces) {
      const matchingPiece = newPieces.find(piece => 
        piece.type === originalPiece.type && 
        piece.color === originalPiece.color && 
        piece.position.row === originalPiece.position.row && 
        piece.position.col === originalPiece.position.col
      );
      
      expect(matchingPiece).toBeTruthy();
    }
  });
});
