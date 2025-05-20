/**
 * Move validation functions for the Chinese Chess game
 */
import { PIECE_TYPES, BOARD_POSITIONS } from '../../constants';

/**
 * Check if a general move is valid
 * @param piece Piece type
 * @param fromRow From row
 * @param fromCol From column
 * @param toRow To row
 * @param toCol To column
 * @param board Board representation
 * @returns True if the move is valid, false otherwise
 */
export const isValidGeneralMove = (
  piece: string,
  fromRow: number,
  fromCol: number,
  toRow: number,
  toCol: number,
  board: string[][]
): boolean => {
  const isRed = piece === PIECE_TYPES.RED_GENERAL;
  
  // Check if the move is within the palace
  if (isRed) {
    // Red palace is at the bottom (rows 7-9, columns 3-5)
    if (toRow < 7 || toRow > 9 || toCol < 3 || toCol > 5) {
      return false;
    }
  } else {
    // Black palace is at the top (rows 0-2, columns 3-5)
    if (toRow < 0 || toRow > 2 || toCol < 3 || toCol > 5) {
      return false;
    }
  }
  
  // Check if the move is orthogonal and one step
  const rowDiff = Math.abs(toRow - fromRow);
  const colDiff = Math.abs(toCol - fromCol);
  
  if ((rowDiff === 1 && colDiff === 0) || (rowDiff === 0 && colDiff === 1)) {
    return true;
  }
  
  // Check for flying general (two generals facing each other in the same column with no pieces in between)
  if (colDiff === 0 && rowDiff > 1) {
    // Check if the destination has the opponent's general
    const destPiece = board[toRow][toCol];
    if ((isRed && destPiece === PIECE_TYPES.BLACK_GENERAL) || 
        (!isRed && destPiece === PIECE_TYPES.RED_GENERAL)) {
      
      // Check if there are pieces between the two generals
      const minRow = Math.min(fromRow, toRow);
      const maxRow = Math.max(fromRow, toRow);
      
      for (let row = minRow + 1; row < maxRow; row++) {
        if (board[row][fromCol] !== PIECE_TYPES.EMPTY) {
          return false;
        }
      }
      
      return true;
    }
  }
  
  return false;
};

/**
 * Check if an advisor move is valid
 * @param piece Piece type
 * @param fromRow From row
 * @param fromCol From column
 * @param toRow To row
 * @param toCol To column
 * @param board Board representation
 * @returns True if the move is valid, false otherwise
 */
export const isValidAdvisorMove = (
  piece: string,
  fromRow: number,
  fromCol: number,
  toRow: number,
  toCol: number,
  board: string[][]
): boolean => {
  const isRed = piece === PIECE_TYPES.RED_ADVISOR;
  
  // Check if the move is within the palace
  if (isRed) {
    // Red palace is at the bottom (rows 7-9, columns 3-5)
    if (toRow < 7 || toRow > 9 || toCol < 3 || toCol > 5) {
      return false;
    }
  } else {
    // Black palace is at the top (rows 0-2, columns 3-5)
    if (toRow < 0 || toRow > 2 || toCol < 3 || toCol > 5) {
      return false;
    }
  }
  
  // Check if the move is diagonal and one step
  const rowDiff = Math.abs(toRow - fromRow);
  const colDiff = Math.abs(toCol - fromCol);
  
  return rowDiff === 1 && colDiff === 1;
};

/**
 * Check if an elephant move is valid
 * @param piece Piece type
 * @param fromRow From row
 * @param fromCol From column
 * @param toRow To row
 * @param toCol To column
 * @param board Board representation
 * @returns True if the move is valid, false otherwise
 */
export const isValidElephantMove = (
  piece: string,
  fromRow: number,
  fromCol: number,
  toRow: number,
  toCol: number,
  board: string[][]
): boolean => {
  const isRed = piece === PIECE_TYPES.RED_ELEPHANT;
  
  // Check if the move is within the player's side of the river
  if (isRed) {
    // Red elephants can't cross the river (must stay in rows 5-9)
    if (toRow < 5) {
      return false;
    }
  } else {
    // Black elephants can't cross the river (must stay in rows 0-4)
    if (toRow > 4) {
      return false;
    }
  }
  
  // Check if the move is diagonal and two steps
  const rowDiff = Math.abs(toRow - fromRow);
  const colDiff = Math.abs(toCol - fromCol);
  
  if (rowDiff !== 2 || colDiff !== 2) {
    return false;
  }
  
  // Check if there's a piece at the elephant's eye (the intersection point)
  const eyeRow = (fromRow + toRow) / 2;
  const eyeCol = (fromCol + toCol) / 2;
  
  return board[eyeRow][eyeCol] === PIECE_TYPES.EMPTY;
};

/**
 * Check if a horse move is valid
 * @param piece Piece type
 * @param fromRow From row
 * @param fromCol From column
 * @param toRow To row
 * @param toCol To column
 * @param board Board representation
 * @returns True if the move is valid, false otherwise
 */
export const isValidHorseMove = (
  piece: string,
  fromRow: number,
  fromCol: number,
  toRow: number,
  toCol: number,
  board: string[][]
): boolean => {
  // Check if the move is an L-shape (2 steps in one direction, 1 step in the other)
  const rowDiff = Math.abs(toRow - fromRow);
  const colDiff = Math.abs(toCol - fromCol);
  
  if (!((rowDiff === 2 && colDiff === 1) || (rowDiff === 1 && colDiff === 2))) {
    return false;
  }
  
  // Check if the horse's leg is blocked
  if (rowDiff === 2) {
    // Moving vertically (2 steps) and horizontally (1 step)
    const legRow = fromRow + (toRow > fromRow ? 1 : -1);
    const legCol = fromCol;
    
    return board[legRow][legCol] === PIECE_TYPES.EMPTY;
  } else {
    // Moving horizontally (2 steps) and vertically (1 step)
    const legRow = fromRow;
    const legCol = fromCol + (toCol > fromCol ? 1 : -1);
    
    return board[legRow][legCol] === PIECE_TYPES.EMPTY;
  }
};

/**
 * Check if a chariot move is valid
 * @param piece Piece type
 * @param fromRow From row
 * @param fromCol From column
 * @param toRow To row
 * @param toCol To column
 * @param board Board representation
 * @returns True if the move is valid, false otherwise
 */
export const isValidChariotMove = (
  piece: string,
  fromRow: number,
  fromCol: number,
  toRow: number,
  toCol: number,
  board: string[][]
): boolean => {
  // Check if the move is orthogonal (either horizontal or vertical)
  const rowDiff = Math.abs(toRow - fromRow);
  const colDiff = Math.abs(toCol - fromCol);
  
  if (rowDiff > 0 && colDiff > 0) {
    return false;
  }
  
  // Check if there are pieces in the way
  if (rowDiff > 0) {
    // Moving vertically
    const minRow = Math.min(fromRow, toRow);
    const maxRow = Math.max(fromRow, toRow);
    
    for (let row = minRow + 1; row < maxRow; row++) {
      if (board[row][fromCol] !== PIECE_TYPES.EMPTY) {
        return false;
      }
    }
  } else {
    // Moving horizontally
    const minCol = Math.min(fromCol, toCol);
    const maxCol = Math.max(fromCol, toCol);
    
    for (let col = minCol + 1; col < maxCol; col++) {
      if (board[fromRow][col] !== PIECE_TYPES.EMPTY) {
        return false;
      }
    }
  }
  
  return true;
};

/**
 * Check if a cannon move is valid
 * @param piece Piece type
 * @param fromRow From row
 * @param fromCol From column
 * @param toRow To row
 * @param toCol To column
 * @param board Board representation
 * @returns True if the move is valid, false otherwise
 */
export const isValidCannonMove = (
  piece: string,
  fromRow: number,
  fromCol: number,
  toRow: number,
  toCol: number,
  board: string[][]
): boolean => {
  // Check if the move is orthogonal (either horizontal or vertical)
  const rowDiff = Math.abs(toRow - fromRow);
  const colDiff = Math.abs(toCol - fromCol);
  
  if (rowDiff > 0 && colDiff > 0) {
    return false;
  }
  
  // Count the number of pieces in the way
  let piecesInWay = 0;
  
  if (rowDiff > 0) {
    // Moving vertically
    const minRow = Math.min(fromRow, toRow);
    const maxRow = Math.max(fromRow, toRow);
    
    for (let row = minRow + 1; row < maxRow; row++) {
      if (board[row][fromCol] !== PIECE_TYPES.EMPTY) {
        piecesInWay++;
      }
    }
  } else {
    // Moving horizontally
    const minCol = Math.min(fromCol, toCol);
    const maxCol = Math.max(fromCol, toCol);
    
    for (let col = minCol + 1; col < maxCol; col++) {
      if (board[fromRow][col] !== PIECE_TYPES.EMPTY) {
        piecesInWay++;
      }
    }
  }
  
  // Check if the move is valid based on the number of pieces in the way
  if (board[toRow][toCol] === PIECE_TYPES.EMPTY) {
    // Moving to an empty square (no capture)
    return piecesInWay === 0;
  } else {
    // Capturing a piece
    return piecesInWay === 1;
  }
};

/**
 * Check if a pawn move is valid
 * @param piece Piece type
 * @param fromRow From row
 * @param fromCol From column
 * @param toRow To row
 * @param toCol To column
 * @param board Board representation
 * @returns True if the move is valid, false otherwise
 */
export const isValidPawnMove = (
  piece: string,
  fromRow: number,
  fromCol: number,
  toRow: number,
  toCol: number,
  board: string[][]
): boolean => {
  const isRed = piece === PIECE_TYPES.RED_PAWN;
  const rowDiff = toRow - fromRow;
  const colDiff = Math.abs(toCol - fromCol);
  
  // Check if the move is one step
  if (Math.abs(rowDiff) + colDiff !== 1) {
    return false;
  }
  
  // Check if the pawn is moving in the correct direction
  if (isRed) {
    // Red pawns move up (decreasing row)
    if (rowDiff > 0) {
      return false;
    }
    
    // Red pawns can only move horizontally after crossing the river
    if (colDiff > 0 && fromRow > 4) {
      return false;
    }
  } else {
    // Black pawns move down (increasing row)
    if (rowDiff < 0) {
      return false;
    }
    
    // Black pawns can only move horizontally after crossing the river
    if (colDiff > 0 && fromRow < 5) {
      return false;
    }
  }
  
  return true;
};
