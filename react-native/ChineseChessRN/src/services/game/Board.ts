/**
 * Board class for the Chinese Chess game
 * This class represents the game board and handles the game logic
 */
import {
  BOARD_ROWS,
  BOARD_COLS,
  PIECE_TYPES,
  PIECE_COLORS,
  getPieceColor,
  INITIAL_FEN
} from '../../constants';
import {
  isValidGeneralMove,
  isValidAdvisorMove,
  isValidElephantMove,
  isValidHorseMove,
  isValidChariotMove,
  isValidCannonMove,
  isValidPawnMove
} from './MoveValidation';

/**
 * Position type
 */
export type Position = {
  row: number;
  col: number;
};

/**
 * Move type
 */
export type Move = {
  from: Position;
  to: Position;
  piece: string;
  capturedPiece?: string;
};

/**
 * Board class
 */
class Board {
  // Board representation as a 2D array
  private board: string[][];

  // Current player
  private currentPlayer: 'red' | 'black';

  // Move history
  private history: Move[];

  /**
   * Constructor
   * @param fen FEN string to initialize the board
   */
  constructor(fen: string = INITIAL_FEN) {
    // Initialize the board as a 10x9 array of empty strings
    this.board = Array(BOARD_ROWS).fill(null).map(() => Array(BOARD_COLS).fill(PIECE_TYPES.EMPTY));

    // Initialize the current player
    this.currentPlayer = 'red';

    // Initialize the history
    this.history = [];

    // Load the board from the FEN string
    this.loadFromFen(fen);
  }

  /**
   * Load the board from a FEN string
   * @param fen FEN string
   */
  loadFromFen(fen: string): void {
    // Split the FEN string into board and player parts
    const [boardPart, playerPart] = fen.split(' ');

    // Split the board part into rows
    const rows = boardPart.split('/');

    // Parse the board part
    for (let row = 0; row < BOARD_ROWS; row++) {
      let col = 0;

      for (let i = 0; i < rows[row].length; i++) {
        const char = rows[row][i];

        if (/[0-9]/.test(char)) {
          // If it's a number, skip that many columns
          col += parseInt(char, 10);
        } else {
          // Otherwise, it's a piece
          this.board[row][col] = char;
          col++;
        }
      }
    }

    // Parse the player part
    this.currentPlayer = playerPart === 'b' ? 'black' : 'red';
  }

  /**
   * Convert the board to a FEN string
   * @returns FEN string
   */
  toFen(): string {
    let fen = '';

    // Convert the board to a FEN string
    for (let row = 0; row < BOARD_ROWS; row++) {
      let emptyCount = 0;

      for (let col = 0; col < BOARD_COLS; col++) {
        const piece = this.board[row][col];

        if (piece === PIECE_TYPES.EMPTY) {
          // If it's an empty square, increment the empty count
          emptyCount++;
        } else {
          // If it's a piece, add the empty count (if any) and the piece
          if (emptyCount > 0) {
            fen += emptyCount.toString();
            emptyCount = 0;
          }

          fen += piece;
        }
      }

      // Add any remaining empty count
      if (emptyCount > 0) {
        fen += emptyCount.toString();
      }

      // Add a slash between rows (except for the last row)
      if (row < BOARD_ROWS - 1) {
        fen += '/';
      }
    }

    // Add the current player
    fen += ' ' + (this.currentPlayer === 'black' ? 'b' : 'w');

    return fen;
  }

  /**
   * Get the piece at the specified position
   * @param row Row
   * @param col Column
   * @returns Piece type or null if out of bounds
   */
  getPieceAt(row: number, col: number): string | null {
    // Check if the position is valid
    if (row < 0 || row >= BOARD_ROWS || col < 0 || col >= BOARD_COLS) {
      return null;
    }

    return this.board[row][col];
  }

  /**
   * Get the current player
   * @returns Current player
   */
  getCurrentPlayer(): 'red' | 'black' {
    return this.currentPlayer;
  }

  /**
   * Get the move history
   * @returns Move history
   */
  getHistory(): Move[] {
    return [...this.history];
  }

  /**
   * Make a move
   * @param fromRow From row
   * @param fromCol From column
   * @param toRow To row
   * @param toCol To column
   * @returns True if the move was successful, false otherwise
   */
  makeMove(fromRow: number, fromCol: number, toRow: number, toCol: number): boolean {
    // Check if the move is valid
    if (!this.isValidMove(fromRow, fromCol, toRow, toCol)) {
      return false;
    }

    // Get the piece and captured piece
    const piece = this.board[fromRow][fromCol];
    const capturedPiece = this.board[toRow][toCol];

    // Make the move
    this.board[toRow][toCol] = piece;
    this.board[fromRow][fromCol] = PIECE_TYPES.EMPTY;

    // Add the move to the history
    this.history.push({
      from: { row: fromRow, col: fromCol },
      to: { row: toRow, col: toCol },
      piece,
      capturedPiece: capturedPiece !== PIECE_TYPES.EMPTY ? capturedPiece : undefined,
    });

    // Switch the current player
    this.currentPlayer = this.currentPlayer === 'red' ? 'black' : 'red';

    return true;
  }

  /**
   * Check if a move is valid
   * @param fromRow From row
   * @param fromCol From column
   * @param toRow To row
   * @param toCol To column
   * @returns True if the move is valid, false otherwise
   */
  isValidMove(fromRow: number, fromCol: number, toRow: number, toCol: number): boolean {
    // Check if the positions are valid
    if (
      fromRow < 0 || fromRow >= BOARD_ROWS || fromCol < 0 || fromCol >= BOARD_COLS ||
      toRow < 0 || toRow >= BOARD_ROWS || toCol < 0 || toCol >= BOARD_COLS
    ) {
      return false;
    }

    // Check if there's a piece at the from position
    const piece = this.board[fromRow][fromCol];
    if (piece === PIECE_TYPES.EMPTY) {
      return false;
    }

    // Check if the piece belongs to the current player
    const pieceColor = getPieceColor(piece);
    if (pieceColor !== this.currentPlayer) {
      return false;
    }

    // Check if the to position has a piece of the same color
    const toPiece = this.board[toRow][toCol];
    if (toPiece !== PIECE_TYPES.EMPTY && getPieceColor(toPiece) === pieceColor) {
      return false;
    }

    // Check if the move is valid for the specific piece type
    return this.isValidPieceMove(piece, fromRow, fromCol, toRow, toCol);
  }

  /**
   * Check if a move is valid for a specific piece type
   * @param piece Piece type
   * @param fromRow From row
   * @param fromCol From column
   * @param toRow To row
   * @param toCol To column
   * @returns True if the move is valid, false otherwise
   */
  isValidPieceMove(piece: string, fromRow: number, fromCol: number, toRow: number, toCol: number): boolean {
    // Check the piece type and delegate to the appropriate validation function
    const upperPiece = piece.toUpperCase();

    switch (upperPiece) {
      case PIECE_TYPES.RED_GENERAL:
        return isValidGeneralMove(piece, fromRow, fromCol, toRow, toCol, this.board);
      case PIECE_TYPES.RED_ADVISOR:
        return isValidAdvisorMove(piece, fromRow, fromCol, toRow, toCol, this.board);
      case PIECE_TYPES.RED_ELEPHANT:
        return isValidElephantMove(piece, fromRow, fromCol, toRow, toCol, this.board);
      case PIECE_TYPES.RED_HORSE:
        return isValidHorseMove(piece, fromRow, fromCol, toRow, toCol, this.board);
      case PIECE_TYPES.RED_CHARIOT:
        return isValidChariotMove(piece, fromRow, fromCol, toRow, toCol, this.board);
      case PIECE_TYPES.RED_CANNON:
        return isValidCannonMove(piece, fromRow, fromCol, toRow, toCol, this.board);
      case PIECE_TYPES.RED_PAWN:
        return isValidPawnMove(piece, fromRow, fromCol, toRow, toCol, this.board);
      default:
        return false;
    }
  }

  /**
   * Get all valid moves for a piece
   * @param row Row
   * @param col Column
   * @returns Array of valid move positions
   */
  getValidMoves(row: number, col: number): Position[] {
    // Check if the position is valid
    if (row < 0 || row >= BOARD_ROWS || col < 0 || col >= BOARD_COLS) {
      return [];
    }

    // Check if there's a piece at the position
    const piece = this.board[row][col];
    if (piece === PIECE_TYPES.EMPTY) {
      return [];
    }

    // Check if the piece belongs to the current player
    const pieceColor = getPieceColor(piece);
    if (pieceColor !== this.currentPlayer) {
      return [];
    }

    // Get all valid moves
    const validMoves: Position[] = [];

    // Check all possible positions
    for (let toRow = 0; toRow < BOARD_ROWS; toRow++) {
      for (let toCol = 0; toCol < BOARD_COLS; toCol++) {
        if (this.isValidMove(row, col, toRow, toCol)) {
          validMoves.push({ row: toRow, col: toCol });
        }
      }
    }

    return validMoves;
  }
}

export default Board;
