import { Piece } from '../Piece';

describe('Piece', () => {
  // Test piece creation
  it('should create a piece with the correct properties', () => {
    const piece = new Piece('r1', 'rook', 0, 0, 'red');
    
    expect(piece.id).toBe('r1');
    expect(piece.type).toBe('rook');
    expect(piece.position.row).toBe(0);
    expect(piece.position.col).toBe(0);
    expect(piece.color).toBe('red');
  });
  
  // Test piece movement
  it('should update position when moved', () => {
    const piece = new Piece('r1', 'rook', 0, 0, 'red');
    
    piece.move(1, 1);
    
    expect(piece.position.row).toBe(1);
    expect(piece.position.col).toBe(1);
  });
  
  // Test piece serialization
  it('should serialize to the correct object', () => {
    const piece = new Piece('r1', 'rook', 0, 0, 'red');
    const serialized = piece.serialize();
    
    expect(serialized).toEqual({
      id: 'r1',
      type: 'rook',
      position: { row: 0, col: 0 },
      color: 'red',
    });
  });
  
  // Test piece deserialization
  it('should deserialize from an object correctly', () => {
    const serialized = {
      id: 'r1',
      type: 'rook',
      position: { row: 0, col: 0 },
      color: 'red',
    };
    
    const piece = Piece.fromObject(serialized);
    
    expect(piece.id).toBe('r1');
    expect(piece.type).toBe('rook');
    expect(piece.position.row).toBe(0);
    expect(piece.position.col).toBe(0);
    expect(piece.color).toBe('red');
  });
  
  // Test piece equality
  it('should correctly determine if two pieces are equal', () => {
    const piece1 = new Piece('r1', 'rook', 0, 0, 'red');
    const piece2 = new Piece('r1', 'rook', 0, 0, 'red');
    const piece3 = new Piece('r2', 'rook', 0, 0, 'red');
    
    expect(piece1.equals(piece2)).toBe(true);
    expect(piece1.equals(piece3)).toBe(false);
  });
  
  // Test piece type checking
  it('should correctly identify piece types', () => {
    const rook = new Piece('r1', 'rook', 0, 0, 'red');
    const knight = new Piece('n1', 'knight', 0, 1, 'red');
    const bishop = new Piece('b1', 'bishop', 0, 2, 'red');
    const advisor = new Piece('a1', 'advisor', 0, 3, 'red');
    const king = new Piece('k1', 'king', 0, 4, 'red');
    const cannon = new Piece('c1', 'cannon', 2, 1, 'red');
    const pawn = new Piece('p1', 'pawn', 3, 0, 'red');
    
    expect(rook.isRook()).toBe(true);
    expect(rook.isKnight()).toBe(false);
    
    expect(knight.isKnight()).toBe(true);
    expect(knight.isBishop()).toBe(false);
    
    expect(bishop.isBishop()).toBe(true);
    expect(bishop.isAdvisor()).toBe(false);
    
    expect(advisor.isAdvisor()).toBe(true);
    expect(advisor.isKing()).toBe(false);
    
    expect(king.isKing()).toBe(true);
    expect(king.isCannon()).toBe(false);
    
    expect(cannon.isCannon()).toBe(true);
    expect(cannon.isPawn()).toBe(false);
    
    expect(pawn.isPawn()).toBe(true);
    expect(pawn.isRook()).toBe(false);
  });
  
  // Test piece color checking
  it('should correctly identify piece colors', () => {
    const redPiece = new Piece('r1', 'rook', 0, 0, 'red');
    const blackPiece = new Piece('R1', 'rook', 9, 0, 'black');
    
    expect(redPiece.isRed()).toBe(true);
    expect(redPiece.isBlack()).toBe(false);
    
    expect(blackPiece.isRed()).toBe(false);
    expect(blackPiece.isBlack()).toBe(true);
  });
  
  // Test piece clone
  it('should create a correct clone of the piece', () => {
    const original = new Piece('r1', 'rook', 0, 0, 'red');
    const clone = original.clone();
    
    // Check that the clone has the same properties
    expect(clone.id).toBe(original.id);
    expect(clone.type).toBe(original.type);
    expect(clone.position.row).toBe(original.position.row);
    expect(clone.position.col).toBe(original.position.col);
    expect(clone.color).toBe(original.color);
    
    // Check that modifying the clone doesn't affect the original
    clone.move(1, 1);
    expect(original.position.row).toBe(0);
    expect(original.position.col).toBe(0);
    expect(clone.position.row).toBe(1);
    expect(clone.position.col).toBe(1);
  });
});
