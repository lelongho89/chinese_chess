/**
 * AI service for the Chinese Chess game
 * This service provides AI functionality for the game
 */
import Board, { Position, Move } from './Board';
import { ChessPiece } from '../../store/slices/gameSlice';
import { getPieceValue } from '../../constants';

/**
 * AI difficulty levels
 */
export enum AIDifficulty {
  EASY = 'easy',
  MEDIUM = 'medium',
  HARD = 'hard',
}

/**
 * AI service class
 */
class AIService {
  // Current difficulty level
  private difficulty: AIDifficulty = AIDifficulty.MEDIUM;
  
  // Thinking time in milliseconds
  private thinkingTime: number = 500;
  
  /**
   * Set the AI difficulty level
   * @param difficulty Difficulty level
   */
  setDifficulty(difficulty: AIDifficulty): void {
    this.difficulty = difficulty;
    
    // Set thinking time based on difficulty
    switch (difficulty) {
      case AIDifficulty.EASY:
        this.thinkingTime = 300;
        break;
      case AIDifficulty.MEDIUM:
        this.thinkingTime = 800;
        break;
      case AIDifficulty.HARD:
        this.thinkingTime = 1200;
        break;
    }
  }
  
  /**
   * Get the current difficulty level
   * @returns Current difficulty level
   */
  getDifficulty(): AIDifficulty {
    return this.difficulty;
  }
  
  /**
   * Get the thinking time
   * @returns Thinking time in milliseconds
   */
  getThinkingTime(): number {
    return this.thinkingTime;
  }
  
  /**
   * Calculate the best move for the AI
   * @param board Board instance
   * @param color AI color ('red' or 'black')
   * @returns Best move
   */
  calculateBestMove(board: Board, color: 'red' | 'black'): Promise<{ from: Position, to: Position }> {
    return new Promise((resolve) => {
      // Simulate thinking time
      setTimeout(() => {
        const move = this.findBestMove(board, color);
        resolve(move);
      }, this.thinkingTime);
    });
  }
  
  /**
   * Find the best move for the AI
   * @param board Board instance
   * @param color AI color ('red' or 'black')
   * @returns Best move
   */
  private findBestMove(board: Board, color: 'red' | 'black'): { from: Position, to: Position } {
    // Get all pieces of the current player
    const pieces = board.getPieces().filter(p => p.color === color);
    
    // Initialize best move and score
    let bestMove: { from: Position, to: Position } | null = null;
    let bestScore = -Infinity;
    
    // Evaluate each possible move
    for (const piece of pieces) {
      const { row, col } = piece.position;
      const validMoves = board.getValidMoves(row, col);
      
      for (const move of validMoves) {
        // Create a copy of the board
        const boardCopy = board.copy();
        
        // Make the move
        boardCopy.makeMove(row, col, move.row, move.col);
        
        // Evaluate the position
        const score = this.evaluatePosition(boardCopy, color, this.getDifficultyDepth());
        
        // Update best move if this move is better
        if (score > bestScore) {
          bestScore = score;
          bestMove = {
            from: { row, col },
            to: { row: move.row, col: move.col },
          };
        }
      }
    }
    
    // If no best move found, return a random move
    if (!bestMove) {
      return this.findRandomMove(board, color);
    }
    
    return bestMove;
  }
  
  /**
   * Find a random move for the AI
   * @param board Board instance
   * @param color AI color ('red' or 'black')
   * @returns Random move
   */
  private findRandomMove(board: Board, color: 'red' | 'black'): { from: Position, to: Position } {
    // Get all pieces of the current player
    const pieces = board.getPieces().filter(p => p.color === color);
    
    // Shuffle the pieces to add randomness
    const shuffledPieces = this.shuffleArray([...pieces]);
    
    // Find a piece with valid moves
    for (const piece of shuffledPieces) {
      const { row, col } = piece.position;
      const validMoves = board.getValidMoves(row, col);
      
      if (validMoves.length > 0) {
        // Pick a random move
        const randomMove = validMoves[Math.floor(Math.random() * validMoves.length)];
        
        return {
          from: { row, col },
          to: { row: randomMove.row, col: randomMove.col },
        };
      }
    }
    
    // If no valid moves found, return a dummy move (should never happen)
    return {
      from: { row: 0, col: 0 },
      to: { row: 0, col: 0 },
    };
  }
  
  /**
   * Evaluate a position
   * @param board Board instance
   * @param color Color to evaluate for ('red' or 'black')
   * @param depth Search depth
   * @returns Position score
   */
  private evaluatePosition(board: Board, color: 'red' | 'black', depth: number): number {
    // Base case: if depth is 0, evaluate the position
    if (depth === 0) {
      return this.evaluateBoard(board, color);
    }
    
    // Get all pieces of the current player
    const pieces = board.getPieces().filter(p => p.color === color);
    
    // If no pieces, return a very low score
    if (pieces.length === 0) {
      return -10000;
    }
    
    // Initialize best score
    let bestScore = -Infinity;
    
    // Evaluate each possible move
    for (const piece of pieces) {
      const { row, col } = piece.position;
      const validMoves = board.getValidMoves(row, col);
      
      for (const move of validMoves) {
        // Create a copy of the board
        const boardCopy = board.copy();
        
        // Make the move
        boardCopy.makeMove(row, col, move.row, move.col);
        
        // Recursively evaluate the position
        const score = -this.evaluatePosition(
          boardCopy,
          color === 'red' ? 'black' : 'red',
          depth - 1
        );
        
        // Update best score
        bestScore = Math.max(bestScore, score);
      }
    }
    
    return bestScore;
  }
  
  /**
   * Evaluate a board position
   * @param board Board instance
   * @param color Color to evaluate for ('red' or 'black')
   * @returns Board score
   */
  private evaluateBoard(board: Board, color: 'red' | 'black'): number {
    const pieces = board.getPieces();
    let score = 0;
    
    // Calculate material score
    for (const piece of pieces) {
      const pieceValue = getPieceValue(piece.type);
      
      if (piece.color === color) {
        score += pieceValue;
      } else {
        score -= pieceValue;
      }
    }
    
    return score;
  }
  
  /**
   * Get the search depth based on difficulty
   * @returns Search depth
   */
  private getDifficultyDepth(): number {
    switch (this.difficulty) {
      case AIDifficulty.EASY:
        return 1;
      case AIDifficulty.MEDIUM:
        return 2;
      case AIDifficulty.HARD:
        return 3;
      default:
        return 2;
    }
  }
  
  /**
   * Shuffle an array
   * @param array Array to shuffle
   * @returns Shuffled array
   */
  private shuffleArray<T>(array: T[]): T[] {
    for (let i = array.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [array[i], array[j]] = [array[j], array[i]];
    }
    return array;
  }
}

// Export a singleton instance
export default new AIService();
