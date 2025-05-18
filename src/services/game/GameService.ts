/**
 * Game service for the Chinese Chess game
 * This service manages the game state and provides methods to interact with the game
 */
import Board, { Position, Move } from './Board';
import { INITIAL_FEN, parseFen, getPieceColor } from '../../constants';
import { ChessPiece } from '../../store/slices/gameSlice';
import AIService, { AIDifficulty } from './AIService';

/**
 * Game event types
 */
export type GameEvent =
  | 'gameInit'
  | 'moveMade'
  | 'gameEnd'
  | 'boardUpdated'
  | 'aiThinking';

/**
 * Game event listener type
 */
export type GameEventListener = (event: GameEvent, data: any) => void;

/**
 * Game mode type
 */
export type GameMode = 'ai' | 'online' | 'free';

/**
 * Game service class
 */
class GameService {
  // Board instance
  private board: Board;

  // Game mode
  private gameMode: GameMode | null = null;

  // Game active flag
  private isGameActive: boolean = false;

  // Event listeners
  private listeners: GameEventListener[] = [];

  // Move history
  private history: Move[] = [];

  /**
   * Constructor
   */
  constructor() {
    this.board = new Board();
  }

  /**
   * Initialize a new game
   * @param gameMode Game mode
   * @param fen FEN string (optional)
   */
  initGame(gameMode: GameMode, fen?: string): void {
    this.gameMode = gameMode;
    this.board = new Board(fen || INITIAL_FEN);
    this.history = [];
    this.isGameActive = true;

    // Notify listeners
    this.notifyListeners('gameInit', {
      gameMode,
      board: this.getBoardState(),
      currentPlayer: this.board.getCurrentPlayer(),
    });
  }

  /**
   * Get the current board state
   * @returns Array of chess pieces
   */
  getBoardState(): ChessPiece[] {
    const pieces: ChessPiece[] = [];

    // Parse the FEN string to get the pieces
    const fenPieces = parseFen(this.board.toFen());

    // Convert to ChessPiece objects
    fenPieces.forEach((piece, index) => {
      pieces.push({
        id: `piece-${index}`,
        type: piece.type,
        position: piece.position,
        color: getPieceColor(piece.type) || 'red',
      });
    });

    return pieces;
  }

  /**
   * Get valid moves for a piece
   * @param row Row
   * @param col Column
   * @returns Array of valid move positions
   */
  getValidMoves(row: number, col: number): Position[] {
    return this.board.getValidMoves(row, col);
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
    // Check if the game is active
    if (!this.isGameActive) {
      return false;
    }

    // Make the move
    const success = this.board.makeMove(fromRow, fromCol, toRow, toCol);

    if (success) {
      // Get the move history
      this.history = this.board.getHistory();

      // Check for game end conditions
      const previousPlayer = this.board.getCurrentPlayer() === 'red' ? 'black' : 'red';

      // Notify listeners
      this.notifyListeners('moveMade', {
        board: this.getBoardState(),
        currentPlayer: this.board.getCurrentPlayer(),
        lastMove: this.history[this.history.length - 1],
      });

      // Make AI move if playing against AI and it's AI's turn
      if (this.gameMode === 'ai' && this.board.getCurrentPlayer() === 'black') {
        // Use setTimeout to avoid blocking the UI
        setTimeout(() => {
          this.makeAIMove();
        }, 100);
      }
    }

    return success;
  }

  /**
   * Make an AI move
   * Uses the AI service to calculate the best move
   */
  async makeAIMove(): Promise<void> {
    // Notify listeners that AI is thinking
    this.notifyListeners('aiThinking', {
      thinking: true,
      difficulty: AIService.getDifficulty(),
    });

    try {
      // Calculate the best move
      const bestMove = await AIService.calculateBestMove(
        this.board,
        this.board.getCurrentPlayer()
      );

      // Make the move
      this.makeMove(
        bestMove.from.row,
        bestMove.from.col,
        bestMove.to.row,
        bestMove.to.col
      );

      // Notify listeners that AI is done thinking
      this.notifyListeners('aiThinking', {
        thinking: false,
      });
    } catch (error) {
      console.error('Error making AI move:', error);

      // Notify listeners that AI is done thinking
      this.notifyListeners('aiThinking', {
        thinking: false,
      });
    }
  }

  /**
   * Set the AI difficulty level
   * @param difficulty Difficulty level
   */
  setAIDifficulty(difficulty: AIDifficulty): void {
    AIService.setDifficulty(difficulty);
  }

  /**
   * Get the current AI difficulty level
   * @returns Current difficulty level
   */
  getAIDifficulty(): AIDifficulty {
    return AIService.getDifficulty();
  }

  /**
   * End the game
   * @param winner Winner ('red' or 'black')
   */
  endGame(winner: 'red' | 'black'): void {
    this.isGameActive = false;

    // Notify listeners
    this.notifyListeners('gameEnd', {
      winner,
      history: this.history,
    });
  }

  /**
   * Get the current FEN string
   * @returns FEN string
   */
  getFen(): string {
    return this.board.toFen();
  }

  /**
   * Load a game from a FEN string
   * @param fen FEN string
   */
  loadFromFen(fen: string): void {
    this.board = new Board(fen);
    this.history = [];

    // Notify listeners
    this.notifyListeners('boardUpdated', {
      board: this.getBoardState(),
      currentPlayer: this.board.getCurrentPlayer(),
    });
  }

  /**
   * Add an event listener
   * @param listener Event listener
   * @returns Function to remove the listener
   */
  addListener(listener: GameEventListener): () => void {
    this.listeners.push(listener);

    // Return a function to remove the listener
    return () => {
      this.listeners = this.listeners.filter(l => l !== listener);
    };
  }

  /**
   * Notify all listeners of an event
   * @param event Event type
   * @param data Event data
   */
  private notifyListeners(event: GameEvent, data: any): void {
    this.listeners.forEach(listener => {
      listener(event, data);
    });
  }
}

// Export a singleton instance
export default new GameService();
