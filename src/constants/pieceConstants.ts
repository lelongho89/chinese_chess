/**
 * Constants for the Chinese Chess pieces
 */

// Piece types
export const PIECE_TYPES = {
  // Red pieces (uppercase)
  RED_GENERAL: 'K',
  RED_ADVISOR: 'A',
  RED_ELEPHANT: 'B',
  RED_HORSE: 'N',
  RED_CHARIOT: 'R',
  RED_CANNON: 'C',
  RED_PAWN: 'P',

  // Black pieces (lowercase)
  BLACK_GENERAL: 'k',
  BLACK_ADVISOR: 'a',
  BLACK_ELEPHANT: 'b',
  BLACK_HORSE: 'n',
  BLACK_CHARIOT: 'r',
  BLACK_CANNON: 'c',
  BLACK_PAWN: 'p',

  // Empty
  EMPTY: '0',
};

// Piece colors
export const PIECE_COLORS = {
  RED: 'red',
  BLACK: 'black',
};

// Get piece color from piece type
export const getPieceColor = (pieceType: string) => {
  if (!pieceType || pieceType === PIECE_TYPES.EMPTY) return null;
  return pieceType.toUpperCase() === pieceType ? PIECE_COLORS.RED : PIECE_COLORS.BLACK;
};

// Get piece name from piece type
export const getPieceName = (pieceType: string) => {
  switch (pieceType.toUpperCase()) {
    case PIECE_TYPES.RED_GENERAL:
      return 'General';
    case PIECE_TYPES.RED_ADVISOR:
      return 'Advisor';
    case PIECE_TYPES.RED_ELEPHANT:
      return 'Elephant';
    case PIECE_TYPES.RED_HORSE:
      return 'Horse';
    case PIECE_TYPES.RED_CHARIOT:
      return 'Chariot';
    case PIECE_TYPES.RED_CANNON:
      return 'Cannon';
    case PIECE_TYPES.RED_PAWN:
      return 'Pawn';
    default:
      return '';
  }
};

// Piece values for AI evaluation
export const PIECE_VALUES = {
  // Red pieces
  [PIECE_TYPES.RED_GENERAL]: 10000,
  [PIECE_TYPES.RED_ADVISOR]: 200,
  [PIECE_TYPES.RED_ELEPHANT]: 200,
  [PIECE_TYPES.RED_HORSE]: 400,
  [PIECE_TYPES.RED_CHARIOT]: 900,
  [PIECE_TYPES.RED_CANNON]: 450,
  [PIECE_TYPES.RED_PAWN]: 100,

  // Black pieces
  [PIECE_TYPES.BLACK_GENERAL]: 10000,
  [PIECE_TYPES.BLACK_ADVISOR]: 200,
  [PIECE_TYPES.BLACK_ELEPHANT]: 200,
  [PIECE_TYPES.BLACK_HORSE]: 400,
  [PIECE_TYPES.BLACK_CHARIOT]: 900,
  [PIECE_TYPES.BLACK_CANNON]: 450,
  [PIECE_TYPES.BLACK_PAWN]: 100,
};

// Get piece value for AI evaluation
export const getPieceValue = (pieceType: string): number => {
  return PIECE_VALUES[pieceType] || 0;
};

// Initial board setup in FEN notation
export const INITIAL_FEN = 'rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w';

// Parse FEN string to get piece positions
export const parseFen = (fen: string) => {
  const [boardPart] = fen.split(' ');
  const rows = boardPart.split('/');

  const pieces: { type: string; position: { row: number; col: number } }[] = [];

  for (let row = 0; row < rows.length; row++) {
    let col = 0;

    for (let i = 0; i < rows[row].length; i++) {
      const char = rows[row][i];

      if (/[0-9]/.test(char)) {
        // If it's a number, skip that many columns
        col += parseInt(char, 10);
      } else {
        // Otherwise, it's a piece
        pieces.push({
          type: char,
          position: { row, col },
        });
        col++;
      }
    }
  }

  return pieces;
};
