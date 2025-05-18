import { Rules } from '../Rules';
import { Board } from '../Board';
import { Piece } from '../Piece';

describe('Rules', () => {
  let board: Board;
  let rules: Rules;
  
  beforeEach(() => {
    // Create a new board and rules instance before each test
    board = new Board();
    rules = new Rules(board);
  });
  
  // Test isValidMove for rook
  it('should correctly validate rook moves', () => {
    // Create an empty board
    board.clear();
    
    // Add a red rook at position (4, 4)
    const rook = new Piece('r1', 'rook', 4, 4, 'red');
    board.addPiece(rook);
    
    // Valid moves: horizontal and vertical
    expect(rules.isValidMove(rook, 4, 0)).toBe(true); // Left
    expect(rules.isValidMove(rook, 4, 8)).toBe(true); // Right
    expect(rules.isValidMove(rook, 0, 4)).toBe(true); // Up
    expect(rules.isValidMove(rook, 9, 4)).toBe(true); // Down
    
    // Invalid moves: diagonal
    expect(rules.isValidMove(rook, 3, 3)).toBe(false);
    expect(rules.isValidMove(rook, 5, 5)).toBe(false);
    
    // Add a piece in the way
    const blockingPiece = new Piece('p1', 'pawn', 4, 2, 'red');
    board.addPiece(blockingPiece);
    
    // Should not be able to move through the blocking piece
    expect(rules.isValidMove(rook, 4, 0)).toBe(false);
    
    // Should be able to capture an enemy piece
    const enemyPiece = new Piece('P1', 'pawn', 4, 6, 'black');
    board.addPiece(enemyPiece);
    
    expect(rules.isValidMove(rook, 4, 6)).toBe(true);
    
    // Should not be able to capture a friendly piece
    const friendlyPiece = new Piece('p2', 'pawn', 6, 4, 'red');
    board.addPiece(friendlyPiece);
    
    expect(rules.isValidMove(rook, 6, 4)).toBe(false);
  });
  
  // Test isValidMove for knight
  it('should correctly validate knight moves', () => {
    // Create an empty board
    board.clear();
    
    // Add a red knight at position (4, 4)
    const knight = new Piece('n1', 'knight', 4, 4, 'red');
    board.addPiece(knight);
    
    // Valid moves: L-shapes
    expect(rules.isValidMove(knight, 2, 3)).toBe(true); // Up-left
    expect(rules.isValidMove(knight, 2, 5)).toBe(true); // Up-right
    expect(rules.isValidMove(knight, 3, 2)).toBe(true); // Left-up
    expect(rules.isValidMove(knight, 3, 6)).toBe(true); // Right-up
    expect(rules.isValidMove(knight, 5, 2)).toBe(true); // Left-down
    expect(rules.isValidMove(knight, 5, 6)).toBe(true); // Right-down
    expect(rules.isValidMove(knight, 6, 3)).toBe(true); // Down-left
    expect(rules.isValidMove(knight, 6, 5)).toBe(true); // Down-right
    
    // Invalid moves: non-L-shapes
    expect(rules.isValidMove(knight, 4, 5)).toBe(false); // Adjacent
    expect(rules.isValidMove(knight, 3, 3)).toBe(false); // Diagonal
    
    // Add a piece blocking the knight's path
    const blockingPiece = new Piece('p1', 'pawn', 3, 4, 'red');
    board.addPiece(blockingPiece);
    
    // Should not be able to move if the path is blocked
    expect(rules.isValidMove(knight, 2, 3)).toBe(false);
    expect(rules.isValidMove(knight, 2, 5)).toBe(false);
    
    // Should be able to capture an enemy piece
    const enemyPiece = new Piece('P1', 'pawn', 6, 5, 'black');
    board.addPiece(enemyPiece);
    
    expect(rules.isValidMove(knight, 6, 5)).toBe(true);
    
    // Should not be able to capture a friendly piece
    const friendlyPiece = new Piece('p2', 'pawn', 6, 3, 'red');
    board.addPiece(friendlyPiece);
    
    expect(rules.isValidMove(knight, 6, 3)).toBe(false);
  });
  
  // Test isValidMove for cannon
  it('should correctly validate cannon moves', () => {
    // Create an empty board
    board.clear();
    
    // Add a red cannon at position (4, 4)
    const cannon = new Piece('c1', 'cannon', 4, 4, 'red');
    board.addPiece(cannon);
    
    // Valid moves: horizontal and vertical (like rook when not capturing)
    expect(rules.isValidMove(cannon, 4, 0)).toBe(true); // Left
    expect(rules.isValidMove(cannon, 4, 8)).toBe(true); // Right
    expect(rules.isValidMove(cannon, 0, 4)).toBe(true); // Up
    expect(rules.isValidMove(cannon, 9, 4)).toBe(true); // Down
    
    // Invalid moves: diagonal
    expect(rules.isValidMove(cannon, 3, 3)).toBe(false);
    expect(rules.isValidMove(cannon, 5, 5)).toBe(false);
    
    // Add a piece in the way
    const blockingPiece = new Piece('p1', 'pawn', 4, 2, 'red');
    board.addPiece(blockingPiece);
    
    // Should not be able to move through the blocking piece
    expect(rules.isValidMove(cannon, 4, 0)).toBe(false);
    
    // Add an enemy piece with a piece in between (for capture)
    const platform = new Piece('p2', 'pawn', 4, 6, 'red');
    board.addPiece(platform);
    
    const enemyPiece = new Piece('P1', 'pawn', 4, 7, 'black');
    board.addPiece(enemyPiece);
    
    // Should be able to capture by jumping over exactly one piece
    expect(rules.isValidMove(cannon, 4, 7)).toBe(true);
    
    // Add another piece in the way
    const anotherPiece = new Piece('p3', 'pawn', 4, 5, 'red');
    board.addPiece(anotherPiece);
    
    // Should not be able to capture with more than one piece in between
    expect(rules.isValidMove(cannon, 4, 7)).toBe(false);
  });
  
  // Test isValidMove for king
  it('should correctly validate king moves', () => {
    // Create an empty board
    board.clear();
    
    // Add a red king at position (0, 4)
    const king = new Piece('k1', 'king', 0, 4, 'red');
    board.addPiece(king);
    
    // Valid moves: orthogonal within palace
    expect(rules.isValidMove(king, 0, 3)).toBe(true); // Left
    expect(rules.isValidMove(king, 0, 5)).toBe(true); // Right
    expect(rules.isValidMove(king, 1, 4)).toBe(true); // Down
    
    // Invalid moves: outside palace or diagonal
    expect(rules.isValidMove(king, 0, 2)).toBe(false); // Outside palace
    expect(rules.isValidMove(king, 0, 6)).toBe(false); // Outside palace
    expect(rules.isValidMove(king, 3, 4)).toBe(false); // Outside palace
    expect(rules.isValidMove(king, 1, 3)).toBe(false); // Diagonal
    
    // Move king to center of palace
    king.move(1, 4);
    
    // Valid moves from center: all orthogonal within palace
    expect(rules.isValidMove(king, 0, 4)).toBe(true); // Up
    expect(rules.isValidMove(king, 1, 3)).toBe(true); // Left
    expect(rules.isValidMove(king, 1, 5)).toBe(true); // Right
    expect(rules.isValidMove(king, 2, 4)).toBe(true); // Down
    
    // Add black king for flying kings test
    const blackKing = new Piece('K1', 'king', 9, 4, 'black');
    board.addPiece(blackKing);
    
    // Should be able to capture opposing king if no pieces in between (flying kings)
    expect(rules.isValidMove(king, 9, 4)).toBe(true);
    
    // Add a piece between kings
    const blockingPiece = new Piece('p1', 'pawn', 5, 4, 'red');
    board.addPiece(blockingPiece);
    
    // Should not be able to capture opposing king with pieces in between
    expect(rules.isValidMove(king, 9, 4)).toBe(false);
  });
  
  // Test isInCheck
  it('should correctly determine if a king is in check', () => {
    // Create an empty board
    board.clear();
    
    // Add kings
    const redKing = new Piece('k1', 'king', 0, 4, 'red');
    const blackKing = new Piece('K1', 'king', 9, 4, 'black');
    board.addPiece(redKing);
    board.addPiece(blackKing);
    
    // No check initially
    expect(rules.isInCheck('red')).toBe(false);
    expect(rules.isInCheck('black')).toBe(false);
    
    // Add a black rook that puts the red king in check
    const blackRook = new Piece('R1', 'rook', 0, 0, 'black');
    board.addPiece(blackRook);
    
    // Red king should be in check
    expect(rules.isInCheck('red')).toBe(true);
    expect(rules.isInCheck('black')).toBe(false);
    
    // Add a piece to block the check
    const blockingPiece = new Piece('p1', 'pawn', 0, 2, 'red');
    board.addPiece(blockingPiece);
    
    // Red king should no longer be in check
    expect(rules.isInCheck('red')).toBe(false);
  });
  
  // Test isCheckmate
  it('should correctly determine if a king is in checkmate', () => {
    // Create an empty board
    board.clear();
    
    // Add kings
    const redKing = new Piece('k1', 'king', 0, 4, 'red');
    const blackKing = new Piece('K1', 'king', 9, 4, 'black');
    board.addPiece(redKing);
    board.addPiece(blackKing);
    
    // No checkmate initially
    expect(rules.isCheckmate('red')).toBe(false);
    expect(rules.isCheckmate('black')).toBe(false);
    
    // Add black rooks to put red king in checkmate
    const blackRook1 = new Piece('R1', 'rook', 0, 0, 'black');
    const blackRook2 = new Piece('R2', 'rook', 1, 4, 'black');
    board.addPiece(blackRook1);
    board.addPiece(blackRook2);
    
    // Red king should be in checkmate (can't move and can't block/capture)
    expect(rules.isCheckmate('red')).toBe(true);
    expect(rules.isCheckmate('black')).toBe(false);
  });
});
